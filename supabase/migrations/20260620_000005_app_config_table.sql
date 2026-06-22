CREATE TABLE IF NOT EXISTS app_config (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL
);

ALTER TABLE app_config ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Service role full access" ON app_config;
CREATE POLICY "Service role full access" ON app_config
  FOR ALL USING (true) WITH CHECK (true);

INSERT INTO app_config (key, value) VALUES
  ('supabase_functions_url', 'https://tfchunxrymewqfbafhnb.supabase.co/functions/v1'),
  ('service_role_key', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRmY2h1bnhyeW1ld3FmYmFmaG5iIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3MzkxOTMxMiwiZXhwIjoyMDg5NDk1MzEyfQ.rk_qTUImQVnQsrgkgxrP_wTBPstRx5z5c8c0idUslAQ')
ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value;