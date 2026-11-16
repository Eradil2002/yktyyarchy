# Database Backup Strategy

## Overview
This document outlines the backup strategy for the volunteer platform database to ensure data integrity, disaster recovery, and business continuity.

## Backup Types

### 1. Full Database Backups
- **Frequency**: Daily at 2:00 AM UTC
- **Retention**: 30 days
- **Storage**: Off-site cloud storage (S3 or equivalent)
- **Method**: PostgreSQL pg_dump

### 2. Incremental Backups
- **Frequency**: Every 6 hours
- **Retention**: 7 days
- **Method**: PostgreSQL WAL (Write-Ahead Logging) archiving

### 3. Point-in-Time Recovery (PITR)
- **Enabled**: Yes
- **WAL Archive**: Continuous
- **Recovery Window**: Up to 7 days

## Backup Commands

### Full Backup (PostgreSQL)
```bash
# Create full backup
pg_dump -h $DB_HOST -U $DB_USER -d $DB_NAME -F c -f backup_$(date +%Y%m%d_%H%M%S).dump

# With compression
pg_dump -h $DB_HOST -U $DB_USER -d $DB_NAME -F c -Z 9 -f backup_$(date +%Y%m%d_%H%M%S).dump
```

### Restore from Backup
```bash
# Restore full backup
pg_restore -h $DB_HOST -U $DB_USER -d $DB_NAME -c backup_YYYYMMDD_HHMMSS.dump

# Restore specific tables
pg_restore -h $DB_HOST -U $DB_USER -d $DB_NAME -t events_event -t users_customuser backup.dump
```

### Automated Backup Script
```bash
#!/bin/bash
# backup.sh - Automated database backup script

BACKUP_DIR="/var/backups/postgres"
DB_NAME="${DB_NAME:-volunteering_db}"
DB_USER="${DB_USER:-postgres}"
DB_HOST="${DB_HOST:-localhost}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/backup_$TIMESTAMP.dump"
S3_BUCKET="${BACKUP_S3_BUCKET}"

# Create backup directory if not exists
mkdir -p $BACKUP_DIR

# Create backup
pg_dump -h $DB_HOST -U $DB_USER -d $DB_NAME -F c -Z 9 -f $BACKUP_FILE

# Upload to S3 (if configured)
if [ ! -z "$S3_BUCKET" ]; then
    aws s3 cp $BACKUP_FILE s3://$S3_BUCKET/backups/
fi

# Delete local backups older than 7 days
find $BACKUP_DIR -name "backup_*.dump" -mtime +7 -delete

# Delete S3 backups older than 30 days (if configured)
if [ ! -z "$S3_BUCKET" ]; then
    aws s3 ls s3://$S3_BUCKET/backups/ | while read -r line; do
        createDate=$(echo $line | awk {'print $1" "$2'})
        createDate=$(date -d "$createDate" +%s)
        olderThan=$(date -d "30 days ago" +%s)
        if [[ $createDate -lt $olderThan ]]; then
            fileName=$(echo $line | awk {'print $4'})
            if [[ $fileName != "" ]]; then
                aws s3 rm s3://$S3_BUCKET/backups/$fileName
            fi
        fi
    done
fi

echo "Backup completed: $BACKUP_FILE"
```

## Cron Schedule

Add to crontab for automated backups:

```cron
# Full backup daily at 2 AM
0 2 * * * /path/to/backup.sh >> /var/log/backup.log 2>&1

# Incremental backup every 6 hours
0 */6 * * * /path/to/incremental_backup.sh >> /var/log/backup.log 2>&1
```

## PostgreSQL WAL Archiving

### Enable WAL Archiving in postgresql.conf
```conf
wal_level = replica
archive_mode = on
archive_command = 'test ! -f /var/lib/postgresql/wal_archive/%f && cp %p /var/lib/postgresql/wal_archive/%f'
archive_timeout = 300  # Force WAL switch every 5 minutes
```

### WAL Archive to S3
```conf
archive_command = 'aws s3 cp %p s3://your-bucket/wal_archive/%f'
```

## Backup Verification

### Test Restore Procedure (Monthly)
```bash
# 1. Create test database
createdb -h $DB_HOST -U $DB_USER test_restore_db

# 2. Restore latest backup
pg_restore -h $DB_HOST -U $DB_USER -d test_restore_db latest_backup.dump

# 3. Verify data integrity
psql -h $DB_HOST -U $DB_USER -d test_restore_db -c "SELECT COUNT(*) FROM events_event;"
psql -h $DB_HOST -U $DB_USER -d test_restore_db -c "SELECT COUNT(*) FROM users_customuser;"

# 4. Drop test database
dropdb -h $DB_HOST -U $DB_USER test_restore_db
```

## Disaster Recovery Plan

### Recovery Time Objective (RTO)
- **Target**: 4 hours
- **Maximum acceptable downtime**: 8 hours

### Recovery Point Objective (RPO)
- **Target**: 6 hours
- **Maximum acceptable data loss**: 24 hours

### Recovery Steps
1. **Assess the situation**: Determine extent of data loss
2. **Provision new database server** (if needed)
3. **Restore latest full backup**
4. **Apply WAL archives** for point-in-time recovery
5. **Verify data integrity**
6. **Update application configuration**
7. **Test application functionality**
8. **Switch DNS/load balancer** to new database
9. **Monitor for issues**

## Backup Monitoring

### Celery Task for Backup Monitoring
```python
@shared_task
def verify_backup_health():
    """
    Verify that backups are running successfully.
    Alert if last backup is older than 25 hours.
    """
    import os
    from datetime import datetime, timedelta
    
    backup_dir = "/var/backups/postgres"
    latest_backup = None
    latest_time = None
    
    for filename in os.listdir(backup_dir):
        if filename.startswith("backup_") and filename.endswith(".dump"):
            file_path = os.path.join(backup_dir, filename)
            file_time = datetime.fromtimestamp(os.path.getmtime(file_path))
            if latest_time is None or file_time > latest_time:
                latest_time = file_time
                latest_backup = filename
    
    if latest_time is None:
        # No backups found - CRITICAL
        return "CRITICAL: No backups found"
    
    age = datetime.now() - latest_time
    if age > timedelta(hours=25):
        # Backup is too old - WARNING
        return f"WARNING: Latest backup is {age.total_seconds()/3600:.1f} hours old"
    
    return f"OK: Latest backup is {latest_backup} ({age.total_seconds()/3600:.1f} hours old)"
```

## Security Considerations

1. **Encryption at Rest**: All backups should be encrypted
2. **Encryption in Transit**: Use SSL/TLS for backup transfers
3. **Access Control**: Limit backup access to authorized personnel only
4. **Audit Logging**: Log all backup and restore operations
5. **Secure Storage**: Store backups in separate geographic location

## Environment Variables

Add to `.env`:
```env
# Backup Configuration
BACKUP_S3_BUCKET=your-backup-bucket
BACKUP_RETENTION_DAYS=30
BACKUP_ENCRYPTION_KEY=your-encryption-key
```

## Checklist

- [ ] Set up automated daily backups
- [ ] Configure WAL archiving
- [ ] Set up S3 bucket for off-site storage
- [ ] Test restore procedure
- [ ] Document recovery procedures
- [ ] Set up backup monitoring alerts
- [ ] Schedule monthly restore tests
- [ ] Review and update backup strategy quarterly
