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
SERVER_HOST=${SERVER_HOST:-"116.118.85.41"}
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

# Function to create docker-compose.prod.yml if missing
create_docker_compose_prod() {
    local compose_file="docker-compose.prod.yml"
    
    if [ -f "$compose_file" ]; then
        log "✅ $compose_file already exists"
        return 0
    fi
    
    log "📋 Creating $compose_file..."
    
    if [ -f "docker-compose.yml" ]; then
        log "📄 Copying from docker-compose.yml..."
        cp docker-compose.yml "$compose_file"
        success "Created $compose_file from docker-compose.yml"
    else
        log "🏗️  Creating production docker-compose.yml from template..."
        cat > "$compose_file" << 'EOF'
version: '3.8'

services:
  # PostgreSQL Database
  postgres:
    image: postgres:16-alpine
    container_name: katacore-postgres-prod
    restart: unless-stopped
    environment:
      POSTGRES_DB: ${POSTGRES_DB:-katacore}
      POSTGRES_USER: ${POSTGRES_USER:-postgres}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      PGDATA: /data/postgres
    volumes:
      - postgres_data:/data/postgres
      - ./backups:/backups
    networks:
      - katacore-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER:-postgres}"]
      interval: 30s
      timeout: 10s
      retries: 3

  # Redis Cache
  redis:
    image: redis:7-alpine
    container_name: katacore-redis-prod
    restart: unless-stopped
    command: redis-server --appendonly yes --requirepass ${REDIS_PASSWORD}
    volumes:
      - redis_data:/data
    networks:
      - katacore-network
    healthcheck:
      test: ["CMD", "redis-cli", "--raw", "incr", "ping"]
      interval: 30s
      timeout: 10s
      retries: 3

  # MinIO Object Storage
  minio:
    image: minio/minio:latest
    container_name: katacore-minio-prod
    restart: unless-stopped
    command: server /data --console-address ":9001"
    environment:
      MINIO_ROOT_USER: ${MINIO_ROOT_USER:-admin}
      MINIO_ROOT_PASSWORD: ${MINIO_ROOT_PASSWORD}
    volumes:
      - minio_data:/data
    ports:
      - "9000:9000"
      - "9001:9001"
    networks:
      - katacore-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:9000/minio/health/live"]
      interval: 30s
      timeout: 10s
      retries: 3

  # PgAdmin for Database Management
  pgadmin:
    image: dpage/pgadmin4:latest
    container_name: katacore-pgadmin-prod
    restart: unless-stopped
    environment:
      PGADMIN_DEFAULT_EMAIL: ${PGADMIN_EMAIL:-admin@katacore.com}
      PGADMIN_DEFAULT_PASSWORD: ${PGADMIN_PASSWORD}
      PGADMIN_CONFIG_SERVER_MODE: 'False'
      PGADMIN_CONFIG_MASTER_PASSWORD_REQUIRED: 'False'
    volumes:
      - pgadmin_data:/var/lib/pgadmin
    ports:
      - "8080:80"
    networks:
      - katacore-network
    depends_on:
      - postgres

  # Prisma Migration Service
  prisma-migrate:
    build:
      context: ./api
      dockerfile: Dockerfile
    container_name: katacore-prisma-migrate-prod
    environment:
      DATABASE_URL: "postgresql://${POSTGRES_USER:-postgres}:${POSTGRES_PASSWORD}@postgres:5432/${POSTGRES_DB:-katacore}?schema=public"
      NODE_ENV: production
    command: ["bun", "run", "db:migrate:deploy"]
    networks:
      - katacore-network
    depends_on:
      postgres:
        condition: service_healthy
    restart: "no"

  # Backend API
  api:
    build:
      context: ./api
      dockerfile: Dockerfile
    container_name: katacore-api-prod
    restart: unless-stopped
    environment:
      NODE_ENV: production
      PORT: 3001
      DATABASE_URL: "postgresql://${POSTGRES_USER:-postgres}:${POSTGRES_PASSWORD}@postgres:5432/${POSTGRES_DB:-katacore}?schema=public"
      REDIS_URL: "redis://:${REDIS_PASSWORD}@redis:6379"
      JWT_SECRET: ${JWT_SECRET}
      CORS_ORIGIN: ${CORS_ORIGIN:-http://localhost:3000}
    ports:
      - "3001:3001"
    networks:
      - katacore-network
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3001/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  # Frontend Site
  site:
    build:
      context: ./site
      dockerfile: Dockerfile
    container_name: katacore-site-prod
    restart: unless-stopped
    environment:
      NODE_ENV: production
      NEXT_PUBLIC_API_URL: ${NEXT_PUBLIC_API_URL:-http://localhost:3001}
    ports:
      - "3000:3000"
    networks:
      - katacore-network
    depends_on:
      - api
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000"]
      interval: 30s
      timeout: 10s
      retries: 3

  # Nginx Reverse Proxy
  nginx:
    image: nginx:alpine
    container_name: katacore-nginx-prod
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/conf.d:/etc/nginx/conf.d
      - ./ssl:/etc/nginx/ssl
      - ./nginx/logs:/var/log/nginx
    networks:
      - katacore-network
    depends_on:
      - site
      - api
    healthcheck:
      test: ["CMD", "nginx", "-t"]
      interval: 30s
      timeout: 10s
      retries: 3

volumes:
  postgres_data:
    driver: local
  redis_data:
    driver: local
  minio_data:
    driver: local
  pgadmin_data:
    driver: local

networks:
  katacore-network:
    driver: bridge
EOF
        success "Created $compose_file from template"
    fi
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

    # Ensure docker-compose.prod.yml exists
    log "📋 Checking for docker-compose.prod.yml..."
    create_docker_compose_prod

    # Check prerequisites
    log "🔍 Checking prerequisites..."
    
    if ! command -v docker &> /dev/null; then
        warning "Docker not found. Installing Docker automatically..."
        if bash "$PROJECT_DIR/scripts/install-docker.sh" install; then
            success "Docker installed successfully"
            warning "You may need to restart your terminal session for full Docker access"
            # Add current user to docker group if not root
            if [ "$EUID" -ne 0 ] && command -v sudo &> /dev/null; then
                log "Adding current user to docker group..."
                sudo usermod -aG docker "$(whoami)" || warning "Could not add user to docker group"
            fi
            # Check if we need to refresh the session
            if ! docker info > /dev/null 2>&1; then
                warning "Docker installed but requires session refresh. Attempting to use with sudo..."
                export SUDO_DOCKER=true
            fi
        else
            error "Failed to install Docker automatically. Please install Docker manually."
        fi
    fi

    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null 2>&1; then
        warning "Docker Compose not found. Installing..."
        if bash "$PROJECT_DIR/scripts/install-docker.sh" install; then
            success "Docker Compose installed successfully"
        else
            error "Failed to install Docker Compose automatically."
        fi
    fi

    # Check if Docker is running and start if needed
    log "🔄 Checking Docker service status..."
    DOCKER_CMD="docker"
    
    # Detect Docker Compose command and handle snap installation
    if [ "${SUDO_DOCKER:-false}" = "true" ]; then
        DOCKER_CMD="sudo docker"
        if command -v docker-compose &> /dev/null; then
            # Check if it's snap installed
            if which docker-compose | grep -q snap; then
                log "⚠️  Detected snap-installed Docker Compose, using 'docker compose' instead"
                COMPOSE_CMD="sudo docker compose"
            else
                COMPOSE_CMD="sudo docker-compose"
            fi
        else
            COMPOSE_CMD="sudo docker compose"
        fi
    else
        if command -v docker-compose &> /dev/null; then
            # Check if it's snap installed
            if which docker-compose | grep -q snap; then
                log "⚠️  Detected snap-installed Docker Compose, using 'docker compose' instead"
                COMPOSE_CMD="docker compose"
            else
                COMPOSE_CMD="docker-compose"
            fi
        else
            COMPOSE_CMD="docker compose"
        fi
    fi
    
    if ! $DOCKER_CMD info > /dev/null 2>&1; then
        log "🔄 Docker is not running. Attempting to start..."
        if command -v systemctl &> /dev/null; then
            sudo systemctl start docker 2>/dev/null || warning "Could not start Docker service"
        elif command -v service &> /dev/null; then
            sudo service docker start 2>/dev/null || warning "Could not start Docker service"
        fi
        
        sleep 3
        if ! $DOCKER_CMD info > /dev/null 2>&1; then
            error "Docker is not running and could not be started. Please start Docker manually."
        fi
        success "Docker started successfully"
    fi

    success "Prerequisites check passed"

    # Pull latest code
    if [ -d ".git" ]; then
        log "📥 Pulling latest code..."
        git pull origin main || git pull origin master || warning "Failed to pull latest code"
        
        # Ensure docker-compose.prod.yml is tracked in git
        if [ -f "docker-compose.prod.yml" ] && ! git ls-files --error-unmatch docker-compose.prod.yml >/dev/null 2>&1; then
            log "📝 Adding docker-compose.prod.yml to git..."
            git add docker-compose.prod.yml
            git commit -m "Add docker-compose.prod.yml for production deployment" || true
            git push origin main || git push origin master || warning "Failed to push docker-compose.prod.yml"
        fi
    fi

    # Build and deploy
    log "🔨 Building Docker images..."
    $COMPOSE_CMD -f docker-compose.prod.yml build --no-cache

    log "🛑 Stopping existing containers..."
    $COMPOSE_CMD -f docker-compose.prod.yml down || true

    log "🧹 Cleaning up Docker resources..."
    $DOCKER_CMD system prune -f || true

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
    $COMPOSE_CMD -f docker-compose.prod.yml up -d postgres redis minio
    
    log "⏳ Waiting for databases..."
    sleep 30
    
    # Run migrations
    log "🗃️  Running database migrations..."
    $COMPOSE_CMD -f docker-compose.prod.yml up prisma-migrate
    
    # Start app services
    log "🌐 Starting application services..."
    $COMPOSE_CMD -f docker-compose.prod.yml up -d api site nginx

    # Health checks
    log "🏥 Performing health checks..."
    sleep 30

    # Final status
    $COMPOSE_CMD -f docker-compose.prod.yml ps
    
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
    
    # Upload the snap fix script
    log "📤 Uploading Docker Compose fix script..."
    scp -P "$SERVER_PORT" "$PROJECT_DIR/scripts/fix-snap-compose.sh" "$SERVER_USER@$SERVER_HOST:$DEPLOY_PATH/"

    # Ensure docker-compose.prod.yml exists on remote server
    log "📋 Ensuring docker-compose.prod.yml exists on remote server..."
    ssh -p "$SERVER_PORT" "$SERVER_USER@$SERVER_HOST" << COMPOSE_CHECK
        set -e
        cd $DEPLOY_PATH
        
        if [ ! -f "docker-compose.prod.yml" ]; then
            echo "⚠️  docker-compose.prod.yml not found on remote server"
            if [ -f "docker-compose.yml" ]; then
                echo "📋 Creating docker-compose.prod.yml from docker-compose.yml"
                cp docker-compose.yml docker-compose.prod.yml
            else
                echo "🏗️  Creating docker-compose.prod.yml from template..."
                cat > docker-compose.prod.yml << 'PRODEOF'
version: '3.8'

services:
  # PostgreSQL Database
  postgres:
    image: postgres:16-alpine
    container_name: katacore-postgres-prod
    restart: unless-stopped
    environment:
      POSTGRES_DB: \${POSTGRES_DB:-katacore}
      POSTGRES_USER: \${POSTGRES_USER:-postgres}
      POSTGRES_PASSWORD: \${POSTGRES_PASSWORD}
      PGDATA: /data/postgres
    volumes:
      - postgres_data:/data/postgres
      - ./backups:/backups
    networks:
      - katacore-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U \${POSTGRES_USER:-postgres}"]
      interval: 30s
      timeout: 10s
      retries: 3

  # Redis Cache
  redis:
    image: redis:7-alpine
    container_name: katacore-redis-prod
    restart: unless-stopped
    command: redis-server --appendonly yes --requirepass \${REDIS_PASSWORD}
    volumes:
      - redis_data:/data
    networks:
      - katacore-network

  # Backend API
  api:
    build:
      context: ./api
      dockerfile: Dockerfile
    container_name: katacore-api-prod
    restart: unless-stopped
    environment:
      NODE_ENV: production
      PORT: 3001
      DATABASE_URL: "postgresql://\${POSTGRES_USER:-postgres}:\${POSTGRES_PASSWORD}@postgres:5432/\${POSTGRES_DB:-katacore}?schema=public"
    ports:
      - "3001:3001"
    networks:
      - katacore-network
    depends_on:
      - postgres
      - redis

  # Frontend Site
  site:
    build:
      context: ./site
      dockerfile: Dockerfile
    container_name: katacore-site-prod
    restart: unless-stopped
    environment:
      NODE_ENV: production
      NEXT_PUBLIC_API_URL: \${NEXT_PUBLIC_API_URL:-http://localhost:3001}
    ports:
      - "3000:3000"
    networks:
      - katacore-network
    depends_on:
      - api

  # Nginx Reverse Proxy
  nginx:
    image: nginx:alpine
    container_name: katacore-nginx-prod
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/conf.d:/etc/nginx/conf.d
      - ./ssl:/etc/nginx/ssl
    networks:
      - katacore-network
    depends_on:
      - site
      - api

volumes:
  postgres_data:
    driver: local
  redis_data:
    driver: local

networks:
  katacore-network:
    driver: bridge
PRODEOF
                echo "✅ Created docker-compose.prod.yml from template"
            fi
        else
            echo "✅ docker-compose.prod.yml found on remote server"
        fi
COMPOSE_CHECK

    # Upload environment file if exists
    if [ -f "$ENV_FILE" ]; then
        log "📋 Uploading environment file..."
        scp -P "$SERVER_PORT" "$ENV_FILE" "$SERVER_USER@$SERVER_HOST:$DEPLOY_PATH/.env.prod"
    else
        warning "No .env.prod file found locally. Creating basic environment file on server..."
        ssh -p "$SERVER_PORT" "$SERVER_USER@$SERVER_HOST" << 'ENV_CREATE'
            cd $DEPLOY_PATH
            if [ ! -f ".env.prod" ]; then
                echo "Creating basic .env.prod file..."
                cat > .env.prod << 'ENVEOF'
# Production Environment Variables
NODE_ENV=production

# Database Configuration
POSTGRES_DB=katacore
POSTGRES_USER=postgres
POSTGRES_PASSWORD=secure_password_change_me

# Redis Configuration
REDIS_PASSWORD=redis_password_change_me

# JWT Configuration
JWT_SECRET=your_super_secret_jwt_key_change_me

# CORS Configuration
CORS_ORIGIN=http://localhost:3000

# API Configuration
NEXT_PUBLIC_API_URL=http://localhost:3001

# MinIO Configuration (if using)
MINIO_ROOT_USER=admin
MINIO_ROOT_PASSWORD=minio_password_change_me

# PgAdmin Configuration (if using)
PGADMIN_EMAIL=admin@example.com
PGADMIN_PASSWORD=pgadmin_password_change_me
ENVEOF
                echo "⚠️  Created basic .env.prod - Please update passwords and secrets!"
            fi
ENV_CREATE
    fi

    # Execute remote deployment
    log "🚀 Executing remote deployment..."
    
    ssh -p "$SERVER_PORT" "$SERVER_USER@$SERVER_HOST" << EOF
        set -e
        cd $DEPLOY_PATH
        
        echo "📍 Working directory: \$(pwd)"
        echo "📋 Files in directory:"
        ls -la
        
        echo "📦 Installing system dependencies..."
        if command -v apt-get &> /dev/null; then
            apt-get update
            apt-get install -y curl git openssl
        elif command -v yum &> /dev/null; then
            yum update -y
            yum install -y curl git openssl
        fi
        
        echo "🐳 Installing Docker if not present..."
        if ! command -v docker &> /dev/null; then
            # Use Docker's convenience script
            curl -fsSL https://get.docker.com -o get-docker.sh
            sh get-docker.sh
            rm get-docker.sh
            
            # Start and enable Docker
            if command -v systemctl &> /dev/null; then
                systemctl enable docker
                systemctl start docker
            elif command -v service &> /dev/null; then
                service docker start
            fi
        fi
        
        echo "🐳 Installing Docker Compose if not present..."
        if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null 2>&1; then
            curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-\$(uname -s)-\$(uname -m)" -o /usr/local/bin/docker-compose
            chmod +x /usr/local/bin/docker-compose
        fi
        
        echo "🔧 Running Docker Compose snap detection and fix..."
        chmod +x fix-snap-compose.sh
        if ./fix-snap-compose.sh; then
            echo "✅ Docker Compose configuration verified"
        else
            echo "⚠️  Docker Compose fix script encountered issues, but continuing..."
        fi
        
        echo "📋 Checking for docker-compose.prod.yml..."
        if [ ! -f "docker-compose.prod.yml" ]; then
            echo "❌ docker-compose.prod.yml not found!"
            exit 1
        fi
        
        # Detect Docker and Compose commands with snap handling
        echo "🔍 Detecting Docker commands..."
        DOCKER_CMD="docker"
        if ! docker ps &> /dev/null; then
            if sudo docker ps &> /dev/null; then
                echo "⚠️  Using sudo for Docker commands"
                DOCKER_CMD="sudo docker"
                SUDO_DOCKER="true"
            else
                echo "❌ Cannot run Docker commands"
                exit 1
            fi
        else
            SUDO_DOCKER="false"
        fi
        
        # Detect Docker Compose and handle snap installation issues
        if [ "$SUDO_DOCKER" = "true" ]; then
            if command -v docker-compose &> /dev/null; then
                if which docker-compose | grep -q snap; then
                    echo "⚠️  Detected snap-installed Docker Compose, using 'docker compose' instead"
                    COMPOSE_CMD="sudo docker compose"
                else
                    COMPOSE_CMD="sudo docker-compose"
                fi
            else
                COMPOSE_CMD="sudo docker compose"
            fi
        else
            if command -v docker-compose &> /dev/null; then
                if which docker-compose | grep -q snap; then
                    echo "⚠️  Detected snap-installed Docker Compose, using 'docker compose' instead"
                    COMPOSE_CMD="docker compose"
                else
                    COMPOSE_CMD="docker-compose"
                fi
            else
                COMPOSE_CMD="docker compose"
            fi
        fi
        
        echo "🐳 Using Docker command: \$DOCKER_CMD"
        echo "🐳 Using Compose command: \$COMPOSE_CMD"
        
        echo "🔨 Building and starting services..."
        # Use absolute path for docker-compose file
        COMPOSE_FILE="\$(pwd)/docker-compose.prod.yml"
        echo "📋 Using compose file: \$COMPOSE_FILE"
        
        # Stop existing containers
        \$COMPOSE_CMD -f "\$COMPOSE_FILE" down || true
        
        # Build with no cache
        \$COMPOSE_CMD -f "\$COMPOSE_FILE" build --no-cache
        
        # Create necessary directories
        mkdir -p ssl backups nginx/logs
        
        # Create self-signed SSL certificates if not exist
        if [ ! -f "ssl/fullchain.pem" ]; then
            echo "🔐 Creating SSL certificates..."
            openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
                -keyout ssl/privkey.pem \
                -out ssl/fullchain.pem \
                -subj "/C=US/ST=State/L=City/O=Organization/CN=\$(hostname)" 2>/dev/null || true
        fi
        
        # Start services in stages
        echo "🗄️  Starting database services..."
        \$COMPOSE_CMD -f "\$COMPOSE_FILE" up -d postgres redis 2>/dev/null || true
        
        echo "⏳ Waiting for databases to be ready..."
        sleep 30
        
        echo "🚀 Starting application services..."
        \$COMPOSE_CMD -f "\$COMPOSE_FILE" up -d api site nginx 2>/dev/null || true
        
        echo "✅ Remote deployment completed!"
        \$COMPOSE_CMD -f "\$COMPOSE_FILE" ps
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
