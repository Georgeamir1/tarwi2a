-- Test: security_app_config.sql
-- Description: Verifies app_config table containment and role permissions.
-- Safe transaction that rolls back.

BEGIN;

-- 1. Ensure service_role_key does not exist in app_config
DO $$
DECLARE
  v_count integer;
BEGIN
  SELECT count(*) INTO v_count FROM app_config WHERE key = 'service_role_key';
  IF v_count > 0 THEN
    RAISE EXCEPTION 'TEST FAILED: service_role_key found in app_config table';
  END IF;
  RAISE NOTICE 'TEST PASSED: service_role_key is not in app_config';
END;
$$;

-- 2. Verify anon cannot read app_config
DO $$
DECLARE
  v_caught boolean := false;
BEGIN
  BEGIN
    SET LOCAL ROLE anon;
    PERFORM count(*) FROM app_config;
  EXCEPTION WHEN insufficient_privilege THEN
    v_caught := true;
  END;

  RESET ROLE;

  IF NOT v_caught THEN
    RAISE EXCEPTION 'TEST FAILED: anon was able to read app_config';
  END IF;
  RAISE NOTICE 'TEST PASSED: anon cannot read app_config';
END;
$$;

-- 3. Verify anon cannot insert into app_config
DO $$
DECLARE
  v_caught boolean := false;
BEGIN
  BEGIN
    SET LOCAL ROLE anon;
    INSERT INTO app_config (key, value) VALUES ('test_anon', 'val');
  EXCEPTION WHEN insufficient_privilege THEN
    v_caught := true;
  END;

  RESET ROLE;

  IF NOT v_caught THEN
    RAISE EXCEPTION 'TEST FAILED: anon was able to insert into app_config';
  END IF;
  RAISE NOTICE 'TEST PASSED: anon cannot insert into app_config';
END;
$$;

-- 4. Verify authenticated cannot read app_config
DO $$
DECLARE
  v_caught boolean := false;
BEGIN
  BEGIN
    SET LOCAL ROLE authenticated;
    PERFORM count(*) FROM app_config;
  EXCEPTION WHEN insufficient_privilege THEN
    v_caught := true;
  END;

  RESET ROLE;

  IF NOT v_caught THEN
    RAISE EXCEPTION 'TEST FAILED: authenticated was able to read app_config';
  END IF;
  RAISE NOTICE 'TEST PASSED: authenticated cannot read app_config';
END;
$$;

-- 5. Verify authenticated cannot insert into app_config
DO $$
DECLARE
  v_caught boolean := false;
BEGIN
  BEGIN
    SET LOCAL ROLE authenticated;
    INSERT INTO app_config (key, value) VALUES ('test_auth', 'val');
  EXCEPTION WHEN insufficient_privilege THEN
    v_caught := true;
  END;

  RESET ROLE;

  IF NOT v_caught THEN
    RAISE EXCEPTION 'TEST FAILED: authenticated was able to insert into app_config';
  END IF;
  RAISE NOTICE 'TEST PASSED: authenticated cannot insert into app_config';
END;
$$;

-- 6. Verify invoke_send_notification does not execute as PUBLIC
DO $$
DECLARE
  v_has_public_exec boolean;
BEGIN
  SELECT has_function_privilege('public', 'invoke_send_notification()', 'EXECUTE')
  INTO v_has_public_exec;

  IF v_has_public_exec THEN
    RAISE EXCEPTION 'TEST FAILED: invoke_send_notification() should not have PUBLIC EXECUTE privilege';
  END IF;
  RAISE NOTICE 'TEST PASSED: PUBLIC cannot execute invoke_send_notification()';
END;
$$;

ROLLBACK;
