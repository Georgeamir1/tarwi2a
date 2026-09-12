-- Migration: 20260908_000004_delete_account_rpc.sql
-- Description: Server-side account deletion and data anonymization function

CREATE OR REPLACE FUNCTION delete_user_account_data(p_user_id UUID)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
  -- 1. Anonymize orders to comply with financial retention while stripping PII
  UPDATE public.orders
  SET
    customer_name = 'مستخدم محذوف',
    customer_phone = 'محذوف',
    customer_address = NULL,
    notes = NULL,
    payment_proof_url = NULL,
    address_id = NULL
  WHERE customer_id = p_user_id;

  -- 2. Delete user addresses
  DELETE FROM public.addresses WHERE user_id = p_user_id;

  -- 3. Delete user device tokens
  DELETE FROM public.device_tokens WHERE user_id = p_user_id;

  -- 4. Delete user notifications
  DELETE FROM public.notifications WHERE user_id = p_user_id;

  -- 5. Delete notification preferences
  DELETE FROM public.notification_preferences WHERE user_id = p_user_id;

  -- 6. Delete ratings & reviews
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'order_ratings') THEN
    DELETE FROM public.order_ratings WHERE customer_id = p_user_id;
  END IF;

  -- 7. Delete profile row (if not already cascaded)
  DELETE FROM public.profiles WHERE id = p_user_id;
END;
$$;

-- Revoke public execution; grant only to service_role and postgres
REVOKE EXECUTE ON FUNCTION delete_user_account_data(UUID) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION delete_user_account_data(UUID) TO postgres, service_role;
