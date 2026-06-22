# send-push-notification Edge Function

Admin-only function to broadcast a single notification (promotion or system) to many users at once.

## How it works

1. Verifies the caller is an admin (via `senderId` → `profiles.role`)
2. Resolves target user IDs based on the `target` parameter
3. Records the broadcast in `broadcast_logs` table
4. Batch-inserts notification rows (each row's `AFTER INSERT` trigger fires the existing `send-notification` FCM pipeline)
5. Returns recipient count + inserted notification IDs

## Request shape

```json
{
  "titleAr": "عرض جديد — خصم 20% على المشويات",
  "bodyAr": "استخدم كود GRILL20 عند الطلب",
  "type": "promotion",
  "target": {
    "type": "all"
  },
  "referenceType": "promotion",
  "referenceId": "promo-123",
  "senderId": "<admin-user-uuid>"
}
```

## Target types

| Type | Description |
|------|-------------|
| `all` | Every user in `profiles` |
| `customers` | Users with `role = 'customer'` |
| `admins` | Users with `role = 'admin'` |
| `specific` | Explicit list of user IDs |

```json
"target": {
  "type": "specific",
  "userIds": ["uuid-1", "uuid-2", "uuid-3"]
}
```

## Response shape

```json
{
  "ok": true,
  "recipientCount": 1234,
  "notificationIds": ["uuid-1", "uuid-2"],
  "skipped": 0
}
```

## Deploy

```bash
supabase functions deploy send-push-notification --no-verify-jwt
```

> The function handles CORS so it can be called from the Flutter web app. For production, consider replacing `Access-Control-Allow-Origin: *` with your deployed domain.

## Apply DB migration

```bash
# Run in Supabase SQL Editor:
# supabase/migrations/2026_06_11_broadcast_policies.sql
```

This migration creates:
- `broadcast_logs` table (history of every broadcast)
- RLS policy for admin-only INSERT

## Validation rules

- `titleAr`: 1–200 chars, required
- `bodyAr`: 1–1000 chars, required
- `type`: must be `promotion` or `system`
- `senderId`: required, must be an admin
- `target.specific.userIds`: 1–10000 user IDs
