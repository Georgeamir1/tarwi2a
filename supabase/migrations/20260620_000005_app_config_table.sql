CREATE TABLE IF NOT EXISTS app_config (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL
);

ALTER TABLE app_config ENABLE ROW LEVEL SECURITY;

-- Deny all client access by default; no public policies
REVOKE ALL ON app_config FROM PUBLIC, anon, authenticated;

INSERT INTO app_config (key, value) VALUES
  ('supabase_functions_url', 'https://tfchunxrymewqfbafhnb.supabase.co/functions/v1')
ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value;