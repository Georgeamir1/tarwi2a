-- Test: delete_account.sql
-- Description: Test suite for account deletion & data anonymization:
-- 1) Direct execution revoked from PUBLIC, anon, and authenticated
-- 2) Service-role execution correctly anonymizes orders and deletes user personal records
-- 3) Other users' records remain unaffected
-- 4) Partial / retry execution is safe and idempotent

BEGIN;

-- Setup test fixtures as postgres superuser
DO $$
DECLARE
  v_user_a UUID := 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
  v_user_b UUID := 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb';
  v_order_a UUID := '11111111-1111-1111-1111-111111111111';
  v_order_b UUID := '22222222-2222-2222-2222-222222222222';
  v_addr_a UUID := '33333333-3333-3333-3333-333333333333';
  v_addr_b UUID := '44444444-4444-4444-4444-444444444444';
  v_token_a UUID := '55555555-5555-5555-5555-555555555555';
  v_token_b UUID := '66666666-6666-6666-6666-666666666666';
BEGIN
  -- Profiles
  INSERT INTO public.profiles (id, name, phone, role) VALUES
    (v_user_a, 'User To Delete', '01011111111', 'customer'),
    (v_user_b, 'Retained User', '01022222222', 'customer')
  ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, phone = EXCLUDED.phone;

  -- Addresses
  INSERT INTO public.addresses (id, user_id, label, address) VALUES
    (v_addr_a, v_user_a, 'Home A', 'Secret Address A'),
    (v_addr_b, v_user_b, 'Home B', 'Address B')
  ON CONFLICT (id) DO NOTHING;

  -- Orders
  INSERT INTO public.orders (id, customer_id, customer_name, customer_phone, customer_address, notes, payment_method, total_amount, status) VALUES
    (v_order_a, v_user_a, 'User To Delete', '01011111111', 'Secret Address A', 'Ring bell twice', 'cash', 150.00, 'delivered'),
    (v_order_b, v_user_b, 'Retained User', '01022222222', 'Address B', 'Leave at door', 'cash', 200.00, 'delivered')
  ON CONFLICT (id) DO NOTHING;

  -- Device Tokens
  INSERT INTO public.device_tokens (id, user_id, token, platform) VALUES
    (v_token_a, v_user_a, 'fcm-token-user-a', 'android'),
    (v_token_b, v_user_b, 'fcm-token-user-b', 'android')
  ON CONFLICT (id) DO NOTHING;

  -- Notification Preferences
  INSERT INTO public.notification_preferences (user_id, push_enabled, order_updates) VALUES
    (v_user_a, true, true),
    (v_user_b, true, true)
  ON CONFLICT (user_id) DO NOTHING;
END;
$$;

-- ============================================================
-- 1. Direct Execution Revoked from authenticated & anon
-- ============================================================
DO $$
DECLARE
  v_user_a UUID := 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
  v_caught BOOLEAN := false;
BEGIN
  SET LOCAL ROLE anon;
  BEGIN
    PERFORM public.delete_user_account_data(v_user_a);
  EXCEPTION WHEN OTHERS THEN
    v_caught := true;
  END;

  IF NOT v_caught THEN
    RAISE EXCEPTION 'TEST FAILED: anon role was able to execute delete_user_account_data';
  END IF;

  v_caught := false;
  SET LOCAL ROLE authenticated;
  PERFORM set_config('request.jwt.claim.sub', v_user_a::text, true);
  BEGIN
    PERFORM public.delete_user_account_data(v_user_a);
  EXCEPTION WHEN OTHERS THEN
    v_caught := true;
  END;

  IF NOT v_caught THEN
    RAISE EXCEPTION 'TEST FAILED: authenticated role was able to execute delete_user_account_data directly';
  END IF;
END;
$$;

-- ============================================================
-- 2. Execution as service_role succeeds and cleans/anonymizes data
-- ============================================================
DO $$
DECLARE
  v_user_a UUID := 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
  v_user_b UUID := 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb';
  v_order_a RECORD;
  v_order_b RECORD;
  v_count INT;
BEGIN
  -- Reset to service_role / postgres
  RESET ROLE;

  -- Call delete_user_account_data for user A
  PERFORM public.delete_user_account_data(v_user_a);

  -- 1) Verify User A profile is deleted
  SELECT count(*) INTO v_count FROM public.profiles WHERE id = v_user_a;
  IF v_count <> 0 THEN
    RAISE EXCEPTION 'TEST FAILED: Profile A was not deleted';
  END IF;

  -- 2) Verify User A order is anonymized
  SELECT * INTO v_order_a FROM public.orders WHERE id = '11111111-1111-1111-1111-111111111111';
  IF v_order_a.customer_name <> 'مستخدم محذوف' OR v_order_a.customer_phone <> 'محذوف' OR v_order_a.customer_address IS NOT NULL OR v_order_a.notes IS NOT NULL THEN
    RAISE EXCEPTION 'TEST FAILED: Order A PII was not anonymized (name=%, phone=%, addr=%, notes=%)',
      v_order_a.customer_name, v_order_a.customer_phone, v_order_a.customer_address, v_order_a.notes;
  END IF;

  -- 3) Verify User A address is deleted
  SELECT count(*) INTO v_count FROM public.addresses WHERE user_id = v_user_a;
  IF v_count <> 0 THEN
    RAISE EXCEPTION 'TEST FAILED: Address A was not deleted';
  END IF;

  -- 4) Verify User A device tokens are deleted
  SELECT count(*) INTO v_count FROM public.device_tokens WHERE user_id = v_user_a;
  IF v_count <> 0 THEN
    RAISE EXCEPTION 'TEST FAILED: Device token A was not deleted';
  END IF;

  -- 5) Verify User A notification preferences are deleted
  SELECT count(*) INTO v_count FROM public.notification_preferences WHERE user_id = v_user_a;
  IF v_count <> 0 THEN
    RAISE EXCEPTION 'TEST FAILED: Notification preferences A was not deleted';
  END IF;

  -- 6) Verify User B records are completely untouched
  SELECT count(*) INTO v_count FROM public.profiles WHERE id = v_user_b;
  IF v_count <> 1 THEN
    RAISE EXCEPTION 'TEST FAILED: Profile B was affected';
  END IF;

  SELECT * INTO v_order_b FROM public.orders WHERE id = '22222222-2222-2222-2222-222222222222';
  IF v_order_b.customer_name <> 'Retained User' OR v_order_b.customer_phone <> '01022222222' THEN
    RAISE EXCEPTION 'TEST FAILED: Order B was modified';
  END IF;

  SELECT count(*) INTO v_count FROM public.addresses WHERE user_id = v_user_b;
  IF v_count <> 1 THEN
    RAISE EXCEPTION 'TEST FAILED: Address B was affected';
  END IF;
END;
$$;

-- ============================================================
-- 3. Idempotent Retry Check
-- ============================================================
DO $$
DECLARE
  v_user_a UUID := 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
BEGIN
  -- Calling again on already-deleted user must not error
  PERFORM public.delete_user_account_data(v_user_a);
END;
$$;

ROLLBACK;
