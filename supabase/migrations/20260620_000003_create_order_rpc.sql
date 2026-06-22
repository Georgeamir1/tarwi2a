CREATE OR REPLACE FUNCTION create_order_with_items(p_order JSONB, p_items JSONB)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_order_id UUID;
  v_item JSONB;
BEGIN
  INSERT INTO orders (
    customer_id, customer_name, customer_phone, customer_address,
    notes, payment_method, total_amount, status,
    scheduled_for, order_type, address_id, coupon_id,
    discount_amount, delivery_fee, delivery_zone_id, delivery_zone_name
  ) VALUES (
    (p_order->>'customer_id')::UUID,
    p_order->>'customer_name',
    p_order->>'customer_phone',
    p_order->>'customer_address',
    p_order->>'notes',
    p_order->>'payment_method',
    (p_order->>'total_amount')::DECIMAL,
    COALESCE(p_order->>'status', 'pending'),
    (p_order->>'scheduled_for')::TIMESTAMPTZ,
    p_order->>'order_type',
    (p_order->>'address_id')::UUID,
    (p_order->>'coupon_id')::UUID,
    (p_order->>'discount_amount')::DECIMAL,
    (p_order->>'delivery_fee')::DECIMAL,
    (p_order->>'delivery_zone_id')::UUID,
    p_order->>'delivery_zone_name'
  ) RETURNING id INTO v_order_id;

  FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
  LOOP
    INSERT INTO order_items (
      order_id, product_id, product_name, product_price,
      quantity, subtotal, selected_options
    ) VALUES (
      v_order_id,
      (v_item->>'product_id')::UUID,
      v_item->>'product_name',
      (v_item->>'product_price')::DECIMAL,
      (v_item->>'quantity')::INT,
      (v_item->>'subtotal')::DECIMAL,
      COALESCE(v_item->'selected_options', '[]'::jsonb)
    );
  END LOOP;

  RETURN v_order_id;
END;
$$;

GRANT EXECUTE ON FUNCTION create_order_with_items(JSONB, JSONB) TO authenticated;