#!/bin/bash

# Innerbright Production Management Script
# Manage your deployed Innerbright application

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Configuration
PROJECT_DIR="/opt/innerbright"
BACKUP_DIR="$PROJECT_DIR/backups"
LOG_DIR="$PROJECT_DIR/logs"

# Utility functions
log() {
    echo -e "$1"
}

error_exit() {
    log "${RED}❌ Error: $1${NC}"
    exit 1
}

check_project_dir() {
    if [[ ! -f "$PROJECT_DIR/docker-compose.yml" ]]; then
        error_exit "Innerbright project not found at $PROJECT_DIR"
    fi
    cd "$PROJECT_DIR"
}

# Main menu function
show_menu() {
    clear
    echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                      🚀 INNERBRIGHT MANAGEMENT CONSOLE 🚀                     ║${NC}"
    echo -e "${BLUE}╠═══════════════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${BLUE}║                                                                               ║${NC}"
    echo -e "${BLUE}║   ${CYAN}1.${NC} 📊 Service Status          ${CYAN}11.${NC} 🔧 Update Application       ║${NC}"
    echo -e "${BLUE}║   ${CYAN}2.${NC} 🔄 Restart Services        ${CYAN}12.${NC} 🏗️  Rebuild Containers       ║${NC}"
    echo -e "${BLUE}║   ${CYAN}3.${NC} ⏹️  Stop Services           ${CYAN}13.${NC} 📋 View Logs                ║${NC}"
    echo -e "${BLUE}║   ${CYAN}4.${NC} ▶️  Start Services          ${CYAN}14.${NC} 🧹 Clean Logs               ║${NC}"
    echo -e "${BLUE}║   ${CYAN}5.${NC} 💾 Database Backup         ${CYAN}15.${NC} 📈 System Resources         ║${NC}"
    echo -e "${BLUE}║   ${CYAN}6.${NC} 🔄 Database Restore        ${CYAN}16.${NC} 🔒 Security Status          ║${NC}"
    echo -e "${BLUE}║   ${CYAN}7.${NC} 🗂️  List Backups            ${CYAN}17.${NC} 🔑 SSL Certificate Status   ║${NC}"
    echo -e "${BLUE}║   ${CYAN}8.${NC} 🏥 Health Check            ${CYAN}18.${NC} 🔄 Renew SSL Certificate    ║${NC}"
    echo -e "${BLUE}║   ${CYAN}9.${NC} 🔍 Service Logs            ${CYAN}19.${NC} ⚙️  Configuration             ║${NC}"
    echo -e "${BLUE}║   ${CYAN}10.${NC} 🧹 Clean System           ${CYAN}20.${NC} 🚪 Exit                     ║${NC}"
    echo -e "${BLUE}║                                                                               ║${NC}"
    echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo
}

# Service management functions
service_status() {
    log "${CYAN}📊 Checking service status...${NC}\n"
    
    check_project_dir
    
    # Docker compose status
    docker compose ps
    
    echo
    log "${CYAN}🏥 Health Check Results:${NC}"
    
    # Test endpoints
    services=(
        "Next.js Frontend:http://localhost:3000/api/health"
        "NestJS API:http://localhost:3333/health"
        "MinIO:http://localhost:9000/minio/health/live"
    )
    
    for service_info in "${services[@]}"; do
        IFS=':' read -r name url <<< "$service_info"
        if curl -f -s "$url" > /dev/null 2>&1; then
            log "${GREEN}✅ $name is healthy${NC}"
        else
            log "${RED}❌ $name is not responding${NC}"
        fi
    done
    
    echo
    log "${CYAN}💻 Container Resource Usage:${NC}"
    docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}"
}

restart_services() {
    log "${YELLOW}🔄 Restarting all services...${NC}"
    
    check_project_dir
    
    read -p "Are you sure you want to restart all services? (y/N): " confirm
    if [[ $confirm =~ ^[Yy]$ ]]; then
        docker compose restart
        log "${GREEN}✅ Services restarted successfully${NC}"
        
        # Wait and check health
        sleep 10
        log "${CYAN}Checking service health...${NC}"
        service_status
    else
        log "${YELLOW}Operation cancelled${NC}"
    fi
}

stop_services() {
    log "${YELLOW}⏹️ Stopping all services...${NC}"
    
    check_project_dir
    
    read -p "Are you sure you want to stop all services? (y/N): " confirm
    if [[ $confirm =~ ^[Yy]$ ]]; then
        docker compose down
        log "${GREEN}✅ Services stopped successfully${NC}"
    else
        log "${YELLOW}Operation cancelled${NC}"
    fi
}

start_services() {
    log "${YELLOW}▶️ Starting all services...${NC}"
    
    check_project_dir
    
    docker compose up -d
    log "${GREEN}✅ Services started successfully${NC}"
    
    # Wait and check health
    sleep 15
    log "${CYAN}Checking service health...${NC}"
    service_status
}

# Database management functions
backup_database() {
    log "${CYAN}💾 Creating database backup...${NC}"
    
    check_project_dir
    
    # Load environment variables
    if [[ -f ".env" ]]; then
        source .env
    else
        error_exit ".env file not found"
    fi
    
    # Create backup directory
    mkdir -p "$BACKUP_DIR"
    
    # Generate backup filename
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    BACKUP_FILE="$BACKUP_DIR/backup_$TIMESTAMP.sql.gz"
    
    # Create backup
    CONTAINER_NAME=$(docker compose ps postgres --format json | jq -r '.[0].Name')
    
    if [[ -z "$CONTAINER_NAME" || "$CONTAINER_NAME" == "null" ]]; then
        error_exit "PostgreSQL container not found or not running"
    fi
    
    log "Creating backup from container: $CONTAINER_NAME"
    
    if docker exec "$CONTAINER_NAME" pg_dump -U "${POSTGRES_USER:-postgres}" "${POSTGRES_DB:-innerbright}" | gzip > "$BACKUP_FILE"; then
        BACKUP_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
        log "${GREEN}✅ Backup created successfully${NC}"
        log "   File: $BACKUP_FILE"
        log "   Size: $BACKUP_SIZE"
        
        # Clean old backups (keep last 7 days)
        find "$BACKUP_DIR" -name "backup_*.sql.gz" -mtime +7 -delete
        log "${BLUE}🧹 Cleaned old backups (kept last 7 days)${NC}"
    else
        error_exit "Failed to create database backup"
    fi
}

restore_database() {
    log "${CYAN}🔄 Database Restore${NC}\n"
    
    check_project_dir
    
    # List available backups
    if [[ ! -d "$BACKUP_DIR" ]] || [[ -z "$(ls -A $BACKUP_DIR/*.sql.gz 2>/dev/null)" ]]; then
        error_exit "No backup files found in $BACKUP_DIR"
    fi
    
    log "${CYAN}Available backups:${NC}"
    ls -la "$BACKUP_DIR"/*.sql.gz | awk '{print NR ". " $9 " (" $5 " bytes, " $6 " " $7 " " $8 ")"}'
    
    echo
    read -p "Enter backup file name (or full path): " backup_file
    
    if [[ ! -f "$backup_file" ]] && [[ -f "$BACKUP_DIR/$backup_file" ]]; then
        backup_file="$BACKUP_DIR/$backup_file"
    fi
    
    if [[ ! -f "$backup_file" ]]; then
        error_exit "Backup file not found: $backup_file"
    fi
    
    echo
    log "${RED}⚠️  WARNING: This will replace all data in the database!${NC}"
    read -p "Are you absolutely sure you want to restore? Type 'YES' to confirm: " confirm
    
    if [[ "$confirm" != "YES" ]]; then
        log "${YELLOW}Operation cancelled${NC}"
        return
    fi
    
    # Load environment variables
    source .env
    
    # Get container name
    CONTAINER_NAME=$(docker compose ps postgres --format json | jq -r '.[0].Name')
    
    if [[ -z "$CONTAINER_NAME" || "$CONTAINER_NAME" == "null" ]]; then
        error_exit "PostgreSQL container not found or not running"
    fi
    
    # Restore database
    log "${YELLOW}Restoring database from: $backup_file${NC}"
    
    if zcat "$backup_file" | docker exec -i "$CONTAINER_NAME" psql -U "${POSTGRES_USER:-postgres}" "${POSTGRES_DB:-innerbright}"; then
        log "${GREEN}✅ Database restored successfully${NC}"
    else
        error_exit "Failed to restore database"
    fi
}

list_backups() {
    log "${CYAN}🗂️ Database Backups${NC}\n"
    
    if [[ ! -d "$BACKUP_DIR" ]] || [[ -z "$(ls -A $BACKUP_DIR/*.sql.gz 2>/dev/null)" ]]; then
        log "${YELLOW}No backup files found${NC}"
        return
    fi
    
    log "${CYAN}Backup files in $BACKUP_DIR:${NC}"
    echo
    ls -lah "$BACKUP_DIR"/*.sql.gz | while read -r line; do
        file=$(echo "$line" | awk '{print $9}')
        size=$(echo "$line" | awk '{print $5}')
        date=$(echo "$line" | awk '{print $6 " " $7 " " $8}')
        echo -e "${GREEN}📄 $(basename "$file")${NC}"
        echo -e "   Size: $size"
        echo -e "   Date: $date"
        echo
    done
}

# Monitoring functions
health_check() {
    log "${CYAN}🏥 Comprehensive Health Check${NC}\n"
    
    check_project_dir
    
    # Check container status
    log "${CYAN}Container Status:${NC}"
    docker compose ps
    echo
    
    # Check disk space
    log "${CYAN}Disk Usage:${NC}"
    df -h / | grep -v Filesystem
    echo
    
    # Check memory usage
    log "${CYAN}Memory Usage:${NC}"
    free -h
    echo
    
    # Check service endpoints
    log "${CYAN}Service Health Endpoints:${NC}"
    endpoints=(
        "Frontend:http://localhost:3000/api/health"
        "API:http://localhost:3333/health"
        "MinIO:http://localhost:9000/minio/health/live"
    )
    
    for endpoint in "${endpoints[@]}"; do
        IFS=':' read -r name url <<< "$endpoint"
        if response=$(curl -f -s -w "%{http_code}" "$url" 2>/dev/null); then
            log "${GREEN}✅ $name: HTTP $response${NC}"
        else
            log "${RED}❌ $name: Not responding${NC}"
        fi
    done
    echo
    
    # Check logs for errors
    log "${CYAN}Recent Error Logs:${NC}"
    if docker compose logs --tail=50 2>/dev/null | grep -i error | tail -5; then
        echo
    else
        log "${GREEN}No recent errors found${NC}"
    fi
}

view_logs() {
    log "${CYAN}🔍 Service Logs${NC}\n"
    
    check_project_dir
    
    echo "Available services:"
    docker compose ps --format "table {{.Service}}\t{{.Status}}"
    echo
    
    read -p "Enter service name (or 'all' for all services): " service
    
    if [[ "$service" == "all" ]]; then
        docker compose logs -f --tail=100
    else
        if docker compose ps | grep -q "$service"; then
            docker compose logs -f --tail=100 "$service"
        else
            error_exit "Service '$service' not found"
        fi
    fi
}

# Maintenance functions
update_application() {
    log "${CYAN}🔧 Updating Application${NC}\n"
    
    check_project_dir
    
    read -p "This will pull latest code and rebuild containers. Continue? (y/N): " confirm
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        log "${YELLOW}Operation cancelled${NC}"
        return
    fi
    
    # Create backup before update
    log "${YELLOW}Creating backup before update...${NC}"
    backup_database
    
    # Pull latest code
    log "${YELLOW}Pulling latest code...${NC}"
    git pull
    
    # Rebuild and restart services
    log "${YELLOW}Rebuilding containers...${NC}"
    docker compose up --build -d --remove-orphans
    
    # Wait for services to be ready
    log "${YELLOW}Waiting for services to be ready...${NC}"
    sleep 30
    
    # Health check
    log "${CYAN}Verifying update...${NC}"
    health_check
    
    log "${GREEN}✅ Application updated successfully${NC}"
}

rebuild_containers() {
    log "${CYAN}🏗️ Rebuilding Containers${NC}\n"
    
    check_project_dir
    
    read -p "This will rebuild all containers from scratch. Continue? (y/N): " confirm
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        log "${YELLOW}Operation cancelled${NC}"
        return
    fi
    
    # Stop services
    docker compose down
    
    # Remove images
    docker compose build --no-cache
    
    # Start services
    docker compose up -d
    
    log "${GREEN}✅ Containers rebuilt successfully${NC}"
}

clean_system() {
    log "${CYAN}🧹 System Cleanup${NC}\n"
    
    echo "This will clean:"
    echo "• Unused Docker images"
    echo "• Unused Docker containers"
    echo "• Unused Docker networks"
    echo "• Old log files"
    echo
    
    read -p "Continue with cleanup? (y/N): " confirm
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        log "${YELLOW}Operation cancelled${NC}"
        return
    fi
    
    # Docker cleanup
    log "${YELLOW}Cleaning Docker resources...${NC}"
    docker system prune -f
    
    # Log cleanup
    if [[ -d "$LOG_DIR" ]]; then
        log "${YELLOW}Cleaning old logs...${NC}"
        find "$LOG_DIR" -name "*.log" -mtime +7 -delete
    fi
    
    # Cleanup old backups (keep last 14 days for manual cleanup)
    if [[ -d "$BACKUP_DIR" ]]; then
        log "${YELLOW}Cleaning old backups (older than 14 days)...${NC}"
        find "$BACKUP_DIR" -name "*.sql.gz" -mtime +14 -delete
    fi
    
    log "${GREEN}✅ System cleanup completed${NC}"
}

# System monitoring functions
system_resources() {
    log "${CYAN}📈 System Resources${NC}\n"
    
    # CPU usage
    log "${CYAN}CPU Usage:${NC}"
    top -bn1 | grep "Cpu(s)" | awk '{print $2 $3 $4 $5}'
    echo
    
    # Memory usage
    log "${CYAN}Memory Usage:${NC}"
    free -h
    echo
    
    # Disk usage
    log "${CYAN}Disk Usage:${NC}"
    df -h
    echo
    
    # Network usage
    log "${CYAN}Network Connections:${NC}"
    ss -tuln | grep -E ":(80|443|3000|3333|5432|9000)"
    echo
    
    # Docker resources
    if command -v docker &> /dev/null; then
        log "${CYAN}Docker Resource Usage:${NC}"
        docker system df
        echo
        
        log "${CYAN}Container Stats:${NC}"
        docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}"
    fi
}

security_status() {
    log "${CYAN}🔒 Security Status${NC}\n"
    
    # UFW status
    if command -v ufw &> /dev/null; then
        log "${CYAN}Firewall Status:${NC}"
        sudo ufw status
        echo
    fi
    
    # Fail2ban status
    if command -v fail2ban-client &> /dev/null; then
        log "${CYAN}Fail2ban Status:${NC}"
        sudo fail2ban-client status
        echo
    fi
    
    # SSL certificate status
    if [[ -f ".env" ]]; then
        source .env
        if [[ -n "$DOMAIN" ]]; then
            log "${CYAN}SSL Certificate Status for $DOMAIN:${NC}"
            if sudo certbot certificates | grep -A 5 "$DOMAIN"; then
                echo
            else
                log "${YELLOW}No SSL certificate found for $DOMAIN${NC}"
            fi
        fi
    fi
    
    # Check for failed login attempts
    log "${CYAN}Recent Failed Login Attempts:${NC}"
    sudo journalctl -u ssh -n 20 --no-pager | grep "Failed password" | tail -5 || log "${GREEN}No recent failed login attempts${NC}"
}

ssl_status() {
    log "${CYAN}🔑 SSL Certificate Status${NC}\n"
    
    if [[ -f ".env" ]]; then
        source .env
        if [[ -n "$DOMAIN" ]]; then
            sudo certbot certificates
        else
            log "${YELLOW}No domain configured in .env file${NC}"
        fi
    else
        log "${YELLOW}.env file not found${NC}"
    fi
}

renew_ssl() {
    log "${CYAN}🔄 Renewing SSL Certificate${NC}\n"
    
    read -p "Force SSL certificate renewal? (y/N): " confirm
    if [[ $confirm =~ ^[Yy]$ ]]; then
        sudo certbot renew --force-renewal
        sudo systemctl reload nginx
        log "${GREEN}✅ SSL certificate renewed${NC}"
    else
        # Check if renewal is needed
        sudo certbot renew --dry-run
    fi
}

show_configuration() {
    log "${CYAN}⚙️ Current Configuration${NC}\n"
    
    check_project_dir
    
    if [[ -f ".env" ]]; then
        log "${CYAN}Environment Variables (sensitive values hidden):${NC}"
        grep -v "^#" .env | grep -v "^$" | while IFS='=' read -r key value; do
            if [[ $key =~ (PASSWORD|SECRET|KEY) ]]; then
                echo "$key=***HIDDEN***"
            else
                echo "$key=$value"
            fi
        done
        echo
    else
        log "${YELLOW}.env file not found${NC}"
    fi
    
    log "${CYAN}Docker Compose Services:${NC}"
    docker compose config --services
    echo
    
    log "${CYAN}Exposed Ports:${NC}"
    docker compose ps --format "table {{.Service}}\t{{.Ports}}"
}

view_logs_menu() {
    log "${CYAN}📋 Log Viewer${NC}\n"
    
    echo "Select log type:"
    echo "1. Application logs (Docker Compose)"
    echo "2. System logs"
    echo "3. Nginx logs"
    echo "4. PostgreSQL logs"
    echo "5. Custom log files"
    echo
    
    read -p "Choose option (1-5): " log_choice
    
    case $log_choice in
        1)
            view_logs
            ;;
        2)
            tail -f /var/log/syslog
            ;;
        3)
            if [[ -f /var/log/nginx/error.log ]]; then
                tail -f /var/log/nginx/error.log
            else
                log "${YELLOW}Nginx logs not found${NC}"
            fi
            ;;
        4)
            check_project_dir
            docker compose logs -f postgres
            ;;
        5)
            if [[ -d "$LOG_DIR" ]]; then
                ls -la "$LOG_DIR"
                read -p "Enter log file name: " log_file
                if [[ -f "$LOG_DIR/$log_file" ]]; then
                    tail -f "$LOG_DIR/$log_file"
                else
                    log "${YELLOW}Log file not found${NC}"
                fi
            else
                log "${YELLOW}Log directory not found${NC}"
            fi
            ;;
        *)
            log "${RED}Invalid option${NC}"
            ;;
    esac
}

clean_logs() {
    log "${CYAN}🧹 Log Cleanup${NC}\n"
    
    # Docker logs cleanup
    read -p "Clean Docker logs? (y/N): " confirm
    if [[ $confirm =~ ^[Yy]$ ]]; then
        # Truncate docker logs
        sudo sh -c 'truncate -s 0 /var/lib/docker/containers/*/*-json.log'
        log "${GREEN}✅ Docker logs cleaned${NC}"
    fi
    
    # Application logs cleanup
    if [[ -d "$LOG_DIR" ]]; then
        read -p "Clean application logs older than 7 days? (y/N): " confirm
        if [[ $confirm =~ ^[Yy]$ ]]; then
            find "$LOG_DIR" -name "*.log" -mtime +7 -delete
            log "${GREEN}✅ Application logs cleaned${NC}"
        fi
    fi
    
    # System logs cleanup
    read -p "Clean system logs (journalctl)? (y/N): " confirm
    if [[ $confirm =~ ^[Yy]$ ]]; then
        sudo journalctl --vacuum-time=7d
        log "${GREEN}✅ System logs cleaned${NC}"
    fi
}

# Main execution
main() {
    while true; do
        show_menu
        read -p "Choose an option (1-20): " choice
        echo
        
        case $choice in
            1) service_status ;;
            2) restart_services ;;
            3) stop_services ;;
            4) start_services ;;
            5) backup_database ;;
            6) restore_database ;;
            7) list_backups ;;
            8) health_check ;;
            9) view_logs ;;
            10) clean_system ;;
            11) update_application ;;
            12) rebuild_containers ;;
            13) view_logs_menu ;;
            14) clean_logs ;;
            15) system_resources ;;
            16) security_status ;;
            17) ssl_status ;;
            18) renew_ssl ;;
            19) show_configuration ;;
            20) 
                log "${GREEN}👋 Goodbye!${NC}"
                exit 0
                ;;
            *)
                log "${RED}Invalid option. Please choose 1-20.${NC}"
                ;;
        esac
        
        echo
        read -p "Press Enter to continue..."
    done
}

# Check if script is being sourced or executed
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
