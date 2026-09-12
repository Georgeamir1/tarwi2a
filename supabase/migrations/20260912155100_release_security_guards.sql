-- Forward-only corrections to the September release candidate.
-- Apply after the 20260908 migrations; run tools/release tests before deployment.
BEGIN;

-- Public catalog policies call this boolean helper. Anonymous callers must be
-- able to evaluate it; it returns false without an authenticated admin profile.
GRANT EXECUTE ON FUNCTION public.is_admin() TO anon;
REVOKE UPDATE ON public.profiles FROM PUBLIC, anon, authenticated;
GRANT UPDATE (name, phone) ON public.profiles TO authenticated;

-- Restrictive policies remain effective even if an older permissive policy is
-- still present on a deployed project. Orders/items can only be created by RPC.
DROP POLICY IF EXISTS release_orders_insert_guard ON public.orders;
CREATE POLICY release_orders_insert_guard ON public.orders AS RESTRICTIVE
  FOR INSERT TO anon, authenticated WITH CHECK (false);
DROP POLICY IF EXISTS release_items_insert_guard ON public.order_items;
CREATE POLICY release_items_insert_guard ON public.order_items AS RESTRICTIVE
  FOR INSERT TO anon, authenticated WITH CHECK (false);
DROP POLICY IF EXISTS release_items_update_guard ON public.order_items;
CREATE POLICY release_items_update_guard ON public.order_items AS RESTRICTIVE
  FOR UPDATE TO anon, authenticated USING (false) WITH CHECK (false);
DROP POLICY IF EXISTS release_items_delete_guard ON public.order_items;
CREATE POLICY release_items_delete_guard ON public.order_items AS RESTRICTIVE
  FOR DELETE TO anon, authenticated USING (false);
DROP POLICY IF EXISTS release_orders_update_guard ON public.orders;
CREATE POLICY release_orders_update_guard ON public.orders AS RESTRICTIVE
  FOR UPDATE TO anon, authenticated USING (public.is_admin()) WITH CHECK (public.is_admin());

-- Preserve legacy paid values while accepting the application's confirmed value.
ALTER TABLE public.orders DROP CONSTRAINT IF EXISTS orders_payment_status_check;
ALTER TABLE public.orders ADD CONSTRAINT orders_payment_status_check
  CHECK (payment_status IN ('pending', 'paid', 'confirmed'));
ALTER TABLE public.notifications DROP CONSTRAINT IF EXISTS notifications_type_check;
ALTER TABLE public.notifications ADD CONSTRAINT notifications_type_check CHECK (type IN (
  'order_confirmed', 'order_preparing', 'order_ready', 'order_out_for_delivery',
  'order_delivered', 'order_cancelled', 'new_order_admin', 'order_cancelled_admin',
  'promotion', 'system'
));

ALTER TABLE public.orders ADD COLUMN IF NOT EXISTS request_payload_hash TEXT;
CREATE SCHEMA IF NOT EXISTS private;
REVOKE ALL ON SCHEMA private FROM PUBLIC, anon, authenticated;

-- Keep the catalog-pricing implementation private. The public wrapper adds
-- validation and serializes equal request IDs before the original lookup.
DO $$ BEGIN
  IF to_regprocedure('private.create_authoritative_order(jsonb)') IS NULL THEN
    ALTER FUNCTION public.create_authoritative_order(JSONB) SET SCHEMA private;
  END IF;
END $$;
REVOKE ALL ON FUNCTION private.create_authoritative_order(JSONB) FROM PUBLIC, anon, authenticated;

CREATE OR REPLACE FUNCTION public.create_authoritative_order(p_payload JSONB)
RETURNS UUID LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp AS $$
DECLARE
  v_user UUID := auth.uid();
  v_key TEXT := trim(p_payload->>'request_id');
  v_hash TEXT := md5(p_payload::text);
  v_existing RECORD;
  v_item JSONB;
  v_options JSONB;
  v_product UUID;
  v_order UUID;
  v_zone_min NUMERIC := 0;
  v_subtotal NUMERIC;
BEGIN
  IF v_user IS NULL OR NOT EXISTS (SELECT 1 FROM profiles WHERE id = v_user) THEN
    RAISE EXCEPTION 'Unauthorized: active account required' USING ERRCODE = '42501';
  END IF;
  IF jsonb_typeof(p_payload) IS DISTINCT FROM 'object' OR v_key IS NULL OR length(v_key) NOT BETWEEN 1 AND 128 THEN
    RAISE EXCEPTION 'Invalid request_id';
  END IF;
  PERFORM pg_advisory_xact_lock(hashtextextended(v_user::text || ':' || v_key, 0));
  SELECT id, request_payload_hash INTO v_existing FROM orders
    WHERE customer_id = v_user AND request_id = v_key;
  IF FOUND THEN
    IF v_existing.request_payload_hash IS DISTINCT FROM v_hash THEN
      RAISE EXCEPTION 'Changed request: use a new request_id for a different order';
    END IF;
    RETURN v_existing.id;
  END IF;

  IF jsonb_typeof(p_payload->'items') IS DISTINCT FROM 'array'
      OR jsonb_array_length(p_payload->'items') NOT BETWEEN 1 AND 100 THEN
    RAISE EXCEPTION 'Invalid order items';
  END IF;
  IF COALESCE(p_payload->>'order_type', 'delivery') = 'delivery' THEN
    SELECT z.min_order INTO v_zone_min FROM addresses a
      JOIN delivery_zones z ON z.id = a.delivery_zone_id
      WHERE a.id = (p_payload->>'address_id')::uuid AND a.user_id = v_user AND z.is_active IS TRUE;
    IF NOT FOUND THEN RAISE EXCEPTION 'A valid active delivery zone is required'; END IF;
  END IF;
  IF p_payload->>'scheduled_for' IS NOT NULL AND (p_payload->>'scheduled_for')::timestamptz <= now() THEN
    RAISE EXCEPTION 'Scheduled time must be in the future';
  END IF;
  IF nullif(p_payload->>'coupon_id', '') IS NOT NULL AND nullif(p_payload->>'coupon_code', '') IS NOT NULL
      AND NOT EXISTS (SELECT 1 FROM coupons WHERE id = (p_payload->>'coupon_id')::uuid
        AND upper(code) = upper(trim(p_payload->>'coupon_code'))) THEN
    RAISE EXCEPTION 'Coupon ID and code do not match';
  END IF;

  FOR v_item IN SELECT * FROM jsonb_array_elements(p_payload->'items') LOOP
    v_product := (v_item->>'product_id')::uuid;
    IF NOT EXISTS (SELECT 1 FROM products WHERE id = v_product AND is_available IS TRUE) THEN
      RAISE EXCEPTION 'Product unavailable';
    END IF;
    IF COALESCE(v_item->>'quantity', '') !~ '^[1-9][0-9]{0,2}$' THEN
      RAISE EXCEPTION 'Quantity must be an integer';
    END IF;
    -- The current app sends IDs, never client-priced option objects.
    IF v_item ? 'selected_options' THEN RAISE EXCEPTION 'Use selected_option_ids'; END IF;
    v_options := COALESCE(v_item->'selected_option_ids', '[]'::jsonb);
    IF jsonb_typeof(v_options) IS DISTINCT FROM 'array' THEN RAISE EXCEPTION 'Invalid option list'; END IF;
    IF EXISTS (SELECT 1 FROM jsonb_array_elements(v_options) e WHERE jsonb_typeof(e) <> 'string') THEN
      RAISE EXCEPTION 'Invalid option ID';
    END IF;
    IF (SELECT count(*) <> count(DISTINCT value) FROM jsonb_array_elements_text(v_options)) THEN
      RAISE EXCEPTION 'Duplicate product option';
    END IF;
    IF EXISTS (SELECT 1 FROM product_options o WHERE o.product_id = v_product AND o.is_required IS TRUE
        AND NOT (v_options ? o.id::text)) THEN
      RAISE EXCEPTION 'A required product option is missing';
    END IF;
  END LOOP;

  v_order := private.create_authoritative_order(p_payload);
  SELECT sum(subtotal) INTO v_subtotal FROM order_items WHERE order_id = v_order;
  IF v_subtotal < COALESCE(v_zone_min, 0) THEN RAISE EXCEPTION 'Delivery zone minimum order not met'; END IF;
  UPDATE orders SET request_payload_hash = v_hash WHERE id = v_order;
  RETURN v_order;
END $$;
REVOKE ALL ON FUNCTION public.create_authoritative_order(JSONB) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.create_authoritative_order(JSONB) TO authenticated, service_role;

-- Enumerate exact owned paths, regardless of directory depth. Deletion of blobs
-- must use the Storage API; SQL must never delete storage.objects metadata.
CREATE OR REPLACE FUNCTION public.list_account_storage_objects(p_user_id UUID)
RETURNS TABLE(bucket_id TEXT, name TEXT)
LANGUAGE sql SECURITY DEFINER SET search_path = public, pg_temp AS $$
  SELECT o.bucket_id, o.name FROM storage.objects o
  WHERE o.owner_id = p_user_id::text ORDER BY o.bucket_id, o.name LIMIT 500
$$;
REVOKE ALL ON FUNCTION public.list_account_storage_objects(UUID) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.list_account_storage_objects(UUID) TO service_role;

COMMIT;
