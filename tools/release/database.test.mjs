import assert from 'node:assert/strict';
import { readFile, readdir } from 'node:fs/promises';
import { test } from 'node:test';
import { PGlite } from '@electric-sql/pglite';

const root = new URL('../../', import.meta.url);
const sql = (path) => readFile(new URL(path, root), 'utf8');

// Real in-memory PostgreSQL exercises SQL, constraints and RLS. These minimal
// Supabase platform fixtures do not emulate Auth/Storage HTTP or concurrent sessions.
async function database() {
  const db = new PGlite();
  await db.exec(`
    CREATE ROLE anon;
    CREATE ROLE authenticated;
    CREATE ROLE service_role BYPASSRLS;
    CREATE SCHEMA auth;
    CREATE TABLE auth.users (id uuid PRIMARY KEY, raw_user_meta_data jsonb DEFAULT '{}');
    CREATE FUNCTION auth.uid() RETURNS uuid LANGUAGE sql STABLE AS
      $$ SELECT nullif(current_setting('request.jwt.claim.sub', true), '')::uuid $$;
    CREATE FUNCTION auth.role() RETURNS text LANGUAGE sql STABLE AS
      $$ SELECT current_user::text $$;
    GRANT USAGE ON SCHEMA public, auth TO anon, authenticated, service_role;
    GRANT SELECT ON auth.users TO service_role;
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO anon, authenticated, service_role;
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO anon, authenticated, service_role;
    CREATE SCHEMA storage;
    CREATE TABLE storage.objects (id uuid DEFAULT gen_random_uuid(), bucket_id text, name text, owner_id text);
    CREATE PUBLICATION supabase_realtime;
  `);
  try {
    // pg_net is a Supabase platform extension unavailable in PGlite. Its SQL
    // functions remain unchanged; no notification HTTP calls run in this harness.
    const schema = await sql('supabase/schema.sql');
    assert.equal((schema.match(/CREATE EXTENSION IF NOT EXISTS pg_net;/g) ?? []).length, 1);
    await db.exec(schema.replace('CREATE EXTENSION IF NOT EXISTS pg_net;', ''));
    const migrations = await readdir(new URL('supabase/migrations/', root));
    for (const name of migrations.filter((name) => /release_security_guards\.sql$/.test(name)).sort()) {
      await db.exec(await sql(`supabase/migrations/${name}`));
    }
    return db;
  } catch (error) {
    await db.close();
    throw error;
  }
}

test('canonical schema and release guards install (pg_net supplied by Supabase in production)', async () => {
  const db = await database();
  try {
    const { rows } = await db.query("SELECT to_regclass('public.orders') AS table_name");
    assert.equal(rows[0].table_name, 'orders');
  } finally {
    await db.close();
  }
});

export { database };

const customer = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
const other = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb';
const admin = 'cccccccc-cccc-cccc-cccc-cccccccccccc';
const product = '11111111-1111-1111-1111-111111111111';
const option = '22222222-2222-2222-2222-222222222222';
const address = '33333333-3333-3333-3333-333333333333';
const zone = '44444444-4444-4444-4444-444444444444';
const payload = (overrides = {}) => ({
  request_id: 'test-request', order_type: 'pickup', payment_method: 'cash',
  items: [{ product_id: product, quantity: 1, selected_option_ids: [] }], ...overrides,
});

async function asCustomer(db, id = customer) {
  await db.query("SELECT set_config('request.jwt.claim.sub', $1, true)", [id]);
  await db.exec('SET LOCAL ROLE authenticated');
}

async function place(db, data = payload()) {
  const { rows } = await db.query('SELECT public.create_authoritative_order($1::jsonb) AS id', [JSON.stringify(data)]);
  return rows[0].id;
}

test('release security regression matrix', async (t) => {
  const db = await database();
  async function check(name, run) {
    await t.test(name, async () => {
      await db.exec('BEGIN');
      try {
        await db.exec(`
          INSERT INTO auth.users (id) VALUES ('${customer}'), ('${other}'), ('${admin}');
          UPDATE profiles SET name = 'Test customer', phone = '01000000000';
          UPDATE profiles SET role = 'admin' WHERE id = '${admin}';
          INSERT INTO products (id, name, name_ar, price) VALUES ('${product}', 'Meal', 'وجبة', 100);
          INSERT INTO product_options (id, product_id, name, price_delta) VALUES ('${option}', '${product}', 'Discount option', -10);
          INSERT INTO delivery_zones (id, name, fee, min_order) VALUES ('${zone}', 'Zone', 20, 50);
          INSERT INTO addresses (id, user_id, label, address, delivery_fee, delivery_zone_id)
            VALUES ('${address}', '${customer}', 'Home', 'Test address', -500, '${zone}');
        `);
        await run(db);
      } finally {
        await db.exec('ROLLBACK; RESET ROLE');
      }
    });
  }
  try {
    await check('anonymous catalog is readable; profiles remain private', async (db) => {
      await db.exec('SET LOCAL ROLE anon');
      assert.equal((await db.query('SELECT * FROM products')).rows.length, 1);
      assert.equal((await db.query('SELECT * FROM profiles')).rows.length, 0);
    });
    await check('customer cannot directly insert a forged paid order', async (db) => {
      await asCustomer(db);
      await assert.rejects(db.exec(`INSERT INTO orders (customer_id, customer_name, customer_phone, payment_method, total_amount, payment_status)
        VALUES ('${customer}', 'Forged', '0', 'cash', 0, 'paid')`), /permission denied|row-level security/);
    });
    await check('customer cannot change another profile or elevate own role', async (db) => {
      await asCustomer(db);
      assert.equal((await db.query(`UPDATE profiles SET name = 'Hacked' WHERE id = '${other}' RETURNING id`)).rows.length, 0);
      await assert.rejects(db.exec("UPDATE profiles SET role = 'admin'"), /permission denied|row-level security/);
    });
    await check('server charges catalog prices and the zone fee, never the address fee', async (db) => {
      await asCustomer(db);
      const id = await place(db, payload({ order_type: 'delivery', address_id: address, total_amount: 0, customer_id: other, status: 'delivered' }));
      const row = (await db.query('SELECT * FROM orders WHERE id = $1', [id])).rows[0];
      assert.equal(Number(row.total_amount), 120);
      assert.equal(row.customer_id, customer);
      assert.equal(row.status, 'pending');
    });
    await check('delivery with no active zone cannot use a customer-controlled fee', async (db) => {
      await db.exec(`UPDATE addresses SET delivery_zone_id = NULL WHERE id = '${address}'`);
      await asCustomer(db);
      await assert.rejects(place(db, payload({ order_type: 'delivery', address_id: address })), /zone|منطقة/);
    });
    await check('repeated discount options cannot reduce the price multiple times', async (db) => {
      await asCustomer(db);
      await assert.rejects(place(db, payload({ items: [{ product_id: product, quantity: 1, selected_option_ids: [option, option] }] })), /duplicate|مكرر/i);
    });
    await check('required product options must be selected on the server', async (db) => {
      await db.exec(`UPDATE product_options SET is_required = true WHERE id = '${option}'`);
      await asCustomer(db);
      await assert.rejects(place(db), /required|إلزامي/);
    });
    await check('retry returns one order and changed payload cannot reuse its key', async (db) => {
      await asCustomer(db);
      const id = await place(db);
      assert.equal(await place(db), id);
      assert.equal((await db.query('SELECT * FROM orders')).rows.length, 1);
      await assert.rejects(place(db, payload({ notes: 'Changed order' })), /request|إرسال/);
    });
    await check('customer cannot insert another item into an already-priced order', async (db) => {
      await asCustomer(db);
      const id = await place(db);
      await assert.rejects(db.query(`INSERT INTO order_items (order_id, product_id, product_name, product_price, quantity, subtotal)
        VALUES ($1, $2, 'Free', 0, 100, 0)`, [id, product]), /permission denied|row-level security/);
    });
    await check('admin can confirm payment and mark an order ready', async (db) => {
      await asCustomer(db);
      const id = await place(db);
      await asCustomer(db, admin);
      await db.query("UPDATE orders SET payment_status = 'confirmed', status = 'ready' WHERE id = $1", [id]);
      const row = (await db.query('SELECT * FROM orders WHERE id = $1', [id])).rows[0];
      assert.equal(row.payment_status, 'confirmed');
      assert.equal(row.status, 'ready');
    });
    await check('deletion strips order identity and other customers remain untouched', async (db) => {
      await asCustomer(db);
      const id = await place(db);
      await db.exec('RESET ROLE');
      await db.query('SELECT delete_user_account_data($1)', [customer]);
      const row = (await db.query('SELECT * FROM orders WHERE id = $1', [id])).rows[0];
      assert.equal(row.customer_id, null);
      assert.equal(row.customer_phone, 'محذوف');
      assert.equal((await db.query('SELECT * FROM profiles WHERE id = $1', [other])).rows.length, 1);
    });
  } finally {
    await db.close();
  }
});
