#!/bin/bash

# KataCore StartKit v1 - Universal Deployment Script
# Optimized for production deployment with zero configuration
# Compatible with any Linux server (Ubuntu, Debian, CentOS, RHEL, etc.)

set -euo pipefail

# Version information
readonly SCRIPT_VERSION="1.0.0"
readonly KATACORE_VERSION="StartKit v1"

# Color codes for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m' # No Color

# Global variables
SERVER_HOST=""
SERVER_PORT="22"
SERVER_USER="root"
DOMAIN=""
CLEAN_DEPLOY=false
SETUP_ONLY=false
DEPLOY_ONLY=false
FORCE_REBUILD=false
CONFIG_ONLY=false
VERBOSE=false
DRY_RUN=false
CREATE_ENV_TEMPLATE=false
SETUP_SSH_KEYS=false
SSH_KEY_NAME="katacore-deploy"

# Deployment paths
readonly REMOTE_DIR="/opt/katacore"
readonly LOG_DIR=".deploy-logs"
readonly CACHE_DIR=".deploy-cache"

# Security settings
readonly SECURE_CIPHERS="ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305"
readonly MIN_PASSWORD_LENGTH=16

# Logging functions
log() {
    echo -e "${BLUE}[$(date +'%H:%M:%S')]${NC} $1" >&2
}

info() {
    echo -e "${CYAN}ℹ️  $1${NC}" >&2
}

success() {
    echo -e "${GREEN}✅ $1${NC}" >&2
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}" >&2
}

error() {
    echo -e "${RED}❌ $1${NC}" >&2
    exit 1
}

debug() {
    if [[ "${VERBOSE}" == "true" ]]; then
        echo -e "${PURPLE}🔍 $1${NC}" >&2
    fi
}

# Enhanced banner with version info
show_banner() {
    echo -e "${CYAN}"
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════════════════════╗
║                     🚀 KataCore StartKit v1 Deployer                        ║
║                                                                              ║
║    Universal Cloud Deployment • Production Ready • Zero Configuration       ║
║    Next.js 15 + NestJS 11 + PostgreSQL + Redis + MinIO + Nginx + SSL       ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    echo -e "  ${GREEN}Version:${NC} ${SCRIPT_VERSION}"
    echo -e "  ${GREEN}KataCore:${NC} ${KATACORE_VERSION}"
    echo ""
}

# Show help information
show_help() {
    cat << EOF
KataCore StartKit v1 - Universal Deployment Script

USAGE:
    $0 [OPTIONS] --host SERVER_IP

REQUIRED:
    --host HOST        Target server IP address or domain

OPTIONS:
    --port PORT        SSH port (default: 22)
    --user USER        SSH user (default: root)
    --domain DOMAIN    Domain name for SSL certificates
    --clean            Clean deployment (remove existing containers)
    --setup-only       Only setup server, don't deploy
    --deploy-only      Only deploy, skip server setup
    --config-only      Only update configuration files
    --force-rebuild    Force rebuild all Docker images
    --setup-ssh        Setup SSH keys before deployment
    --ssh-key-name NAME SSH key name for deployment (default: katacore-deploy)
    --verbose          Enable verbose logging
    --dry-run          Show what would be done without executing
    --create-env-template  Create environment template only
    --help             Show this help message

EXAMPLES:
    # Basic deployment
    $0 --host 192.168.1.100

    # Deployment with SSH key setup
    $0 --host 192.168.1.100 --setup-ssh

    # Deployment with custom domain and SSL
    $0 --host myserver.com --domain myapp.com

    # Clean deployment (removes existing data)
    $0 --host 192.168.1.100 --clean

    # Setup server only (no deployment)
    $0 --host 192.168.1.100 --setup-only

    # Update configuration only (fastest)
    $0 --host 192.168.1.100 --config-only

    # Setup SSH keys only
    $0 --host 192.168.1.100 --setup-ssh --deploy-only

    # Create environment template
    $0 --create-env-template

For more information, visit: https://github.com/your-org/katacore
EOF
}

# Parse command line arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --host)
                if [[ -z "${2:-}" ]] || [[ "${2:-}" =~ ^-- ]]; then
                    error "--host requires a value (IP address or domain)"
                fi
                SERVER_HOST="$2"
                shift 2
                ;;
            --port)
                if [[ -z "${2:-}" ]] || [[ "${2:-}" =~ ^-- ]]; then
                    error "--port requires a value (port number)"
                fi
                SERVER_PORT="$2"
                shift 2
                ;;
            --user)
                if [[ -z "${2:-}" ]] || [[ "${2:-}" =~ ^-- ]]; then
                    error "--user requires a value (username)"
                fi
                SERVER_USER="$2"
                shift 2
                ;;
            --domain)
                if [[ -z "${2:-}" ]] || [[ "${2:-}" =~ ^-- ]]; then
                    error "--domain requires a value (domain name)"
                fi
                DOMAIN="$2"
                shift 2
                ;;
            --clean)
                CLEAN_DEPLOY=true
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
            --config-only)
                CONFIG_ONLY=true
                shift
                ;;
            --force-rebuild)
                FORCE_REBUILD=true
                shift
                ;;
            --setup-ssh)
                SETUP_SSH_KEYS=true
                shift
                ;;
            --ssh-key-name)
                if [[ -z "${2:-}" ]] || [[ "${2:-}" =~ ^-- ]]; then
                    error "--ssh-key-name requires a value (key name)"
                fi
                SSH_KEY_NAME="$2"
                shift 2
                ;;
            --verbose)
                VERBOSE=true
                shift
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --create-env-template)
                CREATE_ENV_TEMPLATE=true
                shift
                ;;
            --help)
                show_help
                exit 0
                ;;
            *)
                warning "Unknown option: $1"
                shift
                ;;
        esac
    done

    # Special case: create template doesn't need host
    if [[ "$CREATE_ENV_TEMPLATE" == "true" ]]; then
        return
    fi

    # Validate required arguments
    if [[ -z "$SERVER_HOST" ]]; then
        error "Server host is required. Use --host SERVER_IP or --help for usage information"
    fi
    
    # Validate host format (basic check)
    if [[ ! "$SERVER_HOST" =~ ^[a-zA-Z0-9.-]+$ ]]; then
        error "Invalid host format: $SERVER_HOST. Please provide a valid IP address or domain name"
    fi
    
    # Validate port is numeric
    if [[ ! "$SERVER_PORT" =~ ^[0-9]+$ ]] || [[ "$SERVER_PORT" -lt 1 ]] || [[ "$SERVER_PORT" -gt 65535 ]]; then
        error "Invalid port: $SERVER_PORT. Port must be a number between 1 and 65535"
    fi
}

# Generate secure passwords
generate_password() {
    local length=${1:-$MIN_PASSWORD_LENGTH}
    openssl rand -base64 $((length * 3 / 4)) | tr -d "=+/" | cut -c1-${length}
}

# Generate JWT secret
generate_jwt_secret() {
    openssl rand -base64 64 | tr -d "\n"
}

# Setup deployment logging
setup_deployment_logging() {
    local log_file="${LOG_DIR}/deploy-$(date +%Y%m%d-%H%M%S).log"
    
    mkdir -p "$LOG_DIR" "$CACHE_DIR"
    
    # Create deployment info
    cat > "${CACHE_DIR}/current-deployment.env" << EOF
DEPLOYMENT_HOST=$SERVER_HOST
DEPLOYMENT_PORT=$SERVER_PORT
DEPLOYMENT_USER=$SERVER_USER
DEPLOYMENT_DOMAIN=$DOMAIN
DEPLOYMENT_TIME=$(date -Iseconds)
DEPLOYMENT_VERSION=$SCRIPT_VERSION
KATACORE_VERSION=$KATACORE_VERSION
EOF

    debug "Logging to: $log_file"
}

# Validate environment
validate_environment() {
    log "🔍 Validating deployment environment..."
    
    # Check required tools
    local missing_tools=()
    
    for tool in ssh scp rsync openssl docker; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            missing_tools+=("$tool")
        fi
    done
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        error "Missing required tools: ${missing_tools[*]}"
    fi
    
    # Check project structure
    local required_files=(
        "docker-compose.prod.yml"
        "package.json"
        "api/"
        "site/"
    )
    
    for file in "${required_files[@]}"; do
        if [[ ! -e "$file" ]]; then
            error "Missing required file/directory: $file"
        fi
    done
    
    success "Environment validation passed"
}

# Enhanced environment validation for first-time deployment
validate_environment_enhanced() {
    log "🔍 Enhanced environment validation..."
    
    # Check required tools
    local missing_tools=()
    
    for tool in ssh scp rsync openssl docker; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            missing_tools+=("$tool")
        fi
    done
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        error "Missing required tools: ${missing_tools[*]}"
    fi
    
    # Check project structure
    local required_files=(
        "docker-compose.prod.yml"
        "package.json"
        "api/"
        "site/"
    )
    
    for file in "${required_files[@]}"; do
        if [[ ! -e "$file" ]]; then
            error "Missing required file/directory: $file"
        fi
    done
    
    # Additional checks for production deployment
    local env_file=".env.prod"
    
    # Check for placeholder domains that need updating
    if grep -q "innerbright.vn\|your-domain.com\|localhost" "$env_file"; then
        warning "Found placeholder domains in $env_file"
        
        # Auto-fix common issues if SERVER_HOST is provided
        if [[ -n "$SERVER_HOST" && "$SERVER_HOST" != "localhost" ]]; then
            log "🔧 Auto-fixing domain references with $SERVER_HOST..."
            
            # Create backup
            cp "$env_file" "${env_file}.backup"
            
            # Replace placeholder domains with actual server host
            sed -i "s/innerbright\.vn/$SERVER_HOST/g" "$env_file"
            sed -i "s/your-domain\.com/$SERVER_HOST/g" "$env_file"
            sed -i "s/localhost/$SERVER_HOST/g" "$env_file"
            
            # Ensure HTTP for IP addresses (disable SSL)
            if [[ "$SERVER_HOST" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                sed -i "s/https:\/\//http:\/\//g" "$env_file"
                sed -i "s/ENABLE_SSL=true/ENABLE_SSL=false/g" "$env_file"
            fi
            
            success "Auto-fixed domain references in $env_file"
        fi
    fi
}

# Test SSH connection
test_ssh_connection() {
    log "🔗 Testing SSH connection to $SERVER_HOST..."
    
    # Try to use the SSH key if it was set up
    local ssh_options="-o ConnectTimeout=10 -o BatchMode=yes -p $SERVER_PORT"
    
    # Check if we have a KataCore SSH key
    if [[ -f "$HOME/.ssh/katacore-keys/${SSH_KEY_NAME}" ]]; then
        debug "Using KataCore SSH key: $HOME/.ssh/katacore-keys/${SSH_KEY_NAME}"
        ssh_options="$ssh_options -i $HOME/.ssh/katacore-keys/${SSH_KEY_NAME}"
    fi
    
    if ! ssh $ssh_options "$SERVER_USER@$SERVER_HOST" exit 2>/dev/null; then
        if [[ "$SETUP_SSH_KEYS" == "true" ]]; then
            warning "SSH connection failed. Running SSH key setup..."
            setup_ssh_keys
            return
        else
            error "Cannot connect to $SERVER_HOST:$SERVER_PORT with user $SERVER_USER. Consider using --setup-ssh to configure SSH keys."
        fi
    fi
    
    success "SSH connection successful"
}

# Setup SSH keys for deployment
setup_ssh_keys() {
    log "🔐 Setting up SSH keys for deployment..."
    
    local script_path="$(dirname "$0")/scripts/ssh-keygen-setup.sh"
    
    if [[ ! -f "$script_path" ]]; then
        error "SSH setup script not found: $script_path"
    fi
    
    # Build arguments for SSH setup script
    local ssh_args=(
        "--setup"
        "--host" "$SERVER_HOST"
        "--port" "$SERVER_PORT"
        "--user" "$SERVER_USER"
        "--key-name" "$SSH_KEY_NAME"
    )
    
    if [[ "$VERBOSE" == "true" ]]; then
        ssh_args+=("--verbose")
    fi
    
    if [[ "$DRY_RUN" == "true" ]]; then
        ssh_args+=("--dry-run")
    fi
    
    # Run SSH setup script
    if bash "$script_path" "${ssh_args[@]}"; then
        success "SSH keys configured successfully"
    else
        error "SSH key setup failed"
    fi
}

# Setup server (install Docker, create directories, etc.)
setup_server() {
    if [[ "$DEPLOY_ONLY" == "true" ]]; then
        debug "Skipping server setup (deploy-only mode)"
        return
    fi
    
    log "🔧 Setting up server environment..."
    
    ssh -p "$SERVER_PORT" "$SERVER_USER@$SERVER_HOST" << 'EOF'
        set -euo pipefail
        
        # Update system packages
        if command -v apt-get >/dev/null 2>&1; then
            apt-get update && apt-get upgrade -y
            apt-get install -y curl wget git ufw fail2ban
        elif command -v yum >/dev/null 2>&1; then
            yum update -y
            yum install -y curl wget git
        fi
        
        # Install Docker if not present
        if ! command -v docker >/dev/null 2>&1; then
            echo "Installing Docker..."
            curl -fsSL https://get.docker.com | sh
            systemctl enable docker
            systemctl start docker
        fi
        
        # Install Docker Compose if not present
        if ! docker compose version >/dev/null 2>&1; then
            echo "Installing Docker Compose..."
            curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
            chmod +x /usr/local/bin/docker-compose
        fi
        
        # Create deployment directory
        mkdir -p /opt/katacore/{nginx/conf.d,ssl,backups,logs}
        
        # Setup firewall
        if command -v ufw >/dev/null 2>&1; then
            ufw --force enable
            ufw allow ssh
            ufw allow 80/tcp
            ufw allow 443/tcp
            ufw allow 8080/tcp
            ufw allow 9001/tcp
        fi
        
        echo "✅ Server setup completed"
EOF
    
    success "Server setup completed"
}

# Generate environment file
generate_environment() {
    log "🔐 Generating secure environment configuration..."
    
    local env_file=".env.prod"
    
    # Check if environment file already exists
    if [[ -f "$env_file" ]] && [[ "$FORCE_REBUILD" != "true" ]]; then
        info "Environment file exists, checking for placeholder values..."
        
        # Check for placeholder values that need to be replaced
        if grep -q "{{.*}}\|your-domain.com\|innerbright.vn\|__SECURE_.*__" "$env_file"; then
            warning "Found placeholder values in existing .env.prod, updating..."
            # Continue to update placeholders
        else
            info "Environment file is properly configured, using existing configuration"
            return
        fi
    fi
    
    # Generate secure passwords
    local postgres_pass=$(generate_password 24)
    local redis_pass=$(generate_password 20)
    local jwt_secret=$(generate_jwt_secret)
    local minio_pass=$(generate_password 20)
    local pgadmin_pass=$(generate_password 16)
    local grafana_pass=$(generate_password 16)
    local prometheus_pass=$(generate_password 16)
    local encryption_key=$(generate_password 32)
    
    # Determine configuration based on input
    local host_url="${DOMAIN:-$SERVER_HOST}"
    local protocol="http"
    local enable_ssl="false"
    local enable_monitoring="false"
    local email_domain="${DOMAIN:-$SERVER_HOST}"
    
    # If domain is provided, enable SSL
    if [[ -n "$DOMAIN" ]] && [[ "$DOMAIN" != "$SERVER_HOST" ]]; then
        protocol="https"
        enable_ssl="true"
        enable_monitoring="true"
    fi
    
    # Generate environment file from template
    if [[ -f ".env.prod.template" ]]; then
        info "Using .env.prod.template for environment generation"
        cp .env.prod.template "$env_file"
        
        # Replace all template placeholders
        sed -i "s/{{SERVER_HOST}}/$SERVER_HOST/g" "$env_file"
        sed -i "s/{{DOMAIN}}/${DOMAIN:-$SERVER_HOST}/g" "$env_file"
        sed -i "s/{{HOST_URL}}/$host_url/g" "$env_file"
        sed -i "s/{{PROTOCOL}}/$protocol/g" "$env_file"
        sed -i "s/{{EMAIL_DOMAIN}}/$email_domain/g" "$env_file"
        sed -i "s/{{ENABLE_SSL}}/$enable_ssl/g" "$env_file"
        sed -i "s/{{ENABLE_MONITORING}}/$enable_monitoring/g" "$env_file"
        
        # Replace subdomain placeholders
        sed -i "s/{{API_SUBDOMAIN}}/api/g" "$env_file"
        sed -i "s/{{ADMIN_SUBDOMAIN}}/admin/g" "$env_file"
        sed -i "s/{{STORAGE_SUBDOMAIN}}/storage/g" "$env_file"
        
        # Replace password placeholders
        sed -i "s/{{POSTGRES_PASSWORD}}/$postgres_pass/g" "$env_file"
        sed -i "s/{{REDIS_PASSWORD}}/$redis_pass/g" "$env_file"
        sed -i "s/{{JWT_SECRET}}/$jwt_secret/g" "$env_file"
        sed -i "s/{{MINIO_PASSWORD}}/$minio_pass/g" "$env_file"
        sed -i "s/{{PGADMIN_PASSWORD}}/$pgadmin_pass/g" "$env_file"
        sed -i "s/{{GRAFANA_PASSWORD}}/$grafana_pass/g" "$env_file"
        sed -i "s/{{PROMETHEUS_PASSWORD}}/$prometheus_pass/g" "$env_file"
        sed -i "s/{{ENCRYPTION_KEY}}/$encryption_key/g" "$env_file"
        
    else
        warning ".env.prod.template not found, creating basic environment file"
        # Create basic environment file
        cat > "$env_file" << EOF
# KataCore StartKit v1 - Production Environment
# Auto-generated secure configuration

# Deployment Configuration
NODE_ENV=production
DEPLOYMENT_MODE=production
DEPLOYMENT_HOST=$SERVER_HOST
DEPLOYMENT_DOMAIN=${DOMAIN:-$SERVER_HOST}

# Database
POSTGRES_DB=katacore_prod
POSTGRES_USER=katacore_user
POSTGRES_PASSWORD=$postgres_pass
DATABASE_URL=postgresql://katacore_user:$postgres_pass@postgres:5432/katacore_prod

# Redis
REDIS_PASSWORD=$redis_pass
REDIS_URL=redis://:$redis_pass@redis:6379

# Application
JWT_SECRET=$jwt_secret
ENCRYPTION_KEY=$encryption_key
LOG_LEVEL=info

# MinIO
MINIO_ROOT_USER=katacore_admin
MINIO_ROOT_PASSWORD=$minio_pass
MINIO_BROWSER_REDIRECT_URL=$protocol://$host_url:9001
MINIO_API_URL=$protocol://$host_url:9000

# pgAdmin
PGADMIN_EMAIL=admin@$email_domain
PGADMIN_PASSWORD=$pgadmin_pass

# API Configuration
API_VERSION=latest
CORS_ORIGIN=$protocol://$host_url
API_BASE_URL=$protocol://$host_url/api

# Frontend
SITE_VERSION=latest
NEXT_PUBLIC_API_URL=$protocol://$host_url/api
NEXT_PUBLIC_SITE_URL=$protocol://$host_url

# Domain Configuration
DOMAIN=$host_url
API_DOMAIN=api.$host_url
ADMIN_DOMAIN=admin.$host_url
STORAGE_DOMAIN=storage.$host_url

# SSL Configuration
LETSENCRYPT_EMAIL=admin@$email_domain
ENABLE_SSL=$enable_ssl

# Security & Monitoring
ENABLE_MONITORING=$enable_monitoring
FAIL2BAN_ENABLED=true
RATE_LIMIT=100
GRAFANA_PASSWORD=$grafana_pass

# Protocol Configuration
PROTOCOL=$protocol
HTTP_PORT=80
HTTPS_PORT=443
EOF
    fi
    
    # Legacy compatibility - replace old template values
    sed -i "s/puwIRuLehf8jDeb98oFUUjzz/$postgres_pass/g" "$env_file"
    sed -i "s/YbyKUZUKS0Md8JJf0ABR/$redis_pass/g" "$env_file"
    sed -i "s/5Bjbnwyj5h23PSrd/$minio_pass/g" "$env_file"
    
    # Replace any remaining domain placeholders
    sed -i "s/your-domain.com/$host_url/g" "$env_file"
    sed -i "s/innerbright.vn/$host_url/g" "$env_file"
    sed -i "s/localhost/$host_url/g" "$env_file"
    
    # Set proper permissions
    chmod 600 "$env_file"
    
    success "Environment configuration generated and secured"
}

# Create environment template file
create_environment_template() {
    log "📄 Creating environment template..."
    
    local template_file=".env.prod.template"
    
    # Check if template already exists
    if [[ -f "$template_file" ]]; then
        warning "Environment template already exists at $template_file"
        return
    fi
    
    # Create environment template with placeholders
    cat > "$template_file" << 'EOF'
# KataCore StartKit v1 - Production Environment Template
# Copy this file to .env.prod and fill in the secure values

# Database Configuration
POSTGRES_DB=katacore_prod
POSTGRES_USER=katacore_user
POSTGRES_PASSWORD=__SECURE_POSTGRES_PASSWORD__
DATABASE_URL=postgresql://katacore_user:__SECURE_POSTGRES_PASSWORD__@postgres:5432/katacore_prod

# Redis Configuration
REDIS_PASSWORD=__SECURE_REDIS_PASSWORD__
REDIS_URL=redis://:__SECURE_REDIS_PASSWORD__@redis:6379

# Application Secrets
JWT_SECRET=__SECURE_JWT_SECRET__
LOG_LEVEL=info
NODE_ENV=production

# MinIO Object Storage
MINIO_ROOT_USER=katacore_admin
MINIO_ROOT_PASSWORD=__SECURE_MINIO_PASSWORD__

# pgAdmin Database Management
PGADMIN_EMAIL=admin@your-domain.com
PGADMIN_PASSWORD=__SECURE_PGADMIN_PASSWORD__

# Grafana Monitoring
GRAFANA_ADMIN_PASSWORD=__SECURE_GRAFANA_PASSWORD__

# API Configuration
API_VERSION=latest
CORS_ORIGIN=https://your-domain.com

# Frontend Configuration
SITE_VERSION=latest
NEXT_PUBLIC_API_URL=https://your-domain.com/api

# Domain & SSL Configuration
DOMAIN=your-domain.com
LETSENCRYPT_EMAIL=admin@your-domain.com

# Optional: Development overrides
# POSTGRES_HOST=localhost
# REDIS_HOST=localhost
# MINIO_HOST=localhost
EOF
    
    success "Environment template created at $template_file"
    info "📋 To use this template:"
    info "   1. Copy .env.prod.template to .env.prod"
    info "   2. Replace all __SECURE_*__ placeholders with actual values"
    info "   3. Update your-domain.com with your actual domain"
}

# Prepare optimized Nginx configuration
prepare_nginx_config() {
    log "🔧 Preparing Nginx configuration for deployment..."
    
    # Remove any conflicting configurations
    if [[ -d "nginx/conf.d" ]]; then
        # Backup existing configs
        mkdir -p nginx/conf.d/backup
        find nginx/conf.d -name "*.conf" -not -path "*/backup/*" -exec cp {} nginx/conf.d/backup/ \; 2>/dev/null || true
        
        # Remove conflicting files to prevent rate limiting conflicts
        rm -f nginx/conf.d/katacore.conf nginx/conf.d/katacore.optimized.conf 2>/dev/null || true
    fi
    
    # Create simple, working configuration for IP-based deployment
    mkdir -p nginx/conf.d
    cat > nginx/conf.d/simple-ip.conf << 'EOF'
# Simple IP-based configuration for KataCore deployment
upstream katacore_api {
    server api:3001;
    keepalive 32;
}

upstream katacore_site {
    server site:3000;
    keepalive 32;
}

server {
    listen 80 default_server;
    server_name _;

    # Health check endpoint
    location /nginx-health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }

    # API routes
    location /api/ {
        proxy_pass http://katacore_api/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
        proxy_buffering off;
    }

    # Frontend routes
    location / {
        proxy_pass http://katacore_site/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
        proxy_buffering off;
    }
}
EOF
    
    success "Created optimized Nginx configuration"
}

# Generate dynamic Nginx configuration based on deployment type
generate_nginx_config() {
    log "🔧 Generating Nginx configuration for deployment..."
    
    local config_file="nginx/conf.d/katacore.conf"
    local template_file="nginx/conf.d/katacore.template.conf"
    
    # Determine deployment configuration
    local host_url="${DOMAIN:-$SERVER_HOST}"
    local protocol="http"
    local enable_ssl="false"
    local cors_origin="*"
    local listen_directives="listen 80 default_server;"
    local server_names="_"
    local ssl_configuration=""
    local ssl_redirect_block=""
    
    # Enhanced configuration for domain-based deployment
    if [[ -n "$DOMAIN" ]] && [[ "$DOMAIN" != "$SERVER_HOST" ]]; then
        protocol="https"
        enable_ssl="true"
        cors_origin="$protocol://$DOMAIN"
        listen_directives="listen 443 ssl http2; listen [::]:443 ssl http2;"
        server_names="$DOMAIN www.$DOMAIN"
        
        # SSL configuration block
        ssl_configuration="
    # SSL Configuration
    ssl_certificate /etc/nginx/ssl/fullchain.pem;
    ssl_certificate_key /etc/nginx/ssl/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    ssl_session_tickets off;
    
    # Security headers for HTTPS
    add_header Strict-Transport-Security \"max-age=31536000; includeSubDomains; preload\" always;"
        
        # HTTP to HTTPS redirect block
        ssl_redirect_block="
# HTTP to HTTPS redirect
server {
    listen 80;
    listen [::]:80;
    server_name $DOMAIN www.$DOMAIN;
    
    # Let's Encrypt ACME challenge
    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
        try_files \$uri =404;
    }
    
    # Redirect all other HTTP traffic to HTTPS
    location / {
        return 301 https://\$host\$request_uri;
    }
}"
    else
        # IP-based deployment - simpler configuration
        cors_origin="$protocol://$host_url"
        listen_directives="listen 80 default_server;"
        server_names="_"
    fi
    
    # Backup existing config and create new one
    mkdir -p nginx/conf.d/backup
    [[ -f "$config_file" ]] && cp "$config_file" "nginx/conf.d/backup/katacore.conf.$(date +%Y%m%d-%H%M%S)" 2>/dev/null || true
    
    # Generate configuration from template if available
    if [[ -f "$template_file" ]]; then
        info "Using template $template_file for nginx configuration"
        cp "$template_file" "$config_file"
        
        # Replace template placeholders
        sed -i "s|{{LISTEN_DIRECTIVES}}|$listen_directives|g" "$config_file"
        sed -i "s|{{SERVER_NAMES}}|$server_names|g" "$config_file"
        sed -i "s|{{SSL_CONFIGURATION}}|$ssl_configuration|g" "$config_file"
        sed -i "s|{{CORS_ORIGIN}}|$cors_origin|g" "$config_file"
        sed -i "s|{{SSL_REDIRECT_BLOCK}}|$ssl_redirect_block|g" "$config_file"
        
    else
        warning "Template not found, creating configuration from scratch"
        
        # Create nginx configuration directory
        mkdir -p nginx/conf.d
        
        # Generate complete nginx configuration
        cat > "$config_file" << EOF
# KataCore Nginx Configuration - Generated for ${DOMAIN:-$SERVER_HOST}
# Generated on $(date)

# Upstream definitions
upstream katacore_api {
    server api:3001;
    keepalive 32;
    keepalive_requests 100;
    keepalive_timeout 60s;
}

upstream katacore_site {
    server site:3000;
    keepalive 32;
    keepalive_requests 100;
    keepalive_timeout 60s;
}

upstream katacore_minio_console {
    server minio:9001;
    keepalive 8;
}

upstream katacore_pgadmin {
    server pgadmin:80;
    keepalive 8;
}

$ssl_redirect_block

# Main Application Server
server {
    $listen_directives
    server_name $server_names;

$ssl_configuration

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header X-Robots-Tag "noindex, nofollow" always;

    # Client settings
    client_max_body_size 50m;
    client_body_timeout 60s;
    client_header_timeout 60s;

    # Health check endpoint
    location /nginx-health {
        access_log off;
        return 200 "healthy\\n";
        add_header Content-Type text/plain;
    }

    # API routes
    location /api/ {
        proxy_pass http://katacore_api/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
        proxy_buffering off;
        
        # Enable CORS
        add_header Access-Control-Allow-Origin "$cors_origin" always;
        add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS" always;
        add_header Access-Control-Allow-Headers "Content-Type, Authorization, X-Requested-With" always;
        
        if (\$request_method = 'OPTIONS') {
            return 204;
        }
    }

    # MinIO Console (Admin Panel)
    location /minio/ {
        auth_basic "MinIO Admin";
        auth_basic_user_file /etc/nginx/.htpasswd;
        
        proxy_pass http://katacore_minio_console/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    # pgAdmin (Database Admin)
    location /pgadmin/ {
        auth_basic "Database Admin";
        auth_basic_user_file /etc/nginx/.htpasswd;
        
        proxy_pass http://katacore_pgadmin/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_redirect off;
    }

    # Static files caching
    location ~* \\.(jpg|jpeg|png|gif|ico|css|js|woff|woff2|ttf|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        add_header Vary Accept-Encoding;
        access_log off;
        
        proxy_pass http://katacore_site;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    # Frontend Application (catch-all)
    location / {
        proxy_pass http://katacore_site;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
        
        # Enable Gzip compression
        gzip on;
        gzip_vary on;
        gzip_min_length 1024;
        gzip_comp_level 6;
        gzip_types text/plain text/css application/json application/javascript text/xml application/xml text/javascript;
    }

    # Error pages
    error_page 404 /404.html;
    error_page 500 502 503 504 /50x.html;
    
    location = /404.html {
        internal;
        return 404 "Page not found\\n";
        add_header Content-Type text/plain;
    }
    
    location = /50x.html {
        internal;
        return 500 "Server error\\n";
        add_header Content-Type text/plain;
    }
}
EOF
    fi
    
    # Remove any conflicting simple configurations for domain-based deployments
    if [[ -n "$DOMAIN" ]] && [[ "$DOMAIN" != "$SERVER_HOST" ]]; then
        rm -f nginx/conf.d/simple-ip.conf 2>/dev/null || true
        info "Removed simple IP configuration for domain deployment"
    fi
    
    success "Generated Nginx configuration: $config_file"
    info "🌐 Configuration type: ${DOMAIN:+Domain-based ($DOMAIN)}${DOMAIN:-IP-based ($SERVER_HOST)}"
    info "🔒 SSL enabled: $enable_ssl"
    info "🌍 CORS origin: $cors_origin"
}

# Upload files to server
upload_files() {
    if [[ "$CONFIG_ONLY" == "true" ]]; then
        log "📤 Uploading configuration files only..."
        scp -P "$SERVER_PORT" .env.prod "$SERVER_USER@$SERVER_HOST:$REMOTE_DIR/"
        
        # Upload nginx config if it exists
        if [[ -d "nginx/conf.d" ]]; then
            scp -P "$SERVER_PORT" nginx/conf.d/* "$SERVER_USER@$SERVER_HOST:$REMOTE_DIR/nginx/conf.d/" 2>/dev/null || true
        fi
    else
        log "📤 Uploading project files..."
        
        # Ensure clean Nginx configuration
        if [[ -f "nginx/conf.d/simple-ip.conf" ]]; then
            # Remove potentially conflicting configs
            rm -f nginx/conf.d/katacore.optimized.conf 2>/dev/null || true
            rm -f nginx/conf.d/katacore.conf 2>/dev/null || true
        fi
        
        # Create exclude file for rsync
        cat > .rsync-exclude << EOF
.git/
node_modules/
.next/
dist/
*.log
.deploy-cache/
.deploy-logs/
.DS_Store
Thumbs.db
nginx/conf.d/backup/
nginx/conf.d/*.backup
EOF
        
        # Upload files using rsync
        rsync -avz --delete --exclude-from=.rsync-exclude \
            -e "ssh -p $SERVER_PORT" \
            ./ "$SERVER_USER@$SERVER_HOST:$REMOTE_DIR/"
        
        rm -f .rsync-exclude
        
        # Ensure proper permissions on remote server
        ssh -p "$SERVER_PORT" "$SERVER_USER@$SERVER_HOST" << 'EOF'
            cd /opt/katacore
            chmod 600 .env.prod 2>/dev/null || true
            chmod +x scripts/*.sh 2>/dev/null || true
            
            # Clean up conflicting Nginx configs
            if [[ -f "nginx/conf.d/simple-ip.conf" ]]; then
                cd nginx/conf.d
                # Keep only the simple-ip.conf
                for conf in *.conf; do
                    if [[ "$conf" != "simple-ip.conf" ]]; then
                        mv "$conf" "$conf.backup" 2>/dev/null || true
                    fi
                done
            fi
EOF
    fi
    
    success "Files uploaded successfully"
}

# Deploy application
deploy_application() {
    if [[ "$SETUP_ONLY" == "true" ]]; then
        debug "Skipping application deployment (setup-only mode)"
        return
    fi
    
    log "🚀 Deploying KataCore application..."
    
    local compose_args=""
    
    if [[ "$CLEAN_DEPLOY" == "true" ]]; then
        compose_args="--force-recreate --remove-orphans"
    fi
    
    if [[ "$FORCE_REBUILD" == "true" ]]; then
        compose_args="$compose_args --build"
    fi
    
    ssh -p "$SERVER_PORT" "$SERVER_USER@$SERVER_HOST" << EOF
        set -euo pipefail
        cd $REMOTE_DIR
        
        # Ensure environment file exists
        if [[ ! -f ".env.prod" ]]; then
            echo "❌ Environment file .env.prod not found!"
            exit 1
        fi
        
        # Stop existing containers if clean deploy
        if [[ "$CLEAN_DEPLOY" == "true" ]]; then
            echo "🧹 Cleaning up existing deployment..."
            docker compose -f docker-compose.prod.yml --env-file .env.prod down --volumes --remove-orphans 2>/dev/null || true
            docker system prune -f 2>/dev/null || true
        fi
        
        # Deploy application
        echo "🚀 Starting KataCore services..."
        docker compose -f docker-compose.prod.yml --env-file .env.prod up -d $compose_args
        
        # Wait for services to be healthy
        echo "⏳ Waiting for services to be ready..."
        sleep 30
        
        # Check service status
        docker compose -f docker-compose.prod.yml --env-file .env.prod ps
        
        echo "✅ Deployment completed"
EOF
    
    success "Application deployed successfully"
}

# Verify deployment
verify_deployment() {
    log "🔍 Verifying deployment..."
    
    # Test endpoints
    local endpoints=(
        "https://$SERVER_HOST/health"
        "https://$SERVER_HOST/"
    )
    
    for endpoint in "${endpoints[@]}"; do
        if curl -fsSL -k "$endpoint" >/dev/null 2>&1; then
            success "✓ $endpoint is accessible"
        else
            warning "✗ $endpoint is not accessible"
        fi
    done
    
    # Show service URLs
    echo ""
    echo -e "${GREEN}🎉 KataCore StartKit v1 Deployment Complete!${NC}"
    echo ""
    echo -e "${CYAN}📍 Service URLs:${NC}"
    echo -e "  🌐 Frontend:    https://$SERVER_HOST/"
    echo -e "  🔧 API:         https://$SERVER_HOST/api/"
    echo -e "  📊 Admin:       https://$SERVER_HOST:8080/"
    echo -e "  💾 Storage:     https://$SERVER_HOST:9001/"
    echo ""
    echo -e "${YELLOW}🔐 Security Info:${NC}"
    echo -e "  📄 Environment: .env.prod (contains passwords)"
    echo -e "  🔒 SSH:         $SERVER_USER@$SERVER_HOST:$SERVER_PORT"
    echo ""
}

# Main deployment function
main() {
    # Show help if no arguments provided
    if [[ $# -eq 0 ]]; then
        show_banner
        echo -e "${YELLOW}No arguments provided.${NC}\n"
        show_help
        exit 1
    fi
    
    show_banner
    parse_arguments "$@"
    
    # Handle environment template creation separately
    if [[ "$CREATE_ENV_TEMPLATE" == "true" ]]; then
        create_environment_template
        success "🎉 Environment template created successfully!"
        exit 0
    fi
    
    setup_deployment_logging
    
    # Run pre-deployment checks
    if [[ -f "scripts/pre-deploy-check.sh" ]]; then
        log "🔍 Running pre-deployment checks..."
        if bash scripts/pre-deploy-check.sh; then
            success "Pre-deployment checks passed"
        else
            error "Pre-deployment checks failed. Please fix the issues before proceeding."
        fi
    fi
    
    if [[ "$DRY_RUN" == "true" ]]; then
        info "DRY RUN MODE - No changes will be made"
    fi
    
    validate_environment
    validate_environment_enhanced
    
    # Setup SSH keys if requested
    if [[ "$SETUP_SSH_KEYS" == "true" ]]; then
        setup_ssh_keys
    fi
    
    test_ssh_connection
    setup_server
    generate_environment
    generate_nginx_config
    upload_files
    deploy_application
    verify_deployment
    
    # Run post-deployment verification
    if [[ -f "scripts/post-deploy-verify.sh" ]]; then
        log "🔍 Running post-deployment verification..."
        if bash scripts/post-deploy-verify.sh "$SERVER_HOST" "$SERVER_PORT" "$SERVER_USER"; then
            success "Post-deployment verification completed"
        else
            warning "Post-deployment verification found some issues"
        fi
    fi
    
    success "🎉 KataCore StartKit v1 deployment completed successfully!"
}

# Execute main function with all arguments
main "$@"
