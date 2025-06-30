#!/bin/bash

# KataCore Cloud Deployment Script - Clean Version
# Deploy to any cloud server with automatic setup

set -e

# Configuration
SERVER_HOST=${SERVER_HOST}
SERVER_USER=${SERVER_USER:-"root"}
SERVER_PORT=${SERVER_PORT:-"22"}
DEPLOY_PATH=${DEPLOY_PATH:-"/opt/katacore"}
PROJECT_NAME="katacore"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
    exit 1
}

# Usage
show_usage() {
    echo "KataCore Cloud Deployment"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --server HOST     Server IP/hostname (required)"
    echo "  --user USER       SSH user (default: root)"
    echo "  --port PORT       SSH port (default: 22)"
    echo "  --path PATH       Deploy path (default: /opt/katacore)"
    echo "  --help           Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 --server 1.2.3.4"
    echo "  $0 --server myserver.com --user ubuntu --port 2222"
    echo ""
    echo "Environment variables:"
    echo "  SERVER_HOST, SERVER_USER, SERVER_PORT, DEPLOY_PATH"
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --server)
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
        --help)
            show_usage
            exit 0
            ;;
        *)
            error "Unknown option: $1"
            ;;
    esac
done

# Validate requirements
if [[ -z "$SERVER_HOST" ]]; then
    error "Server host is required. Use --server or set SERVER_HOST"
fi

log "🚀 Starting KataCore deployment to $SERVER_HOST"
log "👤 User: $SERVER_USER"
log "🔌 Port: $SERVER_PORT"  
log "📁 Path: $DEPLOY_PATH"

# Test SSH connection
log "🔐 Testing SSH connection..."
if ! ssh -p "$SERVER_PORT" -o ConnectTimeout=10 -o BatchMode=yes "$SERVER_USER@$SERVER_HOST" "echo 'SSH OK'" 2>/dev/null; then
    error "Cannot connect to $SERVER_USER@$SERVER_HOST:$SERVER_PORT"
fi
success "SSH connection verified"

# Check local files
log "📋 Checking local files..."
REQUIRED_FILES=("docker-compose.yml" "docker-compose.prod.yml" "package.json")
for file in "${REQUIRED_FILES[@]}"; do
    if [[ ! -f "$file" ]]; then
        error "Required file not found: $file"
    fi
done
success "Local files verified"

# Create remote directory
log "📁 Creating deployment directory..."
ssh -p "$SERVER_PORT" "$SERVER_USER@$SERVER_HOST" "mkdir -p $DEPLOY_PATH"

# Upload project files
log "📤 Uploading project files..."
rsync -avz --progress \
    --exclude='.git' \
    --exclude='node_modules' \
    --exclude='logs' \
    --exclude='backups' \
    --exclude='backup_*' \
    --exclude='tmp' \
    --exclude='*.log' \
    --exclude='.env*' \
    -e "ssh -p $SERVER_PORT" \
    ./ "$SERVER_USER@$SERVER_HOST:$DEPLOY_PATH/"

success "Files uploaded successfully"

# Deploy on remote server
log "🚀 Executing deployment on remote server..."
ssh -p "$SERVER_PORT" "$SERVER_USER@$SERVER_HOST" << EOF
set -e
cd $DEPLOY_PATH

echo "📍 Working in: \$(pwd)"

# Install system dependencies
echo "📦 Installing system dependencies..."
if command -v apt-get &> /dev/null; then
    apt-get update
    apt-get install -y curl git openssl
elif command -v yum &> /dev/null; then
    yum update -y
    yum install -y curl git openssl
fi

# Install Docker
echo "🐳 Installing Docker..."
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com | sh
    systemctl enable docker
    systemctl start docker
else
    echo "✅ Docker already installed"
fi

# Start Docker if not running
if ! systemctl is-active --quiet docker; then
    systemctl start docker
fi

# Determine Docker Compose command
if docker compose version &> /dev/null 2>&1; then
    COMPOSE_CMD="docker compose"
elif command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
else
    echo "❌ No Docker Compose found"
    exit 1
fi

# Check Docker permissions
if ! docker ps &> /dev/null; then
    if sudo docker ps &> /dev/null; then
        COMPOSE_CMD="sudo \$COMPOSE_CMD"
        echo "⚠️  Using sudo for Docker commands"
    else
        echo "❌ Cannot access Docker"
        exit 1
    fi
fi

echo "🐳 Using: \$COMPOSE_CMD"

# Create environment file
echo "📝 Creating environment file..."
if [[ ! -f ".env.prod" ]]; then
    cat > .env.prod << 'ENVEOF'
NODE_ENV=production
POSTGRES_DB=$PROJECT_NAME
POSTGRES_USER=postgres
POSTGRES_PASSWORD=secure_password_change_me
REDIS_PASSWORD=redis_password_change_me
JWT_SECRET=your_super_secret_jwt_key_change_me
CORS_ORIGIN=*
NEXT_PUBLIC_API_URL=http://localhost:3001
MINIO_ROOT_USER=admin
MINIO_ROOT_PASSWORD=minio_password_change_me
PGADMIN_EMAIL=admin@katacore.com
PGADMIN_PASSWORD=admin123
ENVEOF
    echo "✅ Created .env.prod - Please update passwords!"
fi

# Create necessary directories
echo "📁 Creating directories..."
mkdir -p ssl logs backups nginx/logs

# Generate SSL certificates (self-signed for now)
if [[ ! -f "ssl/fullchain.pem" ]]; then
    echo "🔒 Generating SSL certificates..."
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout ssl/privkey.pem \
        -out ssl/fullchain.pem \
        -subj "/C=US/ST=State/L=City/O=KataCore/CN=\$(hostname)" 2>/dev/null || true
fi

# Deploy with Docker Compose
echo "🔨 Building and starting services..."
COMPOSE_FILE="\$(pwd)/docker-compose.prod.yml"

# Stop existing containers
\$COMPOSE_CMD -f "\$COMPOSE_FILE" down || true

# Build and start
\$COMPOSE_CMD -f "\$COMPOSE_FILE" build --no-cache
\$COMPOSE_CMD -f "\$COMPOSE_FILE" up -d

# Show status
echo "📊 Service status:"
\$COMPOSE_CMD -f "\$COMPOSE_FILE" ps

echo "✅ Deployment completed!"
EOF

if [[ $? -eq 0 ]]; then
    success "🎉 Deployment successful!"
    log "🌐 Access your application at: http://$SERVER_HOST"
    log "📊 Check status: ssh $SERVER_USER@$SERVER_HOST 'cd $DEPLOY_PATH && docker compose ps'"
else
    error "❌ Deployment failed!"
fi
