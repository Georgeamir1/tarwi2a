-- Migration: 20260908_000001_secure_app_config.sql
-- Description: Contain exposed credentials, secure app_config table, revoke public/client access, and harden notification trigger.

-- 1. Ensure app_config exists
CREATE TABLE IF NOT EXISTS app_config (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL
);

-- 2. Delete the service_role_key row if it exists
DELETE FROM app_config WHERE key = 'service_role_key';

-- 3. Drop any permissive policies on app_config
DROP POLICY IF EXISTS "Service role full access" ON app_config;

-- 4. Revoke all table privileges from PUBLIC, anon, and authenticated
REVOKE ALL ON TABLE app_config FROM PUBLIC, anon, authenticated;

-- 5. Enable and force Row Level Security
ALTER TABLE app_config ENABLE ROW LEVEL SECURITY;
ALTER TABLE app_config FORCE ROW LEVEL SECURITY;

-- 6. Harden invoke_send_notification function:
-- - Do NOT query app_config for service_role_key
-- - Read non-secret functions url from app_config or app.settings
-- - Read credentials only from GUC app.settings.service_role_key or fail closed
-- - Set secure search_path
-- - Revoke PUBLIC execution
CREATE OR REPLACE FUNCTION invoke_send_notification()
RETURNS TRIGGER AS $$
DECLARE
  v_url text;
  v_request_id bigint;
  v_service_key text;
BEGIN
  -- Read non-secret functions url from app_config or app.settings
  SELECT value INTO v_url FROM app_config WHERE key = 'supabase_functions_url';
  IF v_url IS NULL OR v_url = '' THEN
    v_url := current_setting('app.settings.supabase_functions_url', true);
  END IF;

  IF v_url IS NULL OR v_url = '' THEN
    v_url := 'https://' ||
             (SELECT setting FROM pg_settings WHERE name = 'cluster_name') ||
             '.functions.supabase.co/send-notification';
  ELSE
    IF NOT (v_url LIKE '%/send-notification') THEN
      v_url := v_url || '/send-notification';
    END IF;
  END IF;

  -- Privileged credentials must never reside in app_config table.
  -- Supabase Vault or GUC setting (app.settings.service_role_key) should be used.
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

REVOKE EXECUTE ON FUNCTION invoke_send_notification() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION invoke_send_notification() TO postgres, service_role;
