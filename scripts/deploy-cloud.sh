#!/bin/bash

# KataCore Production Deployment Script for Cloud Server
# This script deploys the application to a remote cloud server or locally

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
ENV_FILE="${PROJECT_DIR}/.env.prod"

# Remote deployment configuration
SERVER_USER=${SERVER_USER:-"root"}
SERVER_HOST=${SERVER_HOST}
SERVER_PORT=${SERVER_PORT:-"22"}
DEPLOY_PATH=${DEPLOY_PATH:-"/opt/katacore"}
GIT_REPO=${GIT_REPO:-"https://github.com/KataChannel/KataCore.git"}
GIT_BRANCH=${GIT_BRANCH:-"main"}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
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

# Usage function
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --local                Deploy locally (default if no SERVER_HOST set)"
    echo "  --remote               Deploy to remote server (requires SERVER_HOST)"
    echo "  --help                 Show this help message"
    echo ""
    echo "Environment Variables:"
    echo "  SERVER_HOST           Remote server IP/hostname"
    echo "  SERVER_USER           Remote server user (default: root)"
    echo "  SERVER_PORT           SSH port (default: 22)"
    echo "  DEPLOY_PATH           Remote deployment path (default: /opt/katacore)"
    echo "  GIT_REPO              Git repository URL"
    echo "  GIT_BRANCH            Git branch to deploy (default: main)"
    echo ""
    echo "Examples:"
    echo "  ./scripts/deploy-cloud.sh --local"
    echo "  SERVER_HOST=192.168.1.100 ./scripts/deploy-cloud.sh --remote"
    echo "  SERVER_HOST=myserver.com SERVER_USER=deploy ./scripts/deploy-cloud.sh --remote"
}

# Local deployment function
deploy_local() {
    log "🏠 Starting local production deployment..."
    
    # Check if environment file exists
    if [ ! -f "$ENV_FILE" ]; then
        error "Production environment file not found: $ENV_FILE"
    fi

    # Load environment variables
    source "$ENV_FILE"

    # Navigate to project directory
    cd "$PROJECT_DIR"

    # Check prerequisites
    log "🔍 Checking prerequisites..."
    
    if ! command -v docker &> /dev/null; then
        error "Docker is not installed. Please install Docker first."
    fi

    if ! command -v docker-compose &> /dev/null; then
        error "Docker Compose is not installed. Please install Docker Compose first."
    fi

    success "Prerequisites check passed"

    # Pull latest code
    if [ -d ".git" ]; then
        log "📥 Pulling latest code..."
        git pull origin main || git pull origin master || warning "Failed to pull latest code"
    fi

    # Build and deploy
    log "🔨 Building Docker images..."
    docker-compose -f docker-compose.prod.yml build --no-cache

    log "🛑 Stopping existing containers..."
    docker-compose -f docker-compose.prod.yml down || true

    log "🧹 Cleaning up Docker resources..."
    docker system prune -f || true

    # Create directories
    log "📁 Creating necessary directories..."
    mkdir -p ssl backups nginx/logs

    # Handle SSL certificates
    if [ ! -f "ssl/fullchain.pem" ] || [ ! -f "ssl/privkey.pem" ]; then
        warning "SSL certificates not found. Creating self-signed certificates for testing..."
        mkdir -p ssl
        openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
            -keyout ssl/privkey.pem \
            -out ssl/fullchain.pem \
            -subj "/C=US/ST=State/L=City/O=Organization/CN=${DOMAIN:-localhost}"
    fi

    # Start services
    log "🚀 Starting production services..."
    
    # Start databases first
    docker-compose -f docker-compose.prod.yml up -d postgres redis minio
    
    log "⏳ Waiting for databases..."
    sleep 30
    
    # Run migrations
    log "🗃️  Running database migrations..."
    docker-compose -f docker-compose.prod.yml up prisma-migrate
    
    # Start app services
    log "🌐 Starting application services..."
    docker-compose -f docker-compose.prod.yml up -d api site nginx

    # Health checks
    log "🏥 Performing health checks..."
    sleep 30

    # Final status
    docker-compose -f docker-compose.prod.yml ps
    
    success "Local deployment completed! 🎉"
    log "Access the application at: http://localhost (or https if SSL configured)"
}

# Remote deployment function
deploy_remote() {
    log "☁️ Starting remote deployment to $SERVER_USER@$SERVER_HOST..."

    if [[ -z "$SERVER_HOST" ]]; then
        error "SERVER_HOST must be set for remote deployment"
    fi

    # Test SSH connection
    log "🔐 Testing SSH connection..."
    if ! ssh -p "$SERVER_PORT" -o ConnectTimeout=10 "$SERVER_USER@$SERVER_HOST" "echo 'SSH connection successful'"; then
        error "Cannot connect to $SERVER_USER@$SERVER_HOST:$SERVER_PORT"
    fi
    success "SSH connection verified"

    # Upload deployment files
    log "📤 Uploading deployment files..."
    
    # Create remote directory
    ssh -p "$SERVER_PORT" "$SERVER_USER@$SERVER_HOST" "mkdir -p $DEPLOY_PATH"
    
    # Upload project files
    rsync -avz -e "ssh -p $SERVER_PORT" \
        --exclude='.git' \
        --exclude='node_modules' \
        --exclude='.env*' \
        --exclude='*.log' \
        "$PROJECT_DIR/" "$SERVER_USER@$SERVER_HOST:$DEPLOY_PATH/"

    # Upload environment file if exists
    if [ -f "$ENV_FILE" ]; then
        scp -P "$SERVER_PORT" "$ENV_FILE" "$SERVER_USER@$SERVER_HOST:$DEPLOY_PATH/.env.prod"
    fi

    # Execute remote deployment
    log "🚀 Executing remote deployment..."
    
    ssh -p "$SERVER_PORT" "$SERVER_USER@$SERVER_HOST" << EOF
        set -e
        cd $DEPLOY_PATH
        
        echo "📦 Installing Docker if not present..."
        if ! command -v docker &> /dev/null; then
            curl -fsSL https://get.docker.com -o get-docker.sh
            sh get-docker.sh
            systemctl enable docker
            systemctl start docker
        fi
        
        if ! command -v docker-compose &> /dev/null; then
            curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-\$(uname -s)-\$(uname -m)" -o /usr/local/bin/docker-compose
            chmod +x /usr/local/bin/docker-compose
        fi
        
        echo "🔨 Building and starting services..."
        docker-compose -f docker-compose.prod.yml down || true
        docker-compose -f docker-compose.prod.yml build --no-cache
        
        # Create necessary directories
        mkdir -p ssl backups nginx/logs
        
        # Create self-signed SSL certificates if not exist
        if [ ! -f "ssl/fullchain.pem" ]; then
            openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
                -keyout ssl/privkey.pem \
                -out ssl/fullchain.pem \
                -subj "/C=US/ST=State/L=City/O=Organization/CN=\$(hostname)"
        fi
        
        # Start services
        docker-compose -f docker-compose.prod.yml up -d postgres redis minio
        sleep 30
        docker-compose -f docker-compose.prod.yml up prisma-migrate
        docker-compose -f docker-compose.prod.yml up -d api site nginx
        
        echo "✅ Remote deployment completed!"
        docker-compose -f docker-compose.prod.yml ps
EOF

    success "Remote deployment completed! 🎉"
    log "Access the application at: http://$SERVER_HOST"
}

# Parse command line arguments
DEPLOY_TYPE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --local)
            DEPLOY_TYPE="local"
            shift
            ;;
        --remote)
            DEPLOY_TYPE="remote"
            shift
            ;;
        --help|-h)
            show_usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Determine deployment type
if [[ -z "$DEPLOY_TYPE" ]]; then
    if [[ -n "$SERVER_HOST" ]]; then
        DEPLOY_TYPE="remote"
    else
        DEPLOY_TYPE="local"
    fi
fi

# Execute deployment
case $DEPLOY_TYPE in
    "local")
        deploy_local
        ;;
    "remote")
        deploy_remote
        ;;
    *)
        error "Invalid deployment type: $DEPLOY_TYPE"
        ;;
esac
    exit 1
fi

echo "🎯 Deploying to: $SERVER_USER@$SERVER_HOST:$DEPLOY_PATH"

# Build locally first
echo "🔨 Building locally..."
bun run install:all
./test-build.sh

# Create deployment script for the server
cat > /tmp/deploy-server.sh << 'EOF'
#!/bin/bash
set -e

echo "🖥️ Starting server deployment..."

# Update system
echo "📦 Updating system packages..."
apt-get update
apt-get install -y curl git docker.io docker-compose-plugin

# Start Docker service
systemctl start docker
systemctl enable docker

# Install Bun if not installed
if ! command -v bun &> /dev/null; then
    echo "📥 Installing Bun..."
    curl -fsSL https://bun.sh/install | bash
    export PATH="$HOME/.bun/bin:$PATH"
fi

# Clone or update repository
if [ -d "$DEPLOY_PATH" ]; then
    echo "🔄 Updating existing repository..."
    cd $DEPLOY_PATH
    git fetch origin
    git reset --hard origin/$GIT_BRANCH
else
    echo "📥 Cloning repository..."
    git clone -b $GIT_BRANCH $GIT_REPO $DEPLOY_PATH
    cd $DEPLOY_PATH
fi

# Set proper permissions
chown -R $USER:$USER $DEPLOY_PATH
chmod +x scripts/*.sh

# Install dependencies
echo "📦 Installing dependencies..."
export PATH="$HOME/.bun/bin:$PATH"
bun install

# Build applications
echo "🏗️ Building applications..."
cd api && bun install && cd ..
cd site && bun install && cd ..

# Stop existing containers
echo "🛑 Stopping existing containers..."
docker compose down --remove-orphans || true

# Build and start containers
echo "🚀 Starting Docker containers..."
docker compose up -d --build

# Wait for services
echo "⏳ Waiting for services to start..."
sleep 60

# Check health
echo "🔍 Checking service health..."
docker compose ps

echo "✅ Cloud deployment completed!"
echo "🌐 Your application should be available at: http://$SERVER_HOST"

EOF

# Copy deployment script to server and execute
echo "📤 Uploading and executing deployment script..."
scp -P $SERVER_PORT /tmp/deploy-server.sh $SERVER_USER@$SERVER_HOST:/tmp/

ssh -p $SERVER_PORT $SERVER_USER@$SERVER_HOST "
    export DEPLOY_PATH='$DEPLOY_PATH'
    export GIT_REPO='$GIT_REPO'  
    export GIT_BRANCH='$GIT_BRANCH'
    chmod +x /tmp/deploy-server.sh
    /tmp/deploy-server.sh
"

# Clean up
rm /tmp/deploy-server.sh

echo ""
echo "🎉 Cloud deployment completed successfully!"
echo ""
echo "📍 Access your application:"
echo "  🌐 Frontend:      http://$SERVER_HOST"
echo "  🔌 API:           http://$SERVER_HOST/api"
echo "  🏥 Health Check:  http://$SERVER_HOST/health"
echo "  🛠️  pgAdmin:       http://$SERVER_HOST:8080"
echo "  📦 MinIO Console: http://$SERVER_HOST:9001"
echo ""
echo "🔧 Server Management:"
echo "  📊 View logs:     ssh $SERVER_USER@$SERVER_HOST 'cd $DEPLOY_PATH && docker compose logs -f'"
echo "  🔄 Restart:       ssh $SERVER_USER@$SERVER_HOST 'cd $DEPLOY_PATH && docker compose restart'"
echo "  🛑 Stop:          ssh $SERVER_USER@$SERVER_HOST 'cd $DEPLOY_PATH && docker compose down'"
echo ""
