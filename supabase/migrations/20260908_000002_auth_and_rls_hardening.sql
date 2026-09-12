-- Migration: 20260908_000002_auth_and_rls_hardening.sql
-- Description: Server authorization hardening: roles, profiles, non-recursive is_admin helper, column-level grants, and table RLS audit.

-- ============================================================
-- 1. Helper: Non-recursive is_admin()
-- ============================================================
-- Must be SECURITY DEFINER to bypass profiles RLS and avoid infinite recursion
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

-- ============================================================
-- 2. Close Role Escalation on Profiles
-- ============================================================
-- Hardcode role to 'customer' on signup; ignore user metadata
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, name, role)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'name', ''),
    'customer'
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp;

-- Column-level grants: authenticated clients may only update self-service columns
REVOKE UPDATE ON public.profiles FROM authenticated;
GRANT UPDATE (name, phone) ON public.profiles TO authenticated;

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

-- ============================================================
-- 3. Profiles Policies (non-recursive)
-- ============================================================
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own profile" ON public.profiles;
CREATE POLICY "Users can view own profile" ON public.profiles
  FOR SELECT USING (auth.uid() = id);

DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
CREATE POLICY "Users can update own profile" ON public.profiles
  FOR UPDATE USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "Admin can view all profiles" ON public.profiles;
DROP POLICY IF EXISTS "Admins can view all profiles" ON public.profiles;
CREATE POLICY "Admins can view all profiles" ON public.profiles
  FOR SELECT USING (is_admin());

DROP POLICY IF EXISTS "Admins can manage profiles" ON public.profiles;
CREATE POLICY "Admins can manage profiles" ON public.profiles
  FOR ALL USING (is_admin());

-- ============================================================
-- 4. Categories & Products & Options Policies
-- ============================================================
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Anyone can view active categories" ON public.categories;
CREATE POLICY "Anyone can view active categories" ON public.categories
  FOR SELECT USING (is_active = true OR is_admin());

DROP POLICY IF EXISTS "Admin can manage categories" ON public.categories;
DROP POLICY IF EXISTS "Admins can manage categories" ON public.categories;
CREATE POLICY "Admins can manage categories" ON public.categories
  FOR ALL USING (is_admin());

ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Anyone can view available products" ON public.products;
CREATE POLICY "Anyone can view available products" ON public.products
  FOR SELECT USING (is_available = true OR is_admin());

DROP POLICY IF EXISTS "Admin can manage products" ON public.products;
DROP POLICY IF EXISTS "Admins can manage products" ON public.products;
CREATE POLICY "Admins can manage products" ON public.products
  FOR ALL USING (is_admin());

ALTER TABLE public.product_options ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Anyone can view product options" ON public.product_options;
CREATE POLICY "Anyone can view product options" ON public.product_options
  FOR SELECT USING (true);

DROP POLICY IF EXISTS "Admin can manage product options" ON public.product_options;
DROP POLICY IF EXISTS "Admins can manage product options" ON public.product_options;
CREATE POLICY "Admins can manage product options" ON public.product_options
  FOR ALL USING (is_admin());

-- ============================================================
-- 5. Orders & Order Items Policies
-- ============================================================
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Customers can view own orders" ON public.orders;
CREATE POLICY "Customers can view own orders" ON public.orders
  FOR SELECT USING (customer_id = auth.uid() OR is_admin());

DROP POLICY IF EXISTS "Customers can create orders" ON public.orders;
CREATE POLICY "Customers can create orders" ON public.orders
  FOR INSERT WITH CHECK (customer_id = auth.uid());

DROP POLICY IF EXISTS "Admin can view all orders" ON public.orders;
DROP POLICY IF EXISTS "Admin can update orders" ON public.orders;
DROP POLICY IF EXISTS "Admins can view all orders" ON public.orders;
DROP POLICY IF EXISTS "Admins can update orders" ON public.orders;
CREATE POLICY "Admins can update orders" ON public.orders
  FOR UPDATE USING (is_admin());

DROP POLICY IF EXISTS "Admins can delete orders" ON public.orders;
CREATE POLICY "Admins can delete orders" ON public.orders
  FOR DELETE USING (is_admin());

ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Customers can view own order items" ON public.order_items;
CREATE POLICY "Customers can view own order items" ON public.order_items
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.orders
      WHERE id = order_items.order_id
        AND (customer_id = auth.uid() OR is_admin())
    )
  );

DROP POLICY IF EXISTS "Customers can insert order items" ON public.order_items;
CREATE POLICY "Customers can insert order items" ON public.order_items
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.orders
      WHERE id = order_items.order_id
        AND customer_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Admin can view all order items" ON public.order_items;
DROP POLICY IF EXISTS "Admin can manage order items" ON public.order_items;
DROP POLICY IF EXISTS "Admins can manage order items" ON public.order_items;
CREATE POLICY "Admins can manage order items" ON public.order_items
  FOR ALL USING (is_admin());

-- ============================================================
-- 6. Coupons & Delivery Zones & Business Profiles
-- ============================================================
ALTER TABLE public.coupons ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Anyone can view active coupons" ON public.coupons;
CREATE POLICY "Anyone can view active coupons" ON public.coupons
  FOR SELECT USING (is_active = true OR is_admin());

DROP POLICY IF EXISTS "Admin can manage coupons" ON public.coupons;
DROP POLICY IF EXISTS "Admins can manage coupons" ON public.coupons;
CREATE POLICY "Admins can manage coupons" ON public.coupons
  FOR ALL USING (is_admin());

ALTER TABLE public.delivery_zones ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Anyone can view active delivery zones" ON public.delivery_zones;
CREATE POLICY "Anyone can view active delivery zones" ON public.delivery_zones
  FOR SELECT USING (is_active = true OR is_admin());

DROP POLICY IF EXISTS "Admin can manage delivery zones" ON public.delivery_zones;
DROP POLICY IF EXISTS "Admins can manage delivery zones" ON public.delivery_zones;
CREATE POLICY "Admins can manage delivery zones" ON public.delivery_zones
  FOR ALL USING (is_admin());

ALTER TABLE public.business_profiles ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Anyone can view business profile" ON public.business_profiles;
CREATE POLICY "Anyone can view business profile" ON public.business_profiles
  FOR SELECT USING (true);

DROP POLICY IF EXISTS "Admin can manage business profile" ON public.business_profiles;
DROP POLICY IF EXISTS "Admins can manage business profile" ON public.business_profiles;
CREATE POLICY "Admins can manage business profile" ON public.business_profiles
  FOR ALL USING (is_admin());

-- ============================================================
-- 7. Audit Logs & Order Prints
-- ============================================================
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Admin can view audit logs" ON public.audit_logs;
DROP POLICY IF EXISTS "Admin can insert audit logs" ON public.audit_logs;
CREATE POLICY "Admins can view audit logs" ON public.audit_logs
  FOR SELECT USING (is_admin());

CREATE POLICY "Admins can insert audit logs" ON public.audit_logs
  FOR INSERT WITH CHECK (is_admin());

ALTER TABLE public.order_prints ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Admin can view order prints" ON public.order_prints;
DROP POLICY IF EXISTS "Admin can manage order prints" ON public.order_prints;
CREATE POLICY "Admins can view order prints" ON public.order_prints
  FOR SELECT USING (is_admin());

CREATE POLICY "Admins can manage order prints" ON public.order_prints
  FOR ALL USING (is_admin());

-- ============================================================
-- 8. Addresses Table & Policies
-- ============================================================
CREATE TABLE IF NOT EXISTS public.addresses (
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
  delivery_zone_id UUID REFERENCES public.delivery_zones(id) ON DELETE SET NULL,
  delivery_zone_name TEXT,
  delivery_fee NUMERIC DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.addresses ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own addresses" ON public.addresses;
CREATE POLICY "Users can view own addresses" ON public.addresses
  FOR SELECT USING (user_id = auth.uid() OR is_admin());

DROP POLICY IF EXISTS "Users can insert own addresses" ON public.addresses;
CREATE POLICY "Users can insert own addresses" ON public.addresses
  FOR INSERT WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS "Users can update own addresses" ON public.addresses;
CREATE POLICY "Users can update own addresses" ON public.addresses
  FOR UPDATE USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS "Users can delete own addresses" ON public.addresses;
CREATE POLICY "Users can delete own addresses" ON public.addresses
  FOR DELETE USING (user_id = auth.uid() OR is_admin());

-- ============================================================
-- 9. Notifications, Preferences, Device Tokens
-- ============================================================
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can view own notifications" ON public.notifications;
CREATE POLICY "Users can view own notifications" ON public.notifications
  FOR SELECT USING (user_id = auth.uid() OR is_admin());

DROP POLICY IF EXISTS "Users can update own notifications" ON public.notifications;
CREATE POLICY "Users can update own notifications" ON public.notifications
  FOR UPDATE USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS "Admins can view all notifications" ON public.notifications;
DROP POLICY IF EXISTS "Admins can insert notifications" ON public.notifications;
CREATE POLICY "Admins can insert notifications" ON public.notifications
  FOR INSERT WITH CHECK (is_admin());

DROP POLICY IF EXISTS "Users or admins can delete notifications" ON public.notifications;
CREATE POLICY "Users or admins can delete notifications" ON public.notifications
  FOR DELETE USING (user_id = auth.uid() OR is_admin());

ALTER TABLE public.notification_preferences ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can view own notification preferences" ON public.notification_preferences;
CREATE POLICY "Users can view own notification preferences" ON public.notification_preferences
  FOR SELECT USING (user_id = auth.uid() OR is_admin());

DROP POLICY IF EXISTS "Users can update own notification preferences" ON public.notification_preferences;
CREATE POLICY "Users can update own notification preferences" ON public.notification_preferences
  FOR UPDATE USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS "Users can insert own notification preferences" ON public.notification_preferences;
CREATE POLICY "Users can insert own notification preferences" ON public.notification_preferences
  FOR INSERT WITH CHECK (user_id = auth.uid());

ALTER TABLE public.device_tokens ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can view own device tokens" ON public.device_tokens;
CREATE POLICY "Users can view own device tokens" ON public.device_tokens
  FOR SELECT USING (user_id = auth.uid());

DROP POLICY IF EXISTS "Users can insert own device tokens" ON public.device_tokens;
CREATE POLICY "Users can insert own device tokens" ON public.device_tokens
  FOR INSERT WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS "Users can update own device tokens" ON public.device_tokens;
CREATE POLICY "Users can update own device tokens" ON public.device_tokens
  FOR UPDATE USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS "Users can delete own device tokens" ON public.device_tokens;
CREATE POLICY "Users can delete own device tokens" ON public.device_tokens
  FOR DELETE USING (user_id = auth.uid());

-- ============================================================
-- 10. Order Ratings Policies
-- ============================================================
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'order_ratings') THEN
    ALTER TABLE public.order_ratings ENABLE ROW LEVEL SECURITY;
    
    DROP POLICY IF EXISTS "Anyone can view ratings" ON public.order_ratings;
    CREATE POLICY "Anyone can view ratings" ON public.order_ratings
      FOR SELECT USING (true);

    DROP POLICY IF EXISTS "Customers can insert own order ratings" ON public.order_ratings;
    CREATE POLICY "Customers can insert own order ratings" ON public.order_ratings
      FOR INSERT WITH CHECK (
        auth.uid() = customer_id AND
        EXISTS (
          SELECT 1 FROM public.orders 
          WHERE id = order_id AND customer_id = auth.uid()
        )
      );

    DROP POLICY IF EXISTS "Customers can update own order ratings" ON public.order_ratings;
    CREATE POLICY "Customers can update own order ratings" ON public.order_ratings
      FOR UPDATE USING (auth.uid() = customer_id)
      WITH CHECK (auth.uid() = customer_id);

    DROP POLICY IF EXISTS "Admins can manage order ratings" ON public.order_ratings;
    CREATE POLICY "Admins can manage order ratings" ON public.order_ratings
      FOR ALL USING (is_admin());
  END IF;
END;
$$;

-- ============================================================
-- 11. Sensitive Function Permissions Hardening
-- ============================================================
DO $$
BEGIN
  -- Revoke public execution on notification triggers
  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'notify_admins_new_order') THEN
    REVOKE EXECUTE ON FUNCTION notify_admins_new_order() FROM PUBLIC;
    REVOKE EXECUTE ON FUNCTION notify_admins_new_order() FROM anon;
    GRANT EXECUTE ON FUNCTION notify_admins_new_order() TO postgres, service_role;
  END IF;

  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'notify_admins_order_cancelled') THEN
    REVOKE EXECUTE ON FUNCTION notify_admins_order_cancelled() FROM PUBLIC;
    REVOKE EXECUTE ON FUNCTION notify_admins_order_cancelled() FROM anon;
    GRANT EXECUTE ON FUNCTION notify_admins_order_cancelled() TO postgres, service_role;
  END IF;

  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'notify_order_status_change') THEN
    REVOKE EXECUTE ON FUNCTION notify_order_status_change() FROM PUBLIC;
    REVOKE EXECUTE ON FUNCTION notify_order_status_change() FROM anon;
    GRANT EXECUTE ON FUNCTION notify_order_status_change() TO postgres, service_role;
  END IF;
END;
$$;

-- ============================================================
-- 12. Storage Bucket Policies (product-images)
-- ============================================================
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.schemata WHERE schema_name = 'storage') THEN
    DROP POLICY IF EXISTS "Public can view product images" ON storage.objects;
    CREATE POLICY "Public can view product images" ON storage.objects
      FOR SELECT USING (bucket_id = 'product-images');

    DROP POLICY IF EXISTS "Admins can manage product images" ON storage.objects;
    CREATE POLICY "Admins can manage product images" ON storage.objects
      FOR ALL USING (bucket_id = 'product-images' AND is_admin());
  END IF;
END;
$$;
