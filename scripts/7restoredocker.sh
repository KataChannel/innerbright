#!/bin/bash

# Script restore Docker backups
# Sử dụng: ./7restoredocker.sh [backup_file_or_directory]

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BACKUP_ROOT="${PROJECT_DIR}/backups"
BACKUP_SOURCE="${1:-}"

# Logging functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_question() {
    echo -e "${BLUE}[?]${NC} $1"
}

# Change to project directory
cd "$PROJECT_DIR"

# Detect Docker Compose command
if command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE="docker-compose"
elif docker compose version &> /dev/null; then
    DOCKER_COMPOSE="docker compose"
else
    log_error "Docker Compose not found. Please install Docker Compose."
    exit 1
fi

log_info "Using Docker Compose: $DOCKER_COMPOSE"

# List available backups
list_backups() {
    echo ""
    echo -e "${BLUE}=== Available Backups ===${NC}"
    echo ""
    
    if [ ! -d "$BACKUP_ROOT" ]; then
        log_warn "No backup directory found: $BACKUP_ROOT"
        return 1
    fi
    
    local backups=($(find "$BACKUP_ROOT" -maxdepth 1 -type d -name "[0-9]*" -printf '%f\n' 2>/dev/null | sort -r | head -5))
    
    if [ ${#backups[@]} -eq 0 ]; then
        log_warn "No backups found!"
        return 1
    fi
    
    local index=1
    for backup in "${backups[@]}"; do
        local timestamp="$backup"
        local backup_path="${BACKUP_ROOT}/${backup}"
        local size=$(du -sh "$backup_path" 2>/dev/null | awk '{print $1}')
        local date_formatted=$(date -d "${timestamp:0:8} ${timestamp:8:2}:${timestamp:10:2}:${timestamp:12:2}" "+%Y-%m-%d %H:%M:%S" 2>/dev/null || echo "Unknown date")
        
        echo -e "  ${GREEN}[$index]${NC} $timestamp"
        echo "      Date: $date_formatted"
        echo "      Size: $size"
        
        # List files in backup
        local files=$(find "$backup_path" -type f \( -name "*.sql.gz" -o -name "*.archive.gz" -o -name "*.rdb.gz" -o -name "*.tar.gz" \) -printf '%f\n' 2>/dev/null | head -3)
        if [ -n "$files" ]; then
            echo "      Files: $(echo "$files" | tr '\n' ', ' | sed 's/,$//')"
        fi
        echo ""
        ((index++))
    done
    
    return 0
}

# Select backup interactively
select_backup() {
    list_backups || return 1
    
    echo ""
    log_question "Select backup number (1-5), enter timestamp (YYYYMMDDHHMMSS), or 'latest': "
    read -r selection
    
    if [ "$selection" = "latest" ]; then
        if [ -L "${BACKUP_ROOT}/latest" ]; then
            BACKUP_SOURCE=$(readlink -f "${BACKUP_ROOT}/latest")
            log_info "Selected latest backup: ${BACKUP_SOURCE##*/}"
        else
            log_error "Latest backup symlink not found"
            return 1
        fi
    elif [[ "$selection" =~ ^[0-9]{14}$ ]]; then
        # User entered timestamp
        BACKUP_SOURCE="${BACKUP_ROOT}/${selection}"
        if [ ! -d "$BACKUP_SOURCE" ]; then
            log_error "Backup not found: $selection"
            return 1
        fi
        log_info "Selected backup: $selection"
    elif [[ "$selection" =~ ^[1-5]$ ]]; then
        # User selected number
        local backups=($(find "$BACKUP_ROOT" -maxdepth 1 -type d -name "[0-9]*" -printf '%p\n' 2>/dev/null | sort -r | head -5))
        local index=$((selection - 1))
        
        if [ $index -lt ${#backups[@]} ]; then
            BACKUP_SOURCE="${backups[$index]}"
            log_info "Selected backup: ${BACKUP_SOURCE##*/}"
        else
            log_error "Invalid selection"
            return 1
        fi
    else
        log_error "Invalid input"
        return 1
    fi
    
    return 0
}

# Check if backup source provided or prompt for selection
if [ -z "$BACKUP_SOURCE" ]; then
    if ! select_backup; then
        exit 1
    fi
elif [[ "$BACKUP_SOURCE" =~ ^[0-9]{14}$ ]]; then
    # Timestamp provided as argument
    BACKUP_SOURCE="${BACKUP_ROOT}/${BACKUP_SOURCE}"
    if [ ! -d "$BACKUP_SOURCE" ]; then
        log_error "Backup not found: $BACKUP_SOURCE"
        exit 1
    fi
elif [ "$BACKUP_SOURCE" = "latest" ]; then
    if [ -L "${BACKUP_ROOT}/latest" ]; then
        BACKUP_SOURCE=$(readlink -f "${BACKUP_ROOT}/latest")
    else
        log_error "Latest backup symlink not found"
        exit 1
    fi
fi

# Verify backup exists
if [ ! -e "$BACKUP_SOURCE" ]; then
    log_error "Backup source not found: $BACKUP_SOURCE"
    exit 1
fi

# Confirmation prompt
confirm_restore() {
    log_warn "⚠️  WARNING: This will OVERWRITE existing data!"
    log_question "Are you sure you want to restore? (yes/no): "
    read -r response
    if [ "$response" != "yes" ]; then
        log_info "Restore cancelled."
        exit 0
    fi
}

# Restore PostgreSQL
restore_postgres() {
    local backup_dir=$1
    local backup_file=$(find "$backup_dir" -name "postgres.sql.gz" -o -name "postgres.sql" | head -1)
    
    if [ -z "$backup_file" ]; then
        log_warn "PostgreSQL backup not found in: $backup_dir"
        return 0
    fi
    
    log_info "Restoring PostgreSQL from: ${backup_file##*/}"
    
    # Decompress if needed
    local sql_file="$backup_file"
    if [[ "$backup_file" == *.gz ]]; then
        sql_file="${backup_file%.gz}"
        gunzip -k "$backup_file"
    fi
    
    # Stop application containers to prevent connections
    log_info "Stopping dependent services..."
    $DOCKER_COMPOSE stop backend frontend || true
    
    # Terminate all active connections to the database
    log_info "Terminating active database connections..."
    $DOCKER_COMPOSE exec -T postgres psql -U postgres -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '${POSTGRES_DB:-rausachcore}' AND pid <> pg_backend_pid();" || true
    
    # Drop and recreate database
    log_info "Recreating database..."
    $DOCKER_COMPOSE exec -T postgres psql -U postgres -c "DROP DATABASE IF EXISTS ${POSTGRES_DB:-rausachcore};" || true
    $DOCKER_COMPOSE exec -T postgres psql -U postgres -c "CREATE DATABASE ${POSTGRES_DB:-rausachcore};"
    
    # Restore
    if cat "$sql_file" | $DOCKER_COMPOSE exec -T postgres psql -U postgres; then
        log_info "PostgreSQL restore completed successfully!"
    else
        log_error "PostgreSQL restore failed!"
        return 1
    fi
    
    # Cleanup decompressed file if it was compressed
    if [[ "$backup_file" == *.gz ]] && [ -f "$sql_file" ]; then
        rm "$sql_file"
    fi
    
    # Restart services
    log_info "Restarting services..."
    $DOCKER_COMPOSE up -d backend frontend
}

# Restore MongoDB
restore_mongodb() {
    local backup_dir=$1
    local backup_file=$(find "$backup_dir" -name "mongodb.archive.gz" -o -name "mongodb.archive" | head -1)
    
    if [ -z "$backup_file" ]; then
        log_warn "MongoDB backup not found in: $backup_dir"
        return 0
    fi
    
    log_info "Restoring MongoDB from: ${backup_file##*/}"
    
    # Decompress if needed
    local archive_file="$backup_file"
    if [[ "$backup_file" == *.gz ]]; then
        archive_file="${backup_file%.gz}"
        gunzip -k "$backup_file"
    fi
    
    # Restore
    if cat "$archive_file" | $DOCKER_COMPOSE exec -T mongo mongorestore --archive --drop; then
        log_info "MongoDB restore completed successfully!"
    else
        log_error "MongoDB restore failed!"
        return 1
    fi
    
    # Cleanup
    if [[ "$backup_file" == *.gz ]] && [ -f "$archive_file" ]; then
        rm "$archive_file"
    fi
}

# Restore Redis
restore_redis() {
    local backup_dir=$1
    local backup_file=$(find "$backup_dir" -name "redis.rdb.gz" -o -name "redis.rdb" | head -1)
    
    if [ -z "$backup_file" ]; then
        log_warn "Redis backup not found in: $backup_dir"
        return 0
    fi
    
    log_info "Restoring Redis from: ${backup_file##*/}"
    
    # Decompress if needed
    local rdb_file="$backup_file"
    if [[ "$backup_file" == *.gz ]]; then
        rdb_file="${backup_file%.gz}"
        gunzip -k "$backup_file"
    fi
    
    # Stop Redis
    $DOCKER_COMPOSE stop redis
    
    # Copy RDB file to Redis volume
    local redis_volume=$(docker volume ls -q | grep redis-data)
    if [ -n "$redis_volume" ]; then
        docker run --rm \
            -v "${redis_volume}:/data" \
            -v "$(dirname "$rdb_file"):/backup" \
            alpine cp "/backup/$(basename "$rdb_file")" /data/dump.rdb
        
        log_info "Redis restore completed successfully!"
    else
        log_error "Redis volume not found!"
        return 1
    fi
    
    # Cleanup and restart
    if [[ "$backup_file" == *.gz ]] && [ -f "$rdb_file" ]; then
        rm "$rdb_file"
    fi
    $DOCKER_COMPOSE start redis
}

# Restore Docker volume
restore_volume() {
    local backup_file=$1
    local filename="${backup_file##*/}"
    local volume_name=$(echo "$filename" | sed -E 's/volume_(.+)\.tar\.gz/\1/')
    
    log_info "Restoring volume: $volume_name from ${backup_file##*/}"
    
    # Create volume if doesn't exist
    docker volume create "$volume_name" || true
    
    # Restore
    if docker run --rm \
        -v "${volume_name}:/data" \
        -v "$(dirname "$backup_file"):/backup" \
        alpine sh -c "rm -rf /data/* && tar xzf /backup/${backup_file##*/} -C /data"; then
        log_info "Volume restore completed: $volume_name"
    else
        log_error "Volume restore failed: $volume_name"
        return 1
    fi
}

# Auto-detect and restore from backup file
restore_single_file() {
    local file=$1
    local filename="${file##*/}"
    
    if [[ "$filename" == postgres.sql* ]]; then
        local dir=$(dirname "$file")
        restore_postgres "$dir"
    elif [[ "$filename" == mongodb.archive* ]]; then
        local dir=$(dirname "$file")
        restore_mongodb "$dir"
    elif [[ "$filename" == redis.rdb* ]]; then
        local dir=$(dirname "$file")
        restore_redis "$dir"
    elif [[ "$filename" == volume_*.tar.gz ]]; then
        restore_volume "$file"
    else
        log_warn "Unknown backup file type: $filename, skipping..."
    fi
}

# Restore from directory (restore all backups)
restore_from_directory() {
    local backup_dir=$1
    log_info "Restoring from directory: ${backup_dir##*/}"
    
    # Restore databases
    restore_postgres "$backup_dir"
    restore_mongodb "$backup_dir"
    restore_redis "$backup_dir"
    
    # Restore volumes
    find "$backup_dir" -name "volume_*.tar.gz" -type f | while read -r volume_backup; do
        restore_volume "$volume_backup"
    done
}

# Main execution
main() {
    log_info "========================================="
    log_info "Docker Restore Script"
    log_info "========================================="
    
    # Confirmation
    confirm_restore
    
    # Determine restore type
    if [ -f "$BACKUP_SOURCE" ]; then
        # Single file restore
        restore_single_file "$BACKUP_SOURCE"
    elif [ -d "$BACKUP_SOURCE" ]; then
        # Directory restore
        restore_from_directory "$BACKUP_SOURCE"
    else
        log_error "Invalid backup source: $BACKUP_SOURCE"
        exit 1
    fi
    
    log_info "========================================="
    log_info "Restore Process Completed!"
    log_info "========================================="
}

# Run main
main
