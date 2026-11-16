# PostgreSQL Migration Guide

## Overview
This guide provides step-by-step instructions for migrating the volunteer platform from SQLite to PostgreSQL in production.

## Prerequisites

- PostgreSQL 14+ installed
- Database backup of current SQLite database
- Access to production server
- Downtime window scheduled

## Step 1: Install PostgreSQL

### Ubuntu/Debian
```bash
sudo apt update
sudo apt install postgresql postgresql-contrib
sudo systemctl start postgresql
sudo systemctl enable postgresql
```

### macOS
```bash
brew install postgresql@14
brew services start postgresql@14
```

### Windows
Download and install from: https://www.postgresql.org/download/windows/

## Step 2: Create Database and User

```bash
# Switch to postgres user
sudo -u postgres psql

# Create database
CREATE DATABASE volunteering_db;

# Create user with password
CREATE USER volunteer_admin WITH PASSWORD 'your_secure_password';

# Grant privileges
GRANT ALL PRIVILEGES ON DATABASE volunteering_db TO volunteer_admin;

# Grant schema privileges (PostgreSQL 15+)
\c volunteering_db
GRANT ALL ON SCHEMA public TO volunteer_admin;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO volunteer_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO volunteer_admin;

# Exit
\q
```

## Step 3: Configure PostgreSQL

Edit `/etc/postgresql/14/main/postgresql.conf`:

```conf
# Connection Settings
listen_addresses = 'localhost'  # or '*' for remote connections
max_connections = 100

# Memory Settings
shared_buffers = 256MB
effective_cache_size = 1GB
maintenance_work_mem = 64MB
work_mem = 4MB

# Write Ahead Log
wal_level = replica
max_wal_size = 1GB
min_wal_size = 80MB

# Query Planner
random_page_cost = 1.1  # For SSD
effective_io_concurrency = 200

# Logging
logging_collector = on
log_directory = 'log'
log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log'
log_statement = 'mod'  # Log all modifications
log_duration = on
log_line_prefix = '%t [%p]: [%l-1] user=%u,db=%d,app=%a,client=%h '
```

Edit `/etc/postgresql/14/main/pg_hba.conf`:

```conf
# Local connections
local   all             all                                     peer
host    all             all             127.0.0.1/32            scram-sha-256
host    all             all             ::1/128                 scram-sha-256

# Remote connections (if needed)
host    volunteering_db volunteer_admin 0.0.0.0/0              scram-sha-256
```

Restart PostgreSQL:
```bash
sudo systemctl restart postgresql
```

## Step 4: Update Django Settings

Update `backend/.env`:

```env
# Database Configuration
DB_ENGINE=django.db.backends.postgresql
DB_NAME=volunteering_db
DB_USER=volunteer_admin
DB_PASSWORD=your_secure_password
DB_HOST=localhost
DB_PORT=5432

# For production with connection pooling
DB_CONN_MAX_AGE=600
```

Update `backend/config/settings.py` (already configured):

```python
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': os.getenv('DB_NAME', 'volunteering_db'),
        'USER': os.getenv('DB_USER', 'postgres'),
        'PASSWORD': os.getenv('DB_PASSWORD', 'postgres'),
        'HOST': os.getenv('DB_HOST', 'localhost'),
        'PORT': os.getenv('DB_PORT', '5432'),
        'OPTIONS': {
            'connect_timeout': 10,
        },
        'CONN_MAX_AGE': int(os.getenv('DB_CONN_MAX_AGE', 0)),
    }
}
```

## Step 5: Install Python PostgreSQL Driver

```bash
pip install psycopg2-binary==2.9.9
```

Already included in `requirements.txt`.

## Step 6: Run Migrations

```bash
cd backend

# Test database connection
python manage.py dbshell
# If successful, you'll see: volunteering_db=>
# Type \q to exit

# Run migrations
python manage.py migrate

# Create superuser
python manage.py createsuperuser
```

## Step 7: Migrate Data from SQLite (if needed)

### Option A: Using Django dumpdata/loaddata

```bash
# 1. Backup SQLite data
python manage.py dumpdata --natural-foreign --natural-primary \
    --exclude contenttypes --exclude auth.Permission \
    --exclude admin.logentry --exclude sessions.session \
    > data_backup.json

# 2. Switch to PostgreSQL in .env
# Update DB_ENGINE=django.db.backends.postgresql

# 3. Run migrations on PostgreSQL
python manage.py migrate

# 4. Load data
python manage.py loaddata data_backup.json
```

### Option B: Using pgloader (Recommended for large databases)

Install pgloader:
```bash
# Ubuntu/Debian
sudo apt install pgloader

# macOS
brew install pgloader
```

Create migration script `migrate.load`:
```
LOAD DATABASE
    FROM sqlite://E:/Projects/Volunteering/backend/db.sqlite3
    INTO postgresql://volunteer_admin:your_password@localhost/volunteering_db

WITH include drop, create tables, create indexes, reset sequences

SET work_mem to '16MB', maintenance_work_mem to '512 MB';
```

Run migration:
```bash
pgloader migrate.load
```

## Step 8: Verify Migration

```bash
# Check tables
python manage.py dbshell
\dt

# Check data counts
SELECT COUNT(*) FROM users_customuser;
SELECT COUNT(*) FROM events_event;
SELECT COUNT(*) FROM initiatives_initiative;
SELECT COUNT(*) FROM reviews_review;

# Exit
\q

# Run tests
python manage.py test

# Check admin panel
python manage.py runserver
# Visit http://localhost:8000/admin
```

## Step 9: Create Database Indexes

Run the index migrations:

```bash
python manage.py migrate events 0003_add_indexes
python manage.py migrate initiatives 0003_add_indexes
python manage.py migrate notifications 0002_add_indexes
python manage.py migrate users 0002_add_indexes
```

## Step 10: Optimize PostgreSQL for Production

```sql
-- Connect to database
psql -U volunteer_admin -d volunteering_db

-- Analyze tables for query optimization
ANALYZE;

-- Vacuum to reclaim storage
VACUUM ANALYZE;

-- Check table sizes
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- Check index usage
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_scan,
    idx_tup_read,
    idx_tup_fetch
FROM pg_stat_user_indexes
ORDER BY idx_scan DESC;
```

## Step 11: Setup Automated Maintenance

Create cron job for regular maintenance:

```bash
# Edit crontab
crontab -e

# Add maintenance tasks
# Vacuum and analyze daily at 3 AM
0 3 * * * psql -U volunteer_admin -d volunteering_db -c "VACUUM ANALYZE;"

# Backup daily at 2 AM
0 2 * * * /path/to/backup.sh
```

## Step 12: Configure Connection Pooling (Optional)

For high-traffic production, use PgBouncer:

```bash
# Install PgBouncer
sudo apt install pgbouncer

# Configure /etc/pgbouncer/pgbouncer.ini
[databases]
volunteering_db = host=localhost port=5432 dbname=volunteering_db

[pgbouncer]
listen_addr = 127.0.0.1
listen_port = 6432
auth_type = md5
auth_file = /etc/pgbouncer/userlist.txt
pool_mode = transaction
max_client_conn = 1000
default_pool_size = 25

# Update Django settings
DB_HOST=localhost
DB_PORT=6432
```

## Troubleshooting

### Connection Issues

```bash
# Check PostgreSQL is running
sudo systemctl status postgresql

# Check PostgreSQL logs
sudo tail -f /var/log/postgresql/postgresql-14-main.log

# Test connection
psql -U volunteer_admin -d volunteering_db -h localhost
```

### Permission Issues

```sql
-- Grant all permissions
GRANT ALL PRIVILEGES ON DATABASE volunteering_db TO volunteer_admin;
GRANT ALL ON SCHEMA public TO volunteer_admin;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO volunteer_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO volunteer_admin;
```

### Migration Errors

```bash
# Reset migrations (CAUTION: Only for development)
python manage.py migrate --fake-initial

# Check migration status
python manage.py showmigrations

# Apply specific migration
python manage.py migrate app_name migration_name
```

## Performance Tuning

### Query Optimization

```python
# Use select_related for foreign keys
events = Event.objects.select_related('organizer').all()

# Use prefetch_related for many-to-many
events = Event.objects.prefetch_related('registrations').all()

# Use only() to fetch specific fields
users = CustomUser.objects.only('id', 'username', 'email')

# Use defer() to exclude fields
users = CustomUser.objects.defer('bio', 'avatar')
```

### Database Indexes

Already created in migrations:
- `events/migrations/0003_add_indexes.py`
- `initiatives/migrations/0003_add_indexes.py`
- `notifications/migrations/0002_add_indexes.py`
- `users/migrations/0002_add_indexes.py`

## Monitoring

### Check Active Connections

```sql
SELECT 
    datname,
    count(*) as connections
FROM pg_stat_activity
GROUP BY datname;
```

### Check Slow Queries

```sql
SELECT 
    query,
    calls,
    total_time,
    mean_time,
    max_time
FROM pg_stat_statements
ORDER BY mean_time DESC
LIMIT 10;
```

### Enable Query Logging

```sql
-- Log queries slower than 1 second
ALTER DATABASE volunteering_db SET log_min_duration_statement = 1000;
```

## Rollback Plan

If migration fails:

1. Stop application
2. Restore SQLite backup
3. Update `.env` to use SQLite
4. Restart application
5. Investigate issues
6. Retry migration

## Post-Migration Checklist

- [ ] All migrations applied successfully
- [ ] Data integrity verified
- [ ] Indexes created
- [ ] Backup strategy implemented
- [ ] Monitoring configured
- [ ] Performance tested
- [ ] Connection pooling configured (if needed)
- [ ] Automated maintenance scheduled
- [ ] Documentation updated
- [ ] Team notified

## Additional Resources

- PostgreSQL Documentation: https://www.postgresql.org/docs/
- Django PostgreSQL Notes: https://docs.djangoproject.com/en/5.0/ref/databases/#postgresql-notes
- PgBouncer Documentation: https://www.pgbouncer.org/
