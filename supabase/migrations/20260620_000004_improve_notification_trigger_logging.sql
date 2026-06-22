CREATE OR REPLACE FUNCTION invoke_send_notification()
RETURNS TRIGGER AS $$
DECLARE
  v_url text;
  v_request_id bigint;
  v_service_key text;
BEGIN
  SELECT value INTO v_url FROM app_config WHERE key = 'supabase_functions_url';
  SELECT value INTO v_service_key FROM app_config WHERE key = 'service_role_key';

  IF v_url IS NULL OR v_url = '' THEN
    RAISE WARNING '[invoke_send_notification] supabase_functions_url not found in app_config — notification push skipped for %', NEW.id;
    RETURN NEW;
  END IF;

  IF v_service_key IS NULL OR v_service_key = '' THEN
    RAISE WARNING '[invoke_send_notification] service_role_key not found in app_config — notification push skipped for %', NEW.id;
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
$$ LANGUAGE plpgsql SECURITY DEFINER;