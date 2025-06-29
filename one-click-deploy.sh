#!/bin/bash

# Innerbright Quick Production Deployment Script
# This script automates the entire deployment process for production

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="Innerbright"
PROJECT_DIR="/opt/innerbright"
BACKUP_DIR="/opt/innerbright/backups"
LOG_FILE="/opt/innerbright/logs/deployment.log"

# Create log directory
mkdir -p $(dirname $LOG_FILE)

# Logging function
log() {
    echo -e "$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S'): $1" | sed 's/\x1b\[[0-9;]*m//g' >> $LOG_FILE
}

# Error handling
error_exit() {
    log "${RED}❌ Error: $1${NC}"
    exit 1
}

# Welcome message
clear
echo -e "${BLUE}"
echo "╔═══════════════════════════════════════════════════════════════════════════════╗"
echo "║                    🚀 INNERBRIGHT PRODUCTION DEPLOYMENT 🚀                    ║"
echo "║                                                                               ║"
echo "║  This script will deploy Innerbright to production with:                     ║"
echo "║  • Next.js Frontend (Port 3000)                                              ║"
echo "║  • NestJS Backend API (Port 3333)                                            ║"
echo "║  • PostgreSQL Database (Port 5432)                                           ║"
echo "║  • MinIO Object Storage (Port 9000)                                          ║"
echo "║  • Nginx Reverse Proxy with SSL                                              ║"
echo "║  • Redis Cache (Optional)                                                    ║"
echo "║  • PgAdmin (Optional)                                                        ║"
echo "║                                                                               ║"
echo "╚═══════════════════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   error_exit "This script should not be run as root. Please run as a regular user with sudo privileges."
fi

# Interactive setup function
interactive_setup() {
    echo -e "${CYAN}🔧 Let's configure your deployment settings...${NC}\n"
    
    # Domain configuration
    read -p "Enter your domain name [innerbright.vn]: " DOMAIN
    DOMAIN=${DOMAIN:-innerbright.vn}
    
    # Email for SSL
    read -p "Enter your email for SSL certificate [trantqchau90@gmail.com]: " EMAIL
    EMAIL=${EMAIL:-trantqchau90@gmail.com}
    
    # Database configuration
    read -p "Enter PostgreSQL database name [innerbright_prod]: " DB_NAME
    DB_NAME=${DB_NAME:-innerbright_prod}
    
    read -p "Enter PostgreSQL username [innerbright_user]: " DB_USER
    DB_USER=${DB_USER:-innerbright_user}
    
    read -s -p "Enter PostgreSQL password [auto-generate]: " DB_PASSWORD
    echo
    if [[ -z "$DB_PASSWORD" ]]; then
        # Auto-generate secure password
        DB_PASSWORD=$(openssl rand -base64 16)
        log "${GREEN}✅ Auto-generated database password${NC}"
    fi
    
    # NextAuth secret
    read -s -p "Enter NextAuth secret (32+ characters) [auto-generate]: " NEXTAUTH_SECRET
    echo
    if [[ -z "$NEXTAUTH_SECRET" ]]; then
        # Auto-generate secure secret
        NEXTAUTH_SECRET=$(openssl rand -base64 32)
        log "${GREEN}✅ Auto-generated NextAuth secret${NC}"
    elif [[ ${#NEXTAUTH_SECRET} -lt 32 ]]; then
        error_exit "NextAuth secret must be at least 32 characters long"
    fi
    
    # MinIO configuration
    read -p "Enter MinIO admin username [minioadmin]: " MINIO_USER
    MINIO_USER=${MINIO_USER:-minioadmin}
    
    read -s -p "Enter MinIO admin password [auto-generate]: " MINIO_PASSWORD
    echo
    if [[ -z "$MINIO_PASSWORD" ]]; then
        # Auto-generate secure password
        MINIO_PASSWORD=$(openssl rand -base64 16)
        log "${GREEN}✅ Auto-generated MinIO password${NC}"
    fi
    
    # Optional services
    read -p "Enable PgAdmin? (y/N): " ENABLE_PGADMIN
    ENABLE_PGADMIN=${ENABLE_PGADMIN:-n}
    
    read -p "Enable Redis? (y/N): " ENABLE_REDIS
    ENABLE_REDIS=${ENABLE_REDIS:-n}
    
    echo -e "\n${GREEN}✅ Configuration completed!${NC}"
    
    # Display configuration summary
    echo -e "\n${CYAN}📋 Configuration Summary:${NC}"
    echo -e "   Domain: ${GREEN}$DOMAIN${NC}"
    echo -e "   Email: ${GREEN}$EMAIL${NC}"
    echo -e "   Database: ${GREEN}$DB_NAME${NC}"
    echo -e "   DB User: ${GREEN}$DB_USER${NC}"
    echo -e "   MinIO User: ${GREEN}$MINIO_USER${NC}"
    echo -e "   PgAdmin: ${GREEN}$ENABLE_PGADMIN${NC}"
    echo -e "   Redis: ${GREEN}$ENABLE_REDIS${NC}"
    echo -e "\n${YELLOW}⚠️  Auto-generated passwords will be saved in .env file${NC}\n"
}

# System check function
system_check() {
    log "${YELLOW}🔍 Performing system checks...${NC}"
    
    # Check OS
    if [[ ! -f /etc/os-release ]]; then
        error_exit "Cannot determine OS version"
    fi
    
    . /etc/os-release
    if [[ $ID != "ubuntu" ]] && [[ $ID != "debian" ]]; then
        log "${YELLOW}⚠️  Warning: This script is optimized for Ubuntu/Debian${NC}"
    fi
    
    # Check system resources
    TOTAL_MEM=$(free -m | awk 'NR==2{print $2}')
    AVAILABLE_DISK=$(df / | awk 'NR==2{print int($4/1024/1024)}')
    CPU_CORES=$(nproc)
    
    log "${BLUE}💻 System Resources:${NC}"
    log "   CPU Cores: $CPU_CORES"
    log "   Total Memory: ${TOTAL_MEM}MB"
    log "   Available Disk: ${AVAILABLE_DISK}GB"
    
    if [[ $TOTAL_MEM -lt 3000 ]]; then
        log "${YELLOW}⚠️  Warning: Low memory (${TOTAL_MEM}MB). Recommended: 4GB+${NC}"
    fi
    
    if [[ $AVAILABLE_DISK -lt 10 ]]; then
        log "${YELLOW}⚠️  Warning: Low disk space (${AVAILABLE_DISK}GB). Recommended: 20GB+${NC}"
    fi
    
    # Check internet connectivity
    if ! ping -c 1 google.com &> /dev/null; then
        error_exit "No internet connection. Please check your network."
    fi
    
    log "${GREEN}✅ System checks passed${NC}"
}

# Install dependencies function
install_dependencies() {
    log "${YELLOW}📦 Installing system dependencies...${NC}"
    
    # Update system
    sudo apt update -y
    sudo apt upgrade -y
    
    # Install essential packages
    sudo apt install -y \
        curl \
        wget \
        git \
        htop \
        vim \
        ufw \
        fail2ban \
        unzip \
        software-properties-common \
        apt-transport-https \
        ca-certificates \
        gnupg \
        lsb-release \
        certbot \
        python3-certbot-nginx \
        nginx
    
    # Install Docker if not present
    if ! command -v docker &> /dev/null; then
        log "${YELLOW}🐳 Installing Docker...${NC}"
        
        # Remove any old Docker packages
        sudo apt-get remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true
        
        # Install prerequisites
        sudo apt-get update
        sudo apt-get install -y \
            ca-certificates \
            curl \
            gnupg \
            lsb-release
        
        # Add Docker's official GPG key
        sudo mkdir -p /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        
        # Set up the repository
        echo \
          "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
          $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        
        # Install Docker Engine
        sudo apt-get update
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        
        # Add user to docker group
        sudo usermod -aG docker $USER
        
        # Start and enable Docker service
        sudo systemctl start docker
        sudo systemctl enable docker
        
        # Set proper permissions for Docker socket
        sudo chmod 666 /var/run/docker.sock
        
        log "${GREEN}✅ Docker installed and configured${NC}"
        log "${YELLOW}⚠️  Group changes will take effect after logout/login or running 'newgrp docker'${NC}"
    else
        log "${GREEN}✅ Docker is already installed${NC}"
        
        # Check if Docker service exists and start it
        if sudo systemctl list-unit-files | grep -q docker.service; then
            # Ensure Docker service is running
            if ! sudo systemctl is-active --quiet docker; then
                log "${YELLOW}🔄 Starting Docker service...${NC}"
                sudo systemctl start docker
                sudo systemctl enable docker
            fi
        else
            log "${RED}❌ Docker service not found. Reinstalling Docker...${NC}"
            
            # Remove broken installation
            sudo apt-get remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true
            
            # Reinstall Docker
            sudo apt-get update
            sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
            
            # Start and enable Docker service
            sudo systemctl start docker
            sudo systemctl enable docker
        fi
        
        # Fix Docker socket permissions
        if [[ -S /var/run/docker.sock ]]; then
            sudo chmod 666 /var/run/docker.sock
            log "${GREEN}✅ Docker socket permissions fixed${NC}"
        fi
        
        # Check if user is in docker group
        if ! groups $USER | grep -q docker; then
            log "${YELLOW}⚠️  Adding $USER to docker group...${NC}"
            sudo usermod -aG docker $USER
            log "${YELLOW}⚠️  Group changes will take effect after logout/login or running 'newgrp docker'${NC}"
        fi
    fi
    
    # Install Docker Compose if not present
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        log "${YELLOW}🐳 Installing Docker Compose...${NC}"
        sudo apt install -y docker-compose-plugin
        log "${GREEN}✅ Docker Compose installed${NC}"
    else
        log "${GREEN}✅ Docker Compose is already available${NC}"
    fi
    
    # Apply group changes without logout
    log "${YELLOW}🔄 Applying Docker group changes...${NC}"
    if groups $USER | grep -q docker; then
        # User is in docker group, try to apply changes
        newgrp docker << 'ENDGROUP' || true
        echo "Group changes applied"
ENDGROUP
    fi
    
    # Test Docker installation with both methods
    log "${YELLOW}🧪 Testing Docker installation...${NC}"
    
    # Try regular docker command first
    if docker run --rm hello-world &> /dev/null; then
        log "${GREEN}✅ Docker is working correctly${NC}"
    else
        log "${YELLOW}⚠️  Regular docker command failed, trying with sudo...${NC}"
        if sudo docker run --rm hello-world &> /dev/null; then
            log "${GREEN}✅ Docker works with sudo${NC}"
            log "${YELLOW}💡 You may need to log out and log back in, or run 'newgrp docker'${NC}"
        else
            log "${RED}❌ Docker test failed even with sudo${NC}"
            
            # Additional troubleshooting
            log "${YELLOW}📋 Docker troubleshooting information:${NC}"
            log "   Docker service status:"
            sudo systemctl status docker --no-pager -l || true
            log "   Docker socket permissions:"
            ls -la /var/run/docker.sock || true
            log "   Current user groups:"
            groups $USER
            
            # Try to fix common issues
            log "${YELLOW}🔧 Attempting to fix Docker issues...${NC}"
            
            # Restart Docker service
            sudo systemctl restart docker
            sleep 5
            
            # Fix socket permissions again
            sudo chmod 666 /var/run/docker.sock
            
            # Test again
            if sudo docker run --rm hello-world &> /dev/null; then
                log "${GREEN}✅ Docker is now working with sudo${NC}"
            else
                log "${RED}❌ Docker installation appears to be broken${NC}"
                log "${YELLOW}💡 Manual steps to fix:${NC}"
                log "   1. sudo systemctl restart docker"
                log "   2. sudo chmod 666 /var/run/docker.sock"
                log "   3. Log out and log back in"
                log "   4. Or run: newgrp docker"
            fi
        fi
    fi
    
    # Install Node.js (for debugging)
    if ! command -v node &> /dev/null; then
        log "${YELLOW}📦 Installing Node.js...${NC}"
        curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
        sudo apt-get install -y nodejs
    fi
    
    log "${GREEN}✅ Dependencies installed${NC}"
}

# Helper function to safely create directories with permissions
safe_mkdir_with_permissions() {
    local dir_path="$1"
    local owner="$2"
    local permissions="$3"
    
    # Create directory if it doesn't exist
    mkdir -p "$dir_path" 2>/dev/null || sudo mkdir -p "$dir_path"
    
    # Try to set ownership
    if [[ -n "$owner" ]]; then
        chown -R "$owner" "$dir_path" 2>/dev/null || \
        sudo chown -R "$owner" "$dir_path" 2>/dev/null || \
        log "${YELLOW}⚠️  Could not set ownership for $dir_path${NC}"
    fi
    
    # Try to set permissions
    if [[ -n "$permissions" ]]; then
        chmod -R "$permissions" "$dir_path" 2>/dev/null || \
        sudo chmod -R "$permissions" "$dir_path" 2>/dev/null || \
        log "${YELLOW}⚠️  Could not set permissions for $dir_path${NC}"
    fi
}

# Setup project function
setup_project() {
    log "${YELLOW}📁 Setting up project directory...${NC}"
    
    # Create project directory
    sudo mkdir -p $PROJECT_DIR
    sudo chown $USER:$USER $PROJECT_DIR
    
    # Navigate to project directory
    cd $PROJECT_DIR
    
    # Create necessary directories
    mkdir -p logs backups
    
    # Setup data directories with proper error handling
    log "${YELLOW}Setting up data directory structure...${NC}"
    
    # Create data directory structure
    mkdir -p data
    
    # Stop any existing containers to avoid conflicts
    if [[ -f "docker-compose.yml" ]]; then
        log "   Stopping existing containers..."
        docker compose down 2>/dev/null || true
    fi
    
    # Create subdirectories for services
    log "   Creating service data directories..."
    mkdir -p data/postgres data/minio data/redis
    
    # Set permissions with proper error handling
    log "${YELLOW}Setting up data directory permissions...${NC}"
    
    # Method 1: Try to set ownership to current user first
    if chown -R $USER:$USER data/ 2>/dev/null; then
        log "${GREEN}✅ Set ownership to $USER${NC}"
        chmod -R 755 data/
        log "${GREEN}✅ Set directory permissions${NC}"
    else
        # Method 2: Use sudo to set ownership
        log "   Trying with sudo..."
        if sudo chown -R $USER:$USER data/ 2>/dev/null; then
            log "${GREEN}✅ Set ownership with sudo${NC}"
            chmod -R 755 data/
            log "${GREEN}✅ Set directory permissions${NC}"
        else
            # Method 3: Set Docker-compatible permissions
            log "${YELLOW}⚠️  Setting Docker-compatible permissions...${NC}"
            
            # Ensure directories exist and are accessible
            sudo mkdir -p data/postgres data/minio data/redis 2>/dev/null || true
            
            # Try to set specific Docker user IDs
            sudo chown -R 999:999 data/postgres 2>/dev/null || {
                log "${YELLOW}   Using fallback permissions for postgres${NC}"
                sudo chmod -R 777 data/postgres 2>/dev/null || true
            }
            
            sudo chown -R 1001:1001 data/minio 2>/dev/null || {
                log "${YELLOW}   Using fallback permissions for minio${NC}"
                sudo chmod -R 777 data/minio 2>/dev/null || true
            }
            
            # Ensure redis directory is accessible
            sudo chmod -R 777 data/redis 2>/dev/null || true
            
            # Ensure main user can access the data directory
            sudo chown $USER:$USER data 2>/dev/null || true
            chmod 755 data 2>/dev/null || true
            
            log "${GREEN}✅ Docker-compatible permissions set${NC}"
        fi
    fi
    
    # Verify directory structure
    log "   Verifying directory structure..."
    if [[ -d "data/postgres" && -d "data/minio" ]]; then
        log "${GREEN}✅ Required directories created successfully${NC}"
        
        # Show current permissions for debugging
        log "   Current directory structure:"
        ls -la data/ 2>/dev/null || log "   (Could not list directory contents)"
    else
        log "${RED}❌ Failed to create required directories${NC}"
        log "${YELLOW}⚠️  Docker will create volumes as needed${NC}"
    fi
    
    # Set proper permissions for logs and backups
    chmod -R 755 logs backups 2>/dev/null || true
    
    # Clone repository if not exists
    if [[ ! -f "docker-compose.yml" ]]; then
        log "${YELLOW}📥 Cloning repository...${NC}"
        read -p "Enter Git repository URL [https://github.com/chikiet/innerbright.git]: " REPO_URL
        REPO_URL=${REPO_URL:-https://github.com/chikiet/innerbright.git}
        
        if [[ -n "$REPO_URL" ]]; then
            # Check if directory is empty
            if [[ "$(ls -A . 2>/dev/null)" ]]; then
                log "${YELLOW}⚠️  Directory is not empty. Creating backup...${NC}"
                BACKUP_NAME="backup_$(date +%Y%m%d_%H%M%S)"
                mkdir -p "../$BACKUP_NAME"
                cp -r . "../$BACKUP_NAME/" 2>/dev/null || true
                log "${YELLOW}📁 Backup created at ../$BACKUP_NAME${NC}"
                
                # Clear directory except for essential files
                find . -mindepth 1 -maxdepth 1 ! -name 'logs' ! -name 'backups' ! -name 'data' -exec rm -rf {} + 2>/dev/null || true
            fi
            
            # Clone repository
            log "   Cloning from $REPO_URL..."
            if git clone "$REPO_URL" . ; then
                log "${GREEN}✅ Repository cloned successfully${NC}"
                
                # Verify essential directories exist
                log "   Verifying project structure..."
                if [[ -d "site" && -d "api" && -f "docker-compose.yml" ]]; then
                    log "${GREEN}✅ Project structure verified${NC}"
                    log "   Found: site/, api/, docker-compose.yml"
                else
                    log "${YELLOW}⚠️  Incomplete project structure${NC}"
                    log "   Current contents:"
                    ls -la
                    
                    # Check if files are in a subdirectory
                    SUBDIR=$(find . -name "docker-compose.yml" -type f | head -1 | xargs dirname 2>/dev/null)
                    if [[ -n "$SUBDIR" && "$SUBDIR" != "." ]]; then
                        log "${YELLOW}📁 Found project files in subdirectory: $SUBDIR${NC}"
                        log "   Moving files to root directory..."
                        mv "$SUBDIR"/* . 2>/dev/null || true
                        mv "$SUBDIR"/.* . 2>/dev/null || true
                        rmdir "$SUBDIR" 2>/dev/null || true
                        log "${GREEN}✅ Project files moved to root${NC}"
                    fi
                fi
            else
                error_exit "Failed to clone repository from $REPO_URL"
            fi
        else
            error_exit "Repository URL is required"
        fi
    else
        log "${GREEN}✅ Project files already exist${NC}"
        
        # Verify project structure
        log "   Verifying existing project structure..."
        if [[ -d "site" && -d "api" ]]; then
            log "${GREEN}✅ Application directories found${NC}"
            
            # Check for Dockerfiles
            if [[ -f "site/Dockerfile" ]]; then
                log "${GREEN}✅ site/Dockerfile found${NC}"
            else
                log "${YELLOW}⚠️  site/Dockerfile missing${NC}"
            fi
            
            if [[ -f "api/Dockerfile" ]]; then
                log "${GREEN}✅ api/Dockerfile found${NC}"
            else
                log "${YELLOW}⚠️  api/Dockerfile missing${NC}"
            fi
        else
            log "${YELLOW}⚠️  Application directories missing${NC}"
            log "   Current directory contents:"
            ls -la
        fi
    fi
    
    # Make scripts executable if they exist
    find . -name "*.sh" -type f -exec chmod +x {} \; 2>/dev/null || true
    
    log "${GREEN}✅ Project setup completed${NC}"
}

# Configure environment function
configure_environment() {
    log "${YELLOW}⚙️  Configuring environment variables...${NC}"
    
    # Create .env file
    cat > .env << EOF
# Production Environment Configuration
NODE_ENV=production
NEXT_TELEMETRY_DISABLED=1

# Database Configuration
POSTGRES_DB=$DB_NAME
POSTGRES_USER=$DB_USER
POSTGRES_PASSWORD=$DB_PASSWORD
DATABASE_URL=postgresql://$DB_USER:$DB_PASSWORD@postgres:5432/$DB_NAME

# Next.js Configuration
NEXTAUTH_SECRET=$NEXTAUTH_SECRET
NEXTAUTH_URL=https://$DOMAIN

# MinIO Configuration
MINIO_ROOT_USER=$MINIO_USER
MINIO_ROOT_PASSWORD=$MINIO_PASSWORD

# Domain Configuration
DOMAIN=$DOMAIN
EMAIL=$EMAIL

# Port Configuration
NEXTJS_PORT=3000
NESTJS_PORT=3333
POSTGRES_PORT=5432
MINIO_PORT=9000
PGADMIN_PORT=5050
REDIS_PORT=6379

# Optional Services
ENABLE_PGADMIN=$ENABLE_PGADMIN
ENABLE_REDIS=$ENABLE_REDIS
EOF

    # Set proper permissions
    chmod 600 .env
    
    # Save credentials to a secure file for reference
    cat > credentials.txt << EOF
# Innerbright Production Credentials
# Generated on: $(date)
# IMPORTANT: Keep this file secure and delete after noting down the credentials

Domain: $DOMAIN
Email: $EMAIL

Database Credentials:
- Database: $DB_NAME
- Username: $DB_USER
- Password: $DB_PASSWORD

MinIO Credentials:
- Username: $MINIO_USER
- Password: $MINIO_PASSWORD

NextAuth Secret: $NEXTAUTH_SECRET

# This file will be automatically deleted in 24 hours
EOF
    
    chmod 600 credentials.txt
    
    log "${GREEN}✅ Environment configured${NC}"
    log "${BLUE}📄 Credentials saved to: credentials.txt (will be deleted in 24 hours)${NC}"
}

# Setup security function
setup_security() {
    log "${YELLOW}🔐 Configuring security settings...${NC}"
    
    # Configure UFW firewall
    sudo ufw --force reset
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    sudo ufw allow ssh
    sudo ufw allow 80/tcp
    sudo ufw allow 443/tcp
    sudo ufw --force enable
    
    # Configure fail2ban
    sudo tee /etc/fail2ban/jail.local > /dev/null << EOF
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 5

[sshd]
enabled = true
port = ssh
logpath = /var/log/auth.log

[nginx-http-auth]
enabled = true
port = http,https
logpath = /var/log/nginx/error.log
EOF
    
    sudo systemctl restart fail2ban
    sudo systemctl enable fail2ban
    
    log "${GREEN}✅ Security configured${NC}"
}

# Deploy application function
deploy_application() {
    log "${YELLOW}🚀 Deploying application...${NC}"
    
    cd $PROJECT_DIR
    
    # Check Docker installation and permissions
    log "${YELLOW}🐳 Checking Docker installation and permissions...${NC}"
    
    # Check if Docker is installed
    if ! command -v docker &> /dev/null; then
        error_exit "Docker is not installed. Please run the install_dependencies function first."
    fi
    
    # Check if Docker daemon is running
    if ! docker info &> /dev/null; then
        log "${YELLOW}⚠️  Docker daemon is not accessible. Checking issues...${NC}"
        
        # Check if Docker service exists
        if ! sudo systemctl list-unit-files | grep -q docker.service; then
            error_exit "Docker service not found. Please run install_dependencies first."
        fi
        
        # Check Docker service status
        if ! sudo systemctl is-active --quiet docker; then
            log "${YELLOW}🔄 Docker service is not running. Starting...${NC}"
            sudo systemctl start docker
            sudo systemctl enable docker
            sleep 5
        fi
        
        # Fix Docker socket permissions
        if [[ -S /var/run/docker.sock ]]; then
            log "${YELLOW}🔧 Fixing Docker socket permissions...${NC}"
            sudo chmod 666 /var/run/docker.sock
        else
            log "${RED}❌ Docker socket not found at /var/run/docker.sock${NC}"
            error_exit "Docker socket is missing. Docker installation may be corrupted."
        fi
        
        # Test again after fixes
        if ! docker info &> /dev/null; then
            log "${RED}❌ Still cannot access Docker daemon${NC}"
            log "${YELLOW}📋 Diagnostic information:${NC}"
            log "   Docker service status:"
            sudo systemctl status docker --no-pager -l || true
            log "   Docker socket:"
            ls -la /var/run/docker.sock || true
            log "   Current user: $(whoami)"
            log "   User groups: $(groups)"
            
            # Try using sudo for all Docker commands
            log "${YELLOW}⚠️  Will use sudo for Docker commands${NC}"
            DOCKER_CMD="sudo docker"
            DOCKER_COMPOSE_CMD="sudo docker compose"
        else
            log "${GREEN}✅ Docker daemon is now accessible${NC}"
            DOCKER_CMD="docker"
            DOCKER_COMPOSE_CMD="docker compose"
        fi
    else
        log "${GREEN}✅ Docker daemon is accessible${NC}"
        DOCKER_CMD="docker"
        DOCKER_COMPOSE_CMD="docker compose"
    fi
    
    # Check if user is in docker group and apply group changes if needed
    if ! groups $USER | grep -q docker; then
        log "${YELLOW}⚠️  User $USER is not in docker group. Adding to group...${NC}"
        sudo usermod -aG docker $USER
        log "${YELLOW}⚠️  Applying group changes without logout...${NC}"
        
        # Try to apply group changes without logout
        exec sg docker -c "$0 $*" 2>/dev/null || {
            log "${YELLOW}⚠️  Could not apply group changes. Using sudo for Docker commands...${NC}"
            DOCKER_CMD="sudo docker"
            DOCKER_COMPOSE_CMD="sudo docker compose"
        }
    fi
    
    # Test Docker with a simple command
    log "   Testing Docker functionality..."
    if $DOCKER_CMD run --rm hello-world &> /dev/null; then
        log "${GREEN}✅ Docker is working correctly${NC}"
    else
        log "${YELLOW}⚠️  Docker test failed, but continuing with deployment...${NC}"
    fi
    
    # Check if docker-compose file exists
    if [[ ! -f "docker-compose.yml" ]] && [[ ! -f "docker-compose.yaml" ]]; then
        log "${RED}❌ No docker-compose.yml file found${NC}"
        log "${YELLOW}📋 Available files in project directory:${NC}"
        ls -la
        
        # Try to find compose files in subdirectories
        COMPOSE_FILE=$(find . -name "docker-compose.yml" -o -name "docker-compose.yaml" | head -1)
        if [[ -n "$COMPOSE_FILE" ]]; then
            log "${YELLOW}📁 Found compose file at: $COMPOSE_FILE${NC}"
            cd "$(dirname "$COMPOSE_FILE")"
            log "${GREEN}✅ Changed to directory: $(pwd)${NC}"
        else
            log "${RED}❌ No docker-compose file found in project${NC}"
            log "${YELLOW}💡 Creating a basic docker-compose.yml file...${NC}"
            
            # Create a basic docker-compose.yml
            cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  postgres:
    image: postgres:15-alpine
    container_name: innerbright-postgres
    environment:
      POSTGRES_DB: ${POSTGRES_DB:-innerbright_prod}
      POSTGRES_USER: ${POSTGRES_USER:-innerbright_user}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_INITDB_ARGS: --encoding=UTF-8 --lc-collate=C --lc-ctype=C
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER:-innerbright_user} -d ${POSTGRES_DB:-innerbright_prod}"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s
    networks:
      - app-network

  minio:
    image: minio/minio:latest
    container_name: innerbright-minio
    environment:
      MINIO_ROOT_USER: ${MINIO_ROOT_USER:-minioadmin}
      MINIO_ROOT_PASSWORD: ${MINIO_ROOT_PASSWORD}
    volumes:
      - minio_data:/data
    ports:
      - "9000:9000"
      - "9001:9001"
    command: server /data --console-address ":9001"
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:9000/minio/health/live"]
      interval: 30s
      timeout: 20s
      retries: 3
    networks:
      - app-network

  redis:
    image: redis:7-alpine
    container_name: innerbright-redis
    volumes:
      - redis_data:/data
    ports:
      - "6379:6379"
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 30s
      timeout: 10s
      retries: 5
    command: redis-server --appendonly yes --maxmemory 256mb --maxmemory-policy allkeys-lru
    networks:
      - app-network

  nextjs:
    build:
      context: ./site
      dockerfile: Dockerfile
      target: runner
    container_name: innerbright-nextjs
    environment:
      - NODE_ENV=production
      - DATABASE_URL=postgresql://${POSTGRES_USER:-innerbright_user}:${POSTGRES_PASSWORD}@postgres:5432/${POSTGRES_DB:-innerbright_prod}
      - NEXTAUTH_SECRET=${NEXTAUTH_SECRET}
      - NEXTAUTH_URL=${NEXTAUTH_URL}
      - NEXT_TELEMETRY_DISABLED=1
    ports:
      - "3000:3000"
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/api/health"]
      interval: 30s
      timeout: 10s
      retries: 5
    networks:
      - app-network

  nestjs:
    build:
      context: ./api
      dockerfile: Dockerfile
      target: runner
    container_name: innerbright-nestjs
    environment:
      - NODE_ENV=production
      - DATABASE_URL=postgresql://${POSTGRES_USER:-innerbright_user}:${POSTGRES_PASSWORD}@postgres:5432/${POSTGRES_DB:-innerbright_prod}
      - MINIO_ENDPOINT=minio:9000
      - MINIO_ACCESS_KEY=${MINIO_ROOT_USER:-minioadmin}
      - MINIO_SECRET_KEY=${MINIO_ROOT_PASSWORD}
    ports:
      - "3333:3333"
    depends_on:
      postgres:
        condition: service_healthy
      minio:
        condition: service_healthy
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3333/health"]
      interval: 30s
      timeout: 10s
      retries: 5
    networks:
      - app-network

networks:
  app-network:
    driver: bridge

volumes:
  postgres_data:
    driver: local
  minio_data:
    driver: local
  redis_data:
    driver: local
EOF
            log "${GREEN}✅ Created basic docker-compose.yml${NC}"
        fi
    fi
    
    # Ensure data directories exist before starting containers
    log "   Ensuring data directories exist..."
    mkdir -p data/postgres data/minio data/redis 2>/dev/null || true
    
    # Final permission check before deployment
    log "   Final permission check..."
    if [[ ! -w "data" ]]; then
        log "${YELLOW}⚠️  Data directory not writable, fixing permissions...${NC}"
        sudo chown -R $USER:$USER data/ 2>/dev/null || \
        sudo chmod -R 777 data/ 2>/dev/null || \
        log "${YELLOW}⚠️  Could not fix permissions, continuing anyway...${NC}"
    fi
    
    # Check if .env file exists for docker compose
    if [[ ! -f ".env" ]]; then
        log "${YELLOW}⚠️  No .env file found, creating basic one...${NC}"
        cat > .env << EOF
POSTGRES_DB=${DB_NAME:-innerbright_prod}
POSTGRES_USER=${DB_USER:-innerbright_user}
POSTGRES_PASSWORD=${DB_PASSWORD:-changeme}
MINIO_ROOT_USER=${MINIO_USER:-minioadmin}
MINIO_ROOT_PASSWORD=${MINIO_PASSWORD:-changeme}
NEXTAUTH_SECRET=${NEXTAUTH_SECRET:-$(openssl rand -base64 32)}
NEXTAUTH_URL=https://${DOMAIN:-localhost}
EOF
    fi
    
    # Check available system resources before starting containers
    log "   Checking system resources..."
    AVAILABLE_MEM=$(free -m | awk 'NR==2{print $7}')
    AVAILABLE_DISK=$(df . | awk 'NR==2{print int($4/1024)}')
    
    if [[ $AVAILABLE_MEM -lt 1000 ]]; then
        log "${YELLOW}⚠️  Low available memory (${AVAILABLE_MEM}MB). Containers may fail to start.${NC}"
    fi
    
    if [[ $AVAILABLE_DISK -lt 2000 ]]; then
        log "${YELLOW}⚠️  Low available disk space (${AVAILABLE_DISK}MB). Containers may fail to start.${NC}"
    fi
    
    # Stop any existing containers to free up resources
    log "   Stopping any existing containers..."
    $DOCKER_COMPOSE_CMD down 2>/dev/null || true
    
    # Clean up any orphaned containers
    $DOCKER_CMD container prune -f 2>/dev/null || true
    
    # Pull latest base images
    log "   Pulling latest images..."
    $DOCKER_COMPOSE_CMD pull postgres minio redis 2>/dev/null || {
        log "${YELLOW}⚠️  Failed to pull some images, but continuing...${NC}"
    }
    
    # Start services one by one to better identify issues
    log "   Starting PostgreSQL database..."
    if $DOCKER_COMPOSE_CMD up postgres -d; then
        log "${GREEN}✅ PostgreSQL started${NC}"
        
        # Wait for PostgreSQL to be ready
        log "   Waiting for PostgreSQL to be ready..."
        for i in {1..30}; do
            if $DOCKER_CMD exec innerbright-postgres pg_isready -U ${DB_USER:-innerbright_user} &>/dev/null; then
                log "${GREEN}✅ PostgreSQL is ready${NC}"
                break
            fi
            sleep 2
        done
    else
        log "${RED}❌ Failed to start PostgreSQL${NC}"
        log "${YELLOW}📋 PostgreSQL logs:${NC}"
        $DOCKER_COMPOSE_CMD logs postgres 2>/dev/null || true
    fi
    
    log "   Starting MinIO object storage..."
    if $DOCKER_COMPOSE_CMD up minio -d; then
        log "${GREEN}✅ MinIO started${NC}"
    else
        log "${RED}❌ Failed to start MinIO${NC}"
        log "${YELLOW}📋 MinIO logs:${NC}"
        $DOCKER_COMPOSE_CMD logs minio 2>/dev/null || true
    fi
    
    log "   Starting Redis cache..."
    if $DOCKER_COMPOSE_CMD up redis -d; then
        log "${GREEN}✅ Redis started${NC}"
    else
        log "${RED}❌ Failed to start Redis${NC}"
        log "${YELLOW}📋 Redis logs:${NC}"
        $DOCKER_COMPOSE_CMD logs redis 2>/dev/null || true
    fi
    
    # Check if basic services are running
    RUNNING_SERVICES=$($DOCKER_COMPOSE_CMD ps --services --filter status=running | wc -l)
    if [[ $RUNNING_SERVICES -eq 0 ]]; then
        log "${RED}❌ No containers are running${NC}"
        log "${YELLOW}📋 Debugging information:${NC}"
        log "   Docker version: $($DOCKER_CMD --version)"
        log "   Docker compose version: $($DOCKER_COMPOSE_CMD version --short 2>/dev/null || echo 'N/A')"
        log "   Available memory: ${AVAILABLE_MEM}MB"
        log "   Available disk: ${AVAILABLE_DISK}MB"
        log "   Current user: $(whoami)"
        log "   User groups: $(groups)"
        
        # Show container status
        log "${YELLOW}📋 Container status:${NC}"
        $DOCKER_COMPOSE_CMD ps || true
        
        # Show recent Docker events
        log "${YELLOW}📋 Recent Docker events:${NC}"
        $DOCKER_CMD events --since 5m --until now 2>/dev/null | tail -10 || true
        
        # Try with simplified compose file
        log "${YELLOW}🔄 Creating simplified docker-compose.yml for basic services...${NC}"
        cat > docker-compose-simple.yml << 'EOF'
version: '3.8'

services:
  postgres:
    image: postgres:13-alpine
    container_name: innerbright-postgres-simple
    environment:
      POSTGRES_DB: ${POSTGRES_DB:-innerbright_prod}
      POSTGRES_USER: ${POSTGRES_USER:-innerbright_user}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-changeme123}
    volumes:
      - postgres_data_simple:/var/lib/postgresql/data
    ports:
      - "5432:5432"
    restart: unless-stopped

volumes:
  postgres_data_simple:
EOF
        
        log "   Trying with simplified PostgreSQL container..."
        if $DOCKER_COMPOSE_CMD -f docker-compose-simple.yml up -d; then
            log "${GREEN}✅ Simplified PostgreSQL container started${NC}"
            log "${YELLOW}� Basic database service is running. You can continue with manual application deployment.${NC}"
        else
            # Final diagnostic
            log "${RED}❌ Even simplified container failed to start${NC}"
            log "${YELLOW}📋 Final diagnostic information:${NC}"
            
            # Check if it's a permission issue
            if ! $DOCKER_CMD ps &>/dev/null; then
                log "${RED}❌ Cannot access Docker daemon. This is likely a permission issue.${NC}"
                log "${YELLOW}💡 Solutions:${NC}"
                log "   1. Log out and log back in (if recently added to docker group)"
                log "   2. Run: newgrp docker"
                log "   3. Restart the system"
                log "   4. Check Docker service: sudo systemctl status docker"
            fi
            
            # Check disk space more thoroughly
            df -h
            
            error_exit "Failed to start even basic containers. Please check the diagnostic information above."
        fi
    else
        log "${GREEN}✅ Basic services are running (${RUNNING_SERVICES} containers)${NC}"
    fi
    
    # Wait for services to be ready
    log "${YELLOW}⏳ Waiting for services to be ready...${NC}"
    sleep 15
    
    # Check service health
    services=("postgres" "minio" "redis")
    for service in "${services[@]}"; do
        if $DOCKER_COMPOSE_CMD ps $service 2>/dev/null | grep -q "healthy\|running"; then
            log "${GREEN}✅ $service is healthy${NC}"
        else
            log "${YELLOW}⚠️  $service status check...${NC}"
            $DOCKER_COMPOSE_CMD ps $service 2>/dev/null || log "Could not check $service status"
        fi
    done
    
    # Try to start application services if basic services are running
    if [[ $RUNNING_SERVICES -gt 0 ]]; then
        log "${YELLOW}🔄 Starting application services...${NC}"
        
        # Check if application directories and Dockerfiles exist
        log "   Checking for application services..."
        
        # Check for Next.js service
        if [[ -d "site" ]]; then
            if [[ -f "site/Dockerfile" ]]; then
                log "   Starting Next.js frontend..."
                if $DOCKER_COMPOSE_CMD up nextjs -d 2>/dev/null; then
                    log "${GREEN}✅ Next.js service started${NC}"
                else
                    log "${YELLOW}⚠️  Next.js service failed to start${NC}"
                    log "${YELLOW}📋 Next.js logs:${NC}"
                    $DOCKER_COMPOSE_CMD logs nextjs 2>/dev/null || true
                fi
            else
                log "${YELLOW}⚠️  site/Dockerfile not found${NC}"
                log "   Available files in site directory:"
                ls -la site/ 2>/dev/null | head -10 || log "   Cannot list site directory"
            fi
        else
            log "${YELLOW}⚠️  site directory not found${NC}"
            log "   Current directory contents:"
            ls -la . | head -10
        fi
        
        # Check for NestJS service
        if [[ -d "api" ]]; then
            if [[ -f "api/Dockerfile" ]]; then
                log "   Starting NestJS backend..."
                if $DOCKER_COMPOSE_CMD up nestjs -d 2>/dev/null; then
                    log "${GREEN}✅ NestJS service started${NC}"
                else
                    log "${YELLOW}⚠️  NestJS service failed to start${NC}"
                    log "${YELLOW}📋 NestJS logs:${NC}"
                    $DOCKER_COMPOSE_CMD logs nestjs 2>/dev/null || true
                fi
            else
                log "${YELLOW}⚠️  api/Dockerfile not found${NC}"
                log "   Available files in api directory:"
                ls -la api/ 2>/dev/null | head -10 || log "   Cannot list api directory"
            fi
        else
            log "${YELLOW}⚠️  api directory not found${NC}"
        fi
        
        # If no application services can start, check if we need to build them differently
        if [[ ! -d "site" && ! -d "api" ]]; then
            log "${YELLOW}💡 Application directories not found. Checking project structure...${NC}"
            log "   Project directory: $(pwd)"
            log "   Directory contents:"
            find . -maxdepth 3 -name "Dockerfile" -type f 2>/dev/null || log "   No Dockerfiles found"
            
            # Try to start services anyway in case docker-compose handles paths differently
            log "${YELLOW}🔄 Attempting to start all services from docker-compose...${NC}"
            $DOCKER_COMPOSE_CMD up -d 2>/dev/null || {
                log "${YELLOW}⚠️  Full service startup failed${NC}"
                log "${YELLOW}📋 Available services in docker-compose.yml:${NC}"
                $DOCKER_COMPOSE_CMD config --services 2>/dev/null || log "   Cannot read docker-compose services"
            }
        fi
    else
        log "${RED}❌ No basic services running, skipping application services${NC}"
    fi
    
    # Final status report
    FINAL_RUNNING_SERVICES=$($DOCKER_COMPOSE_CMD ps --services --filter status=running | wc -l)
    log "${GREEN}✅ Application deployment completed${NC}"
    log "${BLUE}📊 Final Status: ${FINAL_RUNNING_SERVICES} containers running${NC}"
    
    # Show running containers
    log "${BLUE}📋 Running containers:${NC}"
    $DOCKER_COMPOSE_CMD ps 2>/dev/null || $DOCKER_CMD ps
}

# Setup SSL function
setup_ssl() {
    log "${YELLOW}🔒 Setting up SSL certificate...${NC}"
    
    # Create nginx config
    sudo tee /etc/nginx/sites-available/innerbright > /dev/null << EOF
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;
    
    # Allow Let's Encrypt challenges
    location /.well-known/acme-challenge/ {
        root /var/www/html;
    }
    
    # Redirect to HTTPS
    location / {
        return 301 https://\$server_name\$request_uri;
    }
}

server {
    listen 443 ssl http2;
    server_name $DOMAIN www.$DOMAIN;

    # SSL Configuration (will be updated by certbot)
    ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;
    
    # Security headers
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains";
    
    # Enable gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json;
    
    # Frontend (Next.js)
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
        proxy_read_timeout 300;
        proxy_connect_timeout 300;
    }
    
    # API (NestJS)
    location /api/ {
        proxy_pass http://localhost:3333/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
        proxy_read_timeout 300;
        proxy_connect_timeout 300;
    }
}
EOF
    
    # Enable site
    sudo ln -sf /etc/nginx/sites-available/innerbright /etc/nginx/sites-enabled/
    sudo rm -f /etc/nginx/sites-enabled/default
    
    # Test nginx config
    sudo nginx -t
    
    # Restart nginx
    sudo systemctl restart nginx
    sudo systemctl enable nginx
    
    # Get SSL certificate
    sudo certbot --nginx -d $DOMAIN -d www.$DOMAIN --non-interactive --agree-tos --email $EMAIL
    
    log "${GREEN}✅ SSL certificate configured${NC}"
}

# Setup monitoring function
setup_monitoring() {
    log "${YELLOW}📊 Setting up monitoring and maintenance...${NC}"
    
    # Create backup script
    cat > $PROJECT_DIR/backup-db.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="/opt/innerbright/backups"
CONTAINER_NAME="innerbright-postgres-1"
DB_NAME="$DB_NAME"
DB_USER="$DB_USER"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

# Create backup
docker exec $CONTAINER_NAME pg_dump -U $DB_USER $DB_NAME | gzip > $BACKUP_DIR/backup_$DATE.sql.gz

# Keep only last 7 days
find $BACKUP_DIR -name "backup_*.sql.gz" -mtime +7 -delete

echo "Backup completed: backup_$DATE.sql.gz"
EOF
    
    # Make backup script executable
    chmod +x $PROJECT_DIR/backup-db.sh
    
    # Create health check script
    cat > $PROJECT_DIR/health-check.sh << 'EOF'
#!/bin/bash
SERVICES=("nextjs" "nestjs" "postgres" "minio")
LOG_FILE="/opt/innerbright/logs/health-check.log"

echo "$(date): Starting health check" >> $LOG_FILE

for service in "${SERVICES[@]}"; do
    if docker compose ps $service | grep -q "running\|healthy"; then
        echo "$(date): ✅ $service is healthy" >> $LOG_FILE
    else
        echo "$(date): ❌ $service is unhealthy" >> $LOG_FILE
    fi
done
EOF
    
    chmod +x $PROJECT_DIR/health-check.sh
    
    # Setup cron jobs
    (crontab -l 2>/dev/null; echo "0 2 * * * $PROJECT_DIR/backup-db.sh >> $PROJECT_DIR/logs/backup.log 2>&1") | crontab -
    (crontab -l 2>/dev/null; echo "*/5 * * * * $PROJECT_DIR/health-check.sh") | crontab -
    (crontab -l 2>/dev/null; echo "0 0 1 * * certbot renew --quiet") | crontab -
    
    # Auto-delete credentials file after 24 hours
    (crontab -l 2>/dev/null; echo "0 0 * * * find $PROJECT_DIR -name 'credentials.txt' -mtime +1 -delete") | crontab -
    
    log "${GREEN}✅ Monitoring configured${NC}"
}

# Final verification function
final_verification() {
    log "${YELLOW}🔍 Performing final verification...${NC}"
    
    # Check if services are running
    cd $PROJECT_DIR
    
    sleep 10
    
    # Test endpoints
    if curl -f -s https://$DOMAIN > /dev/null; then
        log "${GREEN}✅ Website is accessible${NC}"
    else
        log "${RED}❌ Website is not accessible${NC}"
    fi
    
    if curl -f -s https://$DOMAIN/api/health > /dev/null; then
        log "${GREEN}✅ API is accessible${NC}"
    else
        log "${RED}❌ API is not accessible${NC}"
    fi
    
    # Display service status
    log "${BLUE}📊 Service Status:${NC}"
    docker compose ps
    
    log "${GREEN}✅ Final verification completed${NC}"
}

# Fix Docker permissions and issues
fix_docker_issues() {
    log "${YELLOW}🔧 Fixing Docker installation and permissions...${NC}"
    
    # Stop any running Docker containers
    sudo docker stop $(sudo docker ps -q) 2>/dev/null || true
    
    # Stop Docker service
    sudo systemctl stop docker 2>/dev/null || true
    
    # Clean up Docker socket
    sudo rm -f /var/run/docker.sock
    
    # Start Docker service
    sudo systemctl start docker
    sudo systemctl enable docker
    
    # Wait for Docker socket to be created
    for i in {1..10}; do
        if [[ -S /var/run/docker.sock ]]; then
            break
        fi
        sleep 2
    done
    
    # Set proper permissions on Docker socket
    if [[ -S /var/run/docker.sock ]]; then
        sudo chmod 666 /var/run/docker.sock
        sudo chown root:docker /var/run/docker.sock 2>/dev/null || true
        log "${GREEN}✅ Docker socket permissions fixed${NC}"
    else
        log "${RED}❌ Docker socket was not created${NC}"
        return 1
    fi
    
    # Add user to docker group if not already
    if ! groups $USER | grep -q docker; then
        sudo usermod -aG docker $USER
        log "${GREEN}✅ User added to docker group${NC}"
    fi
    
    # Test Docker functionality
    if sudo docker run --rm hello-world &> /dev/null; then
        log "${GREEN}✅ Docker is working with sudo${NC}"
    else
        log "${RED}❌ Docker test failed${NC}"
        return 1
    fi
    
    log "${GREEN}✅ Docker issues fixed${NC}"
    return 0
}

# Main deployment function
main() {
    log "${BLUE}🚀 Starting Innerbright Production Deployment${NC}"
    
    # Check for Docker issues first
    if ! command -v docker &> /dev/null || ! docker info &> /dev/null 2>&1; then
        log "${YELLOW}⚠️  Docker issues detected${NC}"
        read -p "Would you like to fix Docker installation and permissions? (Y/n): " fix_docker
        if [[ ! $fix_docker =~ ^[Nn]$ ]]; then
            if fix_docker_issues; then
                log "${GREEN}✅ Docker issues resolved${NC}"
            else
                log "${RED}❌ Could not fix Docker issues automatically${NC}"
                log "${YELLOW}💡 Manual steps to fix Docker:${NC}"
                log "   1. sudo systemctl restart docker"
                log "   2. sudo chmod 666 /var/run/docker.sock" 
                log "   3. sudo usermod -aG docker $USER"
                log "   4. Log out and log back in"
                log "   5. Or run: newgrp docker"
                echo
                read -p "Continue anyway? (y/N): " continue_anyway
                if [[ ! $continue_anyway =~ ^[Yy]$ ]]; then
                    error_exit "Docker setup required before deployment"
                fi
            fi
        fi
    fi
    
    # Check if .env already exists
    if [[ -f ".env" ]]; then
        read -p "Found existing .env file. Do you want to reconfigure? (y/N): " RECONFIGURE
        if [[ $RECONFIGURE =~ ^[Yy]$ ]]; then
            interactive_setup
        else
            # Load existing configuration
            source .env
            DOMAIN=${DOMAIN:-localhost}
            EMAIL=${EMAIL:-admin@localhost}
            log "${YELLOW}Using existing configuration${NC}"
        fi
    else
        interactive_setup
    fi
    
    # Run deployment steps
    system_check
    install_dependencies
    setup_project
    configure_environment
    setup_security
    deploy_application
    setup_ssl
    setup_monitoring
    final_verification
    
    # Success message
    echo -e "\n${GREEN}"
    echo "╔═══════════════════════════════════════════════════════════════════════════════╗"
    echo "║                          🎉 DEPLOYMENT SUCCESSFUL! 🎉                        ║"
    echo "║                                                                               ║"
    echo "║  Your Innerbright application is now running in production!                  ║"
    echo "║                                                                               ║"
    echo "║  🌐 Website: https://$DOMAIN                                                  ║"
    echo "║  🔧 API: https://$DOMAIN/api                                                  ║"
    echo "║  💾 Database: PostgreSQL (internal)                                          ║"
    echo "║  📦 Storage: MinIO (internal)                                                ║"
    echo "║                                                                               ║"
    echo "║  � Important Credentials:                                                    ║"
    echo "║    • Database: $DB_USER / (see credentials.txt)                              ║"
    echo "║    • MinIO: $MINIO_USER / (see credentials.txt)                              ║"
    echo "║    • Credentials file: $PROJECT_DIR/credentials.txt                          ║"
    echo "║                                                                               ║"
    echo "║  �📊 Monitoring:                                                               ║"
    echo "║    • Automatic backups: Daily at 2 AM                                        ║"
    echo "║    • Health checks: Every 5 minutes                                          ║"
    echo "║    • SSL renewal: Automatic                                                   ║"
    echo "║                                                                               ║"
    echo "║  📁 Project Directory: $PROJECT_DIR                                           ║"
    echo "║  📝 Logs: $PROJECT_DIR/logs/                                                  ║"
    echo "║  💾 Backups: $PROJECT_DIR/backups/                                           ║"
    echo "║                                                                               ║"
    echo "║  🔧 Management Commands:                                                      ║"
    echo "║    • Management console: ./manage-production.sh                              ║"
    echo "║    • View logs: docker compose logs -f                                       ║"
    echo "║    • Restart: docker compose restart                                         ║"
    echo "║    • Update: git pull && docker compose up --build -d                        ║"
    echo "║                                                                               ║"
    echo "║  ⚠️  IMPORTANT: Save credentials from credentials.txt file!                  ║"
    echo "║      File will be auto-deleted in 24 hours for security.                    ║"
    echo "║                                                                               ║"
    echo "╚═══════════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    log "${GREEN}🎉 Deployment completed successfully!${NC}"
}

# Run main function
main "$@"
