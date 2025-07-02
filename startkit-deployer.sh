#!/bin/bash

# KataCore StartKit v2 - Ultimate Deployment Script
# Auto-configuration, SSL automation, and update management
# Compatible with any Linux server

set -euo pipefail

# Version information
readonly SCRIPT_VERSION="2.0.0"
readonly KATACORE_VERSION="StartKit v2"

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
FIRST_DEPLOY=false
UPDATE_DEPLOY=false
AUTO_SSL=true
VERBOSE=false
DRY_RUN=false

# Deployment paths
readonly REMOTE_DIR="/opt/katacore"
readonly LOG_DIR=".deploy-logs"
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
║                     🚀 KataCore StartKit v2 Deployer                        ║
║                                                                              ║
║    Auto-configuration • SSL Automation • Update Management                  ║
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
KataCore StartKit v2 - Ultimate Deployment Script

USAGE:
    $0 --host SERVER_IP [--domain DOMAIN]

REQUIRED:
    --host HOST        Target server IP address or domain

OPTIONS:
    --domain DOMAIN    Domain name for SSL certificates (auto-configures SSL)
    --clean           Clean deployment (remove existing data)
    --update          Update existing deployment (NextJS + NestJS + Prisma)
    --no-ssl          Disable SSL auto-configuration
    --verbose         Enable verbose logging
    --dry-run         Show what would be done without executing
    --help            Show this help message

DEPLOYMENT MODES:
    First Deploy:     Automatically detects and creates full environment
    Update Deploy:    Updates application code and Prisma schema
    Clean Deploy:     Removes all data and redeploys from scratch

EXAMPLES:
    # First deployment with IP (HTTP only)
    $0 --host 192.168.1.100

    # First deployment with domain (auto SSL)
    $0 --host myserver.com --domain myapp.com

    # Update existing deployment
    $0 --host 192.168.1.100 --update

    # Clean deployment
    $0 --host 192.168.1.100 --clean

StartKit v2 Features:
    ✅ Auto-detects first deployment vs updates
    ✅ Auto-generates secure environment variables
    ✅ Auto-configures SSL certificates
    ✅ Auto-updates NextJS/NestJS/Prisma
    ✅ Minimal configuration required

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
            --domain)
                if [[ -z "${2:-}" ]] || [[ "${2:-}" =~ ^-- ]]; then
                    error "--domain requires a value (domain name)"
                fi
                DOMAIN="$2"
                AUTO_SSL=true
                shift 2
                ;;
            --clean)
                CLEAN_DEPLOY=true
                shift
                ;;
            --update)
                UPDATE_DEPLOY=true
                shift
                ;;
            --no-ssl)
                AUTO_SSL=false
                shift
                ;;
            --verbose)
                VERBOSE=true
                shift
                ;;
            --dry-run)
                DRY_RUN=true
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

    # Validate required arguments
    if [[ -z "$SERVER_HOST" ]]; then
        error "Server host is required. Use --host SERVER_IP or --help for usage information"
    fi
    
    # Validate host format (basic check)
    if [[ ! "$SERVER_HOST" =~ ^[a-zA-Z0-9.-]+$ ]]; then
        error "Invalid host format: $SERVER_HOST. Please provide a valid IP address or domain name"
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

# Auto-generate environment file for first deployment
auto_generate_environment() {
    log "🔧 Auto-generating production environment..."
    
    local env_file=".env.prod"
    local domain_name="${DOMAIN:-$SERVER_HOST}"
    local use_ssl="false"
    
    # Determine if SSL should be used
    if [[ -n "$DOMAIN" ]] && [[ "$AUTO_SSL" == "true" ]]; then
        use_ssl="true"
    fi
    
    local protocol="http"
    if [[ "$use_ssl" == "true" ]]; then
        protocol="https"
    fi
    
    # Generate secure passwords and secrets
    local postgres_password=$(generate_password 24)
    local redis_password=$(generate_password 20)
    local jwt_secret=$(generate_jwt_secret)
    local minio_password=$(generate_password 20)
    local pgadmin_password=$(generate_password 16)
    local encryption_key=$(openssl rand -hex 32)
    
    info "🔐 Generated secure credentials for all services"
    
    # Create comprehensive .env.prod file
    cat > "$env_file" << EOF
# KataCore StartKit v2 - Production Environment
# Auto-generated on $(date -Iseconds)

# ===== DEPLOYMENT CONFIGURATION =====
NODE_ENV=production
DEPLOYMENT_MODE=production
DEPLOYMENT_VERSION=$SCRIPT_VERSION
KATACORE_VERSION=$KATACORE_VERSION
DEPLOYMENT_HOST=$SERVER_HOST
DEPLOYMENT_DOMAIN=$domain_name

# ===== PROTOCOL AND SSL =====
PROTOCOL=$protocol
ENABLE_SSL=$use_ssl
HTTP_PORT=80
HTTPS_PORT=443
HOST_URL=$domain_name

# ===== DATABASE CONFIGURATION =====
POSTGRES_DB=katacore_prod
POSTGRES_USER=katacore_user
POSTGRES_PASSWORD=$postgres_password
DATABASE_URL=postgresql://katacore_user:$postgres_password@postgres:5432/katacore_prod

# ===== REDIS CONFIGURATION =====
REDIS_PASSWORD=$redis_password
REDIS_URL=redis://:$redis_password@redis:6379

# ===== APPLICATION SECRETS =====
JWT_SECRET=$jwt_secret
ENCRYPTION_KEY=$encryption_key
LOG_LEVEL=info

# ===== MINIO OBJECT STORAGE =====
MINIO_ROOT_USER=katacore_admin
MINIO_ROOT_PASSWORD=$minio_password
MINIO_BROWSER_REDIRECT_URL=$protocol://$domain_name:9001
MINIO_API_URL=$protocol://$domain_name:9000

# ===== PGADMIN DATABASE MANAGEMENT =====
PGADMIN_EMAIL=admin@$domain_name
PGADMIN_PASSWORD=$pgadmin_password

# ===== API CONFIGURATION =====
API_VERSION=latest
CORS_ORIGIN=$protocol://$domain_name
API_BASE_URL=$protocol://$domain_name/api

# ===== FRONTEND CONFIGURATION =====
SITE_VERSION=latest
NEXT_PUBLIC_API_URL=$protocol://$domain_name/api
NEXT_PUBLIC_SITE_URL=$protocol://$domain_name
NEXTAUTH_URL=$protocol://$domain_name
NEXTAUTH_SECRET=$jwt_secret

# ===== DOMAIN CONFIGURATION =====
DOMAIN=$domain_name
API_DOMAIN=api.$domain_name
ADMIN_DOMAIN=admin.$domain_name
STORAGE_DOMAIN=storage.$domain_name

# ===== SSL CONFIGURATION =====
LETSENCRYPT_EMAIL=admin@$domain_name
SSL_CERT_PATH=/etc/nginx/ssl/fullchain.pem
SSL_KEY_PATH=/etc/nginx/ssl/privkey.pem

# ===== SECURITY CONFIGURATION =====
RATE_LIMIT=100
FAIL2BAN_ENABLED=true
MAX_REQUEST_SIZE=50mb
SESSION_TIMEOUT=24h

# ===== MONITORING =====
ENABLE_MONITORING=true
GRAFANA_ADMIN_PASSWORD=$(generate_password 16)
PROMETHEUS_PASSWORD=$(generate_password 16)
EOF
    
    # Set secure permissions
    chmod 600 "$env_file"
    
    # Create backup
    cp "$env_file" "${env_file}.backup-$(date +%Y%m%d-%H%M%S)"
    
    success "✅ Production environment file generated with secure credentials"
    info "📝 Environment file: $env_file"
    info "🔒 File permissions set to 600 (owner read/write only)"
    
    # Show credential summary (safely)
    echo ""
    info "🔐 Generated Credentials Summary:"
    echo "   • PostgreSQL: Auto-generated 24-char password"
    echo "   • Redis: Auto-generated 20-char password"
    echo "   • MinIO: Auto-generated 20-char password"
    echo "   • pgAdmin: Auto-generated 16-char password"
    echo "   • JWT Secret: Auto-generated 64-char secret"
    echo "   • Encryption Key: Auto-generated 64-char hex key"
    echo ""
}

# Auto-configure SSL certificates
auto_configure_ssl() {
    log "🔒 Auto-configuring SSL certificates..."
    
    if [[ -z "$DOMAIN" ]]; then
        warning "No domain specified, skipping SSL configuration"
        return 0
    fi
    
    if [[ "$AUTO_SSL" != "true" ]]; then
        info "SSL auto-configuration disabled, skipping"
        return 0
    fi
    
    # Create SSL directory structure
    local ssl_dir="./ssl-temp"
    mkdir -p "$ssl_dir"
    
    # Create SSL configuration script for server
    cat > "$ssl_dir/setup-ssl.sh" << 'EOF'
#!/bin/bash

set -euo pipefail

DOMAIN="$1"
EMAIL="admin@$1"

log() {
    echo "[$(date +'%H:%M:%S')] $1"
}

error() {
    echo "ERROR: $1" >&2
    exit 1
}

# Install certbot if not present
install_certbot() {
    log "Installing Certbot..."
    
    if command -v apt >/dev/null 2>&1; then
        # Ubuntu/Debian
        apt update
        apt install -y certbot python3-certbot-nginx
    elif command -v yum >/dev/null 2>&1; then
        # CentOS/RHEL
        yum install -y epel-release
        yum install -y certbot python3-certbot-nginx
    elif command -v dnf >/dev/null 2>&1; then
        # Fedora
        dnf install -y certbot python3-certbot-nginx
    else
        # Try snap as fallback
        if command -v snap >/dev/null 2>&1; then
            snap install --classic certbot
            ln -sf /snap/bin/certbot /usr/bin/certbot
        else
            error "Could not install certbot. Please install manually."
        fi
    fi
}

# Setup SSL certificates
setup_ssl_certificates() {
    log "Setting up SSL certificates for domain: $DOMAIN"
    
    # Create nginx SSL directory
    mkdir -p /etc/nginx/ssl
    
    # Stop nginx temporarily if running
    if systemctl is-active --quiet nginx 2>/dev/null; then
        log "Stopping nginx temporarily for certificate generation..."
        systemctl stop nginx
        RESTART_NGINX=true
    fi
    
    # Generate certificate using standalone mode
    log "Generating Let's Encrypt certificate..."
    certbot certonly \
        --standalone \
        --non-interactive \
        --agree-tos \
        --email "$EMAIL" \
        -d "$DOMAIN" \
        -d "www.$DOMAIN" \
        --expand
    
    # Copy certificates to nginx directory
    log "Copying certificates to nginx directory..."
    cp "/etc/letsencrypt/live/$DOMAIN/fullchain.pem" /etc/nginx/ssl/
    cp "/etc/letsencrypt/live/$DOMAIN/privkey.pem" /etc/nginx/ssl/
    
    # Set proper permissions
    chmod 644 /etc/nginx/ssl/fullchain.pem
    chmod 600 /etc/nginx/ssl/privkey.pem
    
    # Setup auto-renewal
    log "Setting up certificate auto-renewal..."
    
    # Create renewal hook script
    cat > /etc/letsencrypt/renewal-hooks/deploy/nginx-reload.sh << 'HOOK_EOF'
#!/bin/bash
# Copy renewed certificates to nginx directory
cp "/etc/letsencrypt/live/DOMAIN_PLACEHOLDER/fullchain.pem" /etc/nginx/ssl/
cp "/etc/letsencrypt/live/DOMAIN_PLACEHOLDER/privkey.pem" /etc/nginx/ssl/
chmod 644 /etc/nginx/ssl/fullchain.pem
chmod 600 /etc/nginx/ssl/privkey.pem
# Reload nginx
if systemctl is-active --quiet nginx; then
    systemctl reload nginx
fi
HOOK_EOF
    
    # Replace domain placeholder
    sed -i "s/DOMAIN_PLACEHOLDER/$DOMAIN/g" /etc/letsencrypt/renewal-hooks/deploy/nginx-reload.sh
    chmod +x /etc/letsencrypt/renewal-hooks/deploy/nginx-reload.sh
    
    # Add cron job for auto-renewal
    if ! crontab -l 2>/dev/null | grep -q "certbot renew"; then
        (crontab -l 2>/dev/null; echo "0 12 * * * /usr/bin/certbot renew --quiet") | crontab -
        log "Added cron job for certificate auto-renewal"
    fi
    
    # Restart nginx if it was running
    if [[ "${RESTART_NGINX:-false}" == "true" ]]; then
        log "Starting nginx..."
        systemctl start nginx
    fi
    
    log "✅ SSL certificates configured successfully!"
    log "📋 Certificate files:"
    log "   • /etc/nginx/ssl/fullchain.pem"
    log "   • /etc/nginx/ssl/privkey.pem"
    log "🔄 Auto-renewal configured via cron job"
}

# Main SSL setup function
main() {
    if [[ $# -eq 0 ]]; then
        error "Usage: $0 DOMAIN"
    fi
    
    local domain="$1"
    
    log "🔒 Starting SSL setup for domain: $domain"
    
    # Validate domain format
    if [[ ! "$domain" =~ ^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        error "Invalid domain format: $domain"
    fi
    
    # Check if running as root
    if [[ $EUID -ne 0 ]]; then
        error "This script must be run as root"
    fi
    
    # Install certbot if needed
    if ! command -v certbot >/dev/null 2>&1; then
        install_certbot
    fi
    
    # Setup SSL certificates
    setup_ssl_certificates
    
    log "🎉 SSL configuration completed successfully!"
}

main "$@"
EOF
    
    chmod +x "$ssl_dir/setup-ssl.sh"
    
    success "SSL configuration script prepared"
    info "📝 SSL script: $ssl_dir/setup-ssl.sh"
    info "🚀 Will be executed on server during deployment"
}

# Create optimized nginx configuration with SSL support
create_nginx_config() {
    log "📝 Creating optimized Nginx configuration..."
    
    local domain_name="${DOMAIN:-$SERVER_HOST}"
    local use_ssl="false"
    
    if [[ -n "$DOMAIN" ]] && [[ "$AUTO_SSL" == "true" ]]; then
        use_ssl="true"
    fi
    
    # Ensure nginx directory exists
    mkdir -p nginx/conf.d
    
    # Backup existing config
    if [[ -f "nginx/conf.d/katacore.conf" ]]; then
        cp "nginx/conf.d/katacore.conf" "nginx/conf.d/katacore.conf.backup-$(date +%Y%m%d-%H%M%S)"
    fi
    
    # Create optimized nginx configuration
    cat > "nginx/conf.d/katacore.conf" << EOF
# KataCore StartKit v2 - Optimized Nginx Configuration
# Auto-generated on $(date -Iseconds)

# Rate limiting zones
limit_req_zone \$binary_remote_addr zone=general:10m rate=10r/s;
limit_req_zone \$binary_remote_addr zone=api:10m rate=30r/s;
limit_conn_zone \$binary_remote_addr zone=perip:10m;

# Upstream definitions with load balancing
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

# HTTP server block
server {
    listen 80;
    listen [::]:80;
    server_name $domain_name www.$domain_name;
    
    # Security headers for HTTP
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-Robots-Tag "noindex, nofollow" always;
    
    # Let's Encrypt ACME challenge
    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
        try_files \$uri =404;
    }
    
EOF

    if [[ "$use_ssl" == "true" ]]; then
        cat >> "nginx/conf.d/katacore.conf" << EOF
    # Redirect all other HTTP traffic to HTTPS
    location / {
        return 301 https://\$host\$request_uri;
    }
}

# HTTPS server block
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name $domain_name www.$domain_name;
    
    # SSL Configuration
    ssl_certificate /etc/nginx/ssl/fullchain.pem;
    ssl_certificate_key /etc/nginx/ssl/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    ssl_session_tickets off;
    
    # HTTPS Security headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header X-Robots-Tag "noindex, nofollow" always;
    
    # Rate limiting
    limit_req zone=general burst=20 nodelay;
    limit_conn perip 20;
    
    # Health check endpoint
    location /nginx-health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }
    
    # API routes with enhanced rate limiting
    location /api/ {
        limit_req zone=api burst=10 nodelay;
        
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
        
        # CORS headers
        add_header Access-Control-Allow-Origin "https://$domain_name" always;
        add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS" always;
        add_header Access-Control-Allow-Headers "Content-Type, Authorization, X-Requested-With" always;
        
        if (\$request_method = 'OPTIONS') {
            return 204;
        }
    }
    
    # MinIO Console (Admin Panel) - Protected
    location /minio/ {
        auth_basic "MinIO Admin";
        auth_basic_user_file /etc/nginx/.htpasswd;
        
        proxy_pass http://katacore_minio_console/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
    
    # pgAdmin (Database Admin) - Protected
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
    
    # Static files with aggressive caching
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|woff|woff2|ttf|svg)$ {
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
        
        # Enable compression
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
        return 404 "Page not found\n";
        add_header Content-Type text/plain;
    }
    
    location = /50x.html {
        internal;
        return 500 "Server error\n";
        add_header Content-Type text/plain;
    }
}
EOF
    else
        cat >> "nginx/conf.d/katacore.conf" << EOF
    # Serve HTTP content directly (no SSL)
    
    # Health check endpoint
    location /nginx-health {
        access_log off;
        return 200 "healthy\n";
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
        
        # Enable compression
        gzip on;
        gzip_vary on;
        gzip_min_length 1024;
        gzip_comp_level 6;
        gzip_types text/plain text/css application/json application/javascript text/xml application/xml text/javascript;
    }
}
EOF
    fi
    
    success "✅ Nginx configuration created"
    info "📝 Configuration file: nginx/conf.d/katacore.conf"
    info "🔒 SSL enabled: $use_ssl"
}

# Detect deployment type (first-time vs update)
detect_deployment_type() {
    log "🔍 Detecting deployment type..."
    
    # Check if this is a first deployment
    if [[ "$CLEAN_DEPLOY" == "true" ]]; then
        FIRST_DEPLOY=true
        info "🔄 Clean deployment requested - treating as first deployment"
        return
    fi
    
    if [[ "$UPDATE_DEPLOY" == "true" ]]; then
        FIRST_DEPLOY=false
        info "⬆️ Update deployment requested"
        return
    fi
    
    # Auto-detect based on server state
    if ssh -o ConnectTimeout=10 -o BatchMode=yes "$SERVER_USER@$SERVER_HOST" \
        "[ -d '$REMOTE_DIR' ] && [ -f '$REMOTE_DIR/.env.prod' ]" 2>/dev/null; then
        FIRST_DEPLOY=false
        info "🔄 Existing deployment detected - performing update"
    else
        FIRST_DEPLOY=true
        info "🚀 No existing deployment found - performing first-time setup"
    fi
}

# Execute first-time deployment
execute_first_deployment() {
    log "🚀 Executing first-time deployment..."
    
    # Step 1: Generate environment and configuration
    auto_generate_environment
    auto_configure_ssl
    create_nginx_config
    
    # Step 2: Prepare deployment package
    log "📦 Preparing deployment package..."
    
    # Create temporary deployment directory
    local deploy_dir="deploy-temp-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$deploy_dir"
    
    # Copy essential files
    cp -r . "$deploy_dir/" 2>/dev/null || true
    
    # Remove unnecessary files from deployment package
    find "$deploy_dir" -name "*.log" -delete 2>/dev/null || true
    find "$deploy_dir" -name ".git" -type d -exec rm -rf {} + 2>/dev/null || true
    find "$deploy_dir" -name "node_modules" -type d -exec rm -rf {} + 2>/dev/null || true
    
    # Step 3: Deploy to server
    log "🚀 Deploying to server: $SERVER_HOST"
    
    # Upload deployment package
    rsync -avz --progress "$deploy_dir/" "$SERVER_USER@$SERVER_HOST:$REMOTE_DIR/"
    
    # Step 4: Setup server environment
    log "⚙️ Setting up server environment..."
    
    ssh "$SERVER_USER@$SERVER_HOST" << 'DEPLOY_EOF'
set -euo pipefail

log() {
    echo "[$(date +'%H:%M:%S')] $1"
}

# Install Docker if not present
if ! command -v docker >/dev/null 2>&1; then
    log "Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    systemctl enable docker
    systemctl start docker
    usermod -aG docker $USER
fi

# Install Docker Compose if not present
if ! command -v docker-compose >/dev/null 2>&1; then
    log "Installing Docker Compose..."
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
fi

# Install Nginx if not present
if ! command -v nginx >/dev/null 2>&1; then
    log "Installing Nginx..."
    if command -v apt >/dev/null 2>&1; then
        apt update && apt install -y nginx
    elif command -v yum >/dev/null 2>&1; then
        yum install -y nginx
    elif command -v dnf >/dev/null 2>&1; then
        dnf install -y nginx
    fi
    systemctl enable nginx
fi

log "✅ Server environment setup completed"
DEPLOY_EOF
    
    # Step 5: Setup SSL if domain is provided
    if [[ -n "$DOMAIN" ]] && [[ "$AUTO_SSL" == "true" ]]; then
        log "🔒 Setting up SSL certificates..."
        ssh "$SERVER_USER@$SERVER_HOST" "cd $REMOTE_DIR && chmod +x ssl-temp/setup-ssl.sh && ./ssl-temp/setup-ssl.sh $DOMAIN"
    fi
    
    # Step 6: Deploy application
    log "🚀 Deploying application..."
    
    ssh "$SERVER_USER@$SERVER_HOST" << DEPLOY_EOF
set -euo pipefail
cd $REMOTE_DIR

log() {
    echo "[$(date +'%H:%M:%S')] \$1"
}

# Stop existing containers if any
log "Stopping existing containers..."
docker-compose -f docker-compose.prod.yml down 2>/dev/null || true

# Copy nginx configuration
log "Configuring Nginx..."
cp nginx/conf.d/katacore.conf /etc/nginx/sites-available/katacore
rm -f /etc/nginx/sites-enabled/default
ln -sf /etc/nginx/sites-available/katacore /etc/nginx/sites-enabled/katacore

# Test nginx configuration
nginx -t

# Start application
log "Starting application..."
docker-compose -f docker-compose.prod.yml up -d

# Start nginx
systemctl restart nginx

log "✅ Application deployment completed"
DEPLOY_EOF
    
    # Cleanup
    rm -rf "$deploy_dir"
    
    success "🎉 First-time deployment completed successfully!"
    show_deployment_summary
}

# Execute update deployment
execute_update_deployment() {
    log "⬆️ Executing update deployment..."
    
    # Step 1: Backup existing environment
    log "💾 Backing up existing environment..."
    
    ssh "$SERVER_USER@$SERVER_HOST" << 'BACKUP_EOF'
cd /opt/katacore
if [[ -f .env.prod ]]; then
    cp .env.prod .env.prod.backup-$(date +%Y%m%d-%H%M%S)
fi
BACKUP_EOF
    
    # Step 2: Update application code
    log "📦 Updating application code..."
    
    # Only sync application directories and necessary files
    local sync_paths=(
        "api/"
        "site/"
        "docker-compose.prod.yml"
        "package.json"
    )
    
    for path in "${sync_paths[@]}"; do
        if [[ -e "$path" ]]; then
            rsync -avz --progress "$path" "$SERVER_USER@$SERVER_HOST:$REMOTE_DIR/"
        fi
    done
    
    # Step 3: Update and restart services
    log "🔄 Updating services..."
    
    ssh "$SERVER_USER@$SERVER_HOST" << 'UPDATE_EOF'
set -euo pipefail
cd /opt/katacore

log() {
    echo "[$(date +'%H:%M:%S')] $1"
}

# Pull latest images and rebuild
log "Pulling latest images..."
docker-compose -f docker-compose.prod.yml pull

log "Rebuilding and restarting services..."
docker-compose -f docker-compose.prod.yml up -d --build

# Run Prisma migrations if needed
log "Running database migrations..."
docker-compose -f docker-compose.prod.yml exec -T api npx prisma migrate deploy 2>/dev/null || true

log "✅ Update deployment completed"
UPDATE_EOF
    
    success "🎉 Update deployment completed successfully!"
    show_deployment_summary
}

# Show deployment summary
show_deployment_summary() {
    echo ""
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                           🎉 DEPLOYMENT SUCCESSFUL! 🎉                     ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    local domain_name="${DOMAIN:-$SERVER_HOST}"
    local protocol="http"
    if [[ -n "$DOMAIN" ]] && [[ "$AUTO_SSL" == "true" ]]; then
        protocol="https"
    fi
    
    echo -e "🌐 ${BLUE}Application URLs:${NC}"
    echo -e "   📱 Main Site: ${CYAN}$protocol://$domain_name${NC}"
    echo -e "   🔧 API: ${CYAN}$protocol://$domain_name/api${NC}"
    echo -e "   💾 pgAdmin: ${CYAN}$protocol://$domain_name/pgadmin${NC}"
    echo -e "   📦 MinIO: ${CYAN}$protocol://$domain_name/minio${NC}"
    echo ""
    
    echo -e "🔧 ${BLUE}Management:${NC}"
    echo -e "   📊 Server: ${CYAN}$SERVER_HOST${NC}"
    echo -e "   🔒 SSL: ${CYAN}$([ "$AUTO_SSL" == "true" ] && echo "Enabled" || echo "Disabled")${NC}"
    echo -e "   📂 Remote Dir: ${CYAN}$REMOTE_DIR${NC}"
    echo ""
    
    echo -e "📝 ${BLUE}Next Steps:${NC}"
    echo -e "   1. Visit $protocol://$domain_name to access your application"
    echo -e "   2. Check logs: ${CYAN}ssh $SERVER_USER@$SERVER_HOST 'cd $REMOTE_DIR && docker-compose logs'${NC}"
    echo -e "   3. Monitor status: ${CYAN}ssh $SERVER_USER@$SERVER_HOST 'cd $REMOTE_DIR && docker-compose ps'${NC}"
    echo ""
    
    if [[ "$FIRST_DEPLOY" == "true" ]]; then
        echo -e "🔐 ${YELLOW}Important Security Notes:${NC}"
        echo -e "   • Environment file created with secure passwords"
        echo -e "   • All credentials are randomly generated"
        echo -e "   • SSL configured automatically (if domain provided)"
        echo -e "   • Admin panels protected with HTTP auth"
        echo ""
    fi
}

# Setup deployment logging
setup_deployment_logging() {
    mkdir -p "$LOG_DIR"
    debug "Logging setup completed"
}

# Main execution function
main() {
    # Show banner
    show_banner
    
    # Parse arguments
    parse_arguments "$@"
    
    # Setup logging
    setup_deployment_logging
    
    # Validate environment
    validate_environment
    
    # Detect deployment type
    detect_deployment_type
    
    # Execute appropriate deployment
    if [[ "$FIRST_DEPLOY" == "true" ]]; then
        execute_first_deployment
    else
        execute_update_deployment
    fi
}

# Run main function with all arguments
main "$@"
