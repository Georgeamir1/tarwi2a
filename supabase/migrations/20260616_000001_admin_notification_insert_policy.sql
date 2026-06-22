-- Migration: Add admin INSERT policy on notifications table
-- Fixes S-1: Client-side broadcast inserts were failing due to missing INSERT policy
-- Admin users need to insert notifications when sending broadcasts from the Flutter app

-- Allow admins to insert notifications (for broadcast sends via client SDK)
DROP POLICY IF EXISTS "Admins can insert notifications" ON notifications;
CREATE POLICY "Admins can insert notifications" ON notifications
  FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- Allow admins to update any notification (for broadcast log tracking)
DROP POLICY IF EXISTS "Admins can update notifications" ON notifications;
CREATE POLICY "Admins can update notifications" ON notifications
  FOR UPDATE USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );
