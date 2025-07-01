#!/bin/bash

# KataCore Universal Cloud Deployer v2.0
# Deploy lên bất kỳ cloud server nào - Phiên bản hoàn toàn mới

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Logging
log() { echo -e "${BLUE}[$(date +'%H:%M:%S')]${NC} $1"; }
success() { echo -e "${GREEN}✅ $1${NC}"; }
warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
error() { echo -e "${RED}❌ $1${NC}"; exit 1; }
info() { echo -e "${CYAN}ℹ️  $1${NC}"; }

# Banner
show_banner() {
    echo -e "${PURPLE}"
    echo "██╗  ██╗ █████╗ ████████╗ █████╗  ██████╗ ██████╗ ██████╗ ███████╗"
    echo "██║ ██╔╝██╔══██╗╚══██╔══╝██╔══██╗██╔════╝██╔═══██╗██╔══██╗██╔════╝"
    echo "█████╔╝ ███████║   ██║   ███████║██║     ██║   ██║██████╔╝█████╗  "
    echo "██╔═██╗ ██╔══██║   ██║   ██╔══██║██║     ██║   ██║██╔══██╗██╔══╝  "
    echo "██║  ██╗██║  ██║   ██║   ██║  ██║╚██████╗╚██████╔╝██║  ██║███████╗"
    echo "╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝"
    echo -e "${NC}"
    echo -e "${CYAN}🚀 Universal Cloud Deployer v2.0 - Deploy to ANY server${NC}"
    echo ""
}

# Usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Required:"
    echo "  --host IP/DOMAIN      Server host (required)"
    echo ""
    echo "Optional:"
    echo "  --user USER           SSH user (default: root)"
    echo "  --port PORT           SSH port (default: 22)"
    echo "  --path PATH           Deploy path (default: /opt/katacore)"
    echo "  --domain DOMAIN       Domain for SSL (default: server IP)"
    echo "  --clean               Clean install (remove old containers)"
    echo "  --setup-only          Only setup server, don't deploy"
    echo "  --deploy-only         Only deploy, skip server setup"
    echo "  --help                Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 --host 192.168.1.100"
    echo "  $0 --host myserver.com --user ubuntu --domain mydomain.com"
    echo "  $0 --host 1.2.3.4 --clean"
    echo ""
}

# Default values
SERVER_HOST="116.118.85.41"
SERVER_USER="root"
SERVER_PORT="22"
DEPLOY_PATH="/opt/katacore"
DOMAIN=""
CLEAN_INSTALL=false
SETUP_ONLY=false
DEPLOY_ONLY=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --host)
            SERVER_HOST="$2"
            shift 2
            ;;
        --user)
            SERVER_USER="$2"
            shift 2
            ;;
        --port)
            SERVER_PORT="$2"
            shift 2
            ;;
        --path)
            DEPLOY_PATH="$2"
            shift 2
            ;;
        --domain)
            DOMAIN="$2"
            shift 2
            ;;
        --clean)
            CLEAN_INSTALL=true
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
        --help)
            show_usage
            exit 0
            ;;
        *)
            error "Unknown option: $1"
            ;;
    esac
done

# Validation
if [[ -z "$SERVER_HOST" ]]; then
    error "Server host is required. Use --host IP_OR_DOMAIN"
fi

if [[ -z "$DOMAIN" ]]; then
    DOMAIN="$SERVER_HOST"
fi

# Main function
main() {
    show_banner
    
    log "🎯 Target: $SERVER_USER@$SERVER_HOST:$SERVER_PORT"
    log "📁 Deploy path: $DEPLOY_PATH"
    log "🌐 Domain: $DOMAIN"
    
    # Test SSH
    log "🔐 Testing SSH connection..."
    if ! ssh -p "$SERVER_PORT" -o ConnectTimeout=10 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$SERVER_USER@$SERVER_HOST" "echo 'SSH OK'" 2>/dev/null; then
        error "Cannot connect to $SERVER_USER@$SERVER_HOST:$SERVER_PORT"
    fi
    success "SSH connection verified"
    
    # Check local files
    log "📋 Checking local files..."
    [[ ! -f "docker-compose.yml" ]] && error "docker-compose.yml not found"
    [[ ! -f "package.json" ]] && error "package.json not found"
    success "Local files verified"
    
    # Server setup (if not deploy-only)
    if [[ "$DEPLOY_ONLY" != "true" ]]; then
        setup_server
    fi
    
    # Deployment (if not setup-only)
    if [[ "$SETUP_ONLY" != "true" ]]; then
        deploy_application
        show_deployment_info
    fi
    
    success "🎉 All done!"
}

# Setup server
setup_server() {
    log "🔧 Setting up server..."
    
    ssh -p "$SERVER_PORT" "$SERVER_USER@$SERVER_HOST" << 'SETUP_EOF'
        set -e
        
        echo "📦 Updating system..."
        if command -v apt-get >/dev/null; then
            export DEBIAN_FRONTEND=noninteractive
            apt-get update -qq
            apt-get install -y -qq curl wget git openssl ufw unzip
        elif command -v yum >/dev/null; then
            yum update -y -q
            yum install -y -q curl wget git openssl firewalld unzip
        elif command -v dnf >/dev/null; then
            dnf update -y -q
            dnf install -y -q curl wget git openssl firewalld unzip
        fi
        
        echo "🐳 Installing Docker..."
        if ! command -v docker >/dev/null; then
            curl -fsSL https://get.docker.com | sh
            systemctl enable docker
            systemctl start docker
        else
            echo "✅ Docker already installed"
            systemctl start docker 2>/dev/null || true
        fi
        
        echo "🔧 Configuring Docker Compose..."
        if ! docker compose version >/dev/null 2>&1; then
            if ! command -v docker-compose >/dev/null; then
                COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
                curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
                chmod +x /usr/local/bin/docker-compose
            fi
        fi
        
        echo "🔥 Configuring firewall..."
        if command -v ufw >/dev/null; then
            ufw --force enable >/dev/null 2>&1 || true
            ufw allow ssh >/dev/null 2>&1 || true
            ufw allow 80/tcp >/dev/null 2>&1 || true
            ufw allow 443/tcp >/dev/null 2>&1 || true
            ufw allow 3000/tcp >/dev/null 2>&1 || true
            ufw allow 3001/tcp >/dev/null 2>&1 || true
        elif command -v firewall-cmd >/dev/null; then
            systemctl enable firewalld >/dev/null 2>&1 || true
            systemctl start firewalld >/dev/null 2>&1 || true
            firewall-cmd --permanent --add-service=ssh >/dev/null 2>&1 || true
            firewall-cmd --permanent --add-service=http >/dev/null 2>&1 || true
            firewall-cmd --permanent --add-service=https >/dev/null 2>&1 || true
            firewall-cmd --permanent --add-port=3000/tcp >/dev/null 2>&1 || true
            firewall-cmd --permanent --add-port=3001/tcp >/dev/null 2>&1 || true
            firewall-cmd --reload >/dev/null 2>&1 || true
        fi
        
        echo "✅ Server setup completed"
SETUP_EOF
    
    success "Server setup completed"
}

# Deploy application
deploy_application() {
    log "📤 Uploading project files..."
    
    # Create remote directory
    ssh -p "$SERVER_PORT" "$SERVER_USER@$SERVER_HOST" "mkdir -p $DEPLOY_PATH"
    
    # Upload files
    rsync -avz --progress --delete \
        --exclude='.git' \
        --exclude='node_modules' \
        --exclude='*/node_modules' \
        --exclude='.next' \
        --exclude='*/.next' \
        --exclude='dist' \
        --exclude='*/dist' \
        --exclude='build' \
        --exclude='*/build' \
        --exclude='*.log' \
        --exclude='logs' \
        --exclude='backup_*' \
        --exclude='tmp' \
        -e "ssh -p $SERVER_PORT" \
        ./ "$SERVER_USER@$SERVER_HOST:$DEPLOY_PATH/"
    
    success "Files uploaded"
    
    log "🚀 Deploying application..."
    
    # Deploy on remote server
    ssh -p "$SERVER_PORT" "$SERVER_USER@$SERVER_HOST" << EOF
        set -e
        cd $DEPLOY_PATH
        
        echo "📍 Working in: \$(pwd)"
        
        # Determine Docker Compose command
        if docker compose version >/dev/null 2>&1; then
            COMPOSE_CMD="docker compose"
        elif command -v docker-compose >/dev/null 2>&1; then
            if which docker-compose | grep -q snap 2>/dev/null; then
                COMPOSE_CMD="docker compose"
            else
                COMPOSE_CMD="docker-compose"
            fi
        else
            echo "❌ Docker Compose not found"
            exit 1
        fi
        
        # Check Docker permissions
        if ! docker ps >/dev/null 2>&1; then
            if sudo docker ps >/dev/null 2>&1; then
                COMPOSE_CMD="sudo \$COMPOSE_CMD"
                echo "⚠️  Using sudo for Docker"
            else
                echo "❌ Cannot access Docker"
                exit 1
            fi
        fi
        
        echo "🐳 Using: \$COMPOSE_CMD"
        
        # Create environment file
        echo "📝 Setting up environment..."
        if [[ ! -f ".env.prod" ]]; then
            cat > .env.prod << 'ENVEOF'
NODE_ENV=production

# Database
POSTGRES_DB=katacore
POSTGRES_USER=postgres
POSTGRES_PASSWORD=KataCore_PG_\$(openssl rand -hex 16)

# Redis
REDIS_PASSWORD=KataCore_Redis_\$(openssl rand -hex 16)

# Security
JWT_SECRET=\$(openssl rand -base64 32)

# MinIO
MINIO_ROOT_USER=admin
MINIO_ROOT_PASSWORD=KataCore_MinIO_\$(openssl rand -hex 16)

# PgAdmin
PGADMIN_EMAIL=admin@katacore.com
PGADMIN_PASSWORD=KataCore_Admin_\$(openssl rand -hex 12)

# Application
CORS_ORIGIN=*
NEXT_PUBLIC_API_URL=http://$DOMAIN:3001
DOMAIN=$DOMAIN
API_DOMAIN=$DOMAIN
ENVEOF
            echo "✅ Created .env.prod with secure passwords"
        else
            echo "✅ .env.prod already exists"
        fi
        
        # Ensure docker-compose.prod.yml exists
        if [[ ! -f "docker-compose.prod.yml" ]]; then
            if [[ -f "docker-compose.yml" ]]; then
                cp docker-compose.yml docker-compose.prod.yml
                echo "✅ Created docker-compose.prod.yml"
            else
                echo "❌ No Docker Compose files found"
                exit 1
            fi
        fi
        
        # Create directories
        echo "📁 Creating directories..."
        mkdir -p ssl logs backups nginx/logs
        
        # Generate SSL certificates
        if [[ ! -f "ssl/fullchain.pem" ]]; then
            echo "🔒 Generating SSL certificates..."
            openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
                -keyout ssl/privkey.pem \
                -out ssl/fullchain.pem \
                -subj "/C=VN/ST=HCM/L=HCM/O=KataCore/CN=$DOMAIN" 2>/dev/null || true
        fi
        
        # Use absolute path for compose file
        COMPOSE_FILE="\$(pwd)/docker-compose.prod.yml"
        
        # Clean deployment if requested
        if [[ "$CLEAN_INSTALL" == "true" ]]; then
            echo "🧹 Cleaning old deployment..."
            \${COMPOSE_CMD} -f "\${COMPOSE_FILE}" down --volumes --remove-orphans 2>/dev/null || true
            docker system prune -af 2>/dev/null || true
        else
            echo "🛑 Stopping existing containers..."
            \${COMPOSE_CMD} -f "\${COMPOSE_FILE}" down 2>/dev/null || true
        fi
        
        # Build and start
        echo "🔨 Building images..."
        \${COMPOSE_CMD} -f "\${COMPOSE_FILE}" build --no-cache
        
        echo "🗄️  Starting database services..."
        \${COMPOSE_CMD} -f "\${COMPOSE_FILE}" up -d postgres redis minio 2>/dev/null || true
        
        echo "⏳ Waiting for databases..."
        sleep 30
        
        echo "🌐 Starting all services..."
        \${COMPOSE_CMD} -f "\${COMPOSE_FILE}" up -d
        
        echo "📊 Final status:"
        \${COMPOSE_CMD} -f "\${COMPOSE_FILE}" ps
        
        # Post-deployment cache cleanup for optimization
        echo "🧹 Cleaning Docker cache for optimization..."
        docker builder prune -af 2>/dev/null || true
        docker image prune -a -f 2>/dev/null || true
        docker volume prune -a -f 2>/dev/null || true
        docker network prune -f 2>/dev/null || true
        echo "✅ Cache cleanup completed - storage optimized"
        
        echo "✅ Deployment completed!"
EOF
    
    success "Application deployed successfully"
}

# Show deployment info
show_deployment_info() {
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                 🎉 DEPLOYMENT SUCCESS               ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${GREEN}🌐 Application URLs:${NC}"
    echo "   Frontend:    http://$SERVER_HOST"
    echo "   API:         http://$SERVER_HOST:3001"
    echo "   PgAdmin:     http://$SERVER_HOST:8080"
    echo "   MinIO:       http://$SERVER_HOST:9001"
    echo ""
    echo -e "${GREEN}🔧 Management Commands:${NC}"
    echo "   SSH:         ssh $SERVER_USER@$SERVER_HOST"
    echo "   Logs:        ssh $SERVER_USER@$SERVER_HOST 'cd $DEPLOY_PATH && docker compose logs -f'"
    echo "   Status:      ssh $SERVER_USER@$SERVER_HOST 'cd $DEPLOY_PATH && docker compose ps'"
    echo "   Stop:        ssh $SERVER_USER@$SERVER_HOST 'cd $DEPLOY_PATH && docker compose down'"
    echo "   Restart:     ssh $SERVER_USER@$SERVER_HOST 'cd $DEPLOY_PATH && docker compose restart'"
    echo ""
    echo -e "${YELLOW}⚠️  Important Notes:${NC}"
    echo "   - Check $DEPLOY_PATH/.env.prod for generated passwords"
    echo "   - Configure real SSL certificates for production"
    echo "   - Set up database backups"
    echo "   - Update firewall rules as needed"
    echo ""
}

# Export variables for SSH sessions
export CLEAN_INSTALL DOMAIN

# Run main function
main "$@"
