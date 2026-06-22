ALTER TABLE orders DROP CONSTRAINT IF EXISTS orders_order_type_check;
ALTER TABLE orders ADD CONSTRAINT orders_order_type_check
  CHECK (order_type IN ('delivery', 'pickup', 'dine_in'));