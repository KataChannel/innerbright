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
    read -p "Enter your domain name (e.g., example.com): " DOMAIN
    if [[ -z "$DOMAIN" ]]; then
        error_exit "Domain name is required"
    fi
    
    # Email for SSL
    read -p "Enter your email for SSL certificate: " EMAIL
    if [[ -z "$EMAIL" ]]; then
        error_exit "Email is required for SSL certificate"
    fi
    
    # Database configuration
    read -p "Enter PostgreSQL database name [innerbright_prod]: " DB_NAME
    DB_NAME=${DB_NAME:-innerbright_prod}
    
    read -p "Enter PostgreSQL username [innerbright_user]: " DB_USER
    DB_USER=${DB_USER:-innerbright_user}
    
    read -s -p "Enter PostgreSQL password: " DB_PASSWORD
    echo
    if [[ -z "$DB_PASSWORD" ]]; then
        error_exit "Database password is required"
    fi
    
    # NextAuth secret
    read -s -p "Enter NextAuth secret (32+ characters): " NEXTAUTH_SECRET
    echo
    if [[ ${#NEXTAUTH_SECRET} -lt 32 ]]; then
        error_exit "NextAuth secret must be at least 32 characters long"
    fi
    
    # MinIO configuration
    read -p "Enter MinIO admin username [minioadmin]: " MINIO_USER
    MINIO_USER=${MINIO_USER:-minioadmin}
    
    read -s -p "Enter MinIO admin password: " MINIO_PASSWORD
    echo
    if [[ -z "$MINIO_PASSWORD" ]]; then
        error_exit "MinIO password is required"
    fi
    
    # Optional services
    read -p "Enable PgAdmin? (y/N): " ENABLE_PGADMIN
    ENABLE_PGADMIN=${ENABLE_PGADMIN:-n}
    
    read -p "Enable Redis? (y/N): " ENABLE_REDIS
    ENABLE_REDIS=${ENABLE_REDIS:-n}
    
    echo -e "\n${GREEN}✅ Configuration completed!${NC}\n"
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
        curl -fsSL https://get.docker.com -o get-docker.sh
        sudo sh get-docker.sh
        sudo usermod -aG docker $USER
        rm get-docker.sh
    fi
    
    # Install Docker Compose if not present
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        log "${YELLOW}🐳 Installing Docker Compose...${NC}"
        sudo apt install -y docker-compose-plugin
    fi
    
    # Install Node.js (for debugging)
    if ! command -v node &> /dev/null; then
        log "${YELLOW}📦 Installing Node.js...${NC}"
        curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
        sudo apt-get install -y nodejs
    fi
    
    log "${GREEN}✅ Dependencies installed${NC}"
}

# Setup project function
setup_project() {
    log "${YELLOW}📁 Setting up project directory...${NC}"
    
    # Create project directory
    sudo mkdir -p $PROJECT_DIR
    sudo chown $USER:$USER $PROJECT_DIR
    
    # Create necessary directories
    cd $PROJECT_DIR
    mkdir -p data/postgres data/minio data/redis logs backups
    
    # Set proper permissions
    sudo chown -R 999:999 data/postgres
    sudo chown -R 1001:1001 data/minio
    chmod -R 755 data
    
    # Clone repository if not exists
    if [[ ! -f "docker-compose.yml" ]]; then
        log "${YELLOW}📥 Cloning repository...${NC}"
        read -p "Enter Git repository URL: " REPO_URL
        if [[ -n "$REPO_URL" ]]; then
            git clone $REPO_URL .
        else
            error_exit "Repository URL is required"
        fi
    fi
    
    # Make scripts executable
    chmod +x *.sh
    
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
    
    log "${GREEN}✅ Environment configured${NC}"
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
    
    # Pull latest base images
    docker compose pull postgres minio nginx redis 2>/dev/null || true
    
    # Build and start services
    docker compose up --build -d --remove-orphans
    
    # Wait for services to be ready
    log "${YELLOW}⏳ Waiting for services to be ready...${NC}"
    sleep 30
    
    # Check service health
    services=("postgres" "nextjs" "nestjs" "minio")
    for service in "${services[@]}"; do
        if docker compose ps $service | grep -q "healthy\|running"; then
            log "${GREEN}✅ $service is healthy${NC}"
        else
            log "${RED}❌ $service is not healthy${NC}"
        fi
    done
    
    log "${GREEN}✅ Application deployed${NC}"
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

# Main deployment function
main() {
    log "${BLUE}🚀 Starting Innerbright Production Deployment${NC}"
    
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
    echo "║  📊 Monitoring:                                                               ║"
    echo "║    • Automatic backups: Daily at 2 AM                                        ║"
    echo "║    • Health checks: Every 5 minutes                                          ║"
    echo "║    • SSL renewal: Automatic                                                   ║"
    echo "║                                                                               ║"
    echo "║  📁 Project Directory: $PROJECT_DIR                                           ║"
    echo "║  📝 Logs: $PROJECT_DIR/logs/                                                  ║"
    echo "║  💾 Backups: $PROJECT_DIR/backups/                                           ║"
    echo "║                                                                               ║"
    echo "║  🔧 Management Commands:                                                      ║"
    echo "║    • View logs: docker compose logs -f                                       ║"
    echo "║    • Restart: docker compose restart                                         ║"
    echo "║    • Update: git pull && docker compose up --build -d                        ║"
    echo "║                                                                               ║"
    echo "╚═══════════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    log "${GREEN}🎉 Deployment completed successfully!${NC}"
}

# Run main function
main "$@"
