-- Create order_ratings table
CREATE TABLE IF NOT EXISTS order_ratings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID REFERENCES orders(id) ON DELETE CASCADE UNIQUE,
  customer_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
  customer_name TEXT NOT NULL,
  rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security (RLS)
ALTER TABLE order_ratings ENABLE ROW LEVEL SECURITY;

-- 1. Public Read Policy
DROP POLICY IF EXISTS "Anyone can view ratings" ON order_ratings;
CREATE POLICY "Anyone can view ratings" ON order_ratings
  FOR SELECT USING (true);

-- 2. Customer Insert Policy (only for their own orders)
DROP POLICY IF EXISTS "Customers can insert own order ratings" ON order_ratings;
CREATE POLICY "Customers can insert own order ratings" ON order_ratings
  FOR INSERT WITH CHECK (
    auth.uid() = customer_id AND
    EXISTS (
      SELECT 1 FROM orders 
      WHERE id = order_id AND customer_id = auth.uid()
    )
  );
