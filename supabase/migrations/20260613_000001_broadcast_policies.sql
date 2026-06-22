-- =============================================
-- Notification Broadcast — Schema & Policies
-- Migration: 2026_06_11_broadcast_policies
-- =============================================
-- Adds the `broadcast_logs` table for tracking promotional/system
-- notifications sent by admins, plus RLS for admin-only access.
-- =============================================

CREATE TABLE IF NOT EXISTS broadcast_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  sender_id uuid REFERENCES profiles(id) ON DELETE SET NULL,
  title_ar text NOT NULL,
  body_ar text NOT NULL,
  type text NOT NULL CHECK (type IN ('promotion', 'system')),
  target_type text NOT NULL CHECK (target_type IN (
    'all', 'customers', 'admins', 'specific'
  )),
  target_user_ids uuid[],
  reference_type text,
  reference_id text,
  recipient_count integer NOT NULL DEFAULT 0,
  sent_count integer NOT NULL DEFAULT 0,
  skipped_count integer NOT NULL DEFAULT 0,
  created_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_broadcast_logs_sender ON broadcast_logs(sender_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_broadcast_logs_created ON broadcast_logs(created_at DESC);

ALTER TABLE broadcast_logs ENABLE ROW LEVEL SECURITY;

-- Admins can view all broadcast logs
DROP POLICY IF EXISTS "Admins can view broadcast logs" ON broadcast_logs;
CREATE POLICY "Admins can view broadcast logs" ON broadcast_logs
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- Admins can insert broadcast logs
DROP POLICY IF EXISTS "Admins can insert broadcast logs" ON broadcast_logs;
CREATE POLICY "Admins can insert broadcast logs" ON broadcast_logs
  FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- Admins can update their own broadcast logs (for sent_count / skipped_count)
DROP POLICY IF EXISTS "Admins can update broadcast logs" ON broadcast_logs;
CREATE POLICY "Admins can update broadcast logs" ON broadcast_logs
  FOR UPDATE USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- =============================================
-- Allow admin-only direct INSERT on notifications
-- (used by send-push-notification Edge Function
--  via service role — also exposed for admin client
--  use cases that don't go through the Edge Function)
-- =============================================
DROP POLICY IF EXISTS "Admins can insert any notification" ON notifications;
CREATE POLICY "Admins can insert any notification" ON notifications
  FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- =============================================
-- REALTIME: enable for broadcast_logs (admin view)
-- =============================================
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables
    WHERE pubname = 'supabase_realtime' AND tablename = 'broadcast_logs'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE broadcast_logs;
  END IF;
END $$;
