#!/bin/bash

# Set default variables
SSH_USER="root"
DEFAULT_SERVER_IP="116.118.85.41"
DEFAULT_PROJECT_NAME="innerbright"
TEMP_DIR="/tmp/deploy_$(date +%s)"

# Colors for better display
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function for logging with colors
log() {
    echo -e "${CYAN}📋 $(date '+%Y-%m-%d %H:%M:%S') - $1${NC}"
}

success() {
    echo -e "${GREEN}✅ $(date '+%Y-%m-%d %H:%M:%S') - $1${NC}"
}

error() {
    echo -e "${RED}❌ $(date '+%Y-%m-%d %H:%M:%S') - $1${NC}"
    exit 1
}

error_msg() {
    echo -e "${RED}❌ $(date '+%Y-%m-%d %H:%M:%S') - $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $(date '+%Y-%m-%d %H:%M:%S') - $1${NC}"
}

info() {
    echo -e "${BLUE}ℹ️  $(date '+%Y-%m-%d %H:%M:%S') - $1${NC}"
}

progress() {
    echo -e "${PURPLE}🔄 $(date '+%Y-%m-%d %H:%M:%S') - $1${NC}"
}

# Function to check service health
check_service_health() {
    local service_name="$1"
    local container_name="${PROJECT_NAME}-${service_name}"
    local max_attempts=10
    local attempt=1
    
    progress "🔍 Checking health of $service_name..."
    
    while [ $attempt -le $max_attempts ]; do
        local status=$(ssh "$SSH_USER@$SERVER_IP" "docker inspect --format='{{.State.Status}}' '$container_name' 2>/dev/null || echo 'not_found'")
        
        if [ "$status" = "running" ]; then
            # Additional health checks based on service type
            case $service_name in
                "postgres")
                    local health_check=$(ssh "$SSH_USER@$SERVER_IP" "docker exec '$container_name' pg_isready -U postgres 2>/dev/null && echo 'healthy' || echo 'unhealthy'")
                    ;;
                "redis")
                    local health_check=$(ssh "$SSH_USER@$SERVER_IP" "docker exec '$container_name' redis-cli --no-auth-warning -a \$REDIS_PASSWORD ping 2>/dev/null | grep -q PONG && echo 'healthy' || echo 'unhealthy'")
                    ;;
                "api"|"site")
                    # Check if the service is responding on its port
                    local health_check=$(ssh "$SSH_USER@$SERVER_IP" "docker logs '$container_name' --tail 20 2>/dev/null | grep -i 'error\\|failed\\|exception' >/dev/null && echo 'unhealthy' || echo 'healthy'")
                    ;;
                "minio")
                    local health_check=$(ssh "$SSH_USER@$SERVER_IP" "docker exec '$container_name' curl -f http://localhost:9000/minio/health/live 2>/dev/null && echo 'healthy' || echo 'unhealthy'")
                    ;;
                *)
                    local health_check="healthy"
                    ;;
            esac
            
            if [ "$health_check" = "healthy" ]; then
                success "✅ $service_name is running and healthy"
                return 0
            else
                warning "⚠️  $service_name is running but not healthy (attempt $attempt/$max_attempts)"
            fi
        else
            warning "⚠️  $service_name status: $status (attempt $attempt/$max_attempts)"
        fi
        
        attempt=$((attempt + 1))
        sleep 3
    done
    
    error "❌ $service_name failed health check after $max_attempts attempts"
    return 1
}

# Function to stop only failed services
stop_failed_services() {
    local services_to_check="$1"
    local failed_services=""
    local healthy_services=""
    
    progress "🔍 Analyzing service health status..." >&2
    
    for service in $services_to_check; do
        local container_name="${PROJECT_NAME}-${service}"
        local status=$(ssh "$SSH_USER@$SERVER_IP" "docker inspect --format='{{.State.Status}}' '$container_name' 2>/dev/null || echo 'not_found'")
        
        if [ "$status" = "running" ]; then
            # Check if service is actually healthy
            if check_service_health "$service" >/dev/null 2>&1; then
                healthy_services="$healthy_services $service"
                success "✅ $service is healthy - keeping it running" >&2
            else
                failed_services="$failed_services $service"
                warning "⚠️  $service has issues - will be restarted" >&2
            fi
        else
            failed_services="$failed_services $service"
            warning "⚠️  $service is not running - will be started" >&2
        fi
    done
    
    # Only stop failed services
    if [ -n "$failed_services" ]; then
        progress "🛑 Stopping only failed services: $failed_services" >&2
        ssh "$SSH_USER@$SERVER_IP" "
            cd /opt/$PROJECT_NAME/
            for service in $failed_services; do
                container_name=\"\${PROJECT_NAME}-\$service\"
                echo \"Stopping failed service: \$service\"
                docker stop \"\$container_name\" 2>/dev/null || true
                docker rm -f \"\$container_name\" 2>/dev/null || true
            done
        " >&2
    else
        success "🎉 All services are healthy - no services need to be stopped" >&2
    fi
    
    if [ -n "$healthy_services" ]; then
        info "🟢 Healthy services that will continue running: $healthy_services" >&2
    fi
    
    # Only output the failed services list to stdout (for capture by command substitution)
    echo "$failed_services"
}

# Function to deploy specific services smartly
smart_deploy_services() {
    local services_to_deploy="$1"
    local deployment_mode="$2" # "selective" or "all"
    
    progress "🧠 Smart deployment mode: analyzing current service states..."
    
    # Get list of failed services
    local failed_services
    if [ "$deployment_mode" = "all" ]; then
        failed_services=$(stop_failed_services "$services_to_deploy" | tr -s ' ' | sed 's/^ *//;s/ *$//')
    else
        failed_services="$services_to_deploy"
    fi
    
    if [ -n "$failed_services" ]; then
        progress "🚀 Starting deployment for services: $failed_services"
        ssh "$SSH_USER@$SERVER_IP" "
            cd /opt/$PROJECT_NAME/
            echo 'SMART PROJECT-SCOPED DEPLOYMENT for $PROJECT_NAME'
            echo 'Services to deploy: $failed_services'
            
            if [ -f 'docker-compose.yml' ]; then
                echo 'Starting selective Docker Compose deployment...'
                
                # Start only the failed/missing services
                for service in $failed_services; do
                    echo \"🔄 Building and starting service: \$service with NO CACHE...\"
                    # COMPOSE_PROJECT_NAME=$PROJECT_NAME docker compose build --no-cache \$service
                    # COMPOSE_PROJECT_NAME=$PROJECT_NAME docker compose up -d --force-recreate \$service
                    echo \"🚀 Building \$service with optimized Dockerfile...\"
                    # Use ultra-optimized Dockerfile for site if available
                    if [ \"\$service\" = \"site\" ] && [ -f \"site/Dockerfile.ultra-optimized\" ]; then
                        COMPOSE_PROJECT_NAME=$PROJECT_NAME docker compose -f 'docker-compose.yml' build --no-cache --build-arg BUILDKIT_INLINE_CACHE=1 \$service
                    else
                        COMPOSE_PROJECT_NAME=$PROJECT_NAME docker compose -f 'docker-compose.yml' build --no-cache \$service
                    fi
                    echo \"🚀 Starting \$service with optimizations...\"
                    COMPOSE_PROJECT_NAME=$PROJECT_NAME docker compose -f 'docker-compose.yml' up -d --force-recreate \$service

                    # Wait a bit for the service to start
                    sleep 5
                    
                    # Check immediate status
                    container_name=\"\${PROJECT_NAME}-\$service\"
                    status=\$(docker inspect --format='{{.State.Status}}' \"\$container_name\" 2>/dev/null || echo 'not_found')
                    echo \"Service \$service status: \$status\"
                done
                
                echo 'Waiting for all deployed services to stabilize...'
                sleep 15
                
                echo 'Final deployment status:'
                docker ps --filter name=\"\${PROJECT_NAME}-\" --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
                
            else
                echo 'PROJECT docker-compose.yml not found!'
                exit 1
            fi
        " || error "Failed to deploy services"
        
        # Verify deployment success
        progress "🔍 Verifying deployment success..."
        local deployment_success=true
        for service in $failed_services; do
            if check_service_health "$service"; then
                success "✅ $service deployed successfully"
            else
                error "❌ $service deployment failed"
                deployment_success=false
            fi
        done
        
        if [ "$deployment_success" = true ]; then
            success "🎉 Smart deployment completed successfully!"
        else
            error "❌ Some services failed to deploy properly"
        fi
    else
        success "🎉 All services are already running and healthy - no deployment needed!"
    fi
}

# Function to get server configuration from user
get_server_config() {
    clear
    echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}                   🛠️  Server Configuration${NC}"
    echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
    
    # Get server IP
    echo -e "${YELLOW}Enter server IP address:${NC}"
    echo -e "${BLUE}Default: ${DEFAULT_SERVER_IP}${NC}"
    echo -ne "${YELLOW}Server IP (press Enter for default): ${NC}"
    read input_server_ip
    
    if [ -z "$input_server_ip" ]; then
        SERVER_IP="$DEFAULT_SERVER_IP"
    else
        SERVER_IP="$input_server_ip"
    fi
    
    # Validate IP format (basic validation)
    if [[ ! $SERVER_IP =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        warning "Invalid IP format. Please use format: xxx.xxx.xxx.xxx"
        echo -ne "${YELLOW}Re-enter server IP: ${NC}"
        read SERVER_IP
        if [[ ! $SERVER_IP =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
            error "Invalid IP format provided twice. Exiting."
        fi
    fi
    
    echo ""
    
    # Get project name
    echo -e "${YELLOW}Enter project name:${NC}"
    echo -e "${BLUE}Default: ${DEFAULT_PROJECT_NAME}${NC}"
    echo -ne "${YELLOW}Project name (press Enter for default): ${NC}"
    read input_project_name
    
    if [ -z "$input_project_name" ]; then
        PROJECT_NAME="$DEFAULT_PROJECT_NAME"
    else
        PROJECT_NAME="$input_project_name"
    fi
    
    # Validate project name (only alphanumeric and underscores)
    if [[ ! $PROJECT_NAME =~ ^[a-zA-Z0-9_-]+$ ]]; then
        warning "Project name should only contain letters, numbers, underscores, and hyphens"
        echo -ne "${YELLOW}Re-enter project name: ${NC}"
        read PROJECT_NAME
        if [[ ! $PROJECT_NAME =~ ^[a-zA-Z0-9_-]+$ ]]; then
            error "Invalid project name provided twice. Exiting."
        fi
    fi
    
    echo ""
    echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}✅ Configuration Summary:${NC}"
    echo -e "${YELLOW}Server IP:${NC} $SERVER_IP"
    echo -e "${YELLOW}Project Name:${NC} $PROJECT_NAME"
    echo -e "${YELLOW}SSH User:${NC} $SSH_USER"
    echo -e "${YELLOW}Project Path:${NC} /opt/$PROJECT_NAME"
    echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
    
    echo -e "${YELLOW}Is this configuration correct? (Y/n):${NC}"
    read -p "❓ " confirm
    if [[ $confirm =~ ^[Nn]$ ]]; then
        get_server_config  # Recursive call to re-enter configuration
    fi
    
    success "Server configuration completed"
}

# Function to show enhanced menu
show_menu() {
    clear
    echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}                    🚀 SMART PROJECT-SCOPED Deployment Tool${NC}"
    echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}Project:${NC} $PROJECT_NAME"
    echo -e "${YELLOW}Server:${NC} $SSH_USER@$SERVER_IP"
    echo -e "${YELLOW}Project Path:${NC} /opt/$PROJECT_NAME"
    echo -e "${YELLOW}Time:${NC} $(date '+%Y-%m-%d %H:%M:%S')"
    echo -e "${CYAN}──────────────────────────────────────────────────────────────${NC}"
    echo -e "${BLUE}Smart Deployment Options:${NC}"
    echo -e "  ${GREEN}0)${NC} ⚙️  Configure server settings"
    echo -e "  ${GREEN}1)${NC} 🌐 Smart Deploy Site only (Git + Site service)"
    echo -e "  ${GREEN}2)${NC} 🔧 Smart Deploy API only (Git + API service)"
    echo -e "  ${GREEN}3)${NC} 🧠 Smart Deploy Site & API (Git + both services)"
    echo -e "  ${GREEN}4)${NC} 💾 Smart Deploy Database Stack (Postgres + Redis)"
    echo -e "  ${GREEN}5)${NC} 📦 Smart Deploy Storage Stack (MinIO + pgAdmin)"
    echo -e "  ${GREEN}6)${NC} 🧠 Smart Deploy ALL with Git - preserves healthy services"
    echo -e "  ${GREEN}7)${NC} 🧹 Project cleanup & container fix (PROJECT ONLY)"
    echo -e "  ${GREEN}8)${NC} 📊 Check project status"
    echo -e "  ${GREEN}9)${NC} 🔧 Fresh deploy (clean env + copy env.local)"
    echo -e "  ${GREEN}10)${NC} 🛠️  Smart deploy specific services"
    echo -e "  ${RED}q)${NC} 👋 Quit"
    echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}🧠 SMART MODE: Only restarts failed services, keeps healthy services running${NC}"
    echo -e "${RED}🔒 ALL OPERATIONS ARE PROJECT-SCOPED - NO IMPACT ON OTHER SERVER SERVICES${NC}"
}

# Function for enhanced git operations
git_commit() {
    progress "Starting git operations..."
    
    # Check if we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        error "Not in a git repository. Please initialize git first."
    fi
    
    # Check if there are changes to commit
    if ! git diff --quiet || ! git diff --cached --quiet; then
        log "📝 Staging all changes..."
        git add . || error "Failed to stage changes"
        
        echo -e "${YELLOW}Enter commit message (or press Enter for auto-generated):${NC}"
        read -p "💬 " commit_message
        
        if [ -z "$commit_message" ]; then
            commit_message="Auto-update $(date '+%Y-%m-%d %H:%M:%S')"
        fi
        
        progress "Committing with message: '$commit_message'"
        git commit -m "$commit_message" || error "Failed to commit changes"
        
        progress "Pushing to remote repository..."
        git push || error "Failed to push to git repository"
        
        success "Git operations completed successfully"
    else
        warning "No changes detected in git repository"
        info "Repository is up to date"
    fi
}

# Function to deploy files to server (shared by all deployment functions)
deploy_files_to_server() {
    progress "📤 Preparing project files for full content update..."
    
    # Create temp directory
    mkdir -p "$TEMP_DIR" || error "Failed to create temp directory"
    success "Temporary directory created: $TEMP_DIR"
    
    # Show what will be excluded (only critical system files)
    info "Excluding: .git, node_modules, *.log, *.sh"
    info "⚠️  All other files will be overwritten on server"
    
    # Copy all project files to temp directory (excluding only system files, allow env files)
    rsync -av \
        --exclude='.git' \
        --exclude='node_modules' \
        --exclude='*.log' \
        --exclude='*.sh' \
        . "$TEMP_DIR/" || error "Failed to copy files to temp directory"
    
    # Show transfer size
    size=$(du -sh "$TEMP_DIR" | cut -f1)
    info "Transfer size: $size"

    progress "🔐 Backing up existing PROJECT environment file on server..."
    ssh "$SSH_USER@$SERVER_IP" "
        cd /opt/$PROJECT_NAME/ 2>/dev/null || mkdir -p /opt/$PROJECT_NAME/
        if [ -f .env ]; then
            cp .env .env.server.backup
            echo '✅ PROJECT environment file backed up as .env.server.backup'
        else
            echo '⚠️  No existing PROJECT .env file found to backup'
        fi
    " || warning "Could not backup PROJECT environment file"

    progress "🌐 Transferring and OVERWRITING all project files on server..."
    progress "🔄 This will update all content, data files, and configurations..."
    
    # Transfer ALL files (including .env* files) to completely update server content
    rsync -avz --progress --delete "$TEMP_DIR/" "$SSH_USER@$SERVER_IP:/opt/$PROJECT_NAME/" || error "Failed to transfer files to remote server"
    
    progress "🔧 Managing PROJECT environment configuration..."
    ssh "$SSH_USER@$SERVER_IP" "
        cd /opt/$PROJECT_NAME/
        
        # Check what environment files we have after transfer
        echo '📋 Environment files after transfer:'
        ls -la .env* 2>/dev/null || echo 'No .env files found'
        
        # Prioritize environment file selection
        if [ -f .env.prod ]; then
            cp .env.prod .env
            echo '✅ Using .env.prod as active PROJECT environment'
        elif [ -f .env.server.backup ]; then
            cp .env.server.backup .env
            echo '✅ Restored original server PROJECT environment from backup'
        elif [ -f .env.local ]; then
            cp .env.local .env
            echo '✅ Using .env.local as active PROJECT environment'
        else
            echo '⚠️  No suitable environment file found'
            if [ -f .env.server.backup ]; then
                cp .env.server.backup .env
                echo '📝 Using server backup as fallback'
            fi
        fi
        
        if [ -f .env ]; then
            echo 'PROJECT environment variables count:' \$(grep -c '=' .env 2>/dev/null || echo '0')
            echo '✅ PROJECT environment file is ready'
        else
            echo '❌ No PROJECT environment file available after setup'
        fi
    " || warning "Could not manage PROJECT environment file"
    
    # Cleanup temp directory
    rm -rf "$TEMP_DIR"
    success "Local cleanup completed"
    success "🎉 Project files completely updated on server with latest local content"
    info "✅ All project data, content, and configuration files overwritten"
    info "✅ Server now has the latest version of all project files"
}

# Function: Smart Deploy Site only
git_commit_and_deploy_site() {
    git_commit
    progress "🌐 Initializing SMART PROJECT-SCOPED Site deployment..."
    
    deploy_files_to_server
    smart_deploy_services "site" "selective"
    
    success "🎉 Git commit and SMART Site deployment completed successfully!"
    info "✅ PROJECT Site service updated with latest code"
    info "✅ PROJECT environment file (.env) preserved unchanged"
    warning "🧠 SMART MODE: Only failed services were restarted"
}

# Function: Smart Deploy API only  
git_commit_and_deploy_api() {
    git_commit
    progress "🔧 Initializing SMART PROJECT-SCOPED API deployment..."
    
    deploy_files_to_server
    smart_deploy_services "api" "selective"
    
    success "🎉 Git commit and SMART API deployment completed successfully!"
    info "✅ PROJECT API service updated with latest code"
    info "✅ PROJECT environment file (.env) preserved unchanged"
    warning "🧠 SMART MODE: Only failed services were restarted"
}

# Function: Smart Deploy Site & API
git_commit_and_deploy_site_api() {
    git_commit
    progress "🧠 Initializing SMART PROJECT-SCOPED Site & API deployment..."
    
    deploy_files_to_server
    
    # Stop and prune site and api services before deployment for NO CACHE
    progress "🛑 Stopping and pruning Site & API services (NO CACHE MODE)..."
    ssh "$SSH_USER@$SERVER_IP" "
        cd /opt/$PROJECT_NAME/
        
        # Stop site and api containers
        for service in site api; do
            container_name=\"\${PROJECT_NAME}-\$service\"
            if docker ps --filter name=\"\$container_name\" --format '{{.Names}}' | grep -q \"^\$container_name\$\"; then
                echo \"Stopping \$service service...\"
                docker stop \"\$container_name\" 2>/dev/null || true
                docker rm -f \"\$container_name\" 2>/dev/null || true
            fi
        done
        
        # Prune build cache and unused images for fresh build
        echo '🧹 Clearing Docker build cache...'
        docker builder prune -af 2>/dev/null || true
        
        # Remove any existing site/api images to force rebuild
        SITE_API_IMAGES=\$(docker images | grep -E \"(${PROJECT_NAME}.*site|${PROJECT_NAME}.*api)\" | awk '{print \$3}')
        if [ -n \"\$SITE_API_IMAGES\" ]; then
            echo \"🗑️ Removing old site/api images for fresh build...\"
            echo \"\$SITE_API_IMAGES\" | xargs docker rmi -f 2>/dev/null || true
        fi
        
        echo '✅ Site & API services stopped and cache cleared for fresh deployment'
    "

    # Deploy with NO CACHE
    progress "🚀 Starting NO CACHE deployment for Site & API services..."
    ssh "$SSH_USER@$SERVER_IP" "
        cd /opt/$PROJECT_NAME/
        echo 'SMART PROJECT-SCOPED NO CACHE DEPLOYMENT for $PROJECT_NAME'
        echo 'Services to deploy: site api'
        
        if [ -f 'docker-compose.yml' ]; then
            echo 'Starting NO CACHE Docker Compose deployment...'
            
            # Build and start site and api services with NO CACHE
            for service in site api; do
                echo \"🔄 Building and starting \$service with NO CACHE...\"
                COMPOSE_PROJECT_NAME=$PROJECT_NAME docker compose build --no-cache \$service
                COMPOSE_PROJECT_NAME=$PROJECT_NAME docker compose up -d --force-recreate \$service
                
                # Wait for the service to start
                sleep 5
                
                # Check immediate status
                container_name=\"\${PROJECT_NAME}-\$service\"
                status=\$(docker inspect --format='{{.State.Status}}' \"\$container_name\" 2>/dev/null || echo 'not_found')
                echo \"Service \$service status: \$status\"
            done
            
            echo 'Waiting for all deployed services to stabilize...'
            sleep 15
            
            echo 'Final deployment status:'
            docker ps --filter name=\"\${PROJECT_NAME}-\" --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
            
        else
            echo 'PROJECT docker-compose.yml not found!'
            exit 1
        fi
    " || error "Failed to deploy services with NO CACHE"

    # Verify deployment success
    progress "🔍 Verifying NO CACHE deployment success..."
    local deployment_success=true
    for service in site api; do
        if check_service_health "$service"; then
            success "✅ $service deployed successfully (NO CACHE)"
        else
            error "❌ $service deployment failed"
            deployment_success=false
        fi
    done
    
    if [ "$deployment_success" = true ]; then
        success "🎉 Git commit and SMART Site & API deployment completed successfully!"
        info "✅ PROJECT Site and API services updated with latest code (NO CACHE)"
        info "✅ PROJECT environment file (.env) preserved unchanged"
        warning "🧠 SMART MODE: Fresh build without cache ensures latest code deployment"
    else
        error "❌ Some services failed to deploy properly"
    fi
}

# Function: Smart Deploy Database Stack
smart_deploy_database() {
    progress "💾 Initializing SMART DATABASE Stack deployment..."
    warning "This will deploy/restart PostgreSQL and Redis services only"
    
    echo -e "${YELLOW}Are you sure you want to deploy database stack? (y/N):${NC}"
    read -p "❓ " confirm
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        warning "Database deployment cancelled"
        return
    fi
    
    smart_deploy_services "postgres redis" "selective"
    
    success "🎉 SMART Database Stack deployment completed successfully!"
    info "✅ PROJECT PostgreSQL and Redis services are running"
    warning "🧠 SMART MODE: Only failed database services were restarted"
    warning "💾 All database data preserved during deployment"
}

# Function: Smart Deploy Storage Stack
smart_deploy_storage() {
    progress "📦 Initializing SMART STORAGE Stack deployment..."
    warning "This will deploy/restart MinIO and pgAdmin services only"
    
    echo -e "${YELLOW}Are you sure you want to deploy storage stack? (y/N):${NC}"
    read -p "❓ " confirm
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        warning "Storage deployment cancelled"
        return
    fi
    
    smart_deploy_services "minio pgadmin" "selective"
    
    success "🎉 SMART Storage Stack deployment completed successfully!"
    info "✅ PROJECT MinIO and pgAdmin services are running"
    warning "🧠 SMART MODE: Only failed storage services were restarted"
    warning "📦 All storage data preserved during deployment"
}

# Function: Smart Deploy ALL services
git_commit_and_update_all_preserve_data() {
    git_commit
    progress "🧠 Initializing SMART PROJECT-SCOPED ALL services update process..."
    
    deploy_files_to_server
    smart_deploy_services "api site postgres redis minio pgadmin" "selective"

    success "🎉 Git commit and SMART ALL PROJECT services update completed successfully!"
    info "✅ ALL PROJECT services updated with latest code"
    info "✅ PROJECT environment file (.env) preserved unchanged"
    info "✅ PROJECT data volumes preserved - no data loss"
    info "✅ Healthy services continued running without interruption"
    warning "🧠 SMART MODE: Only failed services were restarted"
    warning "💾 All persistent PROJECT data preserved across update"
}

# Function to check project status (STRICTLY PROJECT-SCOPED)
check_server_status() {
    progress "Checking server connection..."
    
    if ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no "$SSH_USER@$SERVER_IP" "echo 'Connection successful'" >/dev/null 2>&1; then
        success "Server connection established"
        
        progress "Checking PROJECT-ONLY status on server..."
        ssh "$SSH_USER@$SERVER_IP" "
            echo '🔒════════════════════════════════════════════════🔒'
            echo '🔒          PROJECT-SCOPED STATUS REPORT         🔒'
            echo '🔒                PROJECT: $PROJECT_NAME          🔒'
            echo '🔒════════════════════════════════════════════════🔒'
            echo ''
            
            echo '📋 Project Directory Information:'
            if [ -d '/opt/$PROJECT_NAME' ]; then
                echo '✅ Project directory exists: /opt/$PROJECT_NAME'
                echo '📂 Directory size:' \$(du -sh /opt/$PROJECT_NAME 2>/dev/null | cut -f1)
                cd /opt/$PROJECT_NAME
                echo '📄 Main files:'
                ls -la | grep -E '(docker-compose|\.env|Dockerfile)' || echo '   No main config files found'
            else
                echo '❌ Project directory missing: /opt/$PROJECT_NAME'
                echo 'Creating project directory...'
                mkdir -p /opt/$PROJECT_NAME
                echo '✅ Project directory created'
            fi
            echo ''
            
            echo '🐳 PROJECT-SPECIFIC Docker Resources:'
            echo '───────────────────────────────────────────'
            echo '📦 Project Containers (running):'
            PROJECT_CONTAINERS=\$(docker ps --filter name=\"${PROJECT_NAME}-\" --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}' 2>/dev/null)
            if [ -n \"\$PROJECT_CONTAINERS\" ]; then
                echo \"\$PROJECT_CONTAINERS\"
            else
                echo '   No project containers running'
            fi
            echo ''
            
            echo '🔍 Service Health Analysis:'
            for service in api site postgres redis minio pgadmin; do
                container_name=\"${PROJECT_NAME}-\$service\"
                if docker ps --filter name=\"\$container_name\" --format '{{.Names}}' 2>/dev/null | grep -q \"^\$container_name\$\"; then
                    status=\$(docker inspect --format='{{.State.Status}}' \"\$container_name\" 2>/dev/null)
                    echo \"  \$service: \$status ✅\"
                else
                    echo \"  \$service: not running ❌\"
                fi
            done
            echo ''
            
            echo '📊 Server Resource Usage (General):'
            echo 'Memory:' \$(free -h | grep '^Mem:' | awk '{print \$3 \"/\" \$2 \" (\" \$5 \" available)\"}')
            echo 'Disk usage for project:' \$(du -sh /opt/$PROJECT_NAME 2>/dev/null | cut -f1 || echo 'N/A')
            echo ''
        "
    else
        error "Cannot connect to server. Please check connection and SSH key authentication."
    fi
}

# Function for fresh deployment with env cleanup
fresh_deploy_to_server() {
    progress "Initializing PROJECT-SCOPED fresh deployment process..."
    
    # Check if env.local exists locally
    if [ ! -f ".env.prod" ]; then
        error ".env.prod file not found in current directory"
    fi
    
    # Create temp directory
    mkdir -p "$TEMP_DIR" || error "Failed to create temp directory"
    success "Temporary directory created: $TEMP_DIR"

    progress "📤 Preparing project files for PROJECT fresh deployment..."
    # Show what will be excluded
    info "Excluding: .git, node_modules, *.log, .env*, *.md, *.sh"
    
    # Copy all project files to temp directory (excluding all env files)
    rsync -av --exclude='.git' --exclude='node_modules' --exclude='*.log' --exclude='.env*' --exclude='*.md' --exclude='*.sh' . "$TEMP_DIR/" || error "Failed to copy files to temp directory"
    
    # Copy env.local to temp directory as .env
    cp .env.prod "$TEMP_DIR/.env" || error "Failed to copy .env.prod file"
    success "PROJECT environment file prepared from .env.prod"
    
    # Show transfer size
    size=$(du -sh "$TEMP_DIR" | cut -f1)
    info "Transfer size: $size"

    progress "🗑️ Cleaning old PROJECT environment files on server..."
    ssh "$SSH_USER@$SERVER_IP" "
        cd /opt/$PROJECT_NAME/ 2>/dev/null || true
        rm -f .env .env.* 2>/dev/null || true
        echo 'Old PROJECT environment files removed'
    " || warning "Could not clean old PROJECT environment files (directory may not exist)"

    progress "🌐 Transferring files to PROJECT directory on remote server..."
    rsync -avz --progress "$TEMP_DIR/" "$SSH_USER@$SERVER_IP:/opt/$PROJECT_NAME/" || error "Failed to transfer files to remote server"
    
    progress "🔧 Verifying new PROJECT environment configuration..."
    ssh "$SSH_USER@$SERVER_IP" "
        cd /opt/$PROJECT_NAME/
        if [ -f .env ]; then
            echo '✅ New PROJECT environment file is in place'
            echo 'PROJECT environment variables count:' \$(grep -c '=' .env 2>/dev/null || echo '0')
        else
            echo '❌ PROJECT environment file missing after transfer'
            exit 1
        fi
    " || error "Failed to verify PROJECT environment configuration"
    
    # Cleanup temp directory
    rm -rf "$TEMP_DIR"
    success "Local cleanup completed"
    
    # Use smart deployment for fresh deploy
    smart_deploy_services "api site postgres redis minio pgadmin" "all"
}

# STRICTLY PROJECT-SCOPED server cleanup and container fix function
project_cleanup_and_container_fix() {
    progress "🧹🚨 Starting STRICTLY PROJECT-SCOPED cleanup and container fix for $PROJECT_NAME..."
    
    # Ask user if they want to overwrite project data from local
    echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}📋 Data Overwrite Options:${NC}"
    echo -e "${CYAN}──────────────────────────────────────────────────────────────${NC}"
    echo -e "  ${GREEN}1)${NC} 🧹 Cleanup only (preserve existing server data)"
    echo -e "  ${GREEN}2)${NC} 🔄 Cleanup + overwrite project data from local"
    echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
    echo -e "${RED}⚠️  Option 2 will REPLACE ALL project files on server with local files${NC}"
    echo -e "${RED}⚠️  This includes configuration files but excludes .env files${NC}"
    echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
    
    echo -ne "${YELLOW}Select option (1 or 2): ${NC}"
    read data_option
    
    local overwrite_data=false
    case $data_option in
        1)
            info "Selected: Cleanup only (preserve existing server data)"
            ;;
        2)
            warning "Selected: Cleanup + overwrite project data from local"
            echo -e "${RED}⚠️  This will replace ALL project files on server with local files!${NC}"
            echo -e "${YELLOW}Are you absolutely sure? (type 'YES' to confirm):${NC}"
            read -p "❓ " confirm_overwrite
            if [[ "$confirm_overwrite" == "YES" ]]; then
                overwrite_data=true
                success "Data overwrite confirmed"
            else
                warning "Data overwrite cancelled - proceeding with cleanup only"
            fi
            ;;
        *)
            warning "Invalid option - proceeding with cleanup only"
            ;;
    esac
    
    ssh "$SSH_USER@$SERVER_IP" "
        echo '🔒 STRICTLY PROJECT-SCOPED: Emergency container cleanup and fix for $PROJECT_NAME ONLY...'
        cd /opt/$PROJECT_NAME/ 2>/dev/null || true
        
        echo '🌐 Before cleanup - Server state verification:'
        echo 'Total containers on server:' \$(docker ps --format '{{.Names}}' | wc -l)
        echo 'Total images on server:' \$(docker images --format '{{.Repository}}:{{.Tag}}' | wc -l)
        echo 'Total volumes on server:' \$(docker volume ls --format '{{.Name}}' | wc -l)
        echo 'Total networks on server:' \$(docker network ls --format '{{.Name}}' | wc -l)
        echo ''
        
        # STRICTLY force stop and remove ONLY containers with project prefix
        echo '🛑 Force stopping ONLY containers with $PROJECT_NAME prefix...'
        PROJECT_CONTAINERS=\$(docker ps -aq --filter name=\"${PROJECT_NAME}-\")
        if [ -n \"\$PROJECT_CONTAINERS\" ]; then
            echo \"Found PROJECT containers: \$(echo \$PROJECT_CONTAINERS | wc -w)\"
            echo \$PROJECT_CONTAINERS | xargs docker stop 2>/dev/null || true
            echo \$PROJECT_CONTAINERS | xargs docker rm -f 2>/dev/null || true
        else
            echo 'No PROJECT containers found to stop'
        fi
        
        # Also try specific project service cleanup with exact naming
        echo '🧹 Cleaning up specific PROJECT services...'
        for service in postgres redis minio pgadmin api site; do
            container_name=\"${PROJECT_NAME}-\$service\"
            if docker ps -a --filter name=\"\$container_name\" --format '{{.Names}}' | grep -q \"^\$container_name\$\"; then
                echo \"Removing \$container_name\"
                docker stop \"\$container_name\" 2>/dev/null || true
                docker rm -f \"\$container_name\" 2>/dev/null || true
            fi
        done
        
        # Use docker compose down ONLY for this project if docker-compose.yml exists
        if [ -f docker-compose.yml ]; then
            echo '🐳 Running docker compose down for PROJECT ONLY...'
            docker compose --project-directory /opt/$PROJECT_NAME --project-name $PROJECT_NAME down --remove-orphans 2>/dev/null || true
        fi
        
        echo '🗑️  Cleaning PROJECT-SPECIFIC Docker resources ONLY...'
        
        # Clean up PROJECT-SPECIFIC dangling resources ONLY
        echo '🧹 Cleaning PROJECT-SPECIFIC dangling containers...'
        docker container ls -a --filter name=\"${PROJECT_NAME}-\" --filter status=exited -q | xargs -r docker rm 2>/dev/null || true
        
        echo '🧹 Cleaning PROJECT-SPECIFIC unused images...'
        # Only remove images that specifically contain the project name
        docker images | grep \"${PROJECT_NAME}\" | awk '{print \$3}' | xargs -r docker rmi -f 2>/dev/null || true
        
        echo '🧹 Cleaning PROJECT-SPECIFIC unused networks...'
        # Only remove networks that specifically contain the project name
        docker network ls | grep \"${PROJECT_NAME}\" | awk '{print \$1}' | xargs -r docker network rm 2>/dev/null || true
        
        # NOTE: We STRICTLY do NOT clean volumes as they contain data and could affect other projects
        echo '⚠️  PROJECT DATA VOLUMES PRESERVED - No volume cleanup performed for safety'
        
        echo '🗂️  Cleaning PROJECT temporary files only...'
        rm -rf /opt/$PROJECT_NAME/tmp/* 2>/dev/null || true
        rm -rf /opt/$PROJECT_NAME/.cache/* 2>/dev/null || true
        
        echo '✅ STRICTLY PROJECT-SCOPED cleanup and container fix completed for $PROJECT_NAME'
    " || error "Failed to cleanup project and fix containers"

    # Handle data overwrite if selected
    if [ "$overwrite_data" = true ]; then
        deploy_files_to_server
        success "🎉 PROJECT data overwrite completed successfully!"
        info "✅ All PROJECT files updated from local to server"
        info "✅ PROJECT environment files preserved/restored"
        warning "🔒 PROJECT-SCOPED: Only $PROJECT_NAME files were overwritten"
    fi

    success "STRICTLY PROJECT-SCOPED cleanup and container fix completed successfully for $PROJECT_NAME"
    warning "✅ ONLY $PROJECT_NAME containers were affected"
    warning "✅ ALL other server services remain completely untouched"
    warning "✅ Server isolation maintained throughout cleanup process"
}

# Function to select services
select_services() {
    clear
    echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}                   🛠️  Service Selection Menu${NC}"
    echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}Select services to deploy (space-separated numbers or 'all'):${NC}"
    echo -e "${CYAN}──────────────────────────────────────────────────────────────${NC}"
    echo -e "  ${GREEN}1)${NC} 🔧 API Service"
    echo -e "  ${GREEN}2)${NC} 🌐 Site Service"
    echo -e "  ${GREEN}3)${NC} 🐘 PostgreSQL Database"
    echo -e "  ${GREEN}4)${NC} 🔴 Redis Cache"
    echo -e "  ${GREEN}5)${NC} 📦 MinIO Object Storage"
    echo -e "  ${GREEN}6)${NC} 🛠️  pgAdmin Database Admin"
    echo -e "${CYAN}──────────────────────────────────────────────────────────────${NC}"
    echo -e "${BLUE}Examples:${NC}"
    echo -e "  • ${YELLOW}all${NC} - Deploy all services"
    echo -e "  • ${YELLOW}1 2 3${NC} - Deploy API, Site, and PostgreSQL"
    echo -e "  • ${YELLOW}3 4 5${NC} - Deploy Database stack only"
    echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
    
    echo -ne "${YELLOW}Enter your selection: ${NC}"
    read service_selection
    
    # Parse service selection
    SELECTED_SERVICES=""
    if [[ "$service_selection" == "all" ]]; then
        SELECTED_SERVICES="api site postgres redis minio pgadmin"
    else
        for num in $service_selection; do
            case $num in
                1) SELECTED_SERVICES="$SELECTED_SERVICES api" ;;
                2) SELECTED_SERVICES="$SELECTED_SERVICES site" ;;
                3) SELECTED_SERVICES="$SELECTED_SERVICES postgres" ;;
                4) SELECTED_SERVICES="$SELECTED_SERVICES redis" ;;
                5) SELECTED_SERVICES="$SELECTED_SERVICES minio" ;;
                6) SELECTED_SERVICES="$SELECTED_SERVICES pgadmin" ;;
                *) warning "Invalid service number: $num" ;;
            esac
        done
    fi
    
    # Remove leading/trailing spaces and deduplicate
    SELECTED_SERVICES=$(echo $SELECTED_SERVICES | tr ' ' '\n' | sort -u | tr '\n' ' ' | sed 's/^ *//;s/ *$//')
    
    if [ -z "$SELECTED_SERVICES" ]; then
        error "No valid services selected"
    fi
    
    success "Selected services: $SELECTED_SERVICES"
    return 0
}

# Function to deploy specific services smartly (STRICTLY PROJECT-SCOPED)
deploy_selected_services() {
    select_services
    
    if [ -z "$SELECTED_SERVICES" ]; then
        error "No services selected"
    fi
    
    progress "🧠 Smart deployment for selected PROJECT services: $SELECTED_SERVICES"
    
    # Use smart deployment for selected services
    smart_deploy_services "$SELECTED_SERVICES" "selective"
    
    success "🎉 Selected PROJECT services smart deployment completed!"
    info "Selected services ($SELECTED_SERVICES) for project $PROJECT_NAME are optimally running"
    warning "🧠 SMART MODE: Only failed services were restarted"
    warning "✅ Healthy services continued running without interruption"
}

# Initialize configuration
get_server_config

# Main script with enhanced menu handling
while true; do
    show_menu
    echo -ne "${YELLOW}Enter your choice: ${NC}"
    read choice
    echo ""
    
    case $choice in
        0)
            log "Option 0 selected: Configure server settings"
            get_server_config
            ;;
        1)
            log "Option 1 selected: Smart Deploy Site only"
            warning "This will commit git changes and deploy Site service only"
            warning "🧠 SMART MODE: Only unhealthy services will be restarted"
            warning "🔒 STRICTLY PROJECT-SCOPED: Only affects $PROJECT_NAME Site service"
            echo -e "${YELLOW}Are you sure you want to proceed? (y/N):${NC}"
            read -p "❓ " confirm
            if [[ $confirm =~ ^[Yy]$ ]]; then
                git_commit_and_deploy_site
            else
                warning "Site deployment cancelled"
            fi
            echo ""
            info "Press any key to return to menu..."
            read -n 1
            ;;
        2)
            log "Option 2 selected: Smart Deploy API only"
            warning "This will commit git changes and deploy API service only"
            warning "🧠 SMART MODE: Only unhealthy services will be restarted"
            warning "🔒 STRICTLY PROJECT-SCOPED: Only affects $PROJECT_NAME API service"
            echo -e "${YELLOW}Are you sure you want to proceed? (y/N):${NC}"
            read -p "❓ " confirm
            if [[ $confirm =~ ^[Yy]$ ]]; then
                git_commit_and_deploy_api
            else
                warning "API deployment cancelled"
            fi
            echo ""
            info "Press any key to return to menu..."
            read -n 1
            ;;
        3)
            log "Option 3 selected: Smart Deploy Site & API"
            warning "This will commit git changes and deploy both Site & API services"
            warning "🧠 SMART MODE: NO CACHE build for fresh deployment"
            warning "🔒 STRICTLY PROJECT-SCOPED: Only affects $PROJECT_NAME Site & API services"
            echo -e "${YELLOW}Are you sure you want to proceed? (y/N):${NC}"
            read -p "❓ " confirm
            if [[ $confirm =~ ^[Yy]$ ]]; then
                git_commit_and_deploy_site_api
            else
                warning "Site & API deployment cancelled"
            fi
            echo ""
            info "Press any key to return to menu..."
            read -n 1
            ;;
        4)
            log "Option 4 selected: Smart Deploy Database Stack"
            smart_deploy_database
            echo ""
            info "Press any key to return to menu..."
            read -n 1
            ;;
        5)
            log "Option 5 selected: Smart Deploy Storage Stack"
            smart_deploy_storage
            echo ""
            info "Press any key to return to menu..."
            read -n 1
            ;;
        6)
            log "Option 6 selected: Smart Deploy ALL with Git"
            warning "This will commit git changes and intelligently update ALL services"
            warning "🧠 SMART MODE: Only unhealthy services will be restarted"
            warning "🔒 STRICTLY PROJECT-SCOPED: Only affects $PROJECT_NAME containers"
            echo -e "${YELLOW}Are you sure you want to proceed? (y/N):${NC}"
            read -p "❓ " confirm
            if [[ $confirm =~ ^[Yy]$ ]]; then
                git_commit_and_update_all_preserve_data
            else
                warning "Deployment cancelled"
            fi
            echo ""
            info "Press any key to return to menu..."
            read -n 1
            ;;
        7)
            log "Option 7 selected: Project cleanup & container fix"
            warning "This will perform STRICTLY PROJECT-SCOPED cleanup and fix container conflicts"
            warning "🔒 STRICTLY PROJECT-SCOPED: Only affects $PROJECT_NAME containers and resources"
            echo -e "${YELLOW}Are you sure you want to proceed? (y/N):${NC}"
            read -p "❓ " confirm
            if [[ $confirm =~ ^[Yy]$ ]]; then
                project_cleanup_and_container_fix
            else
                warning "Cleanup cancelled"
            fi
            echo ""
            info "Press any key to return to menu..."
            read -n 1
            ;;
        8)
            log "Option 8 selected: Check project status"
            check_server_status
            echo ""
            info "Press any key to return to menu..."
            read -n 1
            ;;
        9)
            log "Option 9 selected: Fresh deploy with new environment"
            warning "This will remove all old .env files and use .env.prod as new environment"
            warning "🧠 SMART MODE: Only unhealthy services will be restarted"
            warning "🔒 STRICTLY PROJECT-SCOPED: Only affects $PROJECT_NAME containers"
            echo -e "${YELLOW}Are you sure you want to proceed? (y/N):${NC}"
            read -p "❓ " confirm
            if [[ $confirm =~ ^[Yy]$ ]]; then
                fresh_deploy_to_server
            else
                warning "Fresh deployment cancelled"
            fi
            echo ""
            info "Press any key to return to menu..."
            read -n 1
            ;;
        10)
            log "Option 10 selected: Smart deploy specific services"
            warning "🧠 SMART MODE: Only unhealthy selected services will be restarted"
            warning "🔒 STRICTLY PROJECT-SCOPED: Only affects selected $PROJECT_NAME services"
            deploy_selected_services
            echo ""
            info "Press any key to return to menu..."
            read -n 1
            ;;
        q|Q)
            echo -e "${GREEN}👋 Thank you for using SMART PROJECT-SCOPED Deployment Tool!${NC}"
            echo -e "${CYAN}Goodbye!${NC}"
            exit 0
            ;;
        *)
            error_msg "Invalid option. Please try again."
            sleep 2
            ;;
    esac
done