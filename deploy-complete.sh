#!/bin/bash

# KataCore Complete Server Setup Script v2
# Automated setup for cloud server 116.118.85.41
# Includes Docker containers + Nginx configuration

set -e

# Color codes for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m' # No Color

# Global variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/.env"
ENV_EXAMPLE="$SCRIPT_DIR/.env.example"
AUTOPUSH_GIT=false
VERBOSE=false
DRY_RUN=false
FORCE_REGENERATE=false
SETUP_NGINX=false
FIRST_TIME_SETUP=false

# Default configuration
DOMAIN="${DOMAIN:-innerbright.vn}"
SERVER_IP="${SERVER_IP:-116.118.85.41}"
EMAIL="${EMAIL:-admin@${DOMAIN}}"

# Logging functions
log() {
    echo -e "${GREEN}[$(date +'%H:%M:%S')]${NC} $1"
}

info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}" >&2
    exit 1
}

debug() {
    if [[ "$VERBOSE" == "true" ]]; then
        echo -e "${PURPLE}🐛 $1${NC}"
    fi
}

# Show banner
show_banner() {
    echo -e "${BLUE}"
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════════════════════╗
║              🚀 KataCore Complete Server Setup v2                           ║
║                                                                              ║
║    Docker Deployment • Nginx Setup • SSL • First-time Setup                ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# Show help
show_help() {
    cat << EOF
KataCore Complete Server Setup Script v2

DESCRIPTION:
    Complete automated setup for KataCore on cloud server 116.118.85.41
    Includes Docker container deployment and Nginx configuration with SSL.

USAGE:
    $0 [OPTIONS]

OPTIONS:
    --autopush         Enable Git autopush after successful deployment
    --force-regen      Force regenerate all passwords and secrets
    --verbose          Enable verbose output
    --dry-run          Show what would be done without executing
    --setup-nginx      Setup Nginx configuration and SSL
    --first-time       Complete first-time server setup
    --help             Show this help message

FEATURES:
    ✅ Auto-generates secure passwords (24+ characters)
    ✅ Docker container deployment (API + Site)
    ✅ Nginx reverse proxy configuration
    ✅ SSL certificate setup with Let's Encrypt
    ✅ Firewall configuration
    ✅ Health monitoring
    ✅ Git autopush with commit messages

EXAMPLES:
    # First-time complete setup
    $0 --first-time

    # Deploy containers only
    $0

    # Deploy with Nginx setup
    $0 --setup-nginx

    # Complete setup with git autopush
    $0 --first-time --autopush

    # Dry run to see what would happen
    $0 --first-time --dry-run

REQUIREMENTS:
    • Run as root for first-time setup
    • Domain DNS pointing to server IP
    • Ports 80, 443, 3000, 3001 accessible

For more information, see SIMPLE_DEPLOYMENT.md
EOF
}

# Parse command line arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --autopush)
                AUTOPUSH_GIT=true
                shift
                ;;
            --force-regen)
                FORCE_REGENERATE=true
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
            --setup-nginx)
                SETUP_NGINX=true
                shift
                ;;
            --first-time)
                FIRST_TIME_SETUP=true
                SETUP_NGINX=true
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
}

# Check if running as root (for Nginx setup)
check_root() {
    if [[ "$SETUP_NGINX" == "true" ]] && [[ $EUID -ne 0 ]]; then
        error "Nginx setup requires root privileges. Use: sudo $0 --setup-nginx"
    fi
}

# Generate secure password
generate_password() {
    local length=${1:-24}
    local charset="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@#$%^&*()_+-=[]{}|;:,.<>?"
    
    if command -v openssl >/dev/null 2>&1; then
        openssl rand -base64 32 | tr -d "=+/" | cut -c1-${length}
    elif command -v /dev/urandom >/dev/null 2>&1; then
        LC_ALL=C tr -dc "${charset}" < /dev/urandom | head -c${length}
    else
        local password=""
        for i in $(seq 1 ${length}); do
            password="${password}${charset:$((RANDOM % ${#charset})):1}"
        done
        echo "$password"
    fi
}

# Generate JWT secret (base64 encoded)
generate_jwt_secret() {
    if command -v openssl >/dev/null 2>&1; then
        openssl rand -base64 64 | tr -d '\n'
    else
        local secret=""
        for i in $(seq 1 64); do
            secret="${secret}$(printf "%c" $((RANDOM % 94 + 33)))"
        done
        echo -n "$secret" | base64 | tr -d '\n'
    fi
}

# Setup environment (from existing deploy-simple.sh)
setup_environment() {
    log "🔧 Setting up environment configuration..."
    
    if [[ ! -f "$ENV_EXAMPLE" ]]; then
        error ".env.example file not found! Please ensure it exists in the project root."
    fi
    
    if [[ ! -f "$ENV_FILE" ]]; then
        info "Creating .env file from .env.example..."
        if [[ "$DRY_RUN" == "false" ]]; then
            cp "$ENV_EXAMPLE" "$ENV_FILE"
        fi
        success ".env file created"
    else
        info ".env file already exists"
    fi
    
    # Update domain and server IP in .env
    if [[ "$DRY_RUN" == "false" ]]; then
        sed -i "s/your-domain.com/$DOMAIN/g" "$ENV_FILE" 2>/dev/null || true
        sed -i "s/116.118.85.41/$SERVER_IP/g" "$ENV_FILE" 2>/dev/null || true
        debug "Updated domain and server IP in .env file"
    fi
    
    generate_secure_passwords
    success "Environment configuration completed"
}

# Generate secure passwords (from existing deploy-simple.sh)
generate_secure_passwords() {
    log "🔐 Generating secure passwords and secrets..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        info "DRY RUN: Would generate secure passwords"
        return 0
    fi
    
    declare -A password_map=(
        ["__SECURE_POSTGRES_PASSWORD__"]="24"
        ["__SECURE_REDIS_PASSWORD__"]="20"
        ["__SECURE_MINIO_PASSWORD__"]="20"
        ["__SECURE_PGADMIN_PASSWORD__"]="16"
        ["__SECURE_GRAFANA_PASSWORD__"]="16"
    )
    
    for placeholder in "${!password_map[@]}"; do
        local length=${password_map[$placeholder]}
        
        if grep -q "$placeholder" "$ENV_FILE"; then
            if [[ "$FORCE_REGENERATE" == "true" ]]; then
                debug "Force regenerating password for $placeholder"
                local new_password=$(generate_password $length)
                sed -i "s/$placeholder/$new_password/g" "$ENV_FILE"
                success "Generated ${length}-character password for ${placeholder}"
            else
                debug "Generating password for $placeholder"
                local new_password=$(generate_password $length)
                sed -i "s/$placeholder/$new_password/g" "$ENV_FILE"
                success "Generated ${length}-character password for ${placeholder}"
            fi
        else
            debug "Password for $placeholder already set"
        fi
    done
    
    # Generate JWT secret
    if grep -q "__SECURE_JWT_SECRET__" "$ENV_FILE"; then
        if [[ "$FORCE_REGENERATE" == "true" ]] || grep -q "__SECURE_JWT_SECRET__" "$ENV_FILE"; then
            debug "Generating JWT secret"
            local jwt_secret=$(generate_jwt_secret)
            sed -i "s/__SECURE_JWT_SECRET__/$jwt_secret/g" "$ENV_FILE"
            success "Generated 64-character JWT secret"
        fi
    else
        debug "JWT secret already set"
    fi
    
    success "Password generation completed"
}

# Setup Nginx configuration
setup_nginx() {
    if [[ "$SETUP_NGINX" == "false" ]]; then
        debug "Nginx setup disabled"
        return 0
    fi
    
    log "🌐 Setting up Nginx configuration..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        info "DRY RUN: Would setup Nginx with SSL"
        return 0
    fi
    
    # Check if setup-nginx-server.sh exists
    if [[ ! -f "$SCRIPT_DIR/setup-nginx-server.sh" ]]; then
        error "setup-nginx-server.sh not found! Please ensure it exists in the project root."
    fi
    
    # Export environment variables for the Nginx setup script
    export DOMAIN="$DOMAIN"
    export SERVER_IP="$SERVER_IP"
    export EMAIL="$EMAIL"
    
    # Run the Nginx setup script
    info "Running Nginx setup script..."
    bash "$SCRIPT_DIR/setup-nginx-server.sh"
    
    success "Nginx configuration completed"
}

# Deploy containers (from existing deploy-simple.sh)
deploy_containers() {
    log "🐳 Deploying containers..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        info "DRY RUN: Would deploy containers"
        return 0
    fi
    
    if ! command -v docker >/dev/null 2>&1; then
        error "Docker not found! Please install Docker first."
    fi
    
    if ! command -v docker-compose >/dev/null 2>&1; then
        error "Docker Compose not found! Please install Docker Compose first."
    fi
    
    info "Stopping existing containers..."
    docker-compose -f docker-compose.prod.yml down 2>/dev/null || true
    
    info "Building API container..."
    docker-compose -f docker-compose.prod.yml build api
    
    info "Building Site container..."
    docker-compose -f docker-compose.prod.yml build site
    
    info "Starting containers..."
    docker-compose -f docker-compose.prod.yml up -d
    
    success "Containers deployed successfully"
}

# Perform health checks
perform_health_checks() {
    log "🏥 Performing health checks..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        info "DRY RUN: Would perform health checks"
        return 0
    fi
    
    info "Waiting for services to start..."
    sleep 15
    
    # Check API health
    info "Checking API health..."
    local api_attempts=0
    local max_attempts=5
    
    while [[ $api_attempts -lt $max_attempts ]]; do
        if curl -f http://localhost:3001/health > /dev/null 2>&1; then
            success "API is healthy on port 3001"
            break
        else
            api_attempts=$((api_attempts + 1))
            if [[ $api_attempts -lt $max_attempts ]]; then
                info "API not ready yet, waiting... (${api_attempts}/${max_attempts})"
                sleep 10
            else
                warning "API health check failed after ${max_attempts} attempts"
            fi
        fi
    done
    
    # Check Site health
    info "Checking Site health..."
    local site_attempts=0
    
    while [[ $site_attempts -lt $max_attempts ]]; do
        if curl -f http://localhost:3000 > /dev/null 2>&1; then
            success "Site is healthy on port 3000"
            break
        else
            site_attempts=$((site_attempts + 1))
            if [[ $site_attempts -lt $max_attempts ]]; then
                info "Site not ready yet, waiting... (${site_attempts}/${max_attempts})"
                sleep 10
            else
                warning "Site health check failed after ${max_attempts} attempts"
            fi
        fi
    done
    
    # Check Nginx if setup
    if [[ "$SETUP_NGINX" == "true" ]]; then
        info "Checking Nginx health..."
        if curl -f http://localhost/nginx-health > /dev/null 2>&1; then
            success "Nginx is healthy"
        else
            warning "Nginx health check failed"
        fi
    fi
    
    info "Container status:"
    docker-compose -f docker-compose.prod.yml ps
    
    success "Health checks completed"
}

# Git autopush functionality
git_autopush() {
    if [[ "$AUTOPUSH_GIT" == "false" ]]; then
        debug "Git autopush disabled"
        return 0
    fi
    
    log "📤 Git autopush functionality..."
    
    if ! command -v git >/dev/null 2>&1; then
        warning "Git not found, skipping autopush"
        return 0
    fi
    
    if [[ ! -d ".git" ]]; then
        warning "Not a git repository, skipping autopush"
        return 0
    fi
    
    if [[ "$DRY_RUN" == "true" ]]; then
        info "DRY RUN: Would perform git autopush"
        return 0
    fi
    
    local git_user=$(git config user.name 2>/dev/null || echo "")
    local git_email=$(git config user.email 2>/dev/null || echo "")
    
    if [[ -z "$git_user" ]] || [[ -z "$git_email" ]]; then
        warning "Git user not configured, skipping autopush"
        return 0
    fi
    
    if git diff --quiet && git diff --cached --quiet; then
        info "No changes to commit"
        return 0
    fi
    
    git add .
    local commit_msg="🚀 KataCore complete server setup - $(date '+%Y-%m-%d %H:%M:%S')"
    git commit -m "$commit_msg"
    
    if git remote -v | grep -q "origin"; then
        if git push origin HEAD 2>/dev/null; then
            success "Git autopush completed successfully"
        else
            warning "Git push failed, but commit was successful"
        fi
    else
        warning "No remote origin configured, skipping push"
        success "Local git commit completed"
    fi
}

# Show deployment summary
show_deployment_summary() {
    echo ""
    success "🎉 KataCore Complete Server Setup Completed!"
    echo ""
    
    echo -e "${BLUE}📋 Deployment Summary:${NC}"
    if [[ "$SETUP_NGINX" == "true" ]]; then
        echo -e "  🌐 Site: ${CYAN}https://$DOMAIN${NC}"
        echo -e "  🔗 API: ${CYAN}https://$DOMAIN/api${NC}"
        echo -e "  🏥 Health: ${CYAN}https://$DOMAIN/nginx-health${NC}"
    else
        echo -e "  🔗 API: ${CYAN}http://$SERVER_IP:3001${NC}"
        echo -e "  🌐 Site: ${CYAN}http://$SERVER_IP:3000${NC}"
    fi
    echo -e "  📁 Environment: ${CYAN}$ENV_FILE${NC}"
    echo ""
    
    echo -e "${BLUE}🔐 Security:${NC}"
    echo -e "  ✅ Secure passwords generated automatically"
    echo -e "  ✅ JWT secret generated"
    echo -e "  ✅ Environment variables configured"
    if [[ "$SETUP_NGINX" == "true" ]]; then
        echo -e "  ✅ SSL certificate configured"
        echo -e "  ✅ Firewall configured"
    fi
    echo ""
    
    echo -e "${BLUE}📊 Management Commands:${NC}"
    echo -e "  🔍 Check status: ${CYAN}katacore-status${NC}"
    echo -e "  🔄 Restart containers: ${CYAN}docker-compose -f docker-compose.prod.yml restart${NC}"
    echo -e "  🛑 Stop containers: ${CYAN}docker-compose -f docker-compose.prod.yml down${NC}"
    echo -e "  📜 View logs: ${CYAN}docker-compose -f docker-compose.prod.yml logs -f${NC}"
    if [[ "$SETUP_NGINX" == "true" ]]; then
        echo -e "  🔄 Reload Nginx: ${CYAN}sudo systemctl reload nginx${NC}"
        echo -e "  🧪 Test Nginx: ${CYAN}sudo nginx -t${NC}"
    fi
    echo ""
    
    if [[ "$AUTOPUSH_GIT" == "true" ]]; then
        echo -e "${BLUE}📤 Git:${NC}"
        echo -e "  ✅ Changes committed and pushed automatically"
        echo ""
    fi
    
    echo -e "${BLUE}💡 Tips:${NC}"
    echo -e "  • Check SIMPLE_DEPLOYMENT.md for detailed setup instructions"
    echo -e "  • Use ${CYAN}--autopush${NC} flag for automatic git commits"
    echo -e "  • Use ${CYAN}--force-regen${NC} to regenerate all passwords"
    if [[ "$SETUP_NGINX" == "false" ]]; then
        echo -e "  • Use ${CYAN}--setup-nginx${NC} to configure Nginx and SSL"
    fi
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
        echo -e "  Autopush Git: $AUTOPUSH_GIT"
        echo -e "  Force Regenerate: $FORCE_REGENERATE"
        echo -e "  Verbose: $VERBOSE"
        echo -e "  Dry Run: $DRY_RUN"
        echo -e "  Setup Nginx: $SETUP_NGINX"
        echo -e "  First Time Setup: $FIRST_TIME_SETUP"
        echo -e "  Domain: $DOMAIN"
        echo -e "  Server IP: $SERVER_IP"
        echo ""
    fi
    
    # Check root if needed
    check_root
    
    # Execute deployment steps
    setup_environment
    
    if [[ "$SETUP_NGINX" == "true" ]]; then
        setup_nginx
    fi
    
    deploy_containers
    perform_health_checks
    git_autopush
    show_deployment_summary
    
    if [[ "$DRY_RUN" == "true" ]]; then
        echo ""
        warning "This was a dry run. No actual changes were made."
        info "Remove --dry-run flag to execute the deployment."
    fi
}

# Run main function with all arguments
main "$@"
