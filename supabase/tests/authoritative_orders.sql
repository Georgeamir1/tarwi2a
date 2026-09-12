-- Test: authoritative_orders.sql
-- Description: Authoritative, atomic, and idempotent order creation tests:
-- 1) Unauthenticated rejection
-- 2) Forged pricing / status / customer ignored/rejected
-- 3) Customer A using Customer B's address rejected
-- 4) Inactive product rejected
-- 5) Foreign product option rejected
-- 6) Empty cart and invalid quantity rejected
-- 7) Pickup / dine-in forces delivery fee = 0 and clears address
-- 8) Coupon usage, atomic locking, and max uses limit
-- 9) Idempotency: retry with same request_id returns existing order without duplicating items or coupon count
-- 10) Same cart with new request_id succeeds as distinct order

BEGIN;

-- Setup test fixtures as postgres superuser
DO $$
DECLARE
  v_cust_a UUID := 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
  v_cust_b UUID := 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb';
  v_prod_active UUID := '11111111-1111-1111-1111-111111111111';
  v_prod_inactive UUID := '22222222-2222-2222-2222-222222222222';
  v_opt_active UUID := '33333333-3333-3333-3333-333333333333';
  v_opt_other UUID := '44444444-4444-4444-4444-444444444444';
  v_addr_a UUID := '55555555-5555-5555-5555-555555555555';
  v_addr_b UUID := '66666666-6666-6666-6666-666666666666';
  v_coupon UUID := '77777777-7777-7777-7777-777777777777';
  v_zone UUID := '88888888-8888-8888-8888-888888888888';
BEGIN
  -- Profiles
  INSERT INTO public.profiles (id, name, phone, role) VALUES
    (v_cust_a, 'Customer A', '01011111111', 'customer'),
    (v_cust_b, 'Customer B', '01022222222', 'customer')
  ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, role = EXCLUDED.role;

  -- Delivery zone
  INSERT INTO public.delivery_zones (id, name, fee, min_order, is_active) VALUES
    (v_zone, 'Zone 1', 15.00, 50.00, true)
  ON CONFLICT (id) DO UPDATE SET fee = 15.00, is_active = true;

  -- Addresses
  INSERT INTO public.addresses (id, user_id, label, address, delivery_zone_id, delivery_zone_name, delivery_fee) VALUES
    (v_addr_a, v_cust_a, 'Home A', 'Street A', v_zone, 'Zone 1', 15.00),
    (v_addr_b, v_cust_b, 'Home B', 'Street B', v_zone, 'Zone 1', 15.00)
  ON CONFLICT (id) DO UPDATE SET user_id = EXCLUDED.user_id, delivery_fee = 15.00;

  -- Products (requires a category)
  INSERT INTO public.categories (id, name_ar, name_en, sort_order)
  VALUES ('99999999-9999-9999-9999-999999999999', 'وجبات', 'Meals', 1)
  ON CONFLICT (id) DO NOTHING;

  INSERT INTO public.products (id, category_id, name_ar, name_en, price, is_available) VALUES
    (v_prod_active, '99999999-9999-9999-9999-999999999999', 'شاورما دجاج', 'Chicken Shawarma', 100.00, true),
    (v_prod_inactive, '99999999-9999-9999-9999-999999999999', 'شاورما لحم', 'Beef Shawarma', 120.00, false)
  ON CONFLICT (id) DO UPDATE SET price = EXCLUDED.price, is_available = EXCLUDED.is_available;

  -- Product options
  INSERT INTO public.product_options (id, product_id, name, name_ar, price_delta) VALUES
    (v_opt_active, v_prod_active, 'Extra Garlic', 'تومية إضافية', 10.00),
    (v_opt_other, v_prod_inactive, 'Extra Tahini', 'طحينة إضافية', 5.00)
  ON CONFLICT (id) DO UPDATE SET price_delta = EXCLUDED.price_delta;

  -- Coupon with max_uses = 1
  INSERT INTO public.coupons (id, code, type, value, min_order, max_uses, used_count, is_active) VALUES
    (v_coupon, 'SAVE20', 'fixed', 20.00, 50.00, 1, 0, true)
  ON CONFLICT (id) DO UPDATE SET used_count = 0, max_uses = 1, is_active = true, value = 20.00;
END;
$$;

-- ============================================================
-- 1. Unauthenticated test (should fail)
-- ============================================================
DO $$
DECLARE
  v_caught BOOLEAN := false;
BEGIN
  SET LOCAL ROLE anon;
  BEGIN
    PERFORM public.create_authoritative_order('{"request_id": "req-anon"}'::jsonb);
  EXCEPTION WHEN OTHERS THEN
    v_caught := true;
  END;

  IF NOT v_caught THEN
    RAISE EXCEPTION 'TEST FAILED: anon/unauthenticated was able to call create_authoritative_order';
  END IF;
END;
$$;

-- ============================================================
-- 2. Customer A: Address Ownership Check (Using Customer B's address)
-- ============================================================
DO $$
DECLARE
  v_cust_a UUID := 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
  v_addr_b UUID := '66666666-6666-6666-6666-666666666666';
  v_prod_active UUID := '11111111-1111-1111-1111-111111111111';
  v_caught BOOLEAN := false;
  v_payload JSONB;
BEGIN
  SET LOCAL ROLE authenticated;
  PERFORM set_config('request.jwt.claim.sub', v_cust_a::text, true);

  v_payload := jsonb_build_object(
    'request_id', 'req-cross-address',
    'order_type', 'delivery',
    'payment_method', 'cash',
    'address_id', v_addr_b,
    'items', jsonb_build_array(
      jsonb_build_object('product_id', v_prod_active, 'quantity', 1)
    )
  );

  BEGIN
    PERFORM public.create_authoritative_order(v_payload);
  EXCEPTION WHEN OTHERS THEN
    v_caught := true;
  END;

  IF NOT v_caught THEN
    RAISE EXCEPTION 'TEST FAILED: Customer A was able to use Customer B address';
  END IF;
END;
$$;

-- ============================================================
-- 3. Inactive Product Rejection
-- ============================================================
DO $$
DECLARE
  v_cust_a UUID := 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
  v_addr_a UUID := '55555555-5555-5555-5555-555555555555';
  v_prod_inactive UUID := '22222222-2222-2222-2222-222222222222';
  v_caught BOOLEAN := false;
  v_payload JSONB;
BEGIN
  SET LOCAL ROLE authenticated;
  PERFORM set_config('request.jwt.claim.sub', v_cust_a::text, true);

  v_payload := jsonb_build_object(
    'request_id', 'req-inactive-prod',
    'order_type', 'delivery',
    'payment_method', 'cash',
    'address_id', v_addr_a,
    'items', jsonb_build_array(
      jsonb_build_object('product_id', v_prod_inactive, 'quantity', 1)
    )
  );

  BEGIN
    PERFORM public.create_authoritative_order(v_payload);
  EXCEPTION WHEN OTHERS THEN
    v_caught := true;
  END;

  IF NOT v_caught THEN
    RAISE EXCEPTION 'TEST FAILED: Allowed order with inactive product';
  END IF;
END;
$$;

-- ============================================================
-- 4. Foreign Option ID Rejection (Option belongs to other product)
-- ============================================================
DO $$
DECLARE
  v_cust_a UUID := 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
  v_addr_a UUID := '55555555-5555-5555-5555-555555555555';
  v_prod_active UUID := '11111111-1111-1111-1111-111111111111';
  v_opt_other UUID := '44444444-4444-4444-4444-444444444444';
  v_caught BOOLEAN := false;
  v_payload JSONB;
BEGIN
  SET LOCAL ROLE authenticated;
  PERFORM set_config('request.jwt.claim.sub', v_cust_a::text, true);

  v_payload := jsonb_build_object(
    'request_id', 'req-foreign-opt',
    'order_type', 'delivery',
    'payment_method', 'cash',
    'address_id', v_addr_a,
    'items', jsonb_build_array(
      jsonb_build_object(
        'product_id', v_prod_active,
        'quantity', 1,
        'selected_option_ids', jsonb_build_array(v_opt_other)
      )
    )
  );

  BEGIN
    PERFORM public.create_authoritative_order(v_payload);
  EXCEPTION WHEN OTHERS THEN
    v_caught := true;
  END;

  IF NOT v_caught THEN
    RAISE EXCEPTION 'TEST FAILED: Allowed option belonging to different product';
  END IF;
END;
$$;

-- ============================================================
-- 5. Empty Cart & Invalid Quantity Rejection
-- ============================================================
DO $$
DECLARE
  v_cust_a UUID := 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
  v_addr_a UUID := '55555555-5555-5555-5555-555555555555';
  v_prod_active UUID := '11111111-1111-1111-1111-111111111111';
  v_caught BOOLEAN := false;
BEGIN
  SET LOCAL ROLE authenticated;
  PERFORM set_config('request.jwt.claim.sub', v_cust_a::text, true);

  -- Empty cart
  BEGIN
    PERFORM public.create_authoritative_order(jsonb_build_object(
      'request_id', 'req-empty',
      'order_type', 'delivery',
      'payment_method', 'cash',
      'address_id', v_addr_a,
      'items', '[]'::jsonb
    ));
  EXCEPTION WHEN OTHERS THEN
    v_caught := true;
  END;

  IF NOT v_caught THEN
    RAISE EXCEPTION 'TEST FAILED: Allowed empty items cart';
  END IF;

  -- Negative quantity
  v_caught := false;
  BEGIN
    PERFORM public.create_authoritative_order(jsonb_build_object(
      'request_id', 'req-neg-qty',
      'order_type', 'delivery',
      'payment_method', 'cash',
      'address_id', v_addr_a,
      'items', jsonb_build_array(
        jsonb_build_object('product_id', v_prod_active, 'quantity', -1)
      )
    ));
  EXCEPTION WHEN OTHERS THEN
    v_caught := true;
  END;

  IF NOT v_caught THEN
    RAISE EXCEPTION 'TEST FAILED: Allowed negative quantity';
  END IF;
END;
$$;

-- ============================================================
-- 6. Authoritative Pricing & Forged Values Overridden / Ignored
-- ============================================================
DO $$
DECLARE
  v_cust_a UUID := 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
  v_addr_a UUID := '55555555-5555-5555-5555-555555555555';
  v_prod_active UUID := '11111111-1111-1111-1111-111111111111';
  v_opt_active UUID := '33333333-3333-3333-3333-333333333333';
  v_order_id UUID;
  v_order RECORD;
  v_item RECORD;
BEGIN
  SET LOCAL ROLE authenticated;
  PERFORM set_config('request.jwt.claim.sub', v_cust_a::text, true);

  -- Client tries to forge:
  -- total_amount = 1.00 (actual: 100 base + 10 opt + 15 delivery = 125.00)
  -- status = 'completed' (must be pending)
  -- customer_id = Customer B (must be Customer A)
  -- item product_price = 0.50 (actual: 110.00)
  v_order_id := public.create_authoritative_order(jsonb_build_object(
    'request_id', 'req-forged-test',
    'order_type', 'delivery',
    'payment_method', 'cash',
    'address_id', v_addr_a,
    'total_amount', 1.00,
    'status', 'completed',
    'customer_id', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
    'items', jsonb_build_array(
      jsonb_build_object(
        'product_id', v_prod_active,
        'quantity', 1,
        'product_price', 0.50,
        'subtotal', 0.50,
        'selected_option_ids', jsonb_build_array(v_opt_active)
      )
    )
  ));

  SELECT * INTO v_order FROM public.orders WHERE id = v_order_id;
  IF v_order.customer_id <> v_cust_a THEN
    RAISE EXCEPTION 'TEST FAILED: Forged customer_id was honored (got %, expected %)', v_order.customer_id, v_cust_a;
  END IF;

  IF v_order.status <> 'pending' THEN
    RAISE EXCEPTION 'TEST FAILED: Forged status was honored (got %)', v_order.status;
  END IF;

  IF v_order.total_amount <> 125.00 THEN
    RAISE EXCEPTION 'TEST FAILED: Forged total was honored (got %, expected 125.00)', v_order.total_amount;
  END IF;

  SELECT * INTO v_item FROM public.order_items WHERE order_id = v_order_id;
  IF v_item.product_price <> 110.00 OR v_item.subtotal <> 110.00 THEN
    RAISE EXCEPTION 'TEST FAILED: Forged item price was honored (got price=%, subtotal=%)', v_item.product_price, v_item.subtotal;
  END IF;
END;
$$;

-- ============================================================
-- 7. Pickup / Dine-in forces delivery fee = 0 and ignores address
-- ============================================================
DO $$
DECLARE
  v_cust_a UUID := 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
  v_prod_active UUID := '11111111-1111-1111-1111-111111111111';
  v_order_id UUID;
  v_order RECORD;
BEGIN
  SET LOCAL ROLE authenticated;
  PERFORM set_config('request.jwt.claim.sub', v_cust_a::text, true);

  v_order_id := public.create_authoritative_order(jsonb_build_object(
    'request_id', 'req-pickup-test',
    'order_type', 'pickup',
    'payment_method', 'cash',
    'items', jsonb_build_array(
      jsonb_build_object('product_id', v_prod_active, 'quantity', 1)
    )
  ));

  SELECT * INTO v_order FROM public.orders WHERE id = v_order_id;
  IF v_order.delivery_fee <> 0 THEN
    RAISE EXCEPTION 'TEST FAILED: Pickup order has delivery_fee %', v_order.delivery_fee;
  END IF;
  IF v_order.address_id IS NOT NULL OR v_order.customer_address IS NOT NULL THEN
    RAISE EXCEPTION 'TEST FAILED: Pickup order retained address';
  END IF;
  IF v_order.total_amount <> 100.00 THEN
    RAISE EXCEPTION 'TEST FAILED: Pickup order total is % (expected 100.00)', v_order.total_amount;
  END IF;
END;
$$;

-- ============================================================
-- 8. Atomic Coupon Usage & Exhaustion
-- ============================================================
DO $$
DECLARE
  v_cust_a UUID := 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
  v_cust_b UUID := 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb';
  v_addr_a UUID := '55555555-5555-5555-5555-555555555555';
  v_addr_b UUID := '66666666-6666-6666-6666-666666666666';
  v_prod_active UUID := '11111111-1111-1111-1111-111111111111';
  v_coupon UUID := '77777777-7777-7777-7777-777777777777';
  v_order_id UUID;
  v_order RECORD;
  v_coupon_row RECORD;
  v_caught BOOLEAN := false;
BEGIN
  SET LOCAL ROLE authenticated;
  PERFORM set_config('request.jwt.claim.sub', v_cust_a::text, true);

  -- First use by Customer A should succeed
  v_order_id := public.create_authoritative_order(jsonb_build_object(
    'request_id', 'req-coupon-first',
    'order_type', 'delivery',
    'payment_method', 'cash',
    'address_id', v_addr_a,
    'coupon_code', 'SAVE20',
    'items', jsonb_build_array(
      jsonb_build_object('product_id', v_prod_active, 'quantity', 1)
    )
  ));

  SELECT * INTO v_order FROM public.orders WHERE id = v_order_id;
  -- Subtotal 100 - discount 20 + delivery 15 = 95.00
  IF v_order.discount_amount <> 20.00 OR v_order.total_amount <> 95.00 THEN
    RAISE EXCEPTION 'TEST FAILED: Coupon discount not applied correctly (discount=%, total=%)', v_order.discount_amount, v_order.total_amount;
  END IF;

  SELECT * INTO v_coupon_row FROM public.coupons WHERE id = v_coupon;
  IF v_coupon_row.used_count <> 1 THEN
    RAISE EXCEPTION 'TEST FAILED: Coupon used_count is % (expected 1)', v_coupon_row.used_count;
  END IF;

  -- Second use by Customer B (max_uses was 1) must be rejected
  PERFORM set_config('request.jwt.claim.sub', v_cust_b::text, true);
  BEGIN
    PERFORM public.create_authoritative_order(jsonb_build_object(
      'request_id', 'req-coupon-second',
      'order_type', 'delivery',
      'payment_method', 'cash',
      'address_id', v_addr_b,
      'coupon_code', 'SAVE20',
      'items', jsonb_build_array(
        jsonb_build_object('product_id', v_prod_active, 'quantity', 1)
      )
    ));
  EXCEPTION WHEN OTHERS THEN
    v_caught := true;
  END;

  IF NOT v_caught THEN
    RAISE EXCEPTION 'TEST FAILED: Exhausted coupon was accepted on second attempt';
  END IF;
END;
$$;

-- ============================================================
-- 9. Idempotency: Retry with same request_id returns existing order
-- ============================================================
DO $$
DECLARE
  v_cust_a UUID := 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
  v_addr_a UUID := '55555555-5555-5555-5555-555555555555';
  v_prod_active UUID := '11111111-1111-1111-1111-111111111111';
  v_id1 UUID;
  v_id2 UUID;
  v_item_count INT;
BEGIN
  SET LOCAL ROLE authenticated;
  PERFORM set_config('request.jwt.claim.sub', v_cust_a::text, true);

  -- First submission
  v_id1 := public.create_authoritative_order(jsonb_build_object(
    'request_id', 'req-idempotency-key-1',
    'order_type', 'delivery',
    'payment_method', 'cash',
    'address_id', v_addr_a,
    'items', jsonb_build_array(
      jsonb_build_object('product_id', v_prod_active, 'quantity', 1)
    )
  ));

  -- Retry submission with identical request_id
  v_id2 := public.create_authoritative_order(jsonb_build_object(
    'request_id', 'req-idempotency-key-1',
    'order_type', 'delivery',
    'payment_method', 'cash',
    'address_id', v_addr_a,
    'items', jsonb_build_array(
      jsonb_build_object('product_id', v_prod_active, 'quantity', 1)
    )
  ));

  IF v_id1 <> v_id2 THEN
    RAISE EXCEPTION 'TEST FAILED: Idempotent retry returned different ID (% vs %)', v_id1, v_id2;
  END IF;

  SELECT count(*) INTO v_item_count FROM public.order_items WHERE order_id = v_id1;
  IF v_item_count <> 1 THEN
    RAISE EXCEPTION 'TEST FAILED: Items duplicated on retry (count=%)', v_item_count;
  END IF;
END;
$$;

-- ============================================================
-- 10. Deliberate second order with new request_id succeeds
-- ============================================================
DO $$
DECLARE
  v_cust_a UUID := 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
  v_addr_a UUID := '55555555-5555-5555-5555-555555555555';
  v_prod_active UUID := '11111111-1111-1111-1111-111111111111';
  v_id1 UUID;
  v_id2 UUID;
BEGIN
  SET LOCAL ROLE authenticated;
  PERFORM set_config('request.jwt.claim.sub', v_cust_a::text, true);

  v_id1 := public.create_authoritative_order(jsonb_build_object(
    'request_id', 'req-order-A',
    'order_type', 'delivery',
    'payment_method', 'cash',
    'address_id', v_addr_a,
    'items', jsonb_build_array(
      jsonb_build_object('product_id', v_prod_active, 'quantity', 1)
    )
  ));

  v_id2 := public.create_authoritative_order(jsonb_build_object(
    'request_id', 'req-order-B',
    'order_type', 'delivery',
    'payment_method', 'cash',
    'address_id', v_addr_a,
    'items', jsonb_build_array(
      jsonb_build_object('product_id', v_prod_active, 'quantity', 1)
    )
  ));

  IF v_id1 = v_id2 THEN
    RAISE EXCEPTION 'TEST FAILED: Second order with different request_id returned same ID';
  END IF;
END;
$$;

ROLLBACK;
