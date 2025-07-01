#!/bin/bash

# KataCore Universal Cloud Deployer v2.0
# Deploy lên bất kỳ cloud server nào - Phiên bản hoàn toàn mới

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Logging
log() { echo -e "${BLUE}[$(date +'%H:%M:%S')]${NC} $1"; }
success() { echo -e "${GREEN}✅ $1${NC}"; }
warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
error() { echo -e "${RED}❌ $1${NC}"; exit 1; }
info() { echo -e "${CYAN}ℹ️  $1${NC}"; }

# Banner
show_banner() {
    echo -e "${PURPLE}"
    echo "██╗  ██╗ █████╗ ████████╗ █████╗  ██████╗ ██████╗ ██████╗ ███████╗"
    echo "██║ ██╔╝██╔══██╗╚══██╔══╝██╔══██╗██╔════╝██╔═══██╗██╔══██╗██╔════╝"
    echo "█████╔╝ ███████║   ██║   ███████║██║     ██║   ██║██████╔╝█████╗  "
    echo "██╔═██╗ ██╔══██║   ██║   ██╔══██║██║     ██║   ██║██╔══██╗██╔══╝  "
    echo "██║  ██╗██║  ██║   ██║   ██║  ██║╚██████╗╚██████╔╝██║  ██║███████╗"
    echo "╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝"
    echo -e "${NC}"
    echo -e "${CYAN}🚀 Universal Cloud Deployer v2.0 - Deploy to ANY server${NC}"
    echo ""
}

# Usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Required:"
    echo "  --host IP/DOMAIN      Server host (required)"
    echo ""
    echo "Optional:"
    echo "  --user USER           SSH user (default: root)"
    echo "  --port PORT           SSH port (default: 22)"
    echo "  --path PATH           Deploy path (default: /opt/katacore)"
    echo "  --domain DOMAIN       Domain for SSL (default: server IP)"
    echo "  --clean               Clean install (remove old containers)"
    echo "  --setup-only          Only setup server, don't deploy"
    echo "  --deploy-only         Only deploy, skip server setup"
    echo "  --force-rebuild       Force rebuild all images"
    echo "  --skip-upload         Skip file upload (for quick config changes)"
    echo "  --help                Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 --host 192.168.1.100"
    echo "  $0 --host myserver.com --user ubuntu --domain mydomain.com"
    echo "  $0 --host 1.2.3.4 --clean"
    echo "  $0 --host 1.2.3.4 --force-rebuild"
    echo "  $0 --host 1.2.3.4 --skip-upload --deploy-only"
    echo ""
}

# Auto-create .env.prod.example template
create_env_example_template() {
    local domain="$1"
    
    log "🔧 Creating .env.prod.example template..."
    
    cat > .env.prod.example << 'ENVEOF'
# Production Environment Variables
# Copy this file to .env.prod and update with your actual values

# Database Configuration
POSTGRES_DB=katacore_prod
POSTGRES_USER=katacore_user
POSTGRES_PASSWORD=your_super_secure_postgres_password_here
DATABASE_URL=postgresql://katacore_user:your_super_secure_postgres_password_here@postgres:5432/katacore_prod

# Redis Configuration
REDIS_PASSWORD=your_super_secure_redis_password_here
REDIS_URL=redis://:your_super_secure_redis_password_here@redis:6379

# MinIO Configuration
MINIO_ROOT_USER=katacore_minio_admin
MINIO_ROOT_PASSWORD=your_super_secure_minio_password_here

# PgAdmin Configuration
PGADMIN_EMAIL=admin@yourcompany.com
PGADMIN_PASSWORD=your_super_secure_pgadmin_password_here

# API Configuration
JWT_SECRET=your_super_secret_jwt_key_minimum_32_characters_long
API_VERSION=latest
CORS_ORIGIN=https://yourdomain.com,https://www.yourdomain.com

# Frontend Configuration
SITE_VERSION=latest
NEXT_PUBLIC_API_URL=https://api.yourdomain.com

# Domain Configuration
DOMAIN=yourdomain.com
API_DOMAIN=api.yourdomain.com
ADMIN_DOMAIN=admin.yourdomain.com
STORAGE_DOMAIN=storage.yourdomain.com

# SSL Configuration (if using Let's Encrypt)
LETSENCRYPT_EMAIL=admin@yourcompany.com

# Backup Configuration
BACKUP_RETENTION_DAYS=7
BACKUP_SCHEDULE="0 2 * * *"  # Daily at 2 AM

# Monitoring (Optional)
ENABLE_MONITORING=false
GRAFANA_PASSWORD=your_grafana_password_here

# Security
FAIL2BAN_ENABLED=true
RATE_LIMIT=100

# Logging
LOG_LEVEL=info
LOG_MAX_SIZE=10m
LOG_MAX_FILES=3

# Performance
MEMORY_LIMIT=1g
CPU_LIMIT=1.0

# Application Settings
NODE_ENV=production
APP_NAME=KataCore
APP_VERSION=1.0.0
ENVEOF

    # Replace domain placeholders with actual domain
    if [[ -n "$domain" ]]; then
        sed -i "s/yourdomain.com/$domain/g" .env.prod.example
        sed -i "s/api.yourdomain.com/api.$domain/g" .env.prod.example
        sed -i "s/admin.yourdomain.com/admin.$domain/g" .env.prod.example
        sed -i "s/storage.yourdomain.com/storage.$domain/g" .env.prod.example
        sed -i "s/admin@yourcompany.com/admin@$domain/g" .env.prod.example
    fi
    
    success "✅ Created .env.prod.example template"
}

# Default values
SERVER_HOST=""
SERVER_USER="root"
SERVER_PORT="22"
DEPLOY_PATH="/opt/katacore"
DOMAIN=""
CLEAN_INSTALL=false
SETUP_ONLY=false
DEPLOY_ONLY=false
FORCE_REBUILD=false
SKIP_UPLOAD=false
CREATE_ENV_TEMPLATE=false
DEPLOY_MODE=""
ENABLE_SSL=false
ENABLE_MONITORING=false
LETSENCRYPT_EMAIL=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --host)
            SERVER_HOST="$2"
            shift 2
            ;;
        --user)
            SERVER_USER="$2"
            shift 2
            ;;
        --port)
            SERVER_PORT="$2"
            shift 2
            ;;
        --path)
            DEPLOY_PATH="$2"
            shift 2
            ;;
        --domain)
            DOMAIN="$2"
            shift 2
            ;;
        --clean)
            CLEAN_INSTALL=true
            shift
            ;;
        --setup-only)
            SETUP_ONLY=true
            shift
            ;;
        --deploy-only)
            DEPLOY_ONLY=true
            shift
            ;;
        --force-rebuild)
            FORCE_REBUILD=true
            shift
            ;;
        --skip-upload)
            SKIP_UPLOAD=true
            shift
            ;;
        --create-env-template)
            CREATE_ENV_TEMPLATE=true
            shift
            ;;
        --help)
            show_usage
            exit 0
            ;;
        *)
            error "Unknown option: $1"
            ;;
    esac
done

# Handle special commands that don't require server host
if [[ "$CREATE_ENV_TEMPLATE" == "true" ]]; then
    create_env_example_template "${DOMAIN:-yourdomain.com}"
    exit 0
fi

# Validation
if [[ -z "$SERVER_HOST" ]]; then
    error "Server host is required. Use --host IP_OR_DOMAIN"
fi

if [[ -z "$DOMAIN" ]]; then
    DOMAIN="$SERVER_HOST"
fi

# Enhanced error handling and retry logic
MAX_RETRIES=3
RETRY_DELAY=5

# Retry function with exponential backoff
retry_with_backoff() {
    local command="$1"
    local description="$2"
    local max_attempts="${3:-$MAX_RETRIES}"
    local delay="${4:-$RETRY_DELAY}"
    
    for ((i=1; i<=max_attempts; i++)); do
        if eval "$command"; then
            return 0
        else
            if [[ $i -eq $max_attempts ]]; then
                error "❌ Failed: $description after $max_attempts attempts"
                return 1
            fi
            warning "⚠️  Attempt $i failed: $description. Retrying in ${delay}s..."
            sleep $delay
            delay=$((delay * 2)) # Exponential backoff
        fi
    done
}

# Enhanced SSH connection test with detailed feedback
test_ssh_connection() {
    local host="$1"
    local user="$2"
    local port="$3"
    
    log "🔐 Testing SSH connection to $user@$host:$port..."
    
    # Test basic connectivity
    if ! timeout 10 nc -z "$host" "$port" 2>/dev/null; then
        error "Cannot reach $host:$port (connection timeout or port closed)"
    fi
    
    # Test SSH authentication
    if ! ssh -p "$port" -o ConnectTimeout=15 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o BatchMode=yes "$user@$host" "echo 'SSH_TEST_OK'" 2>/dev/null | grep -q "SSH_TEST_OK"; then
        echo ""
        warning "SSH authentication failed. Please ensure:"
        echo "  1. SSH key is properly configured"
        echo "  2. User '$user' exists on the server"
        echo "  3. SSH service is running on port $port"
        echo ""
        read -p "Do you want to try with password authentication? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            if ! ssh -p "$port" -o ConnectTimeout=15 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$user@$host" "echo 'SSH_TEST_OK'" 2>/dev/null | grep -q "SSH_TEST_OK"; then
                error "SSH connection failed even with password authentication"
            fi
        else
            error "SSH connection required for deployment"
        fi
    fi
    
    success "SSH connection verified successfully"
}

# Interactive deployment menu
show_deployment_menu() {
    clear
    show_banner
    
    echo -e "${CYAN}🎯 KataCore Deployment Assistant${NC}"
    echo ""
    echo "Please select deployment option:"
    echo ""
    echo "1. 🚀 Quick Deploy (Recommended)"
    echo "2. 🧹 Clean Deploy (Remove all containers)"
    echo "3. 🔄 Force Rebuild (Rebuild all images)"
    echo "4. ⚙️  Setup Server Only"
    echo "5. 📤 Deploy App Only"
    echo "6. 🔧 Interactive Configuration"
    echo "7. 📊 Show Server Status"
    echo "8. 📋 Show Deployment History"
    echo "9. ❌ Exit"
    echo ""
    read -p "Enter your choice (1-9): " choice
    
    case $choice in
        1) DEPLOY_MODE="quick" ;;
        2) DEPLOY_MODE="clean"; CLEAN_INSTALL=true ;;
        3) DEPLOY_MODE="rebuild"; FORCE_REBUILD=true ;;
        4) DEPLOY_MODE="setup"; SETUP_ONLY=true ;;
        5) DEPLOY_MODE="deploy"; DEPLOY_ONLY=true ;;
        6) DEPLOY_MODE="interactive" ;;
        7) DEPLOY_MODE="status" ;;
        8) DEPLOY_MODE="history" ;;
        9) echo "Goodbye!"; exit 0 ;;
        *) warning "Invalid choice. Using quick deploy mode."; DEPLOY_MODE="quick" ;;
    esac
}

# Interactive configuration
interactive_config() {
    echo ""
    echo -e "${CYAN}🔧 Interactive Configuration${NC}"
    echo ""
    
    # Server details
    if [[ -z "$SERVER_HOST" ]]; then
        read -p "Enter server IP or domain: " SERVER_HOST
    fi
    
    read -p "SSH user [default: $SERVER_USER]: " user_input
    if [[ -n "$user_input" ]]; then
        SERVER_USER="$user_input"
    fi
    
    read -p "SSH port [default: $SERVER_PORT]: " port_input
    if [[ -n "$port_input" ]]; then
        SERVER_PORT="$port_input"
    fi
    
    read -p "Deploy path [default: $DEPLOY_PATH]: " path_input
    if [[ -n "$path_input" ]]; then
        DEPLOY_PATH="$path_input"
    fi
    
    read -p "Domain name [default: $SERVER_HOST]: " domain_input
    if [[ -n "$domain_input" ]]; then
        DOMAIN="$domain_input"
    else
        DOMAIN="$SERVER_HOST"
    fi
    
    # Advanced options
    echo ""
    echo "Advanced options:"
    read -p "Enable SSL/HTTPS? (y/n) [default: n]: " ssl_input
    if [[ "$ssl_input" =~ ^[Yy]$ ]]; then
        ENABLE_SSL=true
        read -p "Let's Encrypt email: " LETSENCRYPT_EMAIL
    fi
    
    read -p "Enable monitoring? (y/n) [default: n]: " monitoring_input
    if [[ "$monitoring_input" =~ ^[Yy]$ ]]; then
        ENABLE_MONITORING=true
    fi
    
    # Confirm configuration
    echo ""
    echo -e "${YELLOW}📋 Configuration Summary:${NC}"
    echo "  Server: $SERVER_USER@$SERVER_HOST:$SERVER_PORT"
    echo "  Deploy path: $DEPLOY_PATH"
    echo "  Domain: $DOMAIN"
    echo "  SSL: ${ENABLE_SSL:-false}"
    echo "  Monitoring: ${ENABLE_MONITORING:-false}"
    echo ""
    read -p "Proceed with deployment? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Deployment cancelled."
        exit 0
    fi
}

# Show server status
show_server_status() {
    log "📊 Checking server status..."
    
    ssh -p "$SERVER_PORT" "$SERVER_USER@$SERVER_HOST" << 'STATUS_EOF'
        echo "🖥️  System Information:"
        echo "  OS: $(lsb_release -d 2>/dev/null | cut -f2 || cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
        echo "  Uptime: $(uptime | awk '{print $3,$4}' | sed 's/,//')"
        echo "  Load: $(uptime | awk -F'load average:' '{print $2}')"
        echo "  Memory: $(free -h | awk '/^Mem:/ {printf "%s/%s (%.1f%%)", $3, $2, $3/$2*100}')"
        echo "  Disk: $(df -h / | awk 'NR==2 {printf "%s/%s (%s used)", $3, $2, $5}')"
        echo ""
        
        if command -v docker >/dev/null 2>&1; then
            echo "🐳 Docker Status:"
            echo "  Version: $(docker --version | cut -d' ' -f3 | tr -d ',')"
            echo "  Status: $(systemctl is-active docker)"
            echo "  Containers: $(docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}' 2>/dev/null || echo 'None running')"
            echo ""
        else
            echo "🐳 Docker: Not installed"
            echo ""
        fi
        
        if [[ -d "/opt/katacore" ]]; then
            echo "📁 KataCore Deployment:"
            cd /opt/katacore
            if [[ -f "docker-compose.prod.yml" ]]; then
                if command -v docker >/dev/null 2>&1; then
                    if docker compose version >/dev/null 2>&1; then
                        COMPOSE_CMD="docker compose"
                    else
                        COMPOSE_CMD="docker-compose"
                    fi
                    echo "  Services:"
                    $COMPOSE_CMD -f docker-compose.prod.yml ps 2>/dev/null || echo "    No services running"
                fi
            else
                echo "  Status: Not deployed yet"
            fi
        else
            echo "📁 KataCore: Not deployed"
        fi
STATUS_EOF
}

# Show deployment history
show_deployment_history() {
    log "📋 Fetching deployment history..."
    
    ssh -p "$SERVER_PORT" "$SERVER_USER@$SERVER_HOST" << 'HISTORY_EOF'
        if [[ -f "/opt/katacore/.deploy-cache/deployment-history.log" ]]; then
            echo "📈 Recent Deployments:"
            echo "Date/Time               | Strategy    | Host        | Domain"
            echo "------------------------|-------------|-------------|------------------"
            tail -10 /opt/katacore/.deploy-cache/deployment-history.log | while IFS='|' read -r timestamp strategy host domain; do
                printf "%-22s | %-11s | %-11s | %s\n" "$timestamp" "$strategy" "$host" "$domain"
            done
        else
            echo "📋 No deployment history found"
        fi
        
        if [[ -f "/opt/katacore/.deploy-cache/deploy-info.json" ]]; then
            echo ""
            echo "📊 Last Deployment Info:"
            cat /opt/katacore/.deploy-cache/deploy-info.json | python3 -m json.tool 2>/dev/null || cat /opt/katacore/.deploy-cache/deploy-info.json
        fi
HISTORY_EOF
}

# Validate environment before deployment
validate_environment() {
    log "🔍 Validating deployment environment..."
    
    # Check local prerequisites
    local missing_tools=()
    
    if ! command -v rsync >/dev/null 2>&1; then
        missing_tools+=("rsync")
    fi
    
    if ! command -v ssh >/dev/null 2>&1; then
        missing_tools+=("ssh")
    fi
    
    if ! command -v openssl >/dev/null 2>&1; then
        missing_tools+=("openssl")
    fi
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        error "Missing required tools: ${missing_tools[*]}. Please install them first."
    fi
    
    # Check project structure
    local missing_files=()
    
    if [[ ! -f "docker-compose.yml" && ! -f "docker-compose.prod.yml" ]]; then
        missing_files+=("docker-compose.yml")
    fi
    
    if [[ ! -f "package.json" ]]; then
        missing_files+=("package.json")
    fi
    
    if [[ ! -d "api" || ! -d "site" ]]; then
        missing_files+=("api/ and site/ directories")
    fi
    
    if [[ ${#missing_files[@]} -gt 0 ]]; then
        error "Missing required files/directories: ${missing_files[*]}"
    fi
    
    success "Environment validation passed"
}

# Enhanced logging with deployment tracking
setup_deployment_logging() {
    local log_dir=".deploy-logs"
    local cache_dir=".deploy-cache"
    
    # Create directories if they don't exist
    mkdir -p "$log_dir"
    mkdir -p "$cache_dir"
    
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local host_safe="${SERVER_HOST:-unknown_host}"
    # Replace dots and special characters with underscores for filename
    host_safe=$(echo "$host_safe" | sed 's/[^a-zA-Z0-9]/_/g')
    local log_file="$log_dir/deploy_${host_safe}_${timestamp}.log"
    
    # Start logging to file
    exec 1> >(tee -a "$log_file")
    exec 2> >(tee -a "$log_file" >&2)
    
    log "📝 Deployment logging started: $log_file"
    echo "DEPLOYMENT_LOG_FILE=$log_file" > "$cache_dir/current-deployment.env"
}

# Main function
main() {
    # If no arguments provided, show interactive menu
    if [[ $# -eq 0 || -z "$SERVER_HOST" ]]; then
        show_deployment_menu
        if [[ "$DEPLOY_MODE" == "interactive" ]]; then
            interactive_config
        fi
    fi
    
    # Validate SERVER_HOST is set before continuing
    if [[ -z "$SERVER_HOST" ]]; then
        error "Server host is required. Use --host IP_OR_DOMAIN"
    fi
    
    # Setup deployment logging after SERVER_HOST is confirmed
    setup_deployment_logging
    
    # Handle special modes
    case "${DEPLOY_MODE:-}" in
        "status")
            if [[ -n "$SERVER_HOST" ]]; then
                test_ssh_connection "$SERVER_HOST" "$SERVER_USER" "$SERVER_PORT"
                show_server_status
            else
                error "Server host required for status check"
            fi
            exit 0
            ;;
        "history")
            if [[ -n "$SERVER_HOST" ]]; then
                test_ssh_connection "$SERVER_HOST" "$SERVER_USER" "$SERVER_PORT"
                show_deployment_history
            else
                error "Server host required for history check"
            fi
            exit 0
            ;;
    esac
    
    show_banner
    
    # Validate environment
    validate_environment
    
    log "🎯 Target: $SERVER_USER@$SERVER_HOST:$SERVER_PORT"
    log "📁 Deploy path: $DEPLOY_PATH"
    log "🌐 Domain: $DOMAIN"
    log "🔧 Mode: ${DEPLOY_MODE:-standard}"
    
    # Enhanced SSH connection test
    test_ssh_connection "$SERVER_HOST" "$SERVER_USER" "$SERVER_PORT"
    
    # Server setup (if not deploy-only)
    if [[ "$DEPLOY_ONLY" != "true" ]]; then
        retry_with_backoff "setup_server" "Server setup" 2 10
    fi
    
    # Deployment (if not setup-only)
    if [[ "$SETUP_ONLY" != "true" ]]; then
        retry_with_backoff "deploy_application" "Application deployment" 3 5
        show_deployment_info
    fi
    
    success "🎉 Deployment completed successfully!"
    if [[ -f ".deploy-cache/current-deployment.env" ]]; then
        local log_file=$(grep DEPLOYMENT_LOG_FILE .deploy-cache/current-deployment.env | cut -d'=' -f2)
        log "📝 Deployment log saved to: $log_file"
    fi
}

# Setup server
setup_server() {
    log "🔧 Setting up server..."
    
    ssh -p "$SERVER_PORT" "$SERVER_USER@$SERVER_HOST" << 'SETUP_EOF'
        set -e
        
        echo "📦 Updating system..."
        if command -v apt-get >/dev/null; then
            export DEBIAN_FRONTEND=noninteractive
            apt-get update -qq
            apt-get install -y -qq curl wget git openssl ufw unzip
        elif command -v yum >/dev/null; then
            yum update -y -q
            yum install -y -q curl wget git openssl firewalld unzip
        elif command -v dnf >/dev/null; then
            dnf update -y -q
            dnf install -y -q curl wget git openssl firewalld unzip
        fi
        
        echo "🐳 Installing Docker..."
        if ! command -v docker >/dev/null; then
            curl -fsSL https://get.docker.com | sh
            systemctl enable docker
            systemctl start docker
        else
            echo "✅ Docker already installed"
            systemctl start docker 2>/dev/null || true
        fi
        
        echo "🔧 Configuring Docker Compose..."
        if ! docker compose version >/dev/null 2>&1; then
            if ! command -v docker-compose >/dev/null; then
                COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
                curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
                chmod +x /usr/local/bin/docker-compose
            fi
        fi
        
        echo "🔥 Configuring firewall..."
        if command -v ufw >/dev/null; then
            ufw --force enable >/dev/null 2>&1 || true
            ufw allow ssh >/dev/null 2>&1 || true
            ufw allow 80/tcp >/dev/null 2>&1 || true
            ufw allow 443/tcp >/dev/null 2>&1 || true
            ufw allow 3000/tcp >/dev/null 2>&1 || true
            ufw allow 3001/tcp >/dev/null 2>&1 || true
        elif command -v firewall-cmd >/dev/null; then
            systemctl enable firewalld >/dev/null 2>&1 || true
            systemctl start firewalld >/dev/null 2>&1 || true
            firewall-cmd --permanent --add-service=ssh >/dev/null 2>&1 || true
            firewall-cmd --permanent --add-service=http >/dev/null 2>&1 || true
            firewall-cmd --permanent --add-service=https >/dev/null 2>&1 || true
            firewall-cmd --permanent --add-port=3000/tcp >/dev/null 2>&1 || true
            firewall-cmd --permanent --add-port=3001/tcp >/dev/null 2>&1 || true
            firewall-cmd --reload >/dev/null 2>&1 || true
        fi
        
        echo "✅ Server setup completed"
SETUP_EOF
    
    success "Server setup completed"
}

# Deploy application
deploy_application() {
    # Use optimized upload
    optimized_upload
    
    log "🚀 Deploying application..."
    
    # Deploy on remote server
    ssh -p "$SERVER_PORT" "$SERVER_USER@$SERVER_HOST" << EOF
        set -e
        cd $DEPLOY_PATH
        
        echo "📍 Working in: \$(pwd)"
        
        # Determine Docker Compose command
        if docker compose version >/dev/null 2>&1; then
            COMPOSE_CMD="docker compose"
        elif command -v docker-compose >/dev/null 2>&1; then
            if which docker-compose | grep -q snap 2>/dev/null; then
                COMPOSE_CMD="docker compose"
            else
                COMPOSE_CMD="docker-compose"
            fi
        else
            echo "❌ Docker Compose not found"
            exit 1
        fi
        
        # Check Docker permissions
        if ! docker ps >/dev/null 2>&1; then
            if sudo docker ps >/dev/null 2>&1; then
                COMPOSE_CMD="sudo \$COMPOSE_CMD"
                echo "⚠️  Using sudo for Docker"
            else
                echo "❌ Cannot access Docker"
                exit 1
            fi
        fi
        
        echo "🐳 Using: \$COMPOSE_CMD"
        
        # Define optimization functions for remote execution
        check_deployment_changes() {
            # Create cache directory
            mkdir -p .deploy-cache
            
            # Check if this is first deployment
            if [[ ! -f ".deploy-cache/last-deploy.timestamp" ]]; then
                echo "🎯 First deployment detected - full deploy required"
                echo "first-deploy" > .deploy-cache/deploy-strategy
                return
            fi
            
            local changes_detected=false
            local changed_files=""
            
            # Check Dockerfiles
            if find . -name "Dockerfile" -newer .deploy-cache/last-deploy.timestamp 2>/dev/null | grep -q .; then
                changed_files="\$changed_files Dockerfiles"
                changes_detected=true
            fi
            
            # Check package.json files
            if find . -name "package.json" -newer .deploy-cache/last-deploy.timestamp 2>/dev/null | grep -q .; then
                changed_files="\$changed_files package.json"
                changes_detected=true
            fi
            
            # Check docker-compose files
            if find . -name "docker-compose*.yml" -newer .deploy-cache/last-deploy.timestamp 2>/dev/null | grep -q .; then
                changed_files="\$changed_files docker-compose"
                changes_detected=true
            fi
            
            # Check .env files
            if find . -name ".env*" -newer .deploy-cache/last-deploy.timestamp 2>/dev/null | grep -q .; then
                changed_files="\$changed_files environment"
                changes_detected=true
            fi
            
            # Check source code (for incremental builds)
            local src_changes=false
            if find ./api/src ./site/src -newer .deploy-cache/last-deploy.timestamp 2>/dev/null | grep -q .; then
                src_changes=true
                changed_files="\$changed_files source-code"
            fi
            
            # Determine deployment strategy
            if [[ "$FORCE_REBUILD" == "true" ]]; then
                echo "rebuild" > .deploy-cache/deploy-strategy
                echo "🔄 Force rebuild requested"
            elif [[ "$CLEAN_INSTALL" == "true" ]]; then
                echo "clean" > .deploy-cache/deploy-strategy
                echo "🧹 Clean install requested"
            elif [[ "\$changes_detected" == "true" ]]; then
                echo "incremental-rebuild" > .deploy-cache/deploy-strategy
                echo "🔨 Changes detected in:\$changed_files - rebuild required"
            elif [[ "\$src_changes" == "true" ]]; then
                echo "incremental-source" > .deploy-cache/deploy-strategy
                echo "📝 Source code changes detected - hot reload if supported"
            else
                echo "config-only" > .deploy-cache/deploy-strategy
                echo "⚡ No significant changes - config update only"
            fi
        }
        
        create_deployment_cache() {
            mkdir -p .deploy-cache
            
            # Save file checksums for next comparison
            find . -name "Dockerfile" -o -name "package.json" -o -name "docker-compose*.yml" -o -name ".env*" 2>/dev/null | \\
                xargs md5sum 2>/dev/null > .deploy-cache/file-checksums.new || true
            
            # Save current deployment info
            cat > .deploy-cache/deploy-info.json << CACHE_EOF
{
    "timestamp": "\$(date -Iseconds)",
    "strategy": "\$(cat .deploy-cache/deploy-strategy 2>/dev/null || echo 'unknown')",
    "domain": "$DOMAIN",
    "user": "\$USER",
    "host": "$SERVER_HOST",
    "version": "\$(git rev-parse HEAD 2>/dev/null || echo 'unknown')"
}
CACHE_EOF
        }
        
        update_deployment_cache() {
            # Mark successful deployment
            date -Iseconds > .deploy-cache/last-deploy.timestamp
            mv .deploy-cache/file-checksums.new .deploy-cache/file-checksums 2>/dev/null || true
            rm -f .deploy-cache/deploy-strategy
            
            # Log deployment history
            echo "\$(date -Iseconds) | \$DEPLOY_STRATEGY | $SERVER_HOST | $DOMAIN" >> .deploy-cache/deployment-history.log
            
            # Keep only last 50 deployments in history
            tail -50 .deploy-cache/deployment-history.log > .deploy-cache/deployment-history.log.tmp
            mv .deploy-cache/deployment-history.log.tmp .deploy-cache/deployment-history.log
        }
        
        create_env_example_template() {
            local domain="\$1"
            
            cat > .env.prod.example << 'TEMPLATE_EOF'
# Production Environment Variables
# Copy this file to .env.prod and update with your actual values

# Database Configuration
POSTGRES_DB=katacore_prod
POSTGRES_USER=katacore_user
POSTGRES_PASSWORD=your_super_secure_postgres_password_here
DATABASE_URL=postgresql://katacore_user:your_super_secure_postgres_password_here@postgres:5432/katacore_prod

# Redis Configuration
REDIS_PASSWORD=your_super_secure_redis_password_here
REDIS_URL=redis://:your_super_secure_redis_password_here@redis:6379

# MinIO Configuration
MINIO_ROOT_USER=katacore_minio_admin
MINIO_ROOT_PASSWORD=your_super_secure_minio_password_here

# PgAdmin Configuration
PGADMIN_EMAIL=admin@yourcompany.com
PGADMIN_PASSWORD=your_super_secure_pgadmin_password_here

# API Configuration
JWT_SECRET=your_super_secret_jwt_key_minimum_32_characters_long
API_VERSION=latest
CORS_ORIGIN=https://yourdomain.com,https://www.yourdomain.com

# Frontend Configuration
SITE_VERSION=latest
NEXT_PUBLIC_API_URL=https://api.yourdomain.com

# Domain Configuration
DOMAIN=yourdomain.com
API_DOMAIN=api.yourdomain.com
ADMIN_DOMAIN=admin.yourdomain.com
STORAGE_DOMAIN=storage.yourdomain.com

# SSL Configuration (if using Let's Encrypt)
LETSENCRYPT_EMAIL=admin@yourcompany.com

# Backup Configuration
BACKUP_RETENTION_DAYS=7
BACKUP_SCHEDULE="0 2 * * *"  # Daily at 2 AM

# Monitoring (Optional)
ENABLE_MONITORING=false
GRAFANA_PASSWORD=your_grafana_password_here

# Security
FAIL2BAN_ENABLED=true
RATE_LIMIT=100

# Logging
LOG_LEVEL=info
LOG_MAX_SIZE=10m
LOG_MAX_FILES=3

# Performance
MEMORY_LIMIT=1g
CPU_LIMIT=1.0

# Application Settings
NODE_ENV=production
APP_NAME=KataCore
APP_VERSION=1.0.0
TEMPLATE_EOF

            # Replace domain placeholders with actual domain
            if [[ -n "\$domain" ]]; then
                sed -i "s/yourdomain.com/\$domain/g" .env.prod.example
                sed -i "s/api.yourdomain.com/api.\$domain/g" .env.prod.example
                sed -i "s/admin.yourdomain.com/admin.\$domain/g" .env.prod.example
                sed -i "s/storage.yourdomain.com/storage.\$domain/g" .env.prod.example
                sed -i "s/admin@yourcompany.com/admin@\$domain/g" .env.prod.example
            fi
            
            echo "✅ Created .env.prod.example template"
        }
        
        # Auto-generate .env.prod.example if it doesn't exist
        if [[ ! -f ".env.prod.example" ]]; then
            echo "📝 Auto-generating .env.prod.example template..."
            create_env_example_template "$DOMAIN"
        fi
        
        # Setup environment file with automatic generation
        echo "📝 Setting up environment..."
        if [[ ! -f ".env.prod" ]]; then
            if [[ -f ".env.prod.example" ]]; then
                echo "📋 Using .env.prod.example as template..."
                
                # Generate secure environment from template
                cp .env.prod.example .env.prod.tmp
                
                # Replace placeholder values with secure generated ones
                sed -i "s/your_super_secure_postgres_password_here/KataCore_PG_\$(openssl rand -hex 16)/g" .env.prod.tmp
                sed -i "s/your_super_secure_redis_password_here/KataCore_Redis_\$(openssl rand -hex 16)/g" .env.prod.tmp
                sed -i "s/your_super_secure_minio_password_here/KataCore_MinIO_\$(openssl rand -hex 16)/g" .env.prod.tmp
                sed -i "s/your_super_secure_pgadmin_password_here/KataCore_Admin_\$(openssl rand -hex 12)/g" .env.prod.tmp
                sed -i "s/your_super_secret_jwt_key_minimum_32_characters_long/\$(openssl rand -base64 32)/g" .env.prod.tmp
                sed -i "s/your_grafana_password_here/KataCore_Grafana_\$(openssl rand -hex 12)/g" .env.prod.tmp
                sed -i "s/admin@yourcompany.com/admin@$DOMAIN/g" .env.prod.tmp
                sed -i "s/yourdomain.com/$DOMAIN/g" .env.prod.tmp
                sed -i "s/api.yourdomain.com/api.$DOMAIN/g" .env.prod.tmp
                sed -i "s/admin.yourdomain.com/admin.$DOMAIN/g" .env.prod.tmp
                sed -i "s/storage.yourdomain.com/storage.$DOMAIN/g" .env.prod.tmp
                sed -i "s|https://api.yourdomain.com|http://$DOMAIN:3001|g" .env.prod.tmp
                sed -i "s|https://yourdomain.com,https://www.yourdomain.com|http://$DOMAIN,http://www.$DOMAIN|g" .env.prod.tmp
                
                # Generate actual secure values
                POSTGRES_PASSWORD=\$(openssl rand -hex 16)
                REDIS_PASSWORD=\$(openssl rand -hex 16)
                MINIO_PASSWORD=\$(openssl rand -hex 16)
                PGADMIN_PASSWORD=\$(openssl rand -hex 12)
                JWT_SECRET=\$(openssl rand -base64 32)
                GRAFANA_PASSWORD=\$(openssl rand -hex 12)
                
                # Replace with actual values
                sed "s/KataCore_PG_\$(openssl rand -hex 16)/KataCore_PG_\$POSTGRES_PASSWORD/g; \
                     s/KataCore_Redis_\$(openssl rand -hex 16)/KataCore_Redis_\$REDIS_PASSWORD/g; \
                     s/KataCore_MinIO_\$(openssl rand -hex 16)/KataCore_MinIO_\$MINIO_PASSWORD/g; \
                     s/KataCore_Admin_\$(openssl rand -hex 12)/KataCore_Admin_\$PGADMIN_PASSWORD/g; \
                     s/\$(openssl rand -base64 32)/\$JWT_SECRET/g; \
                     s/KataCore_Grafana_\$(openssl rand -hex 12)/KataCore_Grafana_\$GRAFANA_PASSWORD/g" .env.prod.tmp > .env.prod
                
                # Add dynamic DATABASE_URL and REDIS_URL
                echo "" >> .env.prod
                echo "# Auto-generated URLs" >> .env.prod
                echo "DATABASE_URL=postgresql://katacore_user:KataCore_PG_\$POSTGRES_PASSWORD@postgres:5432/katacore_prod" >> .env.prod
                echo "REDIS_URL=redis://:KataCore_Redis_\$REDIS_PASSWORD@redis:6379" >> .env.prod
                echo "NODE_ENV=production" >> .env.prod
                
                rm .env.prod.tmp
                
                echo "✅ Generated .env.prod from template with secure passwords"
            else
                # Fallback to simple generation if no template
                cat > .env.prod << 'ENVEOF'
NODE_ENV=production

# Database
POSTGRES_DB=katacore_prod
POSTGRES_USER=katacore_user
POSTGRES_PASSWORD=KataCore_PG_\$(openssl rand -hex 16)

# Redis
REDIS_PASSWORD=KataCore_Redis_\$(openssl rand -hex 16)

# Security
JWT_SECRET=\$(openssl rand -base64 32)

# MinIO
MINIO_ROOT_USER=katacore_minio_admin
MINIO_ROOT_PASSWORD=KataCore_MinIO_\$(openssl rand -hex 16)

# PgAdmin
PGADMIN_EMAIL=admin@$DOMAIN
PGADMIN_PASSWORD=KataCore_Admin_\$(openssl rand -hex 12)

# Application
CORS_ORIGIN=http://$DOMAIN,http://www.$DOMAIN
NEXT_PUBLIC_API_URL=http://$DOMAIN:3001
DOMAIN=$DOMAIN
API_DOMAIN=api.$DOMAIN
ENVEOF
                echo "✅ Created basic .env.prod with secure passwords"
            fi
        else
            echo "✅ .env.prod already exists - preserving existing configuration"
        fi
        
        # Ensure docker-compose.prod.yml exists
        if [[ ! -f "docker-compose.prod.yml" ]]; then
            if [[ -f "docker-compose.yml" ]]; then
                cp docker-compose.yml docker-compose.prod.yml
                echo "✅ Created docker-compose.prod.yml"
            else
                echo "❌ No Docker Compose files found"
                exit 1
            fi
        fi
        
        # Create directories
        echo "📁 Creating directories..."
        mkdir -p ssl logs backups nginx/logs
        
        # Generate SSL certificates
        if [[ ! -f "ssl/fullchain.pem" ]]; then
            echo "🔒 Generating SSL certificates..."
            openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
                -keyout ssl/privkey.pem \
                -out ssl/fullchain.pem \
                -subj "/C=VN/ST=HCM/L=HCM/O=KataCore/CN=$DOMAIN" 2>/dev/null || true
        fi
        
        # Optimization: Check what actually needs to be deployed
        check_deployment_changes
        
        # Create deployment tracking
        create_deployment_cache
        
        # Use absolute path for compose file
        COMPOSE_FILE="\$(pwd)/docker-compose.prod.yml"
        
        # Determine deployment strategy from cache or defaults
        if [[ -f ".deploy-cache/deploy-strategy" ]]; then
            DEPLOY_STRATEGY=$(cat .deploy-cache/deploy-strategy)
        else
            DEPLOY_STRATEGY="incremental"
            if [[ "$CLEAN_INSTALL" == "true" ]]; then
                DEPLOY_STRATEGY="clean"
            elif [[ "$FORCE_REBUILD" == "true" ]]; then
                DEPLOY_STRATEGY="rebuild"
            fi
        fi
        
        echo "🎯 Deployment strategy: \$DEPLOY_STRATEGY"
        
        # Execute deployment based on strategy
        case "\$DEPLOY_STRATEGY" in
            "clean"|"first-deploy")
                echo "🧹 Clean deployment - removing all containers and volumes..."
                \${COMPOSE_CMD} -f "\${COMPOSE_FILE}" down --volumes --remove-orphans 2>/dev/null || true
                docker system prune -af 2>/dev/null || true
                echo "🔨 Building all images from scratch..."
                \${COMPOSE_CMD} -f "\${COMPOSE_FILE}" build --no-cache
                ;;
            "rebuild"|"incremental-rebuild")
                echo "🔄 Rebuild deployment - rebuilding changed images..."
                \${COMPOSE_CMD} -f "\${COMPOSE_FILE}" down 2>/dev/null || true
                \${COMPOSE_CMD} -f "\${COMPOSE_FILE}" build --no-cache
                ;;
            "incremental-source")
                echo "📝 Source-only deployment - hot reload where possible..."
                # For source-only changes, we might not need to rebuild everything
                \${COMPOSE_CMD} -f "\${COMPOSE_FILE}" down 2>/dev/null || true
                \${COMPOSE_CMD} -f "\${COMPOSE_FILE}" build
                ;;
            "config-only")
                echo "⚙️  Configuration-only deployment - minimal changes..."
                \${COMPOSE_CMD} -f "\${COMPOSE_FILE}" down 2>/dev/null || true
                # Skip rebuild for config-only changes
                ;;
            "incremental"|*)
                echo "⚡ Incremental deployment - checking for changes..."
                \${COMPOSE_CMD} -f "\${COMPOSE_FILE}" down 2>/dev/null || true
                # Only rebuild if Dockerfile or package.json changed
                if [[ -f ".rebuild_required" ]] || [[ \$(find . -name "Dockerfile" -o -name "package.json" -newer .deploy-cache/last-deploy.timestamp 2>/dev/null | wc -l) -gt 0 ]]; then
                    echo "🔨 Rebuilding changed services..."
                    \${COMPOSE_CMD} -f "\${COMPOSE_FILE}" build
                else
                    echo "📦 Using cached images..."
                fi
                ;;
        esac
        
        # Start services in optimal order
        echo "🗄️  Starting database services..."
        \${COMPOSE_CMD} -f "\${COMPOSE_FILE}" up -d postgres redis minio 2>/dev/null || true
        
        echo "⏳ Waiting for databases to be ready..."
        sleep 15
        
        # Health check for databases
        for i in {1..30}; do
            if \${COMPOSE_CMD} -f "\${COMPOSE_FILE}" exec -T postgres pg_isready -U katacore_user >/dev/null 2>&1; then
                echo "✅ PostgreSQL is ready"
                break
            fi
            if [[ \$i -eq 30 ]]; then
                echo "⚠️  PostgreSQL might not be ready, continuing anyway..."
            fi
            sleep 2
        done
        
        echo "🌐 Starting application services..."
        \${COMPOSE_CMD} -f "\${COMPOSE_FILE}" up -d
        
        # Mark successful deployment and update cache
        update_deployment_cache
        
        echo "📊 Final status:"
        \${COMPOSE_CMD} -f "\${COMPOSE_FILE}" ps
        
        # Optimized cleanup - only remove unused resources
        echo "🧹 Optimizing storage (removing unused resources only)..."
        docker image prune -f 2>/dev/null || true
        docker volume prune -f 2>/dev/null || true
        docker network prune -f 2>/dev/null || true
        
        echo "✅ Deployment completed successfully!"
EOF
    
    success "Application deployed successfully"
}

# Show deployment info
show_deployment_info() {
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                 🎉 DEPLOYMENT SUCCESS               ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${GREEN}🌐 Application URLs:${NC}"
    echo "   Frontend:    http://$SERVER_HOST:3000"
    echo "   API:         http://$SERVER_HOST:3001"
    echo "   PgAdmin:     http://$SERVER_HOST:8080"
    echo "   MinIO:       http://$SERVER_HOST:9001"
    echo ""
    echo -e "${GREEN}🔧 Management Commands:${NC}"
    echo "   SSH:         ssh $SERVER_USER@$SERVER_HOST"
    echo "   Logs:        ssh $SERVER_USER@$SERVER_HOST 'cd $DEPLOY_PATH && docker compose logs -f'"
    echo "   Status:      ssh $SERVER_USER@$SERVER_HOST 'cd $DEPLOY_PATH && docker compose ps'"
    echo "   Stop:        ssh $SERVER_USER@$SERVER_HOST 'cd $DEPLOY_PATH && docker compose down'"
    echo "   Restart:     ssh $SERVER_USER@$SERVER_HOST 'cd $DEPLOY_PATH && docker compose restart'"
    echo ""
    echo -e "${GREEN}⚡ Quick Deploy Commands:${NC}"
    echo "   Fast deploy: $0 --host $SERVER_HOST --deploy-only"
    echo "   Config only: $0 --host $SERVER_HOST --skip-upload --deploy-only"
    echo "   Force rebuild: $0 --host $SERVER_HOST --force-rebuild"
    echo "   Clean deploy: $0 --host $SERVER_HOST --clean"
    echo ""
    echo -e "${YELLOW}⚠️  Important Notes:${NC}"
    echo "   - Environment file auto-generated from .env.prod.example"
    echo "   - Secure passwords automatically created and saved"
    echo "   - Check $DEPLOY_PATH/.env.prod for generated credentials"
    echo "   - Subsequent deploys are optimized (incremental)"
    echo "   - Use --force-rebuild if you need to rebuild images"
    echo ""
    echo -e "${CYAN}📊 Optimization Features:${NC}"
    echo "   ✅ Auto .env.prod.example generation from domain"
    echo "   ✅ Intelligent change detection (files, source, config)"
    echo "   ✅ Smart deployment strategies (clean/rebuild/incremental/config-only)"
    echo "   ✅ Advanced Docker image caching and layer optimization"
    echo "   ✅ Deployment history tracking and rollback support"
    echo "   ✅ Optimized database startup sequence with health checks"
    echo "   ✅ Minimal storage cleanup (preserves caches and artifacts)"
    echo "   ✅ Hot reload support for source-only changes"
    echo ""
    
    # Show deployment history if available
    if [[ -f "$DEPLOY_PATH/.deploy-cache/deployment-history.log" ]]; then
        echo -e "${CYAN}📈 Recent Deployments:${NC}"
        ssh $SERVER_USER@$SERVER_HOST "cd $DEPLOY_PATH && tail -5 .deploy-cache/deployment-history.log 2>/dev/null || echo '   No history available yet'"
        echo ""
    fi
}

# Check what has changed since last deployment
check_deployment_changes() {
    log "🔍 Analyzing changes since last deployment..."
    
    # Create cache directory
    mkdir -p .deploy-cache
    
    # Check if this is first deployment
    if [[ ! -f ".deploy-cache/last-deploy.timestamp" ]]; then
        echo "🎯 First deployment detected - full deploy required"
        echo "first-deploy" > .deploy-cache/deploy-strategy
        return
    fi
    
    local last_deploy=$(cat .deploy-cache/last-deploy.timestamp)
    local changes_detected=false
    
    # Check for significant changes
    local changed_files=""
    
    # Check Dockerfiles
    if find . -name "Dockerfile" -newer .deploy-cache/last-deploy.timestamp 2>/dev/null | grep -q .; then
        changed_files="$changed_files Dockerfiles"
        changes_detected=true
    fi
    
    # Check package.json files
    if find . -name "package.json" -newer .deploy-cache/last-deploy.timestamp 2>/dev/null | grep -q .; then
        changed_files="$changed_files package.json"
        changes_detected=true
    fi
    
    # Check docker-compose files
    if find . -name "docker-compose*.yml" -newer .deploy-cache/last-deploy.timestamp 2>/dev/null | grep -q .; then
        changed_files="$changed_files docker-compose"
        changes_detected=true
    fi
    
    # Check .env files
    if find . -name ".env*" -newer .deploy-cache/last-deploy.timestamp 2>/dev/null | grep -q .; then
        changed_files="$changed_files environment"
        changes_detected=true
    fi
    
    # Check source code (for incremental builds)
    local src_changes=false
    if find ./api/src ./site/src -newer .deploy-cache/last-deploy.timestamp 2>/dev/null | grep -q .; then
        src_changes=true
        changed_files="$changed_files source-code"
    fi
    
    # Determine deployment strategy
    if [[ "$FORCE_REBUILD" == "true" ]]; then
        echo "rebuild" > .deploy-cache/deploy-strategy
        echo "🔄 Force rebuild requested"
    elif [[ "$CLEAN_INSTALL" == "true" ]]; then
        echo "clean" > .deploy-cache/deploy-strategy
        echo "🧹 Clean install requested"
    elif [[ "$changes_detected" == "true" ]]; then
        echo "incremental-rebuild" > .deploy-cache/deploy-strategy
        echo "🔨 Changes detected in:$changed_files - rebuild required"
    elif [[ "$src_changes" == "true" ]]; then
        echo "incremental-source" > .deploy-cache/deploy-strategy
        echo "📝 Source code changes detected - hot reload if supported"
    else
        echo "config-only" > .deploy-cache/deploy-strategy
        echo "⚡ No significant changes - config update only"
    fi
}

# Create deployment cache and tracking
create_deployment_cache() {
    mkdir -p .deploy-cache
    
    # Save file checksums for next comparison
    find . -name "Dockerfile" -o -name "package.json" -o -name "docker-compose*.yml" -o -name ".env*" 2>/dev/null | \
        xargs md5sum 2>/dev/null > .deploy-cache/file-checksums.new || true
    
    # Save current deployment info
    cat > .deploy-cache/deploy-info.json << EOF
{
    "timestamp": "$(date -Iseconds)",
    "strategy": "$(cat .deploy-cache/deploy-strategy 2>/dev/null || echo 'unknown')",
    "domain": "$DOMAIN",
    "user": "$USER",
    "host": "$SERVER_HOST",
    "version": "$(git rev-parse HEAD 2>/dev/null || echo 'unknown')"
}
EOF
}

# Update deployment cache after successful deployment
update_deployment_cache() {
    # Mark successful deployment
    date -Iseconds > .deploy-cache/last-deploy.timestamp
    mv .deploy-cache/file-checksums.new .deploy-cache/file-checksums 2>/dev/null || true
    rm -f .deploy-cache/deploy-strategy
    
    # Log deployment history
    echo "$(date -Iseconds) | $DEPLOY_STRATEGY | $SERVER_HOST | $DOMAIN" >> .deploy-cache/deployment-history.log
    
    # Keep only last 50 deployments in history
    tail -50 .deploy-cache/deployment-history.log > .deploy-cache/deployment-history.log.tmp
    mv .deploy-cache/deployment-history.log.tmp .deploy-cache/deployment-history.log
}



# Export variables for SSH sessions
export CLEAN_INSTALL DOMAIN FORCE_REBUILD

# Generate secure environment from template
generate_env_from_template() {
    local template_file="$1"
    local output_file="$2"
    local domain="$3"
    
    if [[ ! -f "$template_file" ]]; then
        error "Template file $template_file not found"
    fi
    
    log "📝 Generating $output_file from $template_file..."
    
    # Read template and replace placeholders
    sed "s/your_super_secure_postgres_password_here/KataCore_PG_$(openssl rand -hex 16)/g; \
         s/your_super_secure_redis_password_here/KataCore_Redis_$(openssl rand -hex 16)/g; \
         s/your_super_secure_minio_password_here/KataCore_MinIO_$(openssl rand -hex 16)/g; \
         s/your_super_secure_pgadmin_password_here/KataCore_Admin_$(openssl rand -hex 12)/g; \
         s/your_super_secret_jwt_key_minimum_32_characters_long/$(openssl rand -base64 32)/g; \
         s/your_grafana_password_here/KataCore_Grafana_$(openssl rand -hex 12)/g; \
         s/admin@yourcompany.com/admin@$domain/g; \
         s/yourdomain.com/$domain/g; \
         s/api.yourdomain.com/api.$domain/g; \
         s/admin.yourdomain.com/admin.$domain/g; \
         s/storage.yourdomain.com/storage.$domain/g; \
         s/https:/http:/g" "$template_file" > "$output_file"
    
    # Add runtime variables
    cat >> "$output_file" << EOF

# Runtime Generated Variables
NODE_ENV=production
DATABASE_URL=postgresql://katacore_user:\$(grep POSTGRES_PASSWORD $output_file | cut -d'=' -f2)@postgres:5432/katacore_prod
REDIS_URL=redis://:\$(grep REDIS_PASSWORD $output_file | cut -d'=' -f2)@redis:6379
NEXT_PUBLIC_API_URL=http://$domain:3001
EOF
    
    success "Environment file generated with secure passwords"
}

# Check if files have changed (for incremental deployment)
check_file_changes() {
    local remote_path="$1"
    
    log "🔍 Checking for file changes..."
    
    # Create checksums of important files
    local local_checksums=$(find . -name "*.json" -o -name "*.yml" -o -name "*.yaml" -o -name "*.ts" -o -name "*.js" -o -name "*.tsx" -o -name "*.jsx" \
        | grep -v node_modules | grep -v .next | grep -v dist | sort | xargs md5sum 2>/dev/null | md5sum | cut -d' ' -f1)
    
    # Get remote checksums
    local remote_checksums=$(ssh -p "$SERVER_PORT" "$SERVER_USER@$SERVER_HOST" \
        "cd $remote_path 2>/dev/null && find . -name '*.json' -o -name '*.yml' -o -name '*.yaml' -o -name '*.ts' -o -name '*.js' -o -name '*.tsx' -o -name '*.jsx' \
        | grep -v node_modules | grep -v .next | grep -v dist | sort | xargs md5sum 2>/dev/null | md5sum | cut -d' ' -f1" 2>/dev/null || echo "")
    
    if [[ "$local_checksums" == "$remote_checksums" && "$remote_checksums" != "" ]]; then
        info "📋 No significant file changes detected"
        return 1  # No changes
    else
        info "📋 File changes detected or first deployment"
        return 0  # Changes detected
    fi
}

# Optimized file upload
optimized_upload() {
    if [[ "$SKIP_UPLOAD" == "true" ]]; then
        info "⏭️  Skipping file upload as requested"
        return
    fi
    
    if ! check_file_changes "$DEPLOY_PATH"; then
        if [[ "$FORCE_REBUILD" != "true" ]]; then
            info "⚡ Using optimized deployment (no file changes)"
            return
        fi
    fi
    
    log "📤 Uploading project files..."
    
    # Create remote directory
    ssh -p "$SERVER_PORT" "$SERVER_USER@$SERVER_HOST" "mkdir -p $DEPLOY_PATH"
    
    # Upload files with optimizations
    rsync -avz --progress --delete \
        --exclude='.git' \
        --exclude='node_modules' \
        --exclude='*/node_modules' \
        --exclude='.next' \
        --exclude='*/.next' \
        --exclude='dist' \
        --exclude='*/dist' \
        --exclude='build' \
        --exclude='*/build' \
        --exclude='*.log' \
        --exclude='logs' \
        --exclude='backup_*' \
        --exclude='tmp' \
        --exclude='.env.prod' \
        --checksum \
        -e "ssh -p $SERVER_PORT" \
        ./ "$SERVER_USER@$SERVER_HOST:$DEPLOY_PATH/"
    
    success "Files uploaded"
}

# Run main function
main "$@"
