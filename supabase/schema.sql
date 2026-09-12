-- =============================================
-- ترويئه (Tarwi2a) - Complete Database Schema
-- Fresh database bootstrap only; then apply release_security_guards migration.
-- Existing projects must use reviewed forward migrations, not this bootstrap.
-- Last Updated: 2026-09-12
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
  delivery_zone_id UUID,
  delivery_zone_name TEXT,
  order_type TEXT DEFAULT 'delivery' CHECK (order_type IN ('delivery', 'pickup', 'dine_in')),
  address_id UUID,
  coupon_id UUID,
  scheduled_for TIMESTAMPTZ,
  request_id TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT uq_orders_customer_request_id UNIQUE (customer_id, request_id)
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
-- delivery_zones must exist before the orders foreign key can be created.
ALTER TABLE orders DROP CONSTRAINT IF EXISTS orders_delivery_zone_id_fkey;
ALTER TABLE orders ADD CONSTRAINT orders_delivery_zone_id_fkey
  FOREIGN KEY (delivery_zone_id) REFERENCES delivery_zones(id) ON DELETE SET NULL;

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

-- 15. ADDRESSES — Saved customer delivery addresses
CREATE TABLE IF NOT EXISTS addresses (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  label TEXT NOT NULL,
  address TEXT NOT NULL,
  latitude DOUBLE PRECISION,
  longitude DOUBLE PRECISION,
  building TEXT,
  floor TEXT,
  apartment TEXT,
  notes TEXT,
  is_default BOOLEAN DEFAULT false,
  delivery_zone_id UUID REFERENCES delivery_zones(id) ON DELETE SET NULL,
  delivery_zone_name TEXT,
  delivery_fee DECIMAL(10,2) DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_addresses_user ON addresses(user_id);

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
ALTER TABLE addresses ENABLE ROW LEVEL SECURITY;

-- Helper: Non-recursive is_admin()
CREATE OR REPLACE FUNCTION is_admin()
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
SET search_path = public, pg_temp
STABLE
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND role = 'admin'
  );
$$;

REVOKE EXECUTE ON FUNCTION is_admin() FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION is_admin() FROM anon;
GRANT EXECUTE ON FUNCTION is_admin() TO authenticated, service_role;

-- Column-level grants: authenticated clients may only update self-service columns
REVOKE UPDATE ON profiles FROM authenticated;
GRANT UPDATE (name, phone) ON profiles TO authenticated;

-- Admin-only server function for updating user roles
CREATE OR REPLACE FUNCTION admin_update_user_role(target_user_id uuid, new_role text)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
  IF NOT is_admin() THEN
    RAISE EXCEPTION 'Access denied: caller is not an admin';
  END IF;

  IF new_role NOT IN ('customer', 'admin') THEN
    RAISE EXCEPTION 'Invalid role: %', new_role;
  END IF;

  UPDATE public.profiles
  SET role = new_role
  WHERE id = target_user_id;
END;
$$;

REVOKE EXECUTE ON FUNCTION admin_update_user_role(uuid, text) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION admin_update_user_role(uuid, text) FROM anon;
GRANT EXECUTE ON FUNCTION admin_update_user_role(uuid, text) TO authenticated, service_role;

-- PROFILES policies
DROP POLICY IF EXISTS "Users can view own profile" ON profiles;
CREATE POLICY "Users can view own profile" ON profiles
  FOR SELECT USING (auth.uid() = id);

DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "Admin can view all profiles" ON profiles;
DROP POLICY IF EXISTS "Admins can view all profiles" ON profiles;
CREATE POLICY "Admins can view all profiles" ON profiles
  FOR SELECT USING (is_admin());

DROP POLICY IF EXISTS "Admins can manage profiles" ON profiles;
CREATE POLICY "Admins can manage profiles" ON profiles
  FOR ALL USING (is_admin());

-- CATEGORIES policies (public read, admin write)
DROP POLICY IF EXISTS "Anyone can view active categories" ON categories;
CREATE POLICY "Anyone can view active categories" ON categories
  FOR SELECT USING (is_active = true OR is_admin());

DROP POLICY IF EXISTS "Admin can manage categories" ON categories;
DROP POLICY IF EXISTS "Admins can manage categories" ON categories;
CREATE POLICY "Admins can manage categories" ON categories
  FOR ALL USING (is_admin());

-- PRODUCTS policies (public read, admin write)
DROP POLICY IF EXISTS "Anyone can view available products" ON products;
CREATE POLICY "Anyone can view available products" ON products
  FOR SELECT USING (is_available = true OR is_admin());

DROP POLICY IF EXISTS "Admin can manage products" ON products;
DROP POLICY IF EXISTS "Admins can manage products" ON products;
CREATE POLICY "Admins can manage products" ON products
  FOR ALL USING (is_admin());

-- ORDERS policies
DROP POLICY IF EXISTS "Customers can view own orders" ON orders;
CREATE POLICY "Customers can view own orders" ON orders
  FOR SELECT USING (customer_id = auth.uid() OR is_admin());

DROP POLICY IF EXISTS "Customers can create orders" ON orders;
CREATE POLICY "Customers can create orders" ON orders
  FOR INSERT WITH CHECK (customer_id = auth.uid());

DROP POLICY IF EXISTS "Admin can view all orders" ON orders;
DROP POLICY IF EXISTS "Admin can update orders" ON orders;
DROP POLICY IF EXISTS "Admins can view all orders" ON orders;
DROP POLICY IF EXISTS "Admins can update orders" ON orders;
CREATE POLICY "Admins can update orders" ON orders
  FOR UPDATE USING (is_admin());

DROP POLICY IF EXISTS "Admins can delete orders" ON orders;
CREATE POLICY "Admins can delete orders" ON orders
  FOR DELETE USING (is_admin());

-- ORDER ITEMS policies
DROP POLICY IF EXISTS "Customers can view own order items" ON order_items;
CREATE POLICY "Customers can view own order items" ON order_items
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM orders
      WHERE id = order_id AND (customer_id = auth.uid() OR is_admin())
    )
  );

DROP POLICY IF EXISTS "Customers can insert order items" ON order_items;
CREATE POLICY "Customers can insert order items" ON order_items
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM orders
      WHERE id = order_id AND customer_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Admin can view all order items" ON order_items;
DROP POLICY IF EXISTS "Admin can manage order items" ON order_items;
DROP POLICY IF EXISTS "Admins can manage order items" ON order_items;
CREATE POLICY "Admins can manage order items" ON order_items
  FOR ALL USING (is_admin());

-- COUPONS policies (public read active, admin write)
DROP POLICY IF EXISTS "Anyone can view active coupons" ON coupons;
CREATE POLICY "Anyone can view active coupons" ON coupons
  FOR SELECT USING (is_active = true OR is_admin());

DROP POLICY IF EXISTS "Admin can manage coupons" ON coupons;
DROP POLICY IF EXISTS "Admins can manage coupons" ON coupons;
CREATE POLICY "Admins can manage coupons" ON coupons
  FOR ALL USING (is_admin());

-- DELIVERY_ZONES policies (public read active, admin write)
DROP POLICY IF EXISTS "Anyone can view active delivery zones" ON delivery_zones;
CREATE POLICY "Anyone can view active delivery zones" ON delivery_zones
  FOR SELECT USING (is_active = true OR is_admin());

DROP POLICY IF EXISTS "Admin can manage delivery zones" ON delivery_zones;
DROP POLICY IF EXISTS "Admins can manage delivery zones" ON delivery_zones;
CREATE POLICY "Admins can manage delivery zones" ON delivery_zones
  FOR ALL USING (is_admin());

-- BUSINESS_PROFILES policies (admin read/write all, public read own or none)
DROP POLICY IF EXISTS "Anyone can view business profile" ON business_profiles;
CREATE POLICY "Anyone can view business profile" ON business_profiles
  FOR SELECT USING (true);

DROP POLICY IF EXISTS "Admin can manage business profile" ON business_profiles;
DROP POLICY IF EXISTS "Admins can manage business profile" ON business_profiles;
CREATE POLICY "Admins can manage business profile" ON business_profiles
  FOR ALL USING (is_admin());

-- PRODUCT_OPTIONS policies (public read, admin write)
DROP POLICY IF EXISTS "Anyone can view product options" ON product_options;
CREATE POLICY "Anyone can view product options" ON product_options
  FOR SELECT USING (true);

DROP POLICY IF EXISTS "Admin can manage product options" ON product_options;
DROP POLICY IF EXISTS "Admins can manage product options" ON product_options;
CREATE POLICY "Admins can manage product options" ON product_options
  FOR ALL USING (is_admin());

-- AUDIT_LOGS policies (admin only)
DROP POLICY IF EXISTS "Admin can view audit logs" ON audit_logs;
DROP POLICY IF EXISTS "Admin can insert audit logs" ON audit_logs;
DROP POLICY IF EXISTS "Admins can view audit logs" ON audit_logs;
DROP POLICY IF EXISTS "Admins can insert audit logs" ON audit_logs;
CREATE POLICY "Admins can view audit logs" ON audit_logs
  FOR SELECT USING (is_admin());

CREATE POLICY "Admins can insert audit logs" ON audit_logs
  FOR INSERT WITH CHECK (is_admin());

-- ORDER_PRINTS policies (admin only)
DROP POLICY IF EXISTS "Admin can view order prints" ON order_prints;
DROP POLICY IF EXISTS "Admin can manage order prints" ON order_prints;
DROP POLICY IF EXISTS "Admins can view order prints" ON order_prints;
DROP POLICY IF EXISTS "Admins can manage order prints" ON order_prints;
CREATE POLICY "Admins can view order prints" ON order_prints
  FOR SELECT USING (is_admin());

CREATE POLICY "Admins can manage order prints" ON order_prints
  FOR ALL USING (is_admin());

-- NOTIFICATIONS policies
DROP POLICY IF EXISTS "Users can view own notifications" ON notifications;
CREATE POLICY "Users can view own notifications" ON notifications
  FOR SELECT USING (user_id = auth.uid() OR is_admin());

DROP POLICY IF EXISTS "Users can update own notifications" ON notifications;
CREATE POLICY "Users can update own notifications" ON notifications
  FOR UPDATE USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS "Admins can view all notifications" ON notifications;
DROP POLICY IF EXISTS "Admins can insert notifications" ON notifications;
CREATE POLICY "Admins can insert notifications" ON notifications
  FOR INSERT WITH CHECK (is_admin());

DROP POLICY IF EXISTS "Users or admins can delete notifications" ON notifications;
CREATE POLICY "Users or admins can delete notifications" ON notifications
  FOR DELETE USING (user_id = auth.uid() OR is_admin());

-- NOTIFICATION_PREFERENCES policies
DROP POLICY IF EXISTS "Users can view own notification preferences" ON notification_preferences;
CREATE POLICY "Users can view own notification preferences" ON notification_preferences
  FOR SELECT USING (user_id = auth.uid() OR is_admin());

DROP POLICY IF EXISTS "Users can update own notification preferences" ON notification_preferences;
CREATE POLICY "Users can update own notification preferences" ON notification_preferences
  FOR UPDATE USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- DEVICE_TOKENS policies
DROP POLICY IF EXISTS "Users can view own device tokens" ON device_tokens;
CREATE POLICY "Users can view own device tokens" ON device_tokens
  FOR SELECT USING (user_id = auth.uid());

DROP POLICY IF EXISTS "Users can insert own device tokens" ON device_tokens;
CREATE POLICY "Users can insert own device tokens" ON device_tokens
  FOR INSERT WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS "Users can update own device tokens" ON device_tokens;
CREATE POLICY "Users can update own device tokens" ON device_tokens
  FOR UPDATE USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS "Users can delete own device tokens" ON device_tokens;
CREATE POLICY "Users can delete own device tokens" ON device_tokens
  FOR DELETE USING (user_id = auth.uid());

-- ADDRESSES policies
DROP POLICY IF EXISTS "Users can view own addresses" ON addresses;
CREATE POLICY "Users can view own addresses" ON addresses
  FOR SELECT USING (user_id = auth.uid() OR is_admin());

DROP POLICY IF EXISTS "Users can insert own addresses" ON addresses;
CREATE POLICY "Users can insert own addresses" ON addresses
  FOR INSERT WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS "Users can update own addresses" ON addresses;
CREATE POLICY "Users can update own addresses" ON addresses
  FOR UPDATE USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS "Users can delete own addresses" ON addresses;
CREATE POLICY "Users can delete own addresses" ON addresses
  FOR DELETE USING (user_id = auth.uid() OR is_admin());

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
    'customer'
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp;

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
-- App Configuration (non-secret settings only; restricted from client access)
CREATE TABLE IF NOT EXISTS app_config (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL
);

ALTER TABLE app_config ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON app_config FROM PUBLIC, anon, authenticated;

CREATE EXTENSION IF NOT EXISTS pg_net;

CREATE OR REPLACE FUNCTION invoke_send_notification()
RETURNS TRIGGER AS $$
DECLARE
  v_url text;
  v_request_id bigint;
  v_service_key text;
BEGIN
  SELECT value INTO v_url FROM app_config WHERE key = 'supabase_functions_url';
  IF v_url IS NULL OR v_url = '' THEN
    v_url := current_setting('app.settings.supabase_functions_url', true)
             || '/send-notification';
  ELSE
    v_url := v_url || '/send-notification';
  END IF;

  IF v_url IS NULL OR v_url = '/send-notification' THEN
    v_url := 'https://' ||
             (SELECT setting FROM pg_settings WHERE name = 'cluster_name') ||
             '.functions.supabase.co/send-notification';
  END IF;

  v_service_key := current_setting('app.settings.service_role_key', true);
  IF v_service_key IS NULL OR v_service_key = '' THEN
    RAISE WARNING '[invoke_send_notification] service_role_key not configured — notification push skipped for %', NEW.id;
    RETURN NEW;
  END IF;

  SELECT net.http_post(
    url := v_url,
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer ' || v_service_key
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
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp;

DROP TRIGGER IF EXISTS notifications_invoke_send ON notifications;
CREATE TRIGGER notifications_invoke_send
  AFTER INSERT ON notifications
  FOR EACH ROW EXECUTE FUNCTION invoke_send_notification();

-- =============================================
-- AUTHORITATIVE ORDER CREATION RPC
-- =============================================

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

  v_order_items_buffer JSONB := '[]'::JSONB;
BEGIN
  v_customer_id := auth.uid();
  IF v_customer_id IS NULL THEN
    RAISE EXCEPTION 'Unauthorized: User must be authenticated to place an order';
  END IF;

  v_request_id := trim(p_payload->>'request_id');
  IF v_request_id IS NULL OR v_request_id = '' THEN
    RAISE EXCEPTION 'Bad request: request_id (idempotency key) is required';
  END IF;

  SELECT id INTO v_existing_order_id
  FROM public.orders
  WHERE customer_id = v_customer_id AND request_id = v_request_id;

  IF v_existing_order_id IS NOT NULL THEN
    RETURN v_existing_order_id;
  END IF;

  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'business_profiles') THEN
    SELECT accept_orders, min_order INTO v_accept_orders, v_min_order
    FROM public.business_profiles
    LIMIT 1;

    IF v_accept_orders IS FALSE THEN
      RAISE EXCEPTION 'المطعم لا يستقبل طلبات حالياً';
    END IF;
  END IF;

  v_items := p_payload->'items';
  IF v_items IS NULL OR jsonb_typeof(v_items) <> 'array' OR jsonb_array_length(v_items) = 0 THEN
    RAISE EXCEPTION 'السلة فارغة، لا يمكن إتمام الطلب بدون منتجات';
  END IF;

  SELECT name, phone INTO v_customer_name, v_customer_phone
  FROM public.profiles
  WHERE id = v_customer_id;

  IF v_customer_name IS NULL OR trim(v_customer_name) = '' THEN
    v_customer_name := COALESCE(trim(p_payload->>'customer_name'), 'عميل');
  END IF;
  IF v_customer_phone IS NULL OR trim(v_customer_phone) = '' THEN
    v_customer_phone := COALESCE(trim(p_payload->>'customer_phone'), '');
  END IF;

  v_order_type := COALESCE(p_payload->>'order_type', 'delivery');
  IF v_order_type NOT IN ('delivery', 'pickup', 'dine_in') THEN
    RAISE EXCEPTION 'نوع الطلب غير صالح: %', v_order_type;
  END IF;

  IF v_order_type = 'delivery' THEN
    v_address_id := (p_payload->>'address_id')::UUID;
    IF v_address_id IS NULL THEN
      RAISE EXCEPTION 'يجب تحديد عنوان صالح للتوصيل';
    END IF;

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
    v_address_id := NULL;
    v_cust_address := NULL;
    v_zone_id := NULL;
    v_zone_name := NULL;
    v_delivery_fee := 0;
  END IF;

  v_payment_method := p_payload->>'payment_method';
  IF v_payment_method NOT IN ('cash', 'wallet', 'instapay') THEN
    RAISE EXCEPTION 'طريقة الدفع غير صالحة: %', v_payment_method;
  END IF;

  IF (p_payload->>'scheduled_for') IS NOT NULL AND trim(p_payload->>'scheduled_for') <> '' THEN
    v_scheduled_for := (p_payload->>'scheduled_for')::TIMESTAMPTZ;
    IF v_scheduled_for <= NOW() THEN
      RAISE EXCEPTION 'وقت الطلب المجدول يجب أن يكون في المستقبل';
    END IF;
  END IF;

  v_notes := trim(p_payload->>'notes');

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

    v_order_items_buffer := v_order_items_buffer || jsonb_build_object(
      'product_id', v_product_id,
      'product_name', v_product_name,
      'product_price', v_item_unit_price,
      'quantity', v_qty,
      'subtotal', v_item_subtotal,
      'selected_options', v_selected_options
    );
  END LOOP;

  IF v_min_order IS NOT NULL AND v_min_order > 0 AND v_subtotal < v_min_order THEN
    RAISE EXCEPTION 'الحد الأدنى للطلب هو % جنيه (المجموع الحالي % جنيه)', v_min_order, v_subtotal;
  END IF;

  IF (p_payload->>'coupon_id') IS NOT NULL AND trim(p_payload->>'coupon_id') <> '' THEN
    v_coupon_id := (p_payload->>'coupon_id')::UUID;
  END IF;
  v_coupon_code := trim(p_payload->>'coupon_code');

  IF v_coupon_id IS NOT NULL OR (v_coupon_code IS NOT NULL AND v_coupon_code <> '') THEN
    SELECT id, code, type, value, min_order, max_discount, max_uses, used_count, is_active, start_date, end_date
    INTO v_coupon
    FROM public.coupons
    WHERE (id = v_coupon_id OR (v_coupon_code IS NOT NULL AND UPPER(code) = UPPER(v_coupon_code)))
    FOR UPDATE;

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

    UPDATE public.coupons SET used_count = used_count + 1 WHERE id = v_coupon.id;
    v_coupon_id := v_coupon.id;
  END IF;

  v_total_amount := round(v_subtotal - v_discount_amount + v_delivery_fee, 2);
  IF v_total_amount < 0 THEN
    v_total_amount := 0;
  END IF;

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

REVOKE EXECUTE ON FUNCTION create_authoritative_order(JSONB) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION create_authoritative_order(JSONB) FROM anon;
GRANT EXECUTE ON FUNCTION create_authoritative_order(JSONB) TO authenticated, service_role;

-- Account Deletion / Data Anonymization
CREATE OR REPLACE FUNCTION delete_user_account_data(p_user_id UUID)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
  -- 1. Anonymize orders to comply with financial retention while stripping PII
  UPDATE public.orders
  SET
    customer_name = 'مستخدم محذوف',
    customer_phone = 'محذوف',
    customer_address = NULL,
    notes = NULL,
    payment_proof_url = NULL,
    address_id = NULL
  WHERE customer_id = p_user_id;

  -- 2. Delete user addresses
  DELETE FROM public.addresses WHERE user_id = p_user_id;

  -- 3. Delete user device tokens
  DELETE FROM public.device_tokens WHERE user_id = p_user_id;

  -- 4. Delete user notifications
  DELETE FROM public.notifications WHERE user_id = p_user_id;

  -- 5. Delete notification preferences
  DELETE FROM public.notification_preferences WHERE user_id = p_user_id;

  -- 6. Delete ratings & reviews
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'order_ratings') THEN
    DELETE FROM public.order_ratings WHERE customer_id = p_user_id;
  END IF;

  -- 7. Delete profile row (if not already cascaded)
  DELETE FROM public.profiles WHERE id = p_user_id;
END;
$$;

REVOKE EXECUTE ON FUNCTION delete_user_account_data(UUID) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION delete_user_account_data(UUID) TO postgres, service_role;

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
