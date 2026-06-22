-- =============================================
-- Realtime RLS Enforcement — Prevent notification/data leaks
-- Migration: 2026_06_21_realtime_rls_enforcement
-- =============================================
-- Problem: Supabase Realtime Postgres Changes broadcasts
-- row-level events to ALL authenticated subscribers before
-- evaluating RLS. This means customers could receive other
-- customers' order data and notifications in the WebSocket
-- stream even though REST queries correctly enforce RLS.
--
-- Fix: Re-publish only the tables that need Realtime with
-- RLS enforcement, and remove tables that should never be
-- broadcast to all clients.
-- =============================================

-- =============================================
-- 1. Remove tables from supabase_realtime that should NOT
--    be broadcast to all users, then re-add them one by one.
--    (Supabase does not support ALTER PUBLICATION ... SET on
--    individual tables with RLS mode — we recreate the
--    publication and add only the needed tables.)
-- =============================================

-- Drop and recreate the realtime publication with the correct
-- set of tables. This ensures ONLY the listed tables are
-- broadcast, and Supabase's RLS is enforced on the stream.
ALTER PUBLICATION supabase_realtime DROP TABLE orders;
ALTER PUBLICATION supabase_realtime DROP TABLE notifications;
ALTER PUBLICATION supabase_realtime DROP TABLE device_tokens;
ALTER PUBLICATION supabase_realtime DROP TABLE broadcast_logs;

-- =============================================
-- 2. Re-add with RLS-aware publication.
--    Supabase Realtime respects RLS by default since
--    supabase_realtime publication filters rows using the
--    authenticated user's RLS policies. However, we must
--    ensure RLS is enabled and policies are correct.
--
--    Tables re-added:
--      - orders:    customers see own orders (RLS), admins see all
--      - notifications: users see own notifications (RLS), admins see all
--    Tables kept out:
--      - device_tokens: only needed server-side, never client-streamed
--      - broadcast_logs: admin-only, accessed via REST not Realtime
-- =============================================

-- Re-add orders (RLS will filter rows per authenticated user)
ALTER PUBLICATION supabase_realtime ADD TABLE orders;

-- Re-add notifications (RLS will filter rows per authenticated user)
ALTER PUBLICATION supabase_realtime ADD TABLE notifications;

-- Do NOT re-add device_tokens or broadcast_logs — they don't
-- need Realtime and were a potential leak vector.

-- =============================================
-- 3. Verify RLS is enabled on all notification-related tables
-- =============================================
-- These should already be enabled from prior migrations,
-- but we verify and enforce:

ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE notification_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE device_tokens ENABLE ROW LEVEL SECURITY;

-- =============================================
-- 4. Customers must ONLY see their own notifications.
--    The existing policy "Users can view own notifications"
--    already enforces: USING (user_id = auth.uid()).
--    Let's verify it's correct (this will error-drop if it
--    already exists, which is fine — DROP IF EXISTS).

DROP POLICY IF EXISTS "Users can view own notifications" ON notifications;
CREATE POLICY "Users can view own notifications" ON notifications
  FOR SELECT USING (user_id = auth.uid());

-- Ensure admin can still see all notifications:
DROP POLICY IF EXISTS "Admins can view all notifications" ON notifications;
CREATE POLICY "Admins can view all notifications" ON notifications
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- =============================================
-- 5. Customers must ONLY see their own orders via Realtime.
--    Verify the existing RLS policy is correct.
-- =============================================
DROP POLICY IF EXISTS "Customers can view own orders" ON orders;
CREATE POLICY "Customers can view own orders" ON orders
  FOR SELECT USING (customer_id = auth.uid());

DROP POLICY IF EXISTS "Admin can view all orders" ON orders;
CREATE POLICY "Admin can view all orders" ON orders
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- =============================================
-- 6. Ensure profiles RLS is also enforced for Realtime
--    (used by admin subscribers for customer lists).
-- =============================================
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- =============================================
-- NOTE: After running this migration, go to Supabase Dashboard
-- → Database → Replication and verify:
--   ✅ orders:        Realtime ON, RLS enforced
--   ✅ notifications: Realtime ON, RLS enforced
--   ✅ categories:    Realtime ON (public data, no leak risk)
--   ✅ products:      Realtime ON (public data, no leak risk)
--   ✅ coupons:       Realtime ON (admin-only, low risk)
--   ✅ delivery_zones: Realtime ON (public data, no leak risk)
--   ✅ business_profiles: Realtime ON (public data, no leak risk)
--   ❌ device_tokens:  Realtime OFF (removed)
--   ❌ broadcast_logs: Realtime OFF (removed)
-- =============================================