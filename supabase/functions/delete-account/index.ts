import { createClient } from '@supabase/supabase-js';
import { handleDeleteAccount } from './handler.ts';

Deno.serve((req: Request) => {
  const url = Deno.env.get('SUPABASE_URL');
  const key = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
  if (!url || !key) {
    return new Response(JSON.stringify({ error: 'Server configuration missing' }), {
      status: 503,
      headers: { 'Content-Type': 'application/json', 'Cache-Control': 'no-store' },
    });
  }
  const admin = createClient(url, key, { auth: { persistSession: false, autoRefreshToken: false } });
  return handleDeleteAccount(req, {
    async getUser(token) {
      const { data, error } = await admin.auth.getUser(token);
      return { data: data.user, error };
    },
    async listObjects(userId) {
      return await admin.rpc('list_account_storage_objects', { p_user_id: userId });
    },
    async removeObjects(bucket, names) {
      return await admin.storage.from(bucket).remove(names);
    },
    async deleteData(userId) {
      return await admin.rpc('delete_user_account_data', { p_user_id: userId });
    },
    async deleteUser(userId) {
      return await admin.auth.admin.deleteUser(userId);
    },
  });
});
