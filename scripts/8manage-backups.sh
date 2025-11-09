#!/bin/bash

# Backup Management Helper Script
# Sử dụng: ./8manage-backups.sh [command] [options]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BACKUP_DIR="${PROJECT_DIR}/backups"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Show usage
show_usage() {
    cat << EOF
${BLUE}Backup Management Helper${NC}

Usage: $0 <command> [options]

Commands:
  ${GREEN}list${NC}              List all backups
  ${GREEN}latest${NC}            Show latest backups
  ${GREEN}size${NC}              Show backup sizes
  ${GREEN}clean${NC} <days>      Delete backups older than X days (default: 30)
  ${GREEN}verify${NC}            Verify backup integrity
  ${GREEN}compress${NC}          Compress uncompressed backups
  ${GREEN}sync${NC} <dest>       Sync backups to remote location
  ${GREEN}info${NC} <file>       Show detailed info about a backup file

Examples:
  $0 list
  $0 latest
  $0 clean 7
  $0 verify
  $0 sync user@server:/backup/

EOF
    exit 0
}

# List all backups
cmd_list() {
    echo -e "${BLUE}=== All Backups ===${NC}"
    if [ ! -d "$BACKUP_DIR" ] || [ -z "$(ls -A "$BACKUP_DIR" 2>/dev/null)" ]; then
        echo "No backups found."
        return
    fi
    
    echo ""
    printf "%-20s %-20s %-10s %s\n" "TIMESTAMP" "DATE" "SIZE" "FILES"
    echo "--------------------------------------------------------------------------------"
    
    find "$BACKUP_DIR" -maxdepth 1 -type d -name "[0-9]*" | sort -r | while read -r backup; do
        local timestamp=$(basename "$backup")
        local size=$(du -sh "$backup" 2>/dev/null | awk '{print $1}')
        local file_count=$(find "$backup" -type f | wc -l)
        local date_formatted=$(date -d "${timestamp:0:8} ${timestamp:8:2}:${timestamp:10:2}:${timestamp:12:2}" "+%Y-%m-%d %H:%M:%S" 2>/dev/null || echo "Invalid")
        
        printf "%-20s %-20s %-10s %s\n" "$timestamp" "$date_formatted" "$size" "$file_count files"
    done
    
    echo ""
    if [ -L "${BACKUP_DIR}/latest" ]; then
        local latest=$(readlink "${BACKUP_DIR}/latest")
        echo -e "${GREEN}Latest:${NC} $(basename "$latest")"
    fi
}

# Show latest backups
cmd_latest() {
    echo -e "${BLUE}=== Latest 5 Backups ===${NC}"
    if [ ! -d "$BACKUP_DIR" ]; then
        echo "No backups found."
        return
    fi
    
    echo ""
    local backups=($(find "$BACKUP_DIR" -maxdepth 1 -type d -name "[0-9]*" | sort -r | head -5))
    
    if [ ${#backups[@]} -eq 0 ]; then
        echo "No backups found."
        return
    fi
    
    for backup in "${backups[@]}"; do
        local timestamp=$(basename "$backup")
        local size=$(du -sh "$backup" 2>/dev/null | awk '{print $1}')
        local date_formatted=$(date -d "${timestamp:0:8} ${timestamp:8:2}:${timestamp:10:2}:${timestamp:12:2}" "+%Y-%m-%d %H:%M:%S" 2>/dev/null || echo "Unknown")
        
        echo -e "${GREEN}Timestamp:${NC} $timestamp"
        echo -e "${GREEN}Date:${NC}      $date_formatted"
        echo -e "${GREEN}Size:${NC}      $size"
        echo -e "${GREEN}Location:${NC}  $backup"
        
        # Show files
        echo -e "${GREEN}Files:${NC}"
        find "$backup" -type f \( -name "*.sql.gz" -o -name "*.archive.gz" -o -name "*.rdb.gz" \) -exec basename {} \; | while read -r file; do
            local file_size=$(find "$backup" -name "$file" -exec du -h {} \; | awk '{print $1}')
            echo "  - $file ($file_size)"
        done
        
        # Count volumes
        local volume_count=$(find "$backup" -name "volume_*.tar.gz" | wc -l)
        if [ $volume_count -gt 0 ]; then
            echo "  - $volume_count volume backup(s)"
        fi
        
        echo ""
    done
}

# Show backup sizes
cmd_size() {
    echo -e "${BLUE}=== Backup Sizes ===${NC}"
    if [ ! -d "$BACKUP_DIR" ]; then
        echo "No backups found."
        return
    fi
    
    echo -e "\n${GREEN}Total:${NC}"
    du -sh "$BACKUP_DIR"
    
    echo -e "\n${GREEN}By Backup (Top 10):${NC}"
    find "$BACKUP_DIR" -maxdepth 1 -type d -name "[0-9]*" -exec du -sh {} \; 2>/dev/null | sort -rh | head -10 | while read -r size dir; do
        local timestamp=$(basename "$dir")
        local date_formatted=$(date -d "${timestamp:0:8} ${timestamp:8:2}:${timestamp:10:2}:${timestamp:12:2}" "+%Y-%m-%d %H:%M" 2>/dev/null || echo "")
        echo "  $size - $timestamp ($date_formatted)"
    done
    
    echo -e "\n${GREEN}Backup Count:${NC}"
    local count=$(find "$BACKUP_DIR" -maxdepth 1 -type d -name "[0-9]*" | wc -l)
    echo "  Total backups: $count"
}

# Clean old backups
cmd_clean() {
    local days=${1:-30}
    
    echo -e "${YELLOW}⚠️  WARNING: This will delete backups older than $days days!${NC}"
    echo -n "Are you sure? (yes/no): "
    read -r response
    
    if [ "$response" != "yes" ]; then
        echo "Cancelled."
        return
    fi
    
    echo -e "${BLUE}Cleaning backups older than $days days...${NC}"
    
    local count=0
    while IFS= read -r backup_folder; do
        if [ -n "$backup_folder" ]; then
            local timestamp=$(basename "$backup_folder")
            echo "  Deleting: $timestamp"
            rm -rf "$backup_folder"
            ((count++))
        fi
    done < <(find "$BACKUP_DIR" -maxdepth 1 -type d -name "[0-9]*" -mtime +${days} 2>/dev/null)
    
    echo -e "${GREEN}Deleted $count backup folder(s).${NC}"
}

# Verify backup integrity
cmd_verify() {
    echo -e "${BLUE}=== Verifying Backups ===${NC}"
    local failed=0
    
    # Verify gzip files
    echo -e "\n${GREEN}Checking gzip files...${NC}"
    while IFS= read -r file; do
        if [ -n "$file" ]; then
            if gunzip -t "$file" 2>/dev/null; then
                echo "  ✓ $(basename "$file")"
            else
                echo -e "  ${RED}✗ $(basename "$file")${NC}"
                ((failed++))
            fi
        fi
    done < <(find "$BACKUP_DIR" -name "*.gz" -type f 2>/dev/null)
    
    # Verify tar files
    echo -e "\n${GREEN}Checking tar.gz files...${NC}"
    while IFS= read -r file; do
        if [ -n "$file" ]; then
            if tar tzf "$file" >/dev/null 2>&1; then
                echo "  ✓ $(basename "$file")"
            else
                echo -e "  ${RED}✗ $(basename "$file")${NC}"
                ((failed++))
            fi
        fi
    done < <(find "$BACKUP_DIR" -name "*.tar.gz" -type f 2>/dev/null)
    
    if [ $failed -eq 0 ]; then
        echo -e "\n${GREEN}All backups verified successfully!${NC}"
    else
        echo -e "\n${RED}$failed backup(s) failed verification!${NC}"
        return 1
    fi
}

# Compress uncompressed backups
cmd_compress() {
    echo -e "${BLUE}=== Compressing Backups ===${NC}"
    local count=0
    
    # Find uncompressed SQL files
    while IFS= read -r file; do
        if [ -n "$file" ]; then
            echo "  Compressing: $(basename "$file")"
            gzip "$file"
            ((count++))
        fi
    done < <(find "$BACKUP_DIR" -name "*.sql" -not -name "*.gz" -type f 2>/dev/null)
    
    # Find uncompressed archive files
    while IFS= read -r file; do
        if [ -n "$file" ]; then
            echo "  Compressing: $(basename "$file")"
            gzip "$file"
            ((count++))
        fi
    done < <(find "$BACKUP_DIR" -name "*.archive" -not -name "*.gz" -type f 2>/dev/null)
    
    # Find uncompressed RDB files
    while IFS= read -r file; do
        if [ -n "$file" ]; then
            echo "  Compressing: $(basename "$file")"
            gzip "$file"
            ((count++))
        fi
    done < <(find "$BACKUP_DIR" -name "*.rdb" -not -name "*.gz" -type f 2>/dev/null)
    
    echo -e "${GREEN}Compressed $count files.${NC}"
}

# Sync backups to remote
cmd_sync() {
    local dest=$1
    
    if [ -z "$dest" ]; then
        echo -e "${RED}Error: Destination required${NC}"
        echo "Usage: $0 sync <destination>"
        echo "Example: $0 sync user@server:/backup/"
        return 1
    fi
    
    echo -e "${BLUE}Syncing backups to: $dest${NC}"
    
    if command -v rsync &> /dev/null; then
        rsync -avz --progress "$BACKUP_DIR/" "$dest"
        echo -e "${GREEN}Sync completed!${NC}"
    else
        echo -e "${YELLOW}rsync not found, using scp...${NC}"
        scp -r "$BACKUP_DIR"/* "$dest"
        echo -e "${GREEN}Copy completed!${NC}"
    fi
}

# Show detailed info about a backup
cmd_info() {
    local input=$1
    
    if [ -z "$input" ]; then
        echo -e "${RED}Error: Timestamp or path required${NC}"
        echo "Usage: $0 info <timestamp|path>"
        echo "Example: $0 info 20251017011126"
        return 1
    fi
    
    # Check if input is timestamp or path
    local backup_path
    if [[ "$input" =~ ^[0-9]{14}$ ]]; then
        backup_path="${BACKUP_DIR}/${input}"
    else
        backup_path="$input"
    fi
    
    if [ ! -d "$backup_path" ]; then
        echo -e "${RED}Error: Backup not found: $backup_path${NC}"
        return 1
    fi
    
    local timestamp=$(basename "$backup_path")
    local date_formatted=$(date -d "${timestamp:0:8} ${timestamp:8:2}:${timestamp:10:2}:${timestamp:12:2}" "+%Y-%m-%d %H:%M:%S" 2>/dev/null || echo "Unknown")
    
    echo -e "${BLUE}=== Backup Info ===${NC}"
    echo ""
    echo "Timestamp: $timestamp"
    echo "Date: $date_formatted"
    echo "Path: $(realpath "$backup_path")"
    echo "Size: $(du -sh "$backup_path" | awk '{print $1}')"
    echo ""
    
    echo -e "${GREEN}Files:${NC}"
    find "$backup_path" -type f | sort | while read -r file; do
        local filename=$(basename "$file")
        local filesize=$(du -h "$file" | awk '{print $1}')
        local filetype=$(file -b "$file" | cut -d',' -f1)
        echo "  - $filename"
        echo "    Size: $filesize"
        echo "    Type: $filetype"
    done
    
    # Show summary if exists
    if [ -f "$backup_path/summary.txt" ]; then
        echo ""
        echo -e "${GREEN}Summary:${NC}"
        cat "$backup_path/summary.txt" | sed 's/^/  /'
    fi
}

# Main
main() {
    if [ $# -eq 0 ]; then
        show_usage
    fi
    
    local command=$1
    shift
    
    case $command in
        list)
            cmd_list "$@"
            ;;
        latest)
            cmd_latest "$@"
            ;;
        size)
            cmd_size "$@"
            ;;
        clean)
            cmd_clean "$@"
            ;;
        verify)
            cmd_verify "$@"
            ;;
        compress)
            cmd_compress "$@"
            ;;
        sync)
            cmd_sync "$@"
            ;;
        info)
            cmd_info "$@"
            ;;
        help|--help|-h)
            show_usage
            ;;
        *)
            echo -e "${RED}Unknown command: $command${NC}"
            echo ""
            show_usage
            ;;
    esac
}

main "$@"
