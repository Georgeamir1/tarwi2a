# =============================================
# send-notification Edge Function
# =============================================
# Sends FCM push notifications when a row is inserted into the
# `notifications` table. Wired via DB trigger in
# `supabase/migrations/2026_06_11_notification_push_triggers.sql`.
#
# Deploy:
#   supabase functions deploy send-notification --no-verify-jwt
#
# Required env vars (set via `supabase secrets set`):
#   FIREBASE_PROJECT_ID
#   FIREBASE_CLIENT_EMAIL
#   FIREBASE_PRIVATE_KEY
#
# SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY are auto-provided.
# =============================================

# Firebase project (from Firebase Console > Project Settings)
supabase secrets set FIREBASE_PROJECT_ID=your-firebase-project-id

# Service account credentials (from Firebase Console >
# Project Settings > Service Accounts > Generate new private key)
supabase secrets set FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxx@your-project.iam.gserviceaccount.com
# IMPORTANT: paste the full key with \n characters preserved:
supabase secrets set FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nMIIE...\n-----END PRIVATE KEY-----\n"
