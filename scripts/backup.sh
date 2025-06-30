#!/bin/bash

# Database Backup Script for KataCore
# This script creates automated backups of PostgreSQL database

set -e

# Configuration
BACKUP_DIR="/backups"
RETENTION_DAYS=${BACKUP_RETENTION_DAYS:-7}
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="katacore_backup_${TIMESTAMP}.sql"
COMPRESSED_FILE="${BACKUP_FILE}.gz"

# Database connection info
DB_HOST=${PGHOST:-postgres}
DB_NAME=${PGDATABASE:-katacore}
DB_USER=${PGUSER:-postgres}
DB_PASSWORD=${PGPASSWORD}

echo "🗄️  Starting database backup..."
echo "📅 Timestamp: $TIMESTAMP"
echo "🎯 Database: $DB_NAME@$DB_HOST"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Create the backup
echo "💾 Creating backup..."
pg_dump -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" \
    --verbose \
    --no-owner \
    --no-privileges \
    --clean \
    --if-exists \
    > "$BACKUP_DIR/$BACKUP_FILE"

# Compress the backup
echo "🗜️  Compressing backup..."
gzip "$BACKUP_DIR/$BACKUP_FILE"

# Verify backup was created
if [ -f "$BACKUP_DIR/$COMPRESSED_FILE" ]; then
    BACKUP_SIZE=$(du -h "$BACKUP_DIR/$COMPRESSED_FILE" | cut -f1)
    echo "✅ Backup created successfully: $COMPRESSED_FILE ($BACKUP_SIZE)"
else
    echo "❌ Backup creation failed!"
    exit 1
fi

# Clean up old backups
echo "🧹 Cleaning up old backups (keeping last $RETENTION_DAYS days)..."
find "$BACKUP_DIR" -name "katacore_backup_*.sql.gz" -type f -mtime +$RETENTION_DAYS -exec rm -f {} \;

# List current backups
echo "📋 Current backups:"
ls -lah "$BACKUP_DIR"/katacore_backup_*.sql.gz 2>/dev/null || echo "No backups found"

echo "🎉 Backup process completed successfully!"
