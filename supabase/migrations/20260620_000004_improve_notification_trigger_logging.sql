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

  -- Privileged credentials must never reside in app_config table.
  -- Supabase Vault or GUC setting (app.settings.service_role_key) should be used.
  v_service_key := current_setting('app.settings.service_role_key', true);

  IF v_url IS NULL OR v_url = '' THEN
    RAISE WARNING '[invoke_send_notification] functions url not configured — notification push skipped for %', NEW.id;
    RETURN NEW;
  END IF;

  IF v_service_key IS NULL OR v_service_key = '' THEN
    RAISE WARNING '[invoke_send_notification] service_role_key not configured — notification push skipped for %', NEW.id;
    RETURN NEW;
  END IF;

  v_url := v_url || '/send-notification';

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