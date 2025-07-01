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
    --verbose          Enable verbose logging
    --dry-run          Show what would be done without executing
    --create-env-template  Create environment template only
    --help             Show this help message

EXAMPLES:
    # Basic deployment
    $0 --host 192.168.1.100

    # Deployment with custom domain and SSL
    $0 --host myserver.com --domain myapp.com

    # Clean deployment (removes existing data)
    $0 --host 192.168.1.100 --clean

    # Setup server only (no deployment)
    $0 --host 192.168.1.100 --setup-only

    # Update configuration only (fastest)
    $0 --host 192.168.1.100 --config-only

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

# Test SSH connection
test_ssh_connection() {
    log "🔗 Testing SSH connection to $SERVER_HOST..."
    
    if ! ssh -o ConnectTimeout=10 -o BatchMode=yes -p "$SERVER_PORT" "$SERVER_USER@$SERVER_HOST" exit 2>/dev/null; then
        error "Cannot connect to $SERVER_HOST:$SERVER_PORT with user $SERVER_USER"
    fi
    
    success "SSH connection successful"
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
        if grep -q "__SECURE_.*__\|your-domain.com\|innerbright.vn" "$env_file"; then
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
    
    # Generate environment file from template
    if [[ -f ".env.prod.template" ]]; then
        cp .env.prod.template "$env_file"
    else
        # Create basic environment file
        cat > "$env_file" << EOF
# KataCore StartKit v1 - Production Environment
# Auto-generated secure configuration

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
LOG_LEVEL=info
NODE_ENV=production

# MinIO
MINIO_ROOT_USER=katacore_admin
MINIO_ROOT_PASSWORD=$minio_pass
MINIO_BROWSER_REDIRECT_URL=http://${SERVER_HOST:-localhost}:9001

# pgAdmin
PGADMIN_EMAIL=admin@${DOMAIN:-${SERVER_HOST:-localhost}}
PGADMIN_PASSWORD=$pgadmin_pass

# API Configuration
API_VERSION=latest
CORS_ORIGIN=http://${SERVER_HOST:-localhost}

# Frontend
SITE_VERSION=latest
NEXT_PUBLIC_API_URL=http://${SERVER_HOST:-localhost}/api

# Domain
DOMAIN=${DOMAIN:-${SERVER_HOST:-localhost}}
LETSENCRYPT_EMAIL=admin@${DOMAIN:-${SERVER_HOST:-localhost}}
ENABLE_SSL=false
EOF
    fi
    
    # Replace template placeholders with actual values
    sed -i "s/__SECURE_POSTGRES_PASSWORD__/$postgres_pass/g" "$env_file"
    sed -i "s/__SECURE_REDIS_PASSWORD__/$redis_pass/g" "$env_file"
    sed -i "s/__SECURE_JWT_SECRET__/$jwt_secret/g" "$env_file"
    sed -i "s/__SECURE_MINIO_PASSWORD__/$minio_pass/g" "$env_file"
    sed -i "s/__SECURE_PGLADMIN_PASSWORD__/$pgadmin_pass/g" "$env_file"
    sed -i "s/__SECURE_GRAFLADMIN_PASSWORD__/$grafana_pass/g" "$env_file"
    
    # Replace domain placeholders
    sed -i "s/your-domain.com/${DOMAIN:-${SERVER_HOST:-localhost}}/g" "$env_file"
    sed -i "s/innerbright.vn/${DOMAIN:-${SERVER_HOST:-localhost}}/g" "$env_file"
    
    # Replace specific template values with generated ones
    sed -i "s/puwIRuLehf8jDeb98oFUUjzz/$postgres_pass/g" "$env_file"
    sed -i "s/YbyKUZUKS0Md8JJf0ABR/$redis_pass/g" "$env_file"
    sed -i "s/5Bjbnwyj5h23PSrd/$jwt_secret/g" "$env_file"
    
    # Update URLs to use correct server host
    if [[ -n "$SERVER_HOST" ]]; then
        sed -i "s|http://localhost|http://$SERVER_HOST|g" "$env_file"
        sed -i "s|https://localhost|http://$SERVER_HOST|g" "$env_file"
        sed -i "s/localhost:9001/$SERVER_HOST:9001/g" "$env_file"
    fi
    
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
    test_ssh_connection
    setup_server
    generate_environment
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
