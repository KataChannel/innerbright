#!/bin/bash

# 🚀 KataCore StartKit v1 - Clean Minimal Deployment System
# Production-ready deployment with auto-generation and security

set -euo pipefail

# Version and metadata
readonly VERSION="1.0.0"
readonly SCRIPT_NAME="KataCore StartKit v1"

# Color codes
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

# Configuration
SERVER_IP=""
DOMAIN=""
DEPLOY_TYPE="simple"
FORCE_REGEN=false
AUTO_PUSH=false
VERBOSE=false
DRY_RUN=false

# Paths
readonly PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly ENV_FILE="$PROJECT_ROOT/.env"
readonly COMPOSE_FILE="$PROJECT_ROOT/docker-compose.startkitv1.yml"
readonly NGINX_CONFIG="$PROJECT_ROOT/nginx-startkitv1.conf"

# ===== LOGGING FUNCTIONS =====
log() { echo -e "${GREEN}[$(date +'%H:%M:%S')]${NC} $1"; }
info() { echo -e "${CYAN}ℹ️  $1${NC}"; }
success() { echo -e "${GREEN}✅ $1${NC}"; }
warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
error() { echo -e "${RED}❌ $1${NC}"; exit 1; }
debug() { [[ "$VERBOSE" == "true" ]] && echo -e "${PURPLE}🐛 $1${NC}" || true; }

# ===== BANNER =====
show_banner() {
    echo -e "${BLUE}"
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════════════════════╗
║                    🚀 KataCore StartKit v1 - Clean Deploy                   ║
║                                                                              ║
║    ✅ Auto Environment Generation    ✅ Full Docker Stack                    ║
║    ✅ Nginx + SSL Support          ✅ Production Ready                      ║
║    ✅ Simple & Full Deploy         ✅ Git Integration                       ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# ===== HELP FUNCTION =====
show_help() {
    cat << 'EOF'
🚀 KataCore StartKit v1 - Clean Deployment System

USAGE:
    ./deploy-startkitv1-clean.sh [COMMAND] [OPTIONS]

COMMANDS:
    deploy-simple IP           Simple deployment with IP (Docker only)
    deploy-full DOMAIN         Full deployment with domain + Nginx + SSL
    deploy-guide              Step-by-step guided deployment
    generate-env              Generate environment variables only
    test-deployment           Test current deployment
    cleanup                   Clean up old deployment files

OPTIONS:
    --force-regen             Force regenerate passwords/secrets
    --auto-push               Auto commit and push to git
    --verbose                 Enable verbose output
    --dry-run                 Show what would be done
    --help                    Show this help

EXAMPLES:
    # Simple deployment with IP
    ./deploy-startkitv1-clean.sh deploy-simple 116.118.85.41

    # Full deployment with domain and SSL
    ./deploy-startkitv1-clean.sh deploy-full innerbright.vn

    # Guided deployment
    ./deploy-startkitv1-clean.sh deploy-guide

    # Full deployment with options
    ./deploy-startkitv1-clean.sh deploy-full innerbright.vn --force-regen --auto-push --verbose

SERVICES DEPLOYED:
    ✅ API (NestJS)           http://SERVER:3001
    ✅ Site (Next.js)         http://SERVER:3000
    ✅ PostgreSQL             Internal:5432
    ✅ Redis                  Internal:6379
    ✅ MinIO                  http://SERVER:9000
    ✅ pgAdmin                http://SERVER:5050

EOF
}

# ===== UTILITY FUNCTIONS =====
generate_secure_password() {
    local length=${1:-32}
    openssl rand -base64 $length | tr -d "=+/" | cut -c1-$length
}

validate_ip() {
    local ip=$1
    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        return 0
    else
        return 1
    fi
}

validate_domain() {
    local domain=$1
    if [[ $domain =~ ^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$ ]]; then
        return 0
    else
        return 1
    fi
}

# ===== ENVIRONMENT GENERATION =====
generate_environment() {
    local server_target=$1
    local deploy_type=$2
    
    log "🔐 Generating secure environment configuration..."
    
    # Check if .env exists and not forcing regeneration
    if [[ -f "$ENV_FILE" ]] && [[ "$FORCE_REGEN" != "true" ]]; then
        info "Environment file exists. Use --force-regen to regenerate passwords."
        return 0
    fi
    
    # Generate secure passwords
    local postgres_password=$(generate_secure_password 32)
    local redis_password=$(generate_secure_password 32)
    local jwt_secret=$(generate_secure_password 64)
    local encryption_key=$(generate_secure_password 32)
    local minio_password=$(generate_secure_password 32)
    local pgadmin_password=$(generate_secure_password 24)
    local session_secret=$(generate_secure_password 32)
    
    # Determine protocol and URLs
    local protocol="http"
    local host_url="$server_target"
    if [[ "$deploy_type" == "full" ]]; then
        protocol="https"
        host_url="$server_target"
    fi
    
    # Generate environment file
    cat > "$ENV_FILE" << EOF
# KataCore StartKit v1 - Production Environment
# Auto-generated on $(date -u +"%Y-%m-%dT%H:%M:%SZ")

# ===== DEPLOYMENT CONFIGURATION =====
NODE_ENV=production
DEPLOYMENT_MODE=production
DEPLOYMENT_VERSION=1.0.0
KATACORE_VERSION=StartKit v1

# ===== SERVER CONFIGURATION =====
SERVER_IP=$([[ "$deploy_type" == "simple" ]] && echo "$server_target" || echo "")
DOMAIN=$([[ "$deploy_type" == "full" ]] && echo "$server_target" || echo "")
PROTOCOL=$protocol
HOST_URL=$host_url

# ===== APPLICATION PORTS =====
API_PORT=3001
SITE_PORT=3000
HTTP_PORT=80
HTTPS_PORT=443

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
SESSION_SECRET=$session_secret
LOG_LEVEL=info

# ===== MINIO OBJECT STORAGE =====
MINIO_ROOT_USER=katacore_admin
MINIO_ROOT_PASSWORD=$minio_password
MINIO_ACCESS_KEY=katacore_admin
MINIO_SECRET_KEY=$minio_password
MINIO_ENDPOINT=minio
MINIO_PORT=9000
MINIO_CONSOLE_PORT=9001
MINIO_BROWSER_REDIRECT_URL=$protocol://$host_url/minio
MINIO_USE_SSL=false

# ===== PGADMIN CONFIGURATION =====
PGADMIN_DEFAULT_EMAIL=admin@$host_url
PGADMIN_DEFAULT_PASSWORD=$pgadmin_password
PGADMIN_PORT=5050

# ===== FRONTEND CONFIGURATION =====
NEXT_PUBLIC_API_URL=$protocol://$host_url/api
NEXT_PUBLIC_APP_URL=$protocol://$host_url
NEXT_PUBLIC_MINIO_ENDPOINT=$protocol://$host_url/minio
INTERNAL_API_URL=http://api:3001

# ===== DOCKER CONFIGURATION =====
API_VERSION=latest
SITE_VERSION=latest
COMPOSE_PROJECT_NAME=katacore
RESTART_POLICY=unless-stopped

# ===== MONITORING =====
ENABLE_MONITORING=true
HEALTH_CHECK_INTERVAL=30s
HEALTH_CHECK_TIMEOUT=10s
HEALTH_CHECK_RETRIES=3

# ===== SECURITY =====
CORS_ORIGIN=$protocol://$host_url
RATE_LIMIT_WINDOW=15
RATE_LIMIT_MAX_REQUESTS=100

# ===== NGINX CONFIGURATION =====
NGINX_CLIENT_MAX_BODY_SIZE=50M
NGINX_PROXY_TIMEOUT=60s
NGINX_WORKER_PROCESSES=auto
NGINX_WORKER_CONNECTIONS=1024

# ===== SSL CONFIGURATION =====
SSL_CERT_PATH=/etc/ssl/certs/katacore.crt
SSL_KEY_PATH=/etc/ssl/private/katacore.key
SSL_PROTOCOLS=TLSv1.2 TLSv1.3
ENABLE_HSTS=true
EOF
    
    success "Environment file generated with secure passwords"
    warning "🔐 IMPORTANT: Save these credentials securely!"
    echo -e "${YELLOW}PostgreSQL Password: $postgres_password${NC}"
    echo -e "${YELLOW}Redis Password: $redis_password${NC}"
    echo -e "${YELLOW}MinIO Password: $minio_password${NC}"
    echo -e "${YELLOW}pgAdmin Password: $pgadmin_password${NC}"
}

# ===== NGINX CONFIGURATION =====
generate_nginx_config() {
    local server_target=$1
    local deploy_type=$2
    
    log "🌐 Generating Nginx configuration..."
    
    if [[ "$deploy_type" == "simple" ]]; then
        info "Simple deployment mode - Nginx configuration skipped"
        return 0
    fi
    
    cat > "$NGINX_CONFIG" << EOF
# KataCore StartKit v1 - Nginx Configuration
# Auto-generated on $(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Rate limiting
limit_req_zone \$binary_remote_addr zone=api:10m rate=10r/s;
limit_req_zone \$binary_remote_addr zone=general:10m rate=5r/s;

# Upstream backends
upstream katacore_api {
    server 127.0.0.1:3001;
    keepalive 32;
}

upstream katacore_site {
    server 127.0.0.1:3000;
    keepalive 32;
}

upstream katacore_minio {
    server 127.0.0.1:9000;
    keepalive 8;
}

upstream katacore_minio_console {
    server 127.0.0.1:9001;
    keepalive 8;
}

upstream katacore_pgadmin {
    server 127.0.0.1:5050;
    keepalive 8;
}

# HTTP to HTTPS redirect
server {
    listen 80;
    listen [::]:80;
    server_name $server_target www.$server_target;
    
    # Let's Encrypt ACME challenge
    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
        try_files \$uri =404;
    }
    
    # Redirect all HTTP to HTTPS
    location / {
        return 301 https://\$server_name\$request_uri;
    }
}

# Main HTTPS server
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name $server_target www.$server_target;
    
    # SSL Configuration
    ssl_certificate /etc/letsencrypt/live/$server_target/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$server_target/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    
    # Security Headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    
    # Main site
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
        proxy_read_timeout 86400;
    }
    
    # API routes
    location /api/ {
        limit_req zone=api burst=20 nodelay;
        proxy_pass http://katacore_api/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
        proxy_read_timeout 86400;
    }
    
    # MinIO object storage
    location /minio/ {
        proxy_pass http://katacore_minio/;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_buffering off;
        client_max_body_size 50M;
    }
    
    # MinIO console
    location /minio-console/ {
        proxy_pass http://katacore_minio_console/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
    }
    
    # pgAdmin
    location /pgadmin/ {
        proxy_pass http://katacore_pgadmin/;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_redirect off;
    }
    
    # Health check
    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }
}
EOF
    
    success "Nginx configuration generated"
}

# ===== DEPLOYMENT FUNCTIONS =====
deploy_simple() {
    local server_ip=$1
    
    log "🚀 Starting simple deployment to $server_ip..."
    
    # Validate IP
    if ! validate_ip "$server_ip"; then
        error "Invalid IP address: $server_ip"
    fi
    
    # Generate environment
    generate_environment "$server_ip" "simple"
    
    # Deploy with Docker Compose
    log "📦 Deploying Docker containers..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        info "DRY RUN: Would run: docker-compose -f $COMPOSE_FILE up -d"
        return 0
    fi
    
    docker-compose -f "$COMPOSE_FILE" up -d
    
    # Wait for services to be ready
    log "⏳ Waiting for services to be ready..."
    sleep 30
    
    # Check service health
    check_services_health
    
    # Show deployment summary
    show_deployment_summary "$server_ip" "simple"
    
    # Auto push if enabled
    if [[ "$AUTO_PUSH" == "true" ]]; then
        auto_push_changes
    fi
    
    success "Simple deployment completed successfully!"
}

deploy_full() {
    local domain=$1
    
    log "🚀 Starting full deployment to $domain..."
    
    # Validate domain
    if ! validate_domain "$domain"; then
        error "Invalid domain: $domain"
    fi
    
    # Generate environment
    generate_environment "$domain" "full"
    
    # Generate Nginx configuration
    generate_nginx_config "$domain" "full"
    
    # Deploy with Docker Compose
    log "📦 Deploying Docker containers..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        info "DRY RUN: Would run: docker-compose -f $COMPOSE_FILE up -d"
        info "DRY RUN: Would setup Nginx and SSL"
        return 0
    fi
    
    docker-compose -f "$COMPOSE_FILE" up -d
    
    # Setup Nginx
    setup_nginx "$domain"
    
    # Setup SSL
    setup_ssl "$domain"
    
    # Wait for services to be ready
    log "⏳ Waiting for services to be ready..."
    sleep 30
    
    # Check service health
    check_services_health
    
    # Show deployment summary
    show_deployment_summary "$domain" "full"
    
    # Auto push if enabled
    if [[ "$AUTO_PUSH" == "true" ]]; then
        auto_push_changes
    fi
    
    success "Full deployment completed successfully!"
}

# ===== NGINX AND SSL SETUP =====
setup_nginx() {
    local domain=$1
    
    log "🌐 Setting up Nginx..."
    
    # Install Nginx if not installed
    if ! command -v nginx &> /dev/null; then
        log "Installing Nginx..."
        sudo apt update
        sudo apt install -y nginx
    fi
    
    # Copy configuration
    sudo cp "$NGINX_CONFIG" "/etc/nginx/sites-available/$domain"
    sudo ln -sf "/etc/nginx/sites-available/$domain" "/etc/nginx/sites-enabled/$domain"
    
    # Remove default site
    sudo rm -f /etc/nginx/sites-enabled/default
    
    # Test configuration
    sudo nginx -t
    
    # Restart Nginx
    sudo systemctl restart nginx
    sudo systemctl enable nginx
    
    success "Nginx configured and started"
}

setup_ssl() {
    local domain=$1
    
    log "🔒 Setting up SSL certificate..."
    
    # Install certbot if not installed
    if ! command -v certbot &> /dev/null; then
        log "Installing certbot..."
        sudo apt update
        sudo apt install -y certbot python3-certbot-nginx
    fi
    
    # Get SSL certificate
    sudo certbot --nginx -d "$domain" -d "www.$domain" --non-interactive --agree-tos --email "admin@$domain"
    
    # Setup auto-renewal
    sudo systemctl enable certbot.timer
    
    success "SSL certificate configured"
}

# ===== HEALTH CHECKS =====
check_services_health() {
    log "🏥 Checking services health..."
    
    local services=("api:3001" "site:3000" "minio:9000" "pgadmin:5050")
    
    for service in "${services[@]}"; do
        local name=${service%:*}
        local port=${service#*:}
        
        if curl -sf "http://localhost:$port" > /dev/null 2>&1; then
            success "$name is healthy"
        else
            warning "$name is not responding"
        fi
    done
}

# ===== DEPLOYMENT SUMMARY =====
show_deployment_summary() {
    local server_target=$1
    local deploy_type=$2
    
    echo ""
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                         🎉 DEPLOYMENT SUCCESSFUL!                           ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    local protocol="http"
    if [[ "$deploy_type" == "full" ]]; then
        protocol="https"
    fi
    
    echo -e "${CYAN}📊 Services:${NC}"
    echo -e "   🌐 Main Site:     $protocol://$server_target"
    echo -e "   🚀 API:          $protocol://$server_target/api"
    echo -e "   📦 MinIO:        $protocol://$server_target/minio"
    echo -e "   🗄️  pgAdmin:      $protocol://$server_target/pgadmin"
    echo ""
    
    echo -e "${CYAN}🔐 Credentials (check .env file):${NC}"
    echo -e "   📧 pgAdmin Email: admin@$server_target"
    echo -e "   🔑 Passwords: Generated securely in .env file"
    echo ""
    
    echo -e "${CYAN}📋 Next Steps:${NC}"
    echo -e "   1. Access your site at $protocol://$server_target"
    echo -e "   2. Check service health with: ./deploy-startkitv1-clean.sh test-deployment"
    echo -e "   3. View logs with: docker-compose -f docker-compose.startkitv1.yml logs"
    echo ""
}

# ===== GIT INTEGRATION =====
auto_push_changes() {
    log "📤 Auto-pushing changes to git..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        info "DRY RUN: Would push changes to git"
        return 0
    fi
    
    git add .
    git commit -m "feat: deploy KataCore StartKit v1 - $(date -u +"%Y-%m-%d %H:%M:%S UTC")"
    git push
    
    success "Changes pushed to git repository"
}

# ===== TESTING =====
test_deployment() {
    log "🧪 Testing deployment..."
    
    if [[ ! -f "$ENV_FILE" ]]; then
        error "Environment file not found. Run deployment first."
    fi
    
    # Source environment
    source "$ENV_FILE"
    
    # Test services
    check_services_health
    
    # Test database connection
    if docker-compose -f "$COMPOSE_FILE" exec -T postgres pg_isready -U "$POSTGRES_USER" -d "$POSTGRES_DB" > /dev/null 2>&1; then
        success "PostgreSQL connection: OK"
    else
        warning "PostgreSQL connection: FAILED"
    fi
    
    # Test Redis connection
    if docker-compose -f "$COMPOSE_FILE" exec -T redis redis-cli ping > /dev/null 2>&1; then
        success "Redis connection: OK"
    else
        warning "Redis connection: FAILED"
    fi
    
    success "Deployment test completed"
}

# ===== GUIDED DEPLOYMENT =====
deploy_guide() {
    echo -e "${BLUE}🎯 KataCore StartKit v1 - Guided Deployment${NC}"
    echo ""
    
    echo "Choose deployment type:"
    echo "1) Simple deployment (IP address only)"
    echo "2) Full deployment (Domain + SSL)"
    echo ""
    
    read -p "Enter your choice (1-2): " choice
    
    case $choice in
        1)
            echo ""
            read -p "Enter your server IP address: " server_ip
            if validate_ip "$server_ip"; then
                deploy_simple "$server_ip"
            else
                error "Invalid IP address"
            fi
            ;;
        2)
            echo ""
            read -p "Enter your domain name: " domain
            if validate_domain "$domain"; then
                warning "Make sure your domain points to this server!"
                read -p "Continue? (y/N): " confirm
                if [[ "$confirm" =~ ^[Yy]$ ]]; then
                    deploy_full "$domain"
                else
                    info "Deployment cancelled"
                fi
            else
                error "Invalid domain name"
            fi
            ;;
        *)
            error "Invalid choice"
            ;;
    esac
}

# ===== CLEANUP =====
cleanup_deployment() {
    log "🧹 Cleaning up deployment..."
    
    # Stop containers
    if [[ -f "$COMPOSE_FILE" ]]; then
        docker-compose -f "$COMPOSE_FILE" down -v
    fi
    
    # Remove environment file
    if [[ -f "$ENV_FILE" ]]; then
        rm -f "$ENV_FILE"
    fi
    
    # Remove Nginx config
    if [[ -f "$NGINX_CONFIG" ]]; then
        rm -f "$NGINX_CONFIG"
    fi
    
    success "Deployment cleaned up"
}

# ===== MAIN FUNCTION =====
main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            deploy-simple)
                if [[ -z "${2:-}" ]]; then
                    error "IP address required for simple deployment"
                fi
                SERVER_IP="$2"
                DEPLOY_TYPE="simple"
                shift 2
                ;;
            deploy-full)
                if [[ -z "${2:-}" ]]; then
                    error "Domain required for full deployment"
                fi
                DOMAIN="$2"
                DEPLOY_TYPE="full"
                shift 2
                ;;
            deploy-guide)
                deploy_guide
                exit 0
                ;;
            generate-env)
                shift
                # Parse additional options for generate-env
                while [[ $# -gt 0 ]]; do
                    case $1 in
                        --force-regen)
                            FORCE_REGEN=true
                            shift
                            ;;
                        *)
                            break
                            ;;
                    esac
                done
                
                echo "Choose target type:"
                echo "1) IP address"
                echo "2) Domain"
                read -p "Enter choice (1-2): " choice
                case $choice in
                    1)
                        read -p "Enter IP address: " ip
                        generate_environment "$ip" "simple"
                        ;;
                    2)
                        read -p "Enter domain: " domain
                        generate_environment "$domain" "full"
                        ;;
                    *)
                        error "Invalid choice"
                        ;;
                esac
                exit 0
                ;;
            test-deployment)
                test_deployment
                exit 0
                ;;
            cleanup)
                cleanup_deployment
                exit 0
                ;;
            --force-regen)
                FORCE_REGEN=true
                shift
                ;;
            --auto-push)
                AUTO_PUSH=true
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
                error "Unknown option: $1"
                ;;
        esac
    done
    
    # Show banner
    show_banner
    
    # Execute deployment
    case $DEPLOY_TYPE in
        simple)
            deploy_simple "$SERVER_IP"
            ;;
        full)
            deploy_full "$DOMAIN"
            ;;
        *)
            show_help
            ;;
    esac
}

# Run main function
main "$@"
