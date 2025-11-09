#!/bin/bash

# Script backup Docker containers với error handling
# Sử dụng: ./6backupdocker.sh [backup_dir]

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# Cấu hình
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BACKUP_ROOT="${1:-${PROJECT_DIR}/backups}"
TIMESTAMP=$(date +%Y%m%d%H%M%S)
BACKUP_DIR="${BACKUP_ROOT}/${TIMESTAMP}"
LOG_FILE="${BACKUP_DIR}/backup.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1" | tee -a "$LOG_FILE"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
}

# Tạo thư mục backup với timestamp
mkdir -p "$BACKUP_DIR"
log_info "Starting backup process - $TIMESTAMP"
log_info "Backup directory: $BACKUP_DIR"
log_info "Backup timestamp: $TIMESTAMP"

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

# Kiểm tra container đang chạy
check_container() {
    local container_name=$1
    if $DOCKER_COMPOSE ps | grep -q "${container_name}.*Up"; then
        return 0
    else
        return 1
    fi
}

# Backup PostgreSQL
backup_postgres() {
    log_info "Backing up PostgreSQL..."
    if check_container "postgres"; then
        local backup_file="${BACKUP_DIR}/postgres.sql"
        if $DOCKER_COMPOSE exec -T postgres pg_dumpall -U postgres > "$backup_file" 2>>"$LOG_FILE"; then
            log_info "PostgreSQL backup completed: $(basename "$backup_file")"
            # Compress backup
            gzip "$backup_file" && log_info "Compressed to: $(basename "$backup_file").gz"
        else
            log_error "PostgreSQL backup failed"
            return 1
        fi
    else
        log_warn "PostgreSQL container not running, skipping..."
    fi
}

# Backup MongoDB
backup_mongodb() {
    log_info "Backing up MongoDB..."
    if check_container "mongo"; then
        local backup_file="${BACKUP_DIR}/mongodb.archive"
        if $DOCKER_COMPOSE exec -T mongo mongodump --archive > "$backup_file" 2>>"$LOG_FILE"; then
            log_info "MongoDB backup completed: $(basename "$backup_file")"
            # Compress backup
            gzip "$backup_file" && log_info "Compressed to: $(basename "$backup_file").gz"
        else
            log_error "MongoDB backup failed"
            return 1
        fi
    else
        log_warn "MongoDB container not running, skipping..."
    fi
}

# Backup Redis
backup_redis() {
    log_info "Backing up Redis..."
    if check_container "redis"; then
        # Trigger BGSAVE
        $DOCKER_COMPOSE exec -T redis redis-cli BGSAVE >> "$LOG_FILE" 2>&1
        sleep 2  # Wait for BGSAVE to complete
        
        # Copy RDB file
        local backup_file="${BACKUP_DIR}/redis.rdb"
        if $DOCKER_COMPOSE exec -T redis cat /data/dump.rdb > "$backup_file" 2>>"$LOG_FILE"; then
            log_info "Redis backup completed: $(basename "$backup_file")"
            # Compress backup
            gzip "$backup_file" && log_info "Compressed to: $(basename "$backup_file").gz"
        else
            log_error "Redis backup failed"
            return 1
        fi
    else
        log_warn "Redis container not running, skipping..."
    fi
}

# Backup MinIO (S3-compatible storage)
backup_minio() {
    log_info "Backing up MinIO data..."
    if check_container "minio"; then
        local backup_file="${BACKUP_DIR}/minio.tar.gz"
        local minio_volume=$(docker volume ls -q | grep minio-data || echo "")
        
        if [ -n "$minio_volume" ]; then
            if docker run --rm \
                -v "${minio_volume}:/data:ro" \
                -v "${BACKUP_DIR}:/backup" \
                alpine tar czf "/backup/$(basename "$backup_file")" -C /data . >> "$LOG_FILE" 2>&1; then
                log_info "MinIO backup completed: $(basename "$backup_file")"
            else
                log_error "MinIO backup failed"
                return 1
            fi
        else
            log_warn "MinIO volume not found, skipping..."
        fi
    else
        log_warn "MinIO container not running, skipping..."
    fi
}

# Backup specific Docker volumes
backup_volumes() {
    log_info "Backing up important Docker volumes..."
    
    # Get project-specific volumes
    local volumes=$(docker volume ls --format "{{.Name}}" | grep "$(basename "$PROJECT_DIR")" || echo "")
    
    if [ -z "$volumes" ]; then
        log_warn "No project volumes found, skipping volume backup..."
        return 0
    fi
    
    local volume_count=0
    while IFS= read -r volume; do
        if [ -n "$volume" ]; then
            log_info "Backing up volume: $volume"
            local backup_file="${BACKUP_DIR}/volume_${volume}.tar.gz"
            
            if docker run --rm \
                -v "${volume}:/data:ro" \
                -v "${BACKUP_DIR}:/backup" \
                alpine tar czf "/backup/$(basename "$backup_file")" -C /data . >> "$LOG_FILE" 2>&1; then
                log_info "Volume backup completed: $(basename "$backup_file")"
                ((volume_count++))
            else
                log_error "Failed to backup volume: $volume"
            fi
        fi
    done <<< "$volumes"
    
    log_info "Backed up $volume_count volumes"
}

# Backup docker-compose configuration
backup_config() {
    log_info "Backing up configuration files..."
    local config_backup="${BACKUP_DIR}/config.tar.gz"
    
    tar czf "$config_backup" \
        docker-compose*.yml \
        .env* \
        Makefile* \
        2>> "$LOG_FILE" || log_warn "Some config files missing"
    
    log_info "Configuration backup completed: $(basename "$config_backup")"
}

# Cleanup old backups
cleanup_old_backups() {
    log_info "Cleaning up old backups (older than 30 days)..."
    local deleted_count=0
    while IFS= read -r backup_folder; do
        if [ -n "$backup_folder" ]; then
            log_info "Deleting old backup: $(basename "$backup_folder")"
            rm -rf "$backup_folder"
            ((deleted_count++))
        fi
    done < <(find "$BACKUP_ROOT" -maxdepth 1 -type d -name "[0-9]*" -mtime +30 2>/dev/null)
    log_info "Deleted $deleted_count old backup folders"
}

# Generate backup summary
generate_summary() {
    log_info "Generating backup summary..."
    local summary_file="${BACKUP_DIR}/summary.txt"
    
    {
        echo "======================================"
        echo "Backup Summary"
        echo "======================================"
        echo ""
        echo "Timestamp: $TIMESTAMP"
        echo "Backup Location: $BACKUP_DIR"
        echo "Backup Date: $(date)"
        echo ""
        echo "Files Created:"
        find "$BACKUP_DIR" -type f \( -name "*.sql.gz" -o -name "*.archive.gz" -o -name "*.rdb.gz" -o -name "*.tar.gz" \) -exec ls -lh {} \; | awk '{print $9, "-", $5}'
        echo ""
        echo "Total Backup Size:"
        du -sh "$BACKUP_DIR"
        echo ""
        echo "======================================"
    } > "$summary_file"
    
    cat "$summary_file"
    log_info "Summary saved to: $(basename "$summary_file")"
    
    # Create a symlink to latest backup
    ln -sfn "$BACKUP_DIR" "${BACKUP_ROOT}/latest"
    log_info "Created symlink: ${BACKUP_ROOT}/latest -> $TIMESTAMP"
}

# Main execution
main() {
    log_info "========================================="
    log_info "Docker Backup Script Started"
    log_info "========================================="
    
    # Run backups (continue on individual failures)
    backup_postgres || true
    backup_mongodb || true
    backup_redis || true
    backup_minio || true
    backup_volumes || true
    backup_config || true
    
    # Cleanup
    cleanup_old_backups || true
    
    # Summary
    generate_summary
    
    log_info "========================================="
    log_info "Backup Process Completed Successfully!"
    log_info "========================================="
    log_info "Logs saved to: $LOG_FILE"
}

# Run main function
main