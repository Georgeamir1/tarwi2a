# 🗄️ Database Operations Runbook

## Backup & Restore

### Supabase Backups

Supabase (PostgreSQL) provides automatic backups:

| Plan | Backup Frequency | Point-in-Time Restore (PITR) | Retention |
|------|------------------|-------------------------------|-----------|
| Free | Daily | ❌ No | 7 days |
| Pro | Continuous | ✅ Yes | 30 days |
| Team | Continuous | ✅ Yes | 60 days |
| Enterprise | Continuous | ✅ Yes | Custom |

### Verify Your Backup Settings

1. Go to **Supabase Dashboard** → Your Project → **Settings** → **Database**
2. Scroll to **Backups** section
3. Verify PITR is enabled (Pro plan or higher)

### Restore from Backup (PITR)

```sql
-- Connect to Supabase via psql or SQL Editor

-- List available backup points
SELECT * FROM pg_backup_list();

-- Restore to specific point (REPLACEME with actual timestamp)
SELECT pg_restore_to_point('2026-05-20 12:00:00');
```

### Manual Backup (Export)

```bash
# Export entire database using Supabase CLI
supabase db dump -f backup.sql

# Or via pg_dump (requires connection details from Dashboard)
pg_dump -h db.YOUR_PROJECT_REF.supabase.co -U postgres -d postgres -f backup.sql
```

### Restore from Manual Backup

```bash
# Via psql
psql -h db.YOUR_PROJECT_REF.supabase.co -U postgres -d postgres -f backup.sql
```

## Disaster Recovery Checklist

- [ ] **RTO (Recovery Time Objective)**: Target < 4 hours
- [ ] **RPO (Recovery Point Objective)**: Target < 1 hour (PITR)
- [ ] **Backup tested**: Verify you can actually restore
- [ ] **Recovery tested**: Documented steps tested in staging

## Critical Data Considerations

### Order Data
- Orders are critical business data — never delete
- Cascade from `orders` table cascades to `order_items` automatically
- `order_prints` table tracks thermal printer usage (can be reconstructed)

### User Data (GDPR/CCPA)
- Users can request data export (DSAR)
- Users can request deletion (right to be forgotten)
- Profile data links to `auth.users` — handle with care

## Production Safety Rules

```sql
-- ⚠️ NEVER run these in production without backup:
DROP TABLE orders;           -- NEVER
TRUNCATE orders;             -- NEVER without backup
DELETE FROM orders WHERE ...  -- Use soft delete instead
```

## Scheduled Backup (Optional)

For additional safety, set up a cron job to export daily:

```bash
# Add to CI/CD or cron
supabase db dump -f backups/backup-$(date +%Y%m%d).sql
```

---

## Database Maintenance

### Check Table Sizes

```sql
SELECT 
  relname AS table_name,
  pg_size_pretty(pg_total_relation_size(relid)) AS total_size
FROM pg_catalog.pg_statio_user_tables
ORDER BY pg_total_relation_size(relid) DESC;
```

### Check Index Usage

```sql
SELECT 
  indexrelname,
  idx_scan,
  idx_tup_read,
  idx_tup_fetch
FROM pg_stat_user_indexes
ORDER BY idx_scan ASC;
```

### Vacuum (Cleanup Dead Rows)

```sql
-- Run periodically to reclaim space
VACUUM ANALYZE orders;
```

---

## Monitoring

Set up Supabase Dashboard alerts for:
- Database storage > 80% capacity
- Connection count > 80% of limit
- Slow queries (> 1 second)
- Failed auth attempts spike

---

## Escalation

For database emergencies:
1. Check Supabase Status: https://status.supabase.com
2. Supabase Support: support@supabase.com
3. Discord Community: https://discord.gg/supabase