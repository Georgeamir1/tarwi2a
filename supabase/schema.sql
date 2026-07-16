-- =============================================
-- ترويقه (Troo2a) - Complete Database Schema
-- Run this in Supabase SQL Editor
-- Last Updated: 2026-05-22
-- =============================================

-- =============================================
-- CORE TABLES
-- =============================================

-- 1. PROFILES (extends auth.users)
CREATE TABLE IF NOT EXISTS profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  name TEXT NOT NULL DEFAULT '',
  phone TEXT,
  role TEXT NOT NULL DEFAULT 'customer' CHECK (role IN ('customer', 'admin')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. CATEGORIES
CREATE TABLE IF NOT EXISTS categories (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  name_ar TEXT NOT NULL,
  image_url TEXT,
  sort_order INT DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. PRODUCTS
CREATE TABLE IF NOT EXISTS products (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
  name TEXT NOT NULL,
  name_ar TEXT NOT NULL,
  description TEXT,
  description_ar TEXT,
  price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
  image_url TEXT,
  is_available BOOLEAN DEFAULT true,
  sort_order INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. ORDERS
CREATE TABLE IF NOT EXISTS orders (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  customer_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
  customer_name TEXT NOT NULL,
  customer_phone TEXT NOT NULL,
  customer_address TEXT,
  notes TEXT,
  payment_method TEXT NOT NULL CHECK (payment_method IN ('cash', 'wallet', 'instapay')),
  status TEXT NOT NULL DEFAULT 'pending' 
    CHECK (status IN ('pending', 'confirmed', 'preparing', 'ready', 'delivered', 'cancelled')),
  payment_status TEXT NOT NULL DEFAULT 'pending'
    CHECK (payment_status IN ('pending', 'paid')),
  payment_proof_url TEXT,
  total_amount DECIMAL(10,2) NOT NULL CHECK (total_amount >= 0),
  discount_amount DECIMAL(10,2) DEFAULT 0 CHECK (discount_amount >= 0),
  delivery_fee DECIMAL(10,2) DEFAULT 0 CHECK (delivery_fee >= 0),
  delivery_zone_id UUID REFERENCES delivery_zones(id) ON DELETE SET NULL,
  delivery_zone_name TEXT,
  order_type TEXT DEFAULT 'delivery' CHECK (order_type IN ('delivery', 'pickup', 'dine_in')),
  address_id UUID,
  coupon_id UUID,
  scheduled_for TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. ORDER ITEMS
CREATE TABLE IF NOT EXISTS order_items (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
  product_id UUID REFERENCES products(id) ON DELETE SET NULL,
  product_name TEXT NOT NULL,
  product_price DECIMAL(10,2) NOT NULL CHECK (product_price >= 0),
  quantity INT NOT NULL DEFAULT 1 CHECK (quantity > 0),
  subtotal DECIMAL(10,2) NOT NULL CHECK (subtotal >= 0),
  selected_options JSONB DEFAULT '[]'::jsonb
);

-- =============================================
-- ADMIN ENHANCEMENT TABLES (Phases 15-25)
-- =============================================

-- 6. COUPONS
CREATE TABLE IF NOT EXISTS coupons (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  code TEXT UNIQUE NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('percentage', 'fixed')),
  value DECIMAL(10,2) NOT NULL CHECK (value > 0),
  min_order DECIMAL(10,2) DEFAULT 0 CHECK (min_order >= 0),
  max_discount DECIMAL(10,2),
  max_uses INT,
  used_count INT DEFAULT 0 CHECK (used_count >= 0),
  start_date TIMESTAMPTZ,
  end_date TIMESTAMPTZ,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. DELIVERY_ZONES
CREATE TABLE IF NOT EXISTS delivery_zones (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  fee DECIMAL(10,2) NOT NULL DEFAULT 0 CHECK (fee >= 0),
  min_order DECIMAL(10,2) DEFAULT 0 CHECK (min_order >= 0),
  estimated_time TEXT,
  is_active BOOLEAN DEFAULT true,
  coordinates JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 8. BUSINESS_PROFILES
CREATE TABLE IF NOT EXISTS business_profiles (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  phone TEXT,
  address TEXT,
  logo_url TEXT,
  opening_hours JSONB,
  min_order DECIMAL(10,2) DEFAULT 0 CHECK (min_order >= 0),
  default_prep_time INT DEFAULT 30 CHECK (default_prep_time > 0),
  is_busy BOOLEAN DEFAULT false,
  busy_message TEXT,
  accept_orders BOOLEAN DEFAULT true,
  whatsapp_number TEXT,        -- international format without + (e.g. 201xxxxxxxxx)
  vodafone_cash_number TEXT,
  instapay_handle TEXT,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 9. PRODUCT_OPTIONS (Modifiers)
CREATE TABLE IF NOT EXISTS product_options (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  product_id UUID REFERENCES products(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  name_ar TEXT,
  price_delta DECIMAL(10,2) DEFAULT 0,
  is_required BOOLEAN DEFAULT false,
  max_selections INT DEFAULT 1 CHECK (max_selections > 0),
  sort_order INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 10. AUDIT_LOGS
CREATE TABLE IF NOT EXISTS audit_logs (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  admin_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
  action TEXT NOT NULL,
  entity_type TEXT NOT NULL,
  entity_id TEXT,
  old_values JSONB,
  new_values JSONB,
  ip_address TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 11. ORDER_PRINTS (Thermal printer tracking)
CREATE TABLE IF NOT EXISTS order_prints (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  order_id UUID REFERENCES orders(id) ON DELETE SET NULL,
  printed_at TIMESTAMPTZ DEFAULT NOW(),
  print_count INT DEFAULT 1 CHECK (print_count > 0)
);

-- 12. NOTIFICATIONS — in-app + push history
CREATE TABLE IF NOT EXISTS notifications (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  title_ar TEXT NOT NULL,
  body_ar TEXT NOT NULL,
  type TEXT NOT NULL CHECK (type IN (
    'order_confirmed',
    'order_preparing',
    'order_out_for_delivery',
    'order_delivered',
    'order_cancelled',
    'new_order_admin',
    'order_cancelled_admin',
    'promotion',
    'system'
  )),
  reference_type TEXT,
  reference_id TEXT,
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_notifications_user_created
  ON notifications(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notifications_unread
  ON notifications(user_id, is_read) WHERE is_read = false;

-- 13. NOTIFICATION_PREFERENCES — per-user toggles
CREATE TABLE IF NOT EXISTS notification_preferences (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE UNIQUE,
  order_updates BOOLEAN DEFAULT true,
  promotions BOOLEAN DEFAULT true,
  push_enabled BOOLEAN DEFAULT true,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 14. DEVICE_TOKENS — FCM tokens per device
CREATE TABLE IF NOT EXISTS device_tokens (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  token TEXT NOT NULL,
  platform TEXT NOT NULL CHECK (platform IN ('android', 'ios')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, token)
);

CREATE INDEX IF NOT EXISTS idx_device_tokens_user ON device_tokens(user_id);

-- =============================================
-- ROW LEVEL SECURITY
-- =============================================

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE coupons ENABLE ROW LEVEL SECURITY;
ALTER TABLE delivery_zones ENABLE ROW LEVEL SECURITY;
ALTER TABLE business_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE product_options ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_prints ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE notification_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE device_tokens ENABLE ROW LEVEL SECURITY;

-- PROFILES policies
DROP POLICY IF EXISTS "Users can view own profile" ON profiles;
CREATE POLICY "Users can view own profile" ON profiles
  FOR SELECT USING (auth.uid() = id);

DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);

DROP POLICY IF EXISTS "Admin can view all profiles" ON profiles;
CREATE POLICY "Admin can view all profiles" ON profiles
  FOR ALL USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- CATEGORIES policies (public read, admin write)
DROP POLICY IF EXISTS "Anyone can view active categories" ON categories;
CREATE POLICY "Anyone can view active categories" ON categories
  FOR SELECT USING (is_active = true);

DROP POLICY IF EXISTS "Admin can manage categories" ON categories;
CREATE POLICY "Admin can manage categories" ON categories
  FOR ALL USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- PRODUCTS policies (public read, admin write)
DROP POLICY IF EXISTS "Anyone can view available products" ON products;
CREATE POLICY "Anyone can view available products" ON products
  FOR SELECT USING (is_available = true);

DROP POLICY IF EXISTS "Admin can manage products" ON products;
CREATE POLICY "Admin can manage products" ON products
  FOR ALL USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- ORDERS policies
DROP POLICY IF EXISTS "Customers can view own orders" ON orders;
CREATE POLICY "Customers can view own orders" ON orders
  FOR SELECT USING (customer_id = auth.uid());

DROP POLICY IF EXISTS "Customers can create orders" ON orders;
CREATE POLICY "Customers can create orders" ON orders
  FOR INSERT WITH CHECK (customer_id = auth.uid());

DROP POLICY IF EXISTS "Admin can view all orders" ON orders;
CREATE POLICY "Admin can view all orders" ON orders
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

DROP POLICY IF EXISTS "Admin can update orders" ON orders;
CREATE POLICY "Admin can update orders" ON orders
  FOR UPDATE USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- ORDER ITEMS policies
DROP POLICY IF EXISTS "Customers can view own order items" ON order_items;
CREATE POLICY "Customers can view own order items" ON order_items
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM orders WHERE id = order_id AND customer_id = auth.uid())
  );

DROP POLICY IF EXISTS "Customers can insert order items" ON order_items;
CREATE POLICY "Customers can insert order items" ON order_items
  FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM orders WHERE id = order_id AND customer_id = auth.uid())
  );

DROP POLICY IF EXISTS "Admin can view all order items" ON order_items;
CREATE POLICY "Admin can view all order items" ON order_items
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

DROP POLICY IF EXISTS "Admin can manage order items" ON order_items;
CREATE POLICY "Admin can manage order items" ON order_items
  FOR ALL USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- COUPONS policies (public read active, admin write)
DROP POLICY IF EXISTS "Anyone can view active coupons" ON coupons;
CREATE POLICY "Anyone can view active coupons" ON coupons
  FOR SELECT USING (is_active = true);

DROP POLICY IF EXISTS "Admin can manage coupons" ON coupons;
CREATE POLICY "Admin can manage coupons" ON coupons
  FOR ALL USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- DELIVERY_ZONES policies (public read active, admin write)
DROP POLICY IF EXISTS "Anyone can view active delivery zones" ON delivery_zones;
CREATE POLICY "Anyone can view active delivery zones" ON delivery_zones
  FOR SELECT USING (is_active = true);

DROP POLICY IF EXISTS "Admin can manage delivery zones" ON delivery_zones;
CREATE POLICY "Admin can manage delivery zones" ON delivery_zones
  FOR ALL USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- BUSINESS_PROFILES policies (admin read/write all, public read own or none)
DROP POLICY IF EXISTS "Anyone can view business profile" ON business_profiles;
CREATE POLICY "Anyone can view business profile" ON business_profiles
  FOR SELECT USING (true);

DROP POLICY IF EXISTS "Admin can manage business profile" ON business_profiles;
CREATE POLICY "Admin can manage business profile" ON business_profiles
  FOR ALL USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- PRODUCT_OPTIONS policies (public read, admin write)
DROP POLICY IF EXISTS "Anyone can view product options" ON product_options;
CREATE POLICY "Anyone can view product options" ON product_options
  FOR SELECT USING (true);

DROP POLICY IF EXISTS "Admin can manage product options" ON product_options;
CREATE POLICY "Admin can manage product options" ON product_options
  FOR ALL USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- AUDIT_LOGS policies (admin only)
DROP POLICY IF EXISTS "Admin can view audit logs" ON audit_logs;
CREATE POLICY "Admin can view audit logs" ON audit_logs
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

DROP POLICY IF EXISTS "Admin can insert audit logs" ON audit_logs;
CREATE POLICY "Admin can insert audit logs" ON audit_logs
  FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- ORDER_PRINTS policies (admin only)
DROP POLICY IF EXISTS "Admin can view order prints" ON order_prints;
CREATE POLICY "Admin can view order prints" ON order_prints
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

DROP POLICY IF EXISTS "Admin can manage order prints" ON order_prints;
CREATE POLICY "Admin can manage order prints" ON order_prints
  FOR ALL USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- NOTIFICATIONS policies
DROP POLICY IF EXISTS "Users can view own notifications" ON notifications;
CREATE POLICY "Users can view own notifications" ON notifications
  FOR SELECT USING (user_id = auth.uid());

DROP POLICY IF EXISTS "Users can update own notifications" ON notifications;
CREATE POLICY "Users can update own notifications" ON notifications
  FOR UPDATE USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS "Admins can view all notifications" ON notifications;
CREATE POLICY "Admins can view all notifications" ON notifications
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- Server-side writes (via service role) bypass RLS, so we do NOT need
-- an INSERT policy for the client. If the client ever needs to insert
-- directly, add:
--   CREATE POLICY "Users can insert own notifications" ON notifications
--     FOR INSERT WITH CHECK (user_id = auth.uid());

-- NOTIFICATION_PREFERENCES policies
DROP POLICY IF EXISTS "Users can view own notification preferences" ON notification_preferences;
CREATE POLICY "Users can view own notification preferences" ON notification_preferences
  FOR SELECT USING (user_id = auth.uid());

DROP POLICY IF EXISTS "Users can update own notification preferences" ON notification_preferences;
CREATE POLICY "Users can update own notification preferences" ON notification_preferences
  FOR UPDATE USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS "Users can insert own notification preferences" ON notification_preferences;
CREATE POLICY "Users can insert own notification preferences" ON notification_preferences
  FOR INSERT WITH CHECK (user_id = auth.uid());

-- DEVICE_TOKENS policies
DROP POLICY IF EXISTS "Users can view own device tokens" ON device_tokens;
CREATE POLICY "Users can view own device tokens" ON device_tokens
  FOR SELECT USING (user_id = auth.uid());

DROP POLICY IF EXISTS "Users can insert own device tokens" ON device_tokens;
CREATE POLICY "Users can insert own device tokens" ON device_tokens
  FOR INSERT WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS "Users can delete own device tokens" ON device_tokens;
CREATE POLICY "Users can delete own device tokens" ON device_tokens
  FOR DELETE USING (user_id = auth.uid());

-- =============================================
-- FUNCTIONS & TRIGGERS
-- =============================================

-- Auto-create profile on signup
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO profiles (id, name, role)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'name', ''),
    COALESCE(NEW.raw_user_meta_data->>'role', 'customer')
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- Auto-update orders.updated_at
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS orders_updated_at ON orders;
CREATE TRIGGER orders_updated_at
  BEFORE UPDATE ON orders
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Auto-update business_profiles.updated_at
DROP TRIGGER IF EXISTS business_profiles_updated_at ON business_profiles;
CREATE TRIGGER business_profiles_updated_at
  BEFORE UPDATE ON business_profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Auto-update notification_preferences.updated_at
DROP TRIGGER IF EXISTS notification_preferences_updated_at ON notification_preferences;
CREATE TRIGGER notification_preferences_updated_at
  BEFORE UPDATE ON notification_preferences
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Auto-create default notification_preferences on profile creation
CREATE OR REPLACE FUNCTION handle_new_notification_preferences()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO notification_preferences (user_id)
  VALUES (NEW.id)
  ON CONFLICT (user_id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_profile_created_notification_prefs ON profiles;
CREATE TRIGGER on_profile_created_notification_prefs
  AFTER INSERT ON profiles
  FOR EACH ROW EXECUTE FUNCTION handle_new_notification_preferences();

-- Auto-notify customer on order status change
CREATE OR REPLACE FUNCTION notify_order_status_change()
RETURNS TRIGGER AS $$
DECLARE
  v_title text;
  v_body text;
BEGIN
  IF OLD.status IS NOT DISTINCT FROM NEW.status THEN
    RETURN NEW;
  END IF;

  CASE NEW.status
    WHEN 'confirmed' THEN
      v_title := 'تم تأكيد طلبك';
      v_body := 'طلبك رقم #' || LEFT(NEW.id::text, 8) || ' تم تأكيده وجاري التجهيز';
    WHEN 'preparing' THEN
      v_title := 'جاري تجهيز طلبك';
      v_body := 'المطبخ بيحضر طلبك رقم #' || LEFT(NEW.id::text, 8);
    WHEN 'ready' THEN
      v_title := 'طلبك جاهز';
      IF NEW.order_type = 'pickup' THEN
        v_body := 'طلبك رقم #' || LEFT(NEW.id::text, 8) || ' جاهز للاستلام في المطعم';
      ELSE
        v_body := 'طلبك رقم #' || LEFT(NEW.id::text, 8) || ' جاهز وجاري تسليمه للدليفري';
      END IF;
    WHEN 'out_for_delivery' THEN
      v_title := 'طلبك في الطريق';
      v_body := 'الدليفري في طريقه ليك بطلب رقم #' || LEFT(NEW.id::text, 8);
    WHEN 'delivered' THEN
      v_title := 'تم توصيل طلبك';
      v_body := 'نتمنى تكون استمتعت بطلبك رقم #' || LEFT(NEW.id::text, 8);
    WHEN 'cancelled' THEN
      v_title := 'تم إلغاء الطلب';
      v_body := 'تم إلغاء طلبك رقم #' || LEFT(NEW.id::text, 8);
    ELSE
      RETURN NEW;
  END CASE;

  INSERT INTO notifications (user_id, title_ar, body_ar, type, reference_type, reference_id)
  VALUES (
    NEW.customer_id,
    v_title,
    v_body,
    'order_' || NEW.status,
    'order',
    NEW.id::text
  );

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS orders_status_change_notify ON orders;
CREATE TRIGGER orders_status_change_notify
  AFTER UPDATE OF status ON orders
  FOR EACH ROW EXECUTE FUNCTION notify_order_status_change();

-- Auto-notify all admins on new order
CREATE OR REPLACE FUNCTION notify_admins_new_order()
RETURNS TRIGGER AS $$
DECLARE
  admin_record RECORD;
  v_body text;
BEGIN
  v_body := COALESCE(NEW.customer_name, 'عميل') || ' — ' ||
            NEW.total_amount::text || ' جنيه';

  FOR admin_record IN
    SELECT id FROM profiles WHERE role = 'admin'
  LOOP
    INSERT INTO notifications (user_id, title_ar, body_ar, type, reference_type, reference_id)
    VALUES (
      admin_record.id,
      'طلب جديد! #' || LEFT(NEW.id::text, 8),
      v_body,
      'new_order_admin',
      'order',
      NEW.id::text
    );
  END LOOP;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS orders_new_notify_admins ON orders;
CREATE TRIGGER orders_new_notify_admins
  AFTER INSERT ON orders
  FOR EACH ROW EXECUTE FUNCTION notify_admins_new_order();

-- Auto-notify all admins on customer cancellation
CREATE OR REPLACE FUNCTION notify_admins_order_cancelled()
RETURNS TRIGGER AS $$
DECLARE
  admin_record RECORD;
BEGIN
  IF NEW.status <> 'cancelled' THEN
    RETURN NEW;
  END IF;
  IF OLD.status IS NOT DISTINCT FROM NEW.status THEN
    RETURN NEW;
  END IF;

  FOR admin_record IN
    SELECT id FROM profiles WHERE role = 'admin'
  LOOP
    INSERT INTO notifications (user_id, title_ar, body_ar, type, reference_type, reference_id)
    VALUES (
      admin_record.id,
      'تم إلغاء طلب',
      'العميل ' || COALESCE(NEW.customer_name, '') ||
        ' ألغى طلب رقم #' || LEFT(NEW.id::text, 8),
      'order_cancelled_admin',
      'order',
      NEW.id::text
    );
  END LOOP;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS orders_cancelled_notify_admins ON orders;
CREATE TRIGGER orders_cancelled_notify_admins
  AFTER UPDATE OF status ON orders
  FOR EACH ROW EXECUTE FUNCTION notify_admins_order_cancelled();

-- Invoke send-notification Edge Function on every INSERT into notifications
-- Requires pg_net (pre-installed in Supabase projects)
CREATE EXTENSION IF NOT EXISTS pg_net;

CREATE OR REPLACE FUNCTION invoke_send_notification()
RETURNS TRIGGER AS $$
DECLARE
  v_url text;
  v_request_id bigint;
BEGIN
  v_url := current_setting('app.settings.supabase_functions_url', true)
           || '/send-notification';

  IF v_url IS NULL OR v_url = '/send-notification' THEN
    v_url := 'https://' ||
             (SELECT setting FROM pg_settings WHERE name = 'cluster_name') ||
             '.functions.supabase.co/send-notification';
  END IF;

  SELECT net.http_post(
    url := v_url,
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer ' || current_setting('app.settings.service_role_key', true)
    ),
    body := jsonb_build_object(
      'type', 'INSERT',
      'table', 'notifications',
      'record', row_to_json(NEW)
    )
  ) INTO v_request_id;

  RAISE LOG '[invoke_send_notification] dispatched request % for notification %',
    v_request_id, NEW.id;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS notifications_invoke_send ON notifications;
CREATE TRIGGER notifications_invoke_send
  AFTER INSERT ON notifications
  FOR EACH ROW EXECUTE FUNCTION invoke_send_notification();

-- =============================================
-- SEED DATA (Sample Menu)
-- =============================================

INSERT INTO categories (name, name_ar, sort_order) VALUES
  ('Main Dishes', 'الأكلات الرئيسية', 1),
  ('Grills', 'مشويات', 2),
  ('Sandwiches', 'سندوتشات', 3),
  ('Drinks', 'مشروبات', 4),
  ('Desserts', 'حلويات', 5)
ON CONFLICT DO NOTHING;

-- =============================================
-- REALTIME (enable for all admin tables)
-- =============================================
-- Run in Supabase Dashboard: Realtime > Tables > Enable each table
-- Or via SQL below:

ALTER PUBLICATION supabase_realtime ADD TABLE orders;
ALTER PUBLICATION supabase_realtime ADD TABLE categories;
ALTER PUBLICATION supabase_realtime ADD TABLE products;
ALTER PUBLICATION supabase_realtime ADD TABLE coupons;
ALTER PUBLICATION supabase_realtime ADD TABLE delivery_zones;
ALTER PUBLICATION supabase_realtime ADD TABLE business_profiles;
ALTER PUBLICATION supabase_realtime ADD TABLE notifications;
ALTER PUBLICATION supabase_realtime ADD TABLE device_tokens;