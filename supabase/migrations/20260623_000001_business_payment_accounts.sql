-- Add payment account numbers to business_profiles
-- Allows the admin to configure the wallet / InstaPay / WhatsApp numbers
-- used by the checkout screen's transfer card and WhatsApp proof flow.

ALTER TABLE business_profiles
  ADD COLUMN IF NOT EXISTS whatsapp_number TEXT,
  ADD COLUMN IF NOT EXISTS vodafone_cash_number TEXT,
  ADD COLUMN IF NOT EXISTS instapay_handle TEXT;
