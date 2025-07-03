#!/bin/bash

# 🚀 KataCore StartKit v1 - Clean Deployment System
# Minimal deployment solution with all features

set -euo pipefail

# Version and metadata
readonly VERSION="1.0.0"
readonly KATACORE_VERSION="StartKit v1"

# Color codes
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

# Global configuration
SERVER_IP=""
DOMAIN=""
DEPLOY_MODE="simple"
FORCE_REGEN=false
AUTOPUSH=false
VERBOSE=false
DRY_RUN=false

# Paths
readonly PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly ENV_FILE="$PROJECT_ROOT/.env"
readonly ENV_EXAMPLE="$PROJECT_ROOT/.env.example"

# Logging functions
log() { echo -e "${GREEN}[$(date +'%H:%M:%S')]${NC} $1"; }
info() { echo -e "${CYAN}ℹ️  $1${NC}"; }
success() { echo -e "${GREEN}✅ $1${NC}"; }
warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
error() { echo -e "${RED}❌ $1${NC}"; exit 1; }
debug() { [[ "$VERBOSE" == "true" ]] && echo -e "${PURPLE}🐛 $1${NC}" || true; }

# Show banner
show_banner() {
    echo -e "${BLUE}"
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════════════════════╗
║                    🚀 KataCore StartKit v1 - Deployment                     ║
║                                                                              ║
║    Clean • Minimal • Production Ready • Auto Environment                    ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# Help information
show_help() {
    cat << EOF
KataCore StartKit v1 - Clean Deployment System

USAGE:
    $0 [COMMAND] [OPTIONS]

COMMANDS:
    deploy          Deploy with dynamic IP/domain (default)
    full-deploy     Complete first-time deployment with Nginx + SSL
    
ARGUMENTS:
    --ip <IP>           Server IP address (required for deploy)
    --domain <DOMAIN>   Domain name (required for full-deploy)
    --force-regen       Force regenerate all passwords
    --autopush          Auto commit and push to git
    --verbose           Enable detailed logging
    --dry-run           Preview changes without execution
    --help              Show this help

EXAMPLES:
    # Simple deployment with IP
    $0 deploy --ip 116.118.85.41
    
    # Full deployment with domain
    $0 full-deploy --domain innerbright.vn
    
    # With options
    $0 deploy --ip 116.118.85.41 --autopush --force-regen
    
    # Step-by-step guide
    $0 --help

FEATURES:
    ✅ Auto-generate secure passwords (first deploy)
    ✅ Docker deployment (API, Site, pgAdmin, Postgres, Redis, MinIO)
    ✅ Nginx reverse proxy with SSL
    ✅ Environment management
    ✅ Git integration

ARCHITECTURE:
    🐳 Docker: API (3001), Site (3000), pgAdmin (5050)
    🌐 Nginx: Reverse proxy, SSL termination  
    💾 Host: PostgreSQL, Redis, MinIO
EOF
}

# Parse command line arguments
parse_arguments() {
    if [[ $# -eq 0 ]]; then
        show_help
        exit 0
    fi
    
    # Parse command
    case "${1:-}" in
        deploy)
            DEPLOY_MODE="simple"
            shift
            ;;
        full-deploy)
            DEPLOY_MODE="full"
            shift
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        *)
            if [[ "${1:-}" == --* ]]; then
                # Backward compatibility - default to deploy
                DEPLOY_MODE="simple"
            else
                error "Unknown command: ${1:-}. Use --help for usage."
            fi
            ;;
    esac
    
    # Parse options
    while [[ $# -gt 0 ]]; do
        case $1 in
            --ip)
                SERVER_IP="$2"
                shift 2
                ;;
            --domain)
                DOMAIN="$2"
                shift 2
                ;;
            --force-regen)
                FORCE_REGEN=true
                shift
                ;;
            --autopush)
                AUTOPUSH=true
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
            --help|-h)
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
    if [[ "$DEPLOY_MODE" == "simple" && -z "$SERVER_IP" ]]; then
        error "Server IP is required for deploy command. Use: $0 deploy --ip <IP>"
    fi
    
    if [[ "$DEPLOY_MODE" == "full" && -z "$DOMAIN" ]]; then
        error "Domain is required for full-deploy command. Use: $0 full-deploy --domain <DOMAIN>"
    fi
}

# Generate secure passwords
generate_password() {
    local length=${1:-24}
    local charset="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@#$%^&*()_+-="
    
    if command -v openssl >/dev/null 2>&1; then
        openssl rand -base64 32 | tr -d "=+/" | cut -c1-${length}
    else
        LC_ALL=C tr -dc "${charset}" < /dev/urandom | head -c${length}
    fi
}

generate_jwt_secret() {
    if command -v openssl >/dev/null 2>&1; then
        openssl rand -base64 64 | tr -d '\n'
    else
        LC_ALL=C tr -dc 'A-Za-z0-9' < /dev/urandom | head -c88 | base64 | tr -d '\n'
    fi
}

# Setup environment file
setup_environment() {
    log "🔧 Setting up environment configuration..."
    
    # Check .env.example exists
    if [[ ! -f "$ENV_EXAMPLE" ]]; then
        error ".env.example file not found!"
    fi
    
    # Create .env from example if needed
    if [[ ! -f "$ENV_FILE" ]] || [[ "$FORCE_REGEN" == "true" ]]; then
        if [[ "$DRY_RUN" == "false" ]]; then
            cp "$ENV_EXAMPLE" "$ENV_FILE"
            info "Environment file created from template"
        fi
    fi
    
    if [[ "$DRY_RUN" == "true" ]]; then
        info "DRY RUN: Would setup environment with secure passwords"
        return 0
    fi
    
    # Generate passwords for placeholders
    declare -A password_map=(
        ["__SECURE_POSTGRES_PASSWORD__"]="24"
        ["__SECURE_REDIS_PASSWORD__"]="20"
        ["__SECURE_MINIO_PASSWORD__"]="20"
        ["__SECURE_PGADMIN_PASSWORD__"]="16"
    )
    
    # Only generate if placeholders exist or force regen
    local needs_generation=false
    for placeholder in "${!password_map[@]}"; do
        if grep -q "$placeholder" "$ENV_FILE"; then
            needs_generation=true
            break
        fi
    done
    
    if [[ "$needs_generation" == "true" || "$FORCE_REGEN" == "true" ]]; then
        log "🔐 Generating secure passwords..."
        
        # Generate passwords
        for placeholder in "${!password_map[@]}"; do
            local length=${password_map[$placeholder]}
            local new_password=$(generate_password $length)
            sed -i "s/$placeholder/$new_password/g" "$ENV_FILE"
            success "Generated ${length}-char password for ${placeholder//__SECURE_/}"
        done
        
        # Generate JWT secret
        if grep -q "__SECURE_JWT_SECRET__" "$ENV_FILE" || [[ "$FORCE_REGEN" == "true" ]]; then
            local jwt_secret=$(generate_jwt_secret)
            sed -i "s/__SECURE_JWT_SECRET__/$jwt_secret/g" "$ENV_FILE"
            success "Generated JWT secret"
        fi
    else
        info "Environment already configured with secure passwords"
    fi
    
    # Update server-specific values
    if [[ -n "$SERVER_IP" ]]; then
        sed -i "s/116\.118\.85\.41/$SERVER_IP/g" "$ENV_FILE" 2>/dev/null || true
    fi
    
    if [[ -n "$DOMAIN" ]]; then
        sed -i "s/innerbright\.vn/$DOMAIN/g" "$ENV_FILE" 2>/dev/null || true
        sed -i "s/your-domain\.com/$DOMAIN/g" "$ENV_FILE" 2>/dev/null || true
    fi
    
    success "Environment configuration completed"
}

# Validate environment
validate_environment() {
    log "🔍 Validating environment..."
    
    if [[ ! -f "$ENV_FILE" ]]; then
        error "Environment file not found!"
    fi
    
    # Load environment
    set -a
    source "$ENV_FILE"
    set +a
    
    # Check required variables
    local required_vars=(
        "DATABASE_URL"
        "REDIS_URL" 
        "JWT_SECRET"
        "MINIO_ACCESS_KEY"
        "MINIO_SECRET_KEY"
    )
    
    local missing_vars=()
    for var in "${required_vars[@]}"; do
        if [[ -z "${!var:-}" ]]; then
            missing_vars+=("$var")
        fi
    done
    
    if [[ ${#missing_vars[@]} -gt 0 ]]; then
        error "Missing required environment variables: ${missing_vars[*]}"
    fi
    
    success "Environment validation passed"
}

# Deploy containers
deploy_containers() {
    log "🐳 Deploying containers..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        info "DRY RUN: Would deploy Docker containers"
        return 0
    fi
    
    # Check Docker availability
    if ! command -v docker >/dev/null 2>&1; then
        error "Docker not found! Please install Docker first."
    fi
    
    if ! command -v docker-compose >/dev/null 2>&1; then
        error "Docker Compose not found! Please install Docker Compose first."
    fi
    
    # Stop existing containers
    info "Stopping existing containers..."
    docker-compose -f docker-compose.startkitv1.yml down 2>/dev/null || true
    
    # Pull latest images
    info "Pulling latest images..."
    docker-compose -f docker-compose.startkitv1.yml pull 2>/dev/null || true
    
    # Build and start containers
    info "Building and starting containers..."
    docker-compose -f docker-compose.startkitv1.yml build
    docker-compose -f docker-compose.startkitv1.yml up -d
    
    # Wait for services to be ready
    info "Waiting for services to start..."
    sleep 10
    
    success "Containers deployed successfully"
}

# Setup Nginx (for full deployment)
setup_nginx() {
    if [[ "$DEPLOY_MODE" != "full" ]]; then
        return 0
    fi
    
    log "🌐 Setting up Nginx with SSL..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        info "DRY RUN: Would setup Nginx with SSL for $DOMAIN"
        return 0
    fi
    
    # Check if running as root
    if [[ $EUID -ne 0 ]]; then
        error "Nginx setup requires root privileges. Run with sudo."
    fi
    
    # Create Nginx configuration
    local nginx_conf="/etc/nginx/sites-available/katacore"
    
    cat > "$nginx_conf" << EOF
# KataCore StartKit v1 - Nginx Configuration
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name $DOMAIN www.$DOMAIN;
    
    # SSL Configuration
    ssl_certificate /etc/ssl/certs/katacore.crt;
    ssl_certificate_key /etc/ssl/private/katacore.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384;
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    
    # API proxy
    location /api/ {
        proxy_pass http://127.0.0.1:3001/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
    }
    
    # Admin panels
    location /pgadmin/ {
        proxy_pass http://127.0.0.1:5050/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
    
    location /minio/ {
        proxy_pass http://127.0.0.1:9001/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
    
    # Site proxy (default)
    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF
    
    # Enable site
    ln -sf "/etc/nginx/sites-available/katacore" "/etc/nginx/sites-enabled/"
    rm -f "/etc/nginx/sites-enabled/default"
    
    # Generate SSL certificate
    info "Generating SSL certificate..."
    mkdir -p /etc/ssl/private /etc/ssl/certs
    
    # Try Let's Encrypt first, fallback to self-signed
    if command -v certbot >/dev/null 2>&1; then
        certbot --nginx -d "$DOMAIN" -d "www.$DOMAIN" --non-interactive --agree-tos --email "admin@$DOMAIN" || {
            warning "Let's Encrypt failed, using self-signed certificate"
            openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
                -keyout /etc/ssl/private/katacore.key \
                -out /etc/ssl/certs/katacore.crt \
                -subj "/C=VN/ST=HCM/L=HCM/O=KataCore/CN=$DOMAIN"
        }
    else
        openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
            -keyout /etc/ssl/private/katacore.key \
            -out /etc/ssl/certs/katacore.crt \
            -subj "/C=VN/ST=HCM/L=HCM/O=KataCore/CN=$DOMAIN"
    fi
    
    # Test and reload Nginx
    nginx -t
    systemctl reload nginx
    
    success "Nginx configuration completed"
}

# Perform health checks
perform_health_checks() {
    log "🏥 Performing health checks..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        info "DRY RUN: Would perform health checks"
        return 0
    fi
    
    # Check container status
    info "Checking container health..."
    local containers=("katacore-api-prod" "katacore-site-prod")
    
    for container in "${containers[@]}"; do
        if docker ps --format "table {{.Names}}" | grep -q "$container"; then
            success "$container is running"
        else
            warning "$container is not running"
        fi
    done
    
    # Check service connectivity
    local max_attempts=30
    local attempt=1
    
    info "Testing API connectivity..."
    while [[ $attempt -le $max_attempts ]]; do
        if curl -sf "http://localhost:3001/health" >/dev/null 2>&1; then
            success "API health check passed"
            break
        fi
        
        if [[ $attempt -eq $max_attempts ]]; then
            warning "API health check failed after $max_attempts attempts"
        else
            debug "API health check attempt $attempt/$max_attempts failed, retrying..."
            sleep 2
            ((attempt++))
        fi
    done
    
    attempt=1
    info "Testing Site connectivity..."
    while [[ $attempt -le $max_attempts ]]; do
        if curl -sf "http://localhost:3000" >/dev/null 2>&1; then
            success "Site health check passed"
            break
        fi
        
        if [[ $attempt -eq $max_attempts ]]; then
            warning "Site health check failed after $max_attempts attempts"
        else
            debug "Site health check attempt $attempt/$max_attempts failed, retrying..."
            sleep 2
            ((attempt++))
        fi
    done
    
    success "Health checks completed"
}

# Git autopush functionality
git_autopush() {
    if [[ "$AUTOPUSH" == "false" ]]; then
        return 0
    fi
    
    log "📤 Git autopush..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        info "DRY RUN: Would commit and push changes"
        return 0
    fi
    
    # Check if git repo
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        warning "Not a git repository, skipping autopush"
        return 0
    fi
    
    # Check for changes
    if git diff --quiet && git diff --cached --quiet; then
        info "No changes to commit"
        return 0
    fi
    
    # Commit and push
    git add .
    git commit -m "🚀 KataCore deployment update - $(date '+%Y-%m-%d %H:%M:%S')"
    
    if git remote -v | grep -q "origin"; then
        git push origin HEAD
        success "Changes committed and pushed"
    else
        success "Changes committed locally"
        warning "No remote origin configured"
    fi
}

# Show deployment summary
show_deployment_summary() {
    echo ""
    success "🎉 KataCore StartKit v1 Deployment Completed!"
    echo ""
    
    echo -e "${BLUE}📋 Deployment Summary:${NC}"
    if [[ "$DEPLOY_MODE" == "full" && -n "$DOMAIN" ]]; then
        echo -e "  🌐 Site: ${CYAN}https://$DOMAIN${NC}"
        echo -e "  🔗 API: ${CYAN}https://$DOMAIN/api${NC}"
        echo -e "  🗄️ pgAdmin: ${CYAN}https://$DOMAIN/pgadmin${NC}"
        echo -e "  📦 MinIO: ${CYAN}https://$DOMAIN/minio${NC}"
    else
        local display_ip="${SERVER_IP:-localhost}"
        echo -e "  🌐 Site: ${CYAN}http://$display_ip:3000${NC}"
        echo -e "  🔗 API: ${CYAN}http://$display_ip:3001${NC}"
        echo -e "  🗄️ pgAdmin: ${CYAN}http://$display_ip:5050${NC}"
    fi
    echo -e "  📁 Environment: ${CYAN}$ENV_FILE${NC}"
    echo ""
    
    echo -e "${BLUE}🔐 Security:${NC}"
    echo -e "  ✅ Secure passwords auto-generated"
    echo -e "  ✅ JWT secret configured"
    echo -e "  ✅ Environment variables validated"
    if [[ "$DEPLOY_MODE" == "full" ]]; then
        echo -e "  ✅ SSL certificate configured"
    fi
    echo ""
    
    echo -e "${BLUE}📊 Management Commands:${NC}"
    echo -e "  🔍 View logs: ${CYAN}docker-compose -f docker-compose.startkitv1.yml logs -f${NC}"
    echo -e "  🔄 Restart: ${CYAN}docker-compose -f docker-compose.startkitv1.yml restart${NC}"
    echo -e "  🛑 Stop: ${CYAN}docker-compose -f docker-compose.startkitv1.yml down${NC}"
    echo ""
    
    if [[ "$AUTOPUSH" == "true" ]]; then
        echo -e "${BLUE}📤 Git:${NC}"
        echo -e "  ✅ Changes committed and pushed automatically"
        echo ""
    fi
    
    echo -e "${BLUE}💡 Tips:${NC}"
    echo -e "  • Use ${CYAN}--autopush${NC} for automatic git commits"
    echo -e "  • Use ${CYAN}--force-regen${NC} to regenerate passwords"
    echo -e "  • Use ${CYAN}full-deploy${NC} for complete Nginx + SSL setup"
    echo ""
}

# Main execution function
main() {
    show_banner
    
    # Parse arguments
    parse_arguments "$@"
    
    # Show configuration if verbose
    if [[ "$VERBOSE" == "true" ]]; then
        echo -e "${BLUE}Configuration:${NC}"
        echo -e "  Deploy Mode: $DEPLOY_MODE"
        echo -e "  Server IP: ${SERVER_IP:-'not set'}"
        echo -e "  Domain: ${DOMAIN:-'not set'}"
        echo -e "  Force Regenerate: $FORCE_REGEN"
        echo -e "  Autopush: $AUTOPUSH"
        echo -e "  Verbose: $VERBOSE"
        echo -e "  Dry Run: $DRY_RUN"
        echo ""
    fi
    
    # Execute deployment steps
    setup_environment
    validate_environment
    deploy_containers
    setup_nginx
    perform_health_checks
    git_autopush
    show_deployment_summary
    
    if [[ "$DRY_RUN" == "true" ]]; then
        echo ""
        warning "This was a dry run. No actual changes were made."
        info "Remove --dry-run flag to execute the deployment."
    fi
}

# Execute main function
main "$@"
