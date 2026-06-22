-- =============================================
-- Notification Analytics — Tracking Columns
-- Migration: 2026_06_11_notification_analytics
-- =============================================
-- Adds delivered_at, opened_at, dismissed_at, device_platform
-- columns to notifications for tracking push delivery + open rates.
-- =============================================

ALTER TABLE notifications
  ADD COLUMN IF NOT EXISTS delivered_at timestamptz,
  ADD COLUMN IF NOT EXISTS opened_at timestamptz,
  ADD COLUMN IF NOT EXISTS dismissed_at timestamptz,
  ADD COLUMN IF NOT EXISTS device_platform text
    CHECK (device_platform IN ('android', 'ios', 'web'));

CREATE INDEX IF NOT EXISTS idx_notifications_delivered
  ON notifications(delivered_at) WHERE delivered_at IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_notifications_opened
  ON notifications(opened_at) WHERE opened_at IS NOT NULL;

-- User can update their own delivery/opening timestamps via client
DROP POLICY IF EXISTS "Users can update own notification engagement" ON notifications;
CREATE POLICY "Users can update own notification engagement" ON notifications
  FOR UPDATE USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- =============================================
-- broadcast_logs — add delivery tracking summary columns
-- =============================================
ALTER TABLE broadcast_logs
  ADD COLUMN IF NOT EXISTS delivered_count integer NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS opened_count integer NOT NULL DEFAULT 0;

DROP POLICY IF EXISTS "Admins can update broadcast delivery stats" ON broadcast_logs;
CREATE POLICY "Admins can update broadcast delivery stats" ON broadcast_logs
  FOR UPDATE USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );
