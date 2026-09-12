-- Migration: 20260908_000003_authoritative_order_creation.sql
-- Description: Authoritative, atomic, and idempotent order creation RPC.

-- 1. Add request_id (idempotency key) to orders table
ALTER TABLE public.orders ADD COLUMN IF NOT EXISTS request_id TEXT;
CREATE UNIQUE INDEX IF NOT EXISTS idx_orders_customer_request_id 
  ON public.orders(customer_id, request_id) 
  WHERE request_id IS NOT NULL;

-- 2. Drop the old unsafe client-authoritative RPC
DROP FUNCTION IF EXISTS create_order_with_items(JSONB, JSONB);

-- 3. Deprecate client-callable increment_coupon_usage
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'increment_coupon_usage') THEN
    REVOKE EXECUTE ON FUNCTION increment_coupon_usage(UUID) FROM PUBLIC, anon, authenticated;
    GRANT EXECUTE ON FUNCTION increment_coupon_usage(UUID) TO postgres, service_role;
  END IF;
END;
$$;

-- 4. Create authoritative order creation RPC
CREATE OR REPLACE FUNCTION create_authoritative_order(p_payload JSONB)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_customer_id UUID;
  v_request_id TEXT;
  v_existing_order_id UUID;
  v_customer_name TEXT;
  v_customer_phone TEXT;
  v_cust_address TEXT;
  v_order_type TEXT;
  v_payment_method TEXT;
  v_notes TEXT;
  v_scheduled_for TIMESTAMPTZ;
  v_address_id UUID;
  v_zone_id UUID;
  v_zone_name TEXT;
  v_delivery_fee NUMERIC := 0;
  v_actual_zone_fee NUMERIC;
  v_zone_is_active BOOLEAN;
  v_coupon_id UUID;
  v_coupon_code TEXT;
  v_coupon RECORD;
  v_discount_amount NUMERIC := 0;
  v_subtotal NUMERIC := 0;
  v_total_amount NUMERIC := 0;
  v_order_id UUID;
  v_items JSONB;
  v_item JSONB;
  v_product_id UUID;
  v_qty INT;
  v_product_name TEXT;
  v_base_price NUMERIC;
  v_product_available BOOLEAN;
  v_opt_id_elem JSONB;
  v_opt_id UUID;
  v_opt_name TEXT;
  v_opt_delta NUMERIC;
  v_item_options_delta NUMERIC;
  v_selected_options JSONB;
  v_item_unit_price NUMERIC;
  v_item_subtotal NUMERIC;
  v_min_order NUMERIC;
  v_accept_orders BOOLEAN;

  -- Array to buffer validated items for insertion
  v_order_items_buffer JSONB := '[]'::JSONB;
BEGIN
  -- Authenticate caller
  v_customer_id := auth.uid();
  IF v_customer_id IS NULL THEN
    RAISE EXCEPTION 'Unauthorized: User must be authenticated to place an order';
  END IF;

  -- Validate idempotency key (request_id)
  v_request_id := trim(p_payload->>'request_id');
  IF v_request_id IS NULL OR v_request_id = '' THEN
    RAISE EXCEPTION 'Bad request: request_id (idempotency key) is required';
  END IF;

  -- Idempotency check: if order with this (customer_id, request_id) already exists, return it
  SELECT id INTO v_existing_order_id
  FROM public.orders
  WHERE customer_id = v_customer_id AND request_id = v_request_id;

  IF v_existing_order_id IS NOT NULL THEN
    RETURN v_existing_order_id;
  END IF;

  -- Business rules check (if business_profiles table exists)
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'business_profiles') THEN
    SELECT accept_orders, min_order INTO v_accept_orders, v_min_order
    FROM public.business_profiles
    LIMIT 1;

    IF v_accept_orders IS FALSE THEN
      RAISE EXCEPTION 'المطعم لا يستقبل طلبات حالياً';
    END IF;
  END IF;

  -- Validate items payload
  v_items := p_payload->'items';
  IF v_items IS NULL OR jsonb_typeof(v_items) <> 'array' OR jsonb_array_length(v_items) = 0 THEN
    RAISE EXCEPTION 'السلة فارغة، لا يمكن إتمام الطلب بدون منتجات';
  END IF;

  -- Fetch customer snapshot from profile
  SELECT name, phone INTO v_customer_name, v_customer_phone
  FROM public.profiles
  WHERE id = v_customer_id;

  IF v_customer_name IS NULL OR trim(v_customer_name) = '' THEN
    v_customer_name := COALESCE(trim(p_payload->>'customer_name'), 'عميل');
  END IF;
  IF v_customer_phone IS NULL OR trim(v_customer_phone) = '' THEN
    v_customer_phone := COALESCE(trim(p_payload->>'customer_phone'), '');
  END IF;

  -- Validate fulfillment type
  v_order_type := COALESCE(p_payload->>'order_type', 'delivery');
  IF v_order_type NOT IN ('delivery', 'pickup', 'dine_in') THEN
    RAISE EXCEPTION 'نوع الطلب غير صالح: %', v_order_type;
  END IF;

  -- Validate address and zone based on fulfillment type
  IF v_order_type = 'delivery' THEN
    v_address_id := (p_payload->>'address_id')::UUID;
    IF v_address_id IS NULL THEN
      RAISE EXCEPTION 'يجب تحديد عنوان صالح للتوصيل';
    END IF;

    -- Address must belong to the authenticated user
    SELECT address, delivery_zone_id, delivery_zone_name, delivery_fee
    INTO v_cust_address, v_zone_id, v_zone_name, v_delivery_fee
    FROM public.addresses
    WHERE id = v_address_id AND user_id = v_customer_id;

    IF NOT FOUND THEN
      RAISE EXCEPTION 'العنوان المحدد غير موجود أو لا يخص حسابك';
    END IF;

    IF v_zone_id IS NOT NULL THEN
      SELECT fee, is_active INTO v_actual_zone_fee, v_zone_is_active
      FROM public.delivery_zones
      WHERE id = v_zone_id;

      IF v_zone_is_active IS FALSE THEN
        RAISE EXCEPTION 'منطقة التوصيل غير مفعلة حالياً';
      END IF;

      IF v_actual_zone_fee IS NOT NULL THEN
        v_delivery_fee := v_actual_zone_fee;
      END IF;
    END IF;

    v_delivery_fee := COALESCE(v_delivery_fee, 0);
  ELSE
    -- Pickup and dine_in carry zero delivery fee and no address/zone
    v_address_id := NULL;
    v_cust_address := NULL;
    v_zone_id := NULL;
    v_zone_name := NULL;
    v_delivery_fee := 0;
  END IF;

  -- Validate payment method
  v_payment_method := p_payload->>'payment_method';
  IF v_payment_method NOT IN ('cash', 'wallet', 'instapay') THEN
    RAISE EXCEPTION 'طريقة الدفع غير صالحة: %', v_payment_method;
  END IF;

  -- Validate scheduled time
  IF (p_payload->>'scheduled_for') IS NOT NULL AND trim(p_payload->>'scheduled_for') <> '' THEN
    v_scheduled_for := (p_payload->>'scheduled_for')::TIMESTAMPTZ;
    IF v_scheduled_for <= NOW() THEN
      RAISE EXCEPTION 'وقت الطلب المجدول يجب أن يكون في المستقبل';
    END IF;
  END IF;

  v_notes := trim(p_payload->>'notes');

  -- Process and authoritatively calculate each item
  FOR v_item IN SELECT * FROM jsonb_array_elements(v_items)
  LOOP
    v_product_id := (v_item->>'product_id')::UUID;
    v_qty := (v_item->>'quantity')::INT;

    IF v_product_id IS NULL THEN
      RAISE EXCEPTION 'معرف المنتج مفقود في السلة';
    END IF;

    IF v_qty IS NULL OR v_qty <= 0 OR v_qty > 100 THEN
      RAISE EXCEPTION 'كمية المنتج غير صالحة (%): يجب أن تكون بين 1 و 100', v_qty;
    END IF;

    -- Fetch authoritative product details from database
    SELECT name_ar, price, is_available
    INTO v_product_name, v_base_price, v_product_available
    FROM public.products
    WHERE id = v_product_id;

    IF NOT FOUND THEN
      RAISE EXCEPTION 'المنتج غير موجود: %', v_product_id;
    END IF;

    IF v_product_available IS FALSE THEN
      RAISE EXCEPTION 'المنتج "%" غير متوفر حالياً', v_product_name;
    END IF;

    -- Process selected options
    v_item_options_delta := 0;
    v_selected_options := '[]'::JSONB;

    IF v_item ? 'selected_option_ids' AND jsonb_typeof(v_item->'selected_option_ids') = 'array' THEN
      FOR v_opt_id_elem IN SELECT * FROM jsonb_array_elements(v_item->'selected_option_ids')
      LOOP
        v_opt_id := (v_opt_id_elem#>>'{}')::UUID;
        IF v_opt_id IS NOT NULL THEN
          SELECT name_ar, price_delta
          INTO v_opt_name, v_opt_delta
          FROM public.product_options
          WHERE id = v_opt_id AND product_id = v_product_id;

          IF NOT FOUND THEN
            RAISE EXCEPTION 'الخيار % لا ينتمي للمنتج "%"', v_opt_id, v_product_name;
          END IF;

          v_item_options_delta := v_item_options_delta + COALESCE(v_opt_delta, 0);
          v_selected_options := v_selected_options || jsonb_build_object(
            'option_id', v_opt_id,
            'name', v_opt_name,
            'price_adjustment', COALESCE(v_opt_delta, 0)
          );
        END IF;
      END LOOP;
    ELSIF v_item ? 'selected_options' AND jsonb_typeof(v_item->'selected_options') = 'array' THEN
      -- Handle objects with option_id
      FOR v_opt_id_elem IN SELECT * FROM jsonb_array_elements(v_item->'selected_options')
      LOOP
        v_opt_id := (v_opt_id_elem->>'option_id')::UUID;
        IF v_opt_id IS NOT NULL THEN
          SELECT name_ar, price_delta
          INTO v_opt_name, v_opt_delta
          FROM public.product_options
          WHERE id = v_opt_id AND product_id = v_product_id;

          IF NOT FOUND THEN
            RAISE EXCEPTION 'الخيار % لا ينتمي للمنتج "%"', v_opt_id, v_product_name;
          END IF;

          v_item_options_delta := v_item_options_delta + COALESCE(v_opt_delta, 0);
          v_selected_options := v_selected_options || jsonb_build_object(
            'option_id', v_opt_id,
            'name', v_opt_name,
            'price_adjustment', COALESCE(v_opt_delta, 0)
          );
        END IF;
      END LOOP;
    END IF;

    v_item_unit_price := v_base_price + v_item_options_delta;
    IF v_item_unit_price < 0 THEN
      v_item_unit_price := 0;
    END IF;

    v_item_subtotal := round(v_item_unit_price * v_qty, 2);
    v_subtotal := v_subtotal + v_item_subtotal;

    -- Buffer validated item for insertion
    v_order_items_buffer := v_order_items_buffer || jsonb_build_object(
      'product_id', v_product_id,
      'product_name', v_product_name,
      'product_price', v_item_unit_price,
      'quantity', v_qty,
      'subtotal', v_item_subtotal,
      'selected_options', v_selected_options
    );
  END LOOP;

  -- Validate minimum order requirement
  IF v_min_order IS NOT NULL AND v_min_order > 0 AND v_subtotal < v_min_order THEN
    RAISE EXCEPTION 'الحد الأدنى للطلب هو % جنيه (المجموع الحالي % جنيه)', v_min_order, v_subtotal;
  END IF;

  -- Atomic coupon validation and locking
  IF (p_payload->>'coupon_id') IS NOT NULL AND trim(p_payload->>'coupon_id') <> '' THEN
    v_coupon_id := (p_payload->>'coupon_id')::UUID;
  END IF;
  v_coupon_code := trim(p_payload->>'coupon_code');

  IF v_coupon_id IS NOT NULL OR (v_coupon_code IS NOT NULL AND v_coupon_code <> '') THEN
    SELECT id, code, type, value, min_order, max_discount, max_uses, used_count, is_active, start_date, end_date
    INTO v_coupon
    FROM public.coupons
    WHERE (id = v_coupon_id OR (v_coupon_code IS NOT NULL AND UPPER(code) = UPPER(v_coupon_code)))
    FOR UPDATE; -- Row-level lock prevents race conditions

    IF NOT FOUND THEN
      RAISE EXCEPTION 'كوبون الخصم غير موجود';
    END IF;

    IF v_coupon.is_active IS FALSE THEN
      RAISE EXCEPTION 'كوبون الخصم غير مفعل';
    END IF;

    IF v_coupon.start_date IS NOT NULL AND v_coupon.start_date > NOW() THEN
      RAISE EXCEPTION 'كوبون الخصم لم يبدأ بعد';
    END IF;

    IF v_coupon.end_date IS NOT NULL AND v_coupon.end_date < NOW() THEN
      RAISE EXCEPTION 'كوبون الخصم منتهي الصلاحية';
    END IF;

    IF v_coupon.max_uses IS NOT NULL AND v_coupon.used_count >= v_coupon.max_uses THEN
      RAISE EXCEPTION 'كوبون الخصم استنفد الحد الأقصى لعدد مرات الاستخدام';
    END IF;

    IF v_coupon.min_order > 0 AND v_subtotal < v_coupon.min_order THEN
      RAISE EXCEPTION 'الحد الأدنى لاستخدام هذا الكوبون هو % جنيه', v_coupon.min_order;
    END IF;

    -- Calculate discount
    IF v_coupon.type = 'percentage' THEN
      v_discount_amount := round(v_subtotal * (v_coupon.value / 100.0), 2);
      IF v_coupon.max_discount IS NOT NULL AND v_discount_amount > v_coupon.max_discount THEN
        v_discount_amount := v_coupon.max_discount;
      END IF;
    ELSE
      v_discount_amount := v_coupon.value;
    END IF;

    IF v_discount_amount > v_subtotal THEN
      v_discount_amount := v_subtotal;
    END IF;

    -- Atomically increment usage
    UPDATE public.coupons SET used_count = used_count + 1 WHERE id = v_coupon.id;
    v_coupon_id := v_coupon.id;
  END IF;

  -- Authoritatively calculate final total
  v_total_amount := round(v_subtotal - v_discount_amount + v_delivery_fee, 2);
  IF v_total_amount < 0 THEN
    v_total_amount := 0;
  END IF;

  -- Insert order
  INSERT INTO public.orders (
    customer_id, customer_name, customer_phone, customer_address,
    notes, payment_method, total_amount, status, payment_status,
    scheduled_for, order_type, address_id, coupon_id,
    discount_amount, delivery_fee, delivery_zone_id, delivery_zone_name,
    request_id
  ) VALUES (
    v_customer_id, v_customer_name, v_customer_phone, v_cust_address,
    v_notes, v_payment_method, v_total_amount, 'pending', 'pending',
    v_scheduled_for, v_order_type, v_address_id, v_coupon_id,
    v_discount_amount, v_delivery_fee, v_zone_id, v_zone_name,
    v_request_id
  ) RETURNING id INTO v_order_id;

  -- Insert order items with server-verified prices
  FOR v_item IN SELECT * FROM jsonb_array_elements(v_order_items_buffer)
  LOOP
    INSERT INTO public.order_items (
      order_id, product_id, product_name, product_price,
      quantity, subtotal, selected_options
    ) VALUES (
      v_order_id,
      (v_item->>'product_id')::UUID,
      v_item->>'product_name',
      (v_item->>'product_price')::NUMERIC,
      (v_item->>'quantity')::INT,
      (v_item->>'subtotal')::NUMERIC,
      v_item->'selected_options'
    );
  END LOOP;

  RETURN v_order_id;
END;
$$;

-- Revoke public execution; grant only to authenticated clients and service_role
REVOKE EXECUTE ON FUNCTION create_authoritative_order(JSONB) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION create_authoritative_order(JSONB) FROM anon;
GRANT EXECUTE ON FUNCTION create_authoritative_order(JSONB) TO authenticated, service_role;
