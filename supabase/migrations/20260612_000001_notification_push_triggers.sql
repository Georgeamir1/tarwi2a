-- =============================================
-- Notification System — DB Triggers
-- Migration: 2026_06_11_notification_push_triggers
-- =============================================
-- This file wires Postgres triggers to the Supabase Edge Function
-- `send-notification` so that INSERTs into the `notifications` table
-- automatically invoke the function (which sends FCM pushes).
--
-- Requires:
--   1. The `notifications`, `notification_preferences`, `device_tokens`
--      tables to exist (see schema.sql).
--   2. The `send-notification` Edge Function to be deployed:
--        supabase functions deploy send-notification
--   3. The `pg_net` extension (enabled by default in Supabase projects).
-- =============================================

-- Enable pg_net (HTTP client from Postgres) — Supabase has this pre-installed
-- but we explicitly reference it for clarity.
CREATE EXTENSION IF NOT EXISTS pg_net;

-- =============================================
-- NOTIFICATIONS TABLES
-- =============================================
-- These tables are owned by schema.sql. We add them here as a safety net
-- so this migration is self-contained for fresh projects that haven't
-- yet run the full schema.sql.
-- =============================================

CREATE TABLE IF NOT EXISTS notifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  title_ar text NOT NULL,
  body_ar text NOT NULL,
  type text NOT NULL CHECK (type IN (
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
  reference_type text,
  reference_id text,
  is_read boolean DEFAULT false,
  created_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_notifications_user_created
  ON notifications(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notifications_unread
  ON notifications(user_id, is_read) WHERE is_read = false;

CREATE TABLE IF NOT EXISTS notification_preferences (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES profiles(id) ON DELETE CASCADE UNIQUE,
  order_updates boolean DEFAULT true,
  promotions boolean DEFAULT true,
  push_enabled boolean DEFAULT true,
  updated_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS device_tokens (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  token text NOT NULL,
  platform text NOT NULL CHECK (platform IN ('android', 'ios')),
  created_at timestamptz DEFAULT now(),
  UNIQUE(user_id, token)
);

CREATE INDEX IF NOT EXISTS idx_device_tokens_user ON device_tokens(user_id);

-- =============================================
-- RLS POLICIES
-- =============================================

ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE notification_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE device_tokens ENABLE ROW LEVEL SECURITY;

-- notifications: user can SELECT/UPDATE own rows; admin can SELECT all
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

-- notification_preferences: user can SELECT/UPDATE own
DROP POLICY IF EXISTS "Users can view own preferences" ON notification_preferences;
CREATE POLICY "Users can view own preferences" ON notification_preferences
  FOR SELECT USING (user_id = auth.uid());

DROP POLICY IF EXISTS "Users can update own preferences" ON notification_preferences;
CREATE POLICY "Users can update own preferences" ON notification_preferences
  FOR UPDATE USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS "Users can insert own preferences" ON notification_preferences;
CREATE POLICY "Users can insert own preferences" ON notification_preferences
  FOR INSERT WITH CHECK (user_id = auth.uid());

-- device_tokens: user can manage own
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
-- UPDATED_AT TRIGGER FOR notification_preferences
-- =============================================
DROP TRIGGER IF EXISTS notification_preferences_updated_at ON notification_preferences;
CREATE TRIGGER notification_preferences_updated_at
  BEFORE UPDATE ON notification_preferences
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- =============================================
-- AUTO-CREATE DEFAULT PREFERENCES ON PROFILE CREATION
-- =============================================
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

-- =============================================
-- AUTO-NOTIFY: order status changes (customer)
-- =============================================
-- When an order's status transitions to a new value, automatically
-- create a `notifications` row for the customer. The trigger from
-- the Edge Function (below) will then push it to the device.
-- =============================================

CREATE OR REPLACE FUNCTION notify_order_status_change()
RETURNS TRIGGER AS $$
DECLARE
  v_title text;
  v_body text;
BEGIN
  -- Only act on status change
  IF OLD.status IS NOT DISTINCT FROM NEW.status THEN
    RETURN NEW;
  END IF;

  -- Map status to Arabic title/body
  CASE NEW.status
    WHEN 'confirmed' THEN
      v_title := 'تم تأكيد طلبك';
      v_body := 'طلبك رقم #' || LEFT(NEW.id::text, 8) || ' تم تأكيده وجاري التجهيز';
    WHEN 'preparing' THEN
      v_title := 'جاري تجهيز طلبك';
      v_body := 'المطبخ بيحضر طلبك رقم #' || LEFT(NEW.id::text, 8);
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

-- =============================================
-- AUTO-NOTIFY: new order (admin)
-- =============================================
-- When a new order is created, fan out a notification to all admin users.
-- (Admins' device tokens are stored under each admin's user_id.)
-- =============================================

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

-- =============================================
-- AUTO-NOTIFY: customer cancellation (admin)
-- =============================================
CREATE OR REPLACE FUNCTION notify_admins_order_cancelled()
RETURNS TRIGGER AS $$
DECLARE
  admin_record RECORD;
BEGIN
  -- Only fire when status transitions TO cancelled (not initial inserts)
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

-- =============================================
-- PUSH TRIGGER: INSERT into notifications → Edge Function
-- =============================================
-- This trigger fires AFTER INSERT on notifications and asynchronously
-- invokes the `send-notification` Edge Function via pg_net.
-- =============================================

CREATE OR REPLACE FUNCTION invoke_send_notification()
RETURNS TRIGGER AS $$
DECLARE
  v_url text;
  v_request_id bigint;
BEGIN
  -- Resolve Edge Function URL from project ref (auto-set by Supabase)
  v_url := current_setting('app.settings.supabase_functions_url', true)
           || '/send-notification';

  IF v_url IS NULL OR v_url = '/send-notification' THEN
    -- Fallback: build from SUPABASE_URL env at deploy time
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
-- REALTIME: enable for notifications + device_tokens
-- =============================================
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables
    WHERE pubname = 'supabase_realtime' AND tablename = 'notifications'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE notifications;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables
    WHERE pubname = 'supabase_realtime' AND tablename = 'device_tokens'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE device_tokens;
  END IF;
END $$;
