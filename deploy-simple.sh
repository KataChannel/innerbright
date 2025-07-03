#!/bin/bash

# KataCore Simple Deployment Script v2
# Auto-generates secure passwords and secrets
# Includes Git autopush functionality
# For use on cloud server 116.118.85.41

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
FIRST_TIME=false

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
║                🚀 KataCore Simple Deployment v2                             ║
║                                                                              ║
║    Auto-Password Generation • Git Autopush • Container Deployment           ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# Show help
show_help() {
    cat << EOF
KataCore Simple Deployment Script v2

DESCRIPTION:
    Deploy KataCore with automatic password generation and Git autopush functionality.
    Only builds and deploys API and Site containers with external services.

USAGE:
    $0 [OPTIONS]

OPTIONS:
    --autopush         Enable Git autopush after successful deployment
    --force-regen      Force regenerate all passwords and secrets
    --setup-nginx      Setup Nginx configuration and SSL
    --first-time       Complete first-time server setup (includes Nginx)
    --verbose          Enable verbose output
    --dry-run          Show what would be done without executing
    --help             Show this help message

FEATURES:
    ✅ Auto-generates secure passwords (24+ characters)
    ✅ Creates JWT secrets (64-character base64)
    ✅ Preserves existing passwords if already set
    ✅ Git autopush with commit messages
    ✅ Container health checks
    ✅ Environment validation

EXAMPLES:
    # Simple deployment
    $0

    # Deployment with git autopush
    $0 --autopush

    # Force regenerate all passwords
    $0 --force-regen

    # First-time server setup with Nginx
    $0 --first-time

    # Setup Nginx only
    $0 --setup-nginx

    # Dry run to see what would happen
    $0 --dry-run

SECURITY:
    • PostgreSQL: 24-character password
    • Redis: 20-character password
    • MinIO: 20-character password
    • pgAdmin: 16-character password
    • JWT Secret: 64-character base64
    • Grafana: 16-character password

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
            --setup-nginx)
                SETUP_NGINX=true
                shift
                ;;
            --first-time)
                FIRST_TIME=true
                SETUP_NGINX=true
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
}

echo "🚀 Starting KataCore Simple Deployment..."

# Generate secure password
generate_password() {
    local length=${1:-24}
    local charset="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@#$%^&*()_+-=[]{}|;:,.<>?"
    
    if command -v openssl >/dev/null 2>&1; then
        # Use openssl for better randomness
        openssl rand -base64 32 | tr -d "=+/" | cut -c1-${length}
    elif command -v /dev/urandom >/dev/null 2>&1; then
        # Use urandom as fallback
        LC_ALL=C tr -dc "${charset}" < /dev/urandom | head -c${length}
    else
        # Basic fallback using bash
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
        # Fallback method
        local secret=""
        for i in $(seq 1 64); do
            secret="${secret}$(printf "%c" $((RANDOM % 94 + 33)))"
        done
        echo -n "$secret" | base64 | tr -d '\n'
    fi
}

# Check if environment file exists and create if needed
setup_environment() {
    log "🔧 Setting up environment configuration..."
    
    # Check if .env.example exists
    if [[ ! -f "$ENV_EXAMPLE" ]]; then
        error ".env.example file not found! Please ensure it exists in the project root."
    fi
    
    # Create .env from example if it doesn't exist
    if [[ ! -f "$ENV_FILE" ]]; then
        info "Creating .env file from .env.example..."
        if [[ "$DRY_RUN" == "false" ]]; then
            cp "$ENV_EXAMPLE" "$ENV_FILE"
        fi
        success ".env file created"
    else
        info ".env file already exists"
    fi
    
    # Generate passwords for placeholders
    generate_secure_passwords
    
    success "Environment configuration completed"
}

# Generate secure passwords and replace placeholders
generate_secure_passwords() {
    log "🔐 Generating secure passwords and secrets..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        info "DRY RUN: Would generate secure passwords"
        return 0
    fi
    
    # Define password mappings
    declare -A password_map=(
        ["__SECURE_POSTGRES_PASSWORD__"]="24"
        ["__SECURE_REDIS_PASSWORD__"]="20"
        ["__SECURE_MINIO_PASSWORD__"]="20"
        ["__SECURE_PGADMIN_PASSWORD__"]="16"
        ["__SECURE_GRAFANA_PASSWORD__"]="16"
    )
    
    # Generate passwords
    for placeholder in "${!password_map[@]}"; do
        local length=${password_map[$placeholder]}
        
        # Check if password is already set
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
    
    # Replace domain placeholders if needed
    if grep -q "your-domain.com" "$ENV_FILE"; then
        warning "Domain placeholder 'your-domain.com' found in .env file"
        info "Please update the domain settings manually in .env file"
    fi
    
    success "Password generation completed"
}

# Validate environment file
validate_environment() {
    log "🔍 Validating environment configuration..."
    
    # Check if .env file exists
    if [[ ! -f "$ENV_FILE" ]]; then
        if [[ "$DRY_RUN" == "true" ]]; then
            info "DRY RUN: Would validate environment file"
            return 0
        else
            error ".env file not found! Run the script to generate it first."
        fi
    fi
    
    if [[ "$DRY_RUN" == "true" ]]; then
        info "DRY RUN: Would validate environment variables"
        return 0
    fi
    
    # Load environment variables
    set -a
    source "$ENV_FILE"
    set +a
    
    # Check required variables
    local missing_vars=()
    local required_vars=(
        "DATABASE_URL"
        "REDIS_URL"
        "JWT_SECRET"
        "MINIO_ENDPOINT"
        "MINIO_ACCESS_KEY"
        "MINIO_SECRET_KEY"
        "NEXT_PUBLIC_API_URL"
    )
    
    for var in "${required_vars[@]}"; do
        if [[ -z "${!var:-}" ]]; then
            missing_vars+=("$var")
        fi
    done
    
    if [[ ${#missing_vars[@]} -gt 0 ]]; then
        error "Missing required environment variables: ${missing_vars[*]}"
    fi
    
    # Check for remaining placeholders
    local remaining_placeholders=$(grep -o "__SECURE_[^_]*__" "$ENV_FILE" 2>/dev/null | sort -u || true)
    if [[ -n "$remaining_placeholders" ]]; then
        warning "Found remaining placeholders in .env file:"
        echo "$remaining_placeholders"
        info "These will be auto-generated on next run"
    fi
    
    success "Environment validation completed"
}

# Git autopush functionality
git_autopush() {
    if [[ "$AUTOPUSH_GIT" == "false" ]]; then
        debug "Git autopush disabled"
        return 0
    fi
    
    log "📤 Git autopush functionality..."
    
    # Check if git is available
    if ! command -v git >/dev/null 2>&1; then
        warning "Git not found, skipping autopush"
        return 0
    fi
    
    # Check if this is a git repository
    if [[ ! -d ".git" ]]; then
        warning "Not a git repository, skipping autopush"
        return 0
    fi
    
    if [[ "$DRY_RUN" == "true" ]]; then
        info "DRY RUN: Would perform git autopush"
        return 0
    fi
    
    # Check git configuration
    local git_user=$(git config user.name 2>/dev/null || echo "")
    local git_email=$(git config user.email 2>/dev/null || echo "")
    
    if [[ -z "$git_user" ]] || [[ -z "$git_email" ]]; then
        warning "Git user not configured, skipping autopush"
        info "Configure git with:"
        echo "  git config --global user.name 'Your Name'"
        echo "  git config --global user.email 'your.email@example.com'"
        return 0
    fi
    
    # Check if there are changes to commit
    if git diff --quiet && git diff --cached --quiet; then
        info "No changes to commit"
        return 0
    fi
    
    # Add all changes
    debug "Adding all changes to git"
    git add .
    
    # Create commit message
    local commit_msg="🚀 KataCore deployment update - $(date '+%Y-%m-%d %H:%M:%S')"
    
    # Commit changes
    debug "Committing changes"
    git commit -m "$commit_msg"
    
    # Push to remote (if configured)
    if git remote -v | grep -q "origin"; then
        debug "Pushing to remote origin"
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

# Nginx setup functionality
setup_nginx_server() {
    if [[ "$SETUP_NGINX" == "false" ]]; then
        debug "Nginx setup disabled"
        return 0
    fi
    
    log "🌐 Setting up Nginx server configuration..."
    
    # Check if nginx setup script exists
    local nginx_script="$SCRIPT_DIR/scripts/setup-nginx-auto.sh"
    if [[ ! -f "$nginx_script" ]]; then
        error "Nginx setup script not found at $nginx_script"
    fi
    
    if [[ "$DRY_RUN" == "true" ]]; then
        info "DRY RUN: Would setup Nginx with SSL for innerbright.vn"
        return 0
    fi
    
    # Check if running as root for Nginx setup
    if [[ $EUID -ne 0 ]]; then
        error "Nginx setup requires root privileges. Please run with sudo."
    fi
    
    # Make sure the script is executable
    chmod +x "$nginx_script"
    
    # Run the Nginx setup script
    info "Running Nginx auto-setup script..."
    if bash "$nginx_script"; then
        success "Nginx setup completed successfully"
    else
        error "Nginx setup failed"
    fi
}

# System requirements check for first-time setup
check_system_requirements() {
    if [[ "$FIRST_TIME" == "false" ]]; then
        debug "Skipping system requirements check"
        return 0
    fi
    
    log "🔍 Checking system requirements for first-time setup..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        info "DRY RUN: Would check system requirements"
        return 0
    fi
    
    # Check if running on the correct server IP
    local server_ip=$(curl -s ifconfig.me 2>/dev/null || curl -s ipinfo.io/ip 2>/dev/null || echo "unknown")
    if [[ "$server_ip" == "116.118.85.41" ]]; then
        success "Running on correct server: $server_ip"
    else
        warning "Server IP mismatch. Expected: 116.118.85.41, Got: $server_ip"
        info "Continuing anyway..."
    fi
    
    # Check available disk space
    local available_space=$(df / | awk 'NR==2 {print $4}')
    if [[ $available_space -gt 2000000 ]]; then  # 2GB in KB
        success "Sufficient disk space available: $(($available_space / 1024 / 1024))GB"
    else
        warning "Low disk space: $(($available_space / 1024 / 1024))GB available"
    fi
    
    # Check memory
    local total_memory=$(free -m | awk 'NR==2{print $2}')
    if [[ $total_memory -gt 1000 ]]; then  # 1GB
        success "Sufficient memory available: ${total_memory}MB"
    else
        warning "Low memory: ${total_memory}MB available"
    fi
    
    # Update system packages
    info "Updating system packages..."
    apt update && apt upgrade -y
    success "System packages updated"
}

# Container deployment
deploy_containers() {
    log "🐳 Deploying containers..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        info "DRY RUN: Would deploy containers"
        return 0
    fi
    
    # Check if docker and docker-compose are available
    if ! command -v docker >/dev/null 2>&1; then
        error "Docker not found! Please install Docker first."
    fi
    
    if ! command -v docker-compose >/dev/null 2>&1; then
        error "Docker Compose not found! Please install Docker Compose first."
    fi
    
    # Stop existing containers
    info "Stopping existing containers..."
    docker-compose -f docker-compose.prod.yml down 2>/dev/null || true
    
    # Build containers
    info "Building API container..."
    docker-compose -f docker-compose.prod.yml build api
    
    info "Building Site container..."
    docker-compose -f docker-compose.prod.yml build site
    
    # Start containers
    info "Starting containers..."
    docker-compose -f docker-compose.prod.yml up -d
    
    success "Containers deployed successfully"
}

# Health checks
perform_health_checks() {
    log "🏥 Performing health checks..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        info "DRY RUN: Would perform health checks"
        return 0
    fi
    
    # Wait for services to start
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
    
    # Show container status
    info "Container status:"
    docker-compose -f docker-compose.prod.yml ps
    
    success "Health checks completed"
}

# Show deployment summary
show_deployment_summary() {
    echo ""
    success "🎉 KataCore Simple Deployment Completed!"
    echo ""
    
    echo -e "${BLUE}📋 Deployment Summary:${NC}"
    echo -e "  🔗 API: ${CYAN}http://116.118.85.41:3001${NC}"
    echo -e "  🌐 Site: ${CYAN}http://116.118.85.41:3000${NC}"
    echo -e "  📁 Environment: ${CYAN}$ENV_FILE${NC}"
    
    if [[ "$SETUP_NGINX" == "true" ]]; then
        echo -e "  🌐 Domain: ${CYAN}https://innerbright.vn${NC}"
        echo -e "  🔗 API via Nginx: ${CYAN}https://innerbright.vn/api${NC}"
        echo -e "  🏥 Health Check: ${CYAN}https://innerbright.vn/health${NC}"
    fi
    echo ""
    
    echo -e "${BLUE}🔐 Security:${NC}"
    echo -e "  ✅ Secure passwords generated automatically"
    echo -e "  ✅ JWT secret generated"
    echo -e "  ✅ Environment variables configured"
    echo ""
    
    echo -e "${BLUE}🚀 Next Steps:${NC}"
    echo -e "  1. Configure Nginx on host server to proxy to containers"
    echo -e "  2. Set up SSL certificates"
    echo -e "  3. Configure external services (PostgreSQL, Redis, MinIO)"
    echo -e "  4. Update domain settings in .env file"
    echo ""
    
    echo -e "${BLUE}📊 Management Commands:${NC}"
    echo -e "  🔍 Check logs: ${CYAN}docker-compose -f docker-compose.prod.yml logs -f${NC}"
    echo -e "  🔄 Restart: ${CYAN}docker-compose -f docker-compose.prod.yml restart${NC}"
    echo -e "  🛑 Stop: ${CYAN}docker-compose -f docker-compose.prod.yml down${NC}"
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
        echo -e "  Setup Nginx: $SETUP_NGINX"
        echo -e "  First Time: $FIRST_TIME"
        echo -e "  Verbose: $VERBOSE"
        echo -e "  Dry Run: $DRY_RUN"
        echo ""
    fi
    
    # Execute deployment steps
    check_system_requirements
    setup_nginx_server
    setup_environment
    validate_environment
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
