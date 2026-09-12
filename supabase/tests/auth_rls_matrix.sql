-- Test: auth_rls_matrix.sql
-- Description: Comprehensive RLS & authorization matrix test across 4 roles:
-- 1) anon
-- 2) customer A
-- 3) customer B
-- 4) admin
-- Safe transaction that rolls back.

BEGIN;

-- Setup test fixtures
DO $$
DECLARE
  v_cust_a uuid := 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
  v_cust_b uuid := 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb';
  v_admin  uuid := 'cccccccc-cccc-cccc-cccc-cccccccccccc';
BEGIN
  -- Insert test profiles directly (as postgres/superuser)
  INSERT INTO public.profiles (id, name, phone, role) VALUES
    (v_cust_a, 'Customer A', '01011111111', 'customer'),
    (v_cust_b, 'Customer B', '01022222222', 'customer'),
    (v_admin,  'Admin User', '01033333333', 'admin')
  ON CONFLICT (id) DO UPDATE SET role = EXCLUDED.role, name = EXCLUDED.name;

  -- Insert test addresses
  INSERT INTO public.addresses (id, user_id, label, address) VALUES
    ('11111111-1111-1111-1111-111111111111', v_cust_a, 'Home A', 'Street A'),
    ('22222222-2222-2222-2222-222222222222', v_cust_b, 'Home B', 'Street B')
  ON CONFLICT (id) DO NOTHING;

  -- Insert test orders
  INSERT INTO public.orders (id, customer_id, customer_name, customer_phone, payment_method, total_amount, status) VALUES
    ('33333333-3333-3333-3333-333333333333', v_cust_a, 'Customer A', '01011111111', 'cash', 100, 'pending'),
    ('44444444-4444-4444-4444-444444444444', v_cust_b, 'Customer B', '01022222222', 'cash', 200, 'pending')
  ON CONFLICT (id) DO NOTHING;
END;
$$;

-- ============================================================
-- 1. Unauthenticated (anon) Tests
-- ============================================================
DO $$
DECLARE
  v_count integer;
  v_caught boolean := false;
BEGIN
  SET LOCAL ROLE anon;

  -- Anon should NOT see profiles
  SELECT count(*) INTO v_count FROM public.profiles;
  IF v_count <> 0 THEN
    RAISE EXCEPTION 'TEST FAILED: anon can view profiles (count=%)', v_count;
  END IF;

  -- Anon should NOT see orders
  SELECT count(*) INTO v_count FROM public.orders;
  IF v_count <> 0 THEN
    RAISE EXCEPTION 'TEST FAILED: anon can view orders (count=%)', v_count;
  END IF;

  -- Anon should NOT see addresses
  SELECT count(*) INTO v_count FROM public.addresses;
  IF v_count <> 0 THEN
    RAISE EXCEPTION 'TEST FAILED: anon can view addresses (count=%)', v_count;
  END IF;

  -- Anon should NOT be able to call is_admin()
  BEGIN
    PERFORM public.is_admin();
  EXCEPTION WHEN insufficient_privilege THEN
    v_caught := true;
  END;

  RESET ROLE;

  IF NOT v_caught THEN
    RAISE EXCEPTION 'TEST FAILED: anon was able to execute is_admin()';
  END IF;

  RAISE NOTICE 'TEST PASSED: anon access restrictions verified';
END;
$$;

-- ============================================================
-- 2. Customer A vs Customer B Isolation Tests
-- ============================================================
DO $$
DECLARE
  v_count integer;
  v_cust_a uuid := 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
  v_cust_b uuid := 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb';
  v_caught boolean := false;
BEGIN
  -- Simulate Customer A login
  SET LOCAL ROLE authenticated;
  PERFORM set_config('request.jwt.claim.sub', v_cust_a::text, true);

  -- Customer A can see own profile
  SELECT count(*) INTO v_count FROM public.profiles WHERE id = v_cust_a;
  IF v_count <> 1 THEN
    RAISE EXCEPTION 'TEST FAILED: Customer A cannot see own profile';
  END IF;

  -- Customer A CANNOT see Customer B profile
  SELECT count(*) INTO v_count FROM public.profiles WHERE id = v_cust_b;
  IF v_count <> 0 THEN
    RAISE EXCEPTION 'TEST FAILED: Customer A can see Customer B profile';
  END IF;

  -- Customer A CANNOT see Customer B address
  SELECT count(*) INTO v_count FROM public.addresses WHERE user_id = v_cust_b;
  IF v_count <> 0 THEN
    RAISE EXCEPTION 'TEST FAILED: Customer A can see Customer B address';
  END IF;

  -- Customer A CANNOT see Customer B order
  SELECT count(*) INTO v_count FROM public.orders WHERE customer_id = v_cust_b;
  IF v_count <> 0 THEN
    RAISE EXCEPTION 'TEST FAILED: Customer A can see Customer B order';
  END IF;

  -- Customer A is NOT admin
  IF public.is_admin() THEN
    RAISE EXCEPTION 'TEST FAILED: Customer A evaluated as admin';
  END IF;

  -- Customer A CANNOT elevate role directly
  BEGIN
    UPDATE public.profiles SET role = 'admin' WHERE id = v_cust_a;
  EXCEPTION WHEN insufficient_privilege THEN
    v_caught := true;
  END;

  IF NOT v_caught THEN
    RAISE EXCEPTION 'TEST FAILED: Customer A was able to update role column directly';
  END IF;

  -- Customer A CANNOT call admin_update_user_role
  v_caught := false;
  BEGIN
    PERFORM public.admin_update_user_role(v_cust_a, 'admin');
  EXCEPTION WHEN OTHERS THEN
    v_caught := true;
  END;

  IF NOT v_caught THEN
    RAISE EXCEPTION 'TEST FAILED: Customer A was able to call admin_update_user_role';
  END IF;

  RESET ROLE;
  RAISE NOTICE 'TEST PASSED: Customer A isolation and role escalation prevention verified';
END;
$$;

-- ============================================================
-- 3. Admin Permissions Tests
-- ============================================================
DO $$
DECLARE
  v_count integer;
  v_admin  uuid := 'cccccccc-cccc-cccc-cccc-cccccccccccc';
  v_cust_a uuid := 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
BEGIN
  -- Simulate Admin login
  SET LOCAL ROLE authenticated;
  PERFORM set_config('request.jwt.claim.sub', v_admin::text, true);

  -- Admin is recognized
  IF NOT public.is_admin() THEN
    RAISE EXCEPTION 'TEST FAILED: Admin not recognized by is_admin()';
  END IF;

  -- Admin can see all profiles (at least 3)
  SELECT count(*) INTO v_count FROM public.profiles;
  IF v_count < 3 THEN
    RAISE EXCEPTION 'TEST FAILED: Admin cannot view all profiles (found %)', v_count;
  END IF;

  -- Admin can see all orders (at least 2)
  SELECT count(*) INTO v_count FROM public.orders;
  IF v_count < 2 THEN
    RAISE EXCEPTION 'TEST FAILED: Admin cannot view all orders (found %)', v_count;
  END IF;

  -- Admin can see all addresses (at least 2)
  SELECT count(*) INTO v_count FROM public.addresses;
  IF v_count < 2 THEN
    RAISE EXCEPTION 'TEST FAILED: Admin cannot view all addresses (found %)', v_count;
  END IF;

  -- Admin can update user role via admin_update_user_role
  PERFORM public.admin_update_user_role(v_cust_a, 'admin');
  PERFORM public.admin_update_user_role(v_cust_a, 'customer');

  RESET ROLE;
  RAISE NOTICE 'TEST PASSED: Admin full visibility and role update function verified';
END;
$$;

ROLLBACK;
