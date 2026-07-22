# 🚀 Staging Environment Setup

## Overview

Separate staging environment allows you to test:
- New admin features before production
- Schema migrations safely
- Breaking changes without affecting live customers

## Option 1: Separate Supabase Project (Recommended)

### Create Staging Project

1. Go to https://supabase.com/dashboard
2. Click **New Project**
3. Name: `tarwi2a-staging`
4. Set a strong password and save it in your password manager

### Get Staging Credentials

1. Settings → API
2. Copy **Project URL** (e.g., `https://xyzabc.supabase.co`)
3. Copy **anon/public** key (for staging, we use same pattern)

### Update App for Staging

```dart
// lib/core/constants/app_constants.dart

static const supabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  // In staging, use staging URL
  defaultValue: 'https://xyzabc.staging.supabase.co',
);
```

### Deploy to Staging

Run with staging variables:
```bash
flutter run \
  --dart-define=SUPABASE_URL=https://xyzabc.staging.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=staging-anon-key
```

## Option 2: Supabase Branch (Pro/Enterprise)

Supabase Enterprise plans have **Branching** — instant staging:

```bash
# Create a development branch
supabase branch create staging

# Apply all migrations to branch
supabase branch push staging

# When done, merge back to main
supabase branch merge staging
```

## CI/CD with Multiple Environments

```yaml
# .github/workflows/flutter-ci.yml

jobs:
  staging:
    if: github.ref == 'refs/heads/main'
    env:
      SUPABASE_URL: ${{ vars.STAGING_SUPABASE_URL }}
      SUPABASE_ANON_KEY: ${{ secrets.STAGING_SUPABASE_KEY }}
    steps:
      - run: flutter build web --dart-define=SUPABASE_URL=$SUPABASE_URL ...

  production:
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    env:
      SUPABASE_URL: ${{ vars.PROD_SUPABASE_URL }}
      SUPABASE_ANON_KEY: ${{ secrets.PROD_SUPABASE_KEY }}
    steps:
      - run: flutter build web --dart-define=SUPABASE_URL=$SUPABASE_URL ...
```

## Staging Data Strategy

### Anonymize Production Data

Never use real customer data in staging. Anonymize:

```sql
-- In staging, run after schema sync:
UPDATE profiles SET name = 'Test User', phone = '+1234567890';
UPDATE orders SET customer_address = 'Test Address';
```

### Seed Test Data

```sql
-- Add test categories
INSERT INTO categories (name, name_ar, sort_order) VALUES
  ('Test Category', 'فئة اختبار', 99);

-- Add test products
INSERT INTO products (name, name_ar, price) VALUES
  ('Test Product', 'منتج اختبار', 99.99);

-- Add test admin
INSERT INTO profiles (id, name, role) VALUES
  (auth.uuid_nil(), 'Test Admin', 'admin');
```

## GitHub Repository Variables

Add these in GitHub → Settings → Variables:

| Variable | Description | Example |
|----------|-------------|---------|
| `STAGING_SUPABASE_URL` | Staging project URL | `https://xyzabc.staging.supabase.co` |
| `PROD_SUPABASE_URL` | Production project URL | `https://tfchunxrymewqfbafhnb.supabase.co` |

Add these in GitHub → Settings → Secrets:

| Secret | Description |
|--------|-------------|
| `STAGING_SUPABASE_KEY` | Staging anon key |
| `PROD_SUPABASE_KEY` | Production anon key |

## Verification Checklist

Before any staging deploy:
- [ ] Staging schema matches production
- [ ] RLS policies tested
- [ ] No hardcoded production URLs
- [ ] Test credentials work
- [ ] CI/CD passes for staging

## Firewall Rules

Ensure staging allows your IP:
1. Supabase Dashboard → Settings → Database
2. Set allowed IPs to your office/developer IPs
3. For development, allow `0.0.0.0/0` (but secure with password)