#!/bin/bash

# Unified deployment script for Innerbright
set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
BUILD_MODE="${BUILD_MODE:-prebuilt}"
PROFILE="${PROFILE:-default}"
SKIP_BUILD="${SKIP_BUILD:-false}"
SERVER_IP="${SERVER_IP:-116.118.48.208}"

# Function to show help
show_help() {
    echo -e "${GREEN}Innerbright Unified Deployment Script${NC}"
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -m, --mode MODE      Build mode: prebuilt (default) or build"
    echo "  -p, --profile PROF   Docker compose profile: default, redis, minio, pgadmin, full"
    echo "  -s, --skip-build     Skip local build step"
    echo "  --server IP          Server IP address (default: 116.118.48.208)"
    echo "  -h, --help           Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                                    # Prebuilt mode, minimal setup"
    echo "  $0 -m build -p full                  # Build mode, all services"
    echo "  $0 -p redis                          # Prebuilt with Redis"
    echo "  $0 -s                                # Skip build, use existing files"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -m|--mode)
            BUILD_MODE="$2"
            shift 2
            ;;
        -p|--profile)
            PROFILE="$2"
            shift 2
            ;;
        -s|--skip-build)
            SKIP_BUILD="true"
            shift
            ;;
        --server)
            SERVER_IP="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            show_help
            exit 1
            ;;
    esac
done

echo -e "${GREEN}🚀 Innerbright Unified Deployment${NC}"
echo -e "${BLUE}Build Mode: ${BUILD_MODE}${NC}"
echo -e "${BLUE}Profile: ${PROFILE}${NC}"
echo -e "${BLUE}Server: ${SERVER_IP}${NC}"
echo "================================================"

# Validate build mode
if [[ "$BUILD_MODE" != "prebuilt" && "$BUILD_MODE" != "build" ]]; then
    echo -e "${RED}❌ Invalid build mode: $BUILD_MODE. Must be 'prebuilt' or 'build'${NC}"
    exit 1
fi

# Local build step (if not skipped)
if [[ "$SKIP_BUILD" != "true" && "$BUILD_MODE" == "prebuilt" ]]; then
    echo -e "${BLUE}🔨 Building application locally...${NC}"
    
    # Check if .next exists and is recent
    if [[ -d ".next" ]]; then
        NEXT_AGE=$(find .next -name "BUILD_ID" -mmin -30 2>/dev/null | wc -l)
        if [[ $NEXT_AGE -gt 0 ]]; then
            echo -e "${YELLOW}ℹ️ Recent build found, skipping local build${NC}"
            SKIP_BUILD="true"
        fi
    fi
    
    if [[ "$SKIP_BUILD" != "true" ]]; then
        # Clean previous builds
        rm -rf .next 2>/dev/null || true
        
        # Build with memory optimization
        if command -v bun &> /dev/null; then
            NODE_OPTIONS="--max-old-space-size=512" bun run build
        else
            NODE_OPTIONS="--max-old-space-size=512" npm run build
        fi
        
        echo -e "${GREEN}✅ Local build completed${NC}"
    fi
fi

# Validate prebuilt files
if [[ "$BUILD_MODE" == "prebuilt" ]]; then
    if [[ ! -d ".next/standalone" ]]; then
        echo -e "${RED}❌ Error: .next/standalone not found!${NC}"
        echo -e "${YELLOW}💡 Run with --mode build or ensure local build is completed${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ Pre-built files validated${NC}"
fi

# Create deployment package
echo -e "${BLUE}📦 Creating deployment package...${NC}"
tar -czf deploy-package.tar.gz \
    .next/ \
    package.json \
    next.config.ts \
    public/ \
    Dockerfile \
    Dockerfile.simple \
    docker-compose.yml \
    prisma/ \
    .env.example \
    2>/dev/null || echo "Some files may be missing, continuing..."

echo -e "${GREEN}✅ Package created ($(du -h deploy-package.tar.gz | cut -f1))${NC}"

# Test server connection
echo -e "${BLUE}🔌 Testing server connection...${NC}"
if ! ssh -o ConnectTimeout=10 -o BatchMode=yes root@${SERVER_IP} exit; then
    echo -e "${RED}❌ Failed to connect to server ${SERVER_IP}${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Server connection successful${NC}"

# Deploy to server
echo -e "${GREEN}🚀 Deploying to server...${NC}"

# Upload package
scp deploy-package.tar.gz root@${SERVER_IP}:/root/innerbright/ || {
    echo -e "${YELLOW}⚠️ Upload failed, creating directory and retrying...${NC}"
    ssh root@${SERVER_IP} "mkdir -p /root/innerbright"
    scp deploy-package.tar.gz root@${SERVER_IP}:/root/innerbright/
}

# Deploy on server
ssh root@${SERVER_IP} << ENDSSH
set -e

# Colors for remote output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "\${GREEN}📍 Starting deployment on server...${NC}"

cd /root/innerbright

# Stop existing containers
echo -e "\${BLUE}🛑 Stopping existing containers...${NC}"
docker-compose down 2>/dev/null || echo "No containers to stop"

# Extract package
echo -e "\${BLUE}📦 Extracting deployment package...${NC}"
tar -xzf deploy-package.tar.gz

# Set environment variables for deployment
export BUILD_MODE=${BUILD_MODE}
if [[ "${BUILD_MODE}" == "prebuilt" ]]; then
    export DOCKERFILE_NAME=Dockerfile.simple
else
    export DOCKERFILE_NAME=Dockerfile
fi

# Build and start services with profile
echo -e "\${BLUE}🔨 Building and starting services...${NC}"
if [[ "${PROFILE}" == "default" ]]; then
    docker-compose build --no-cache
    docker-compose up -d
else
    docker-compose --profile ${PROFILE} build --no-cache
    docker-compose --profile ${PROFILE} up -d
fi

# Wait for services to be ready
echo -e "\${BLUE}⏳ Waiting for services to start...${NC}"
sleep 15

# Check container status
echo -e "\${BLUE}📊 Container status:${NC}"
if [[ "${PROFILE}" == "default" ]]; then
    docker-compose ps
else
    docker-compose --profile ${PROFILE} ps
fi

# Test application health
echo -e "\${BLUE}🔍 Testing application health...${NC}"
if curl -f http://localhost:3000 > /dev/null 2>&1; then
    echo -e "\${GREEN}✅ Application is responding${NC}"
else
    echo -e "\${YELLOW}⚠️ Application may still be starting up...${NC}"
fi

# Show resource usage
echo -e "\${BLUE}📊 Resource usage:${NC}"
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}"

echo -e "\${GREEN}🎉 Deployment completed successfully!${NC}"

# Clean up
rm -f deploy-package.tar.gz
ENDSSH

# Clean up local package
rm -f deploy-package.tar.gz

echo -e "${GREEN}🎉 Deployment completed successfully!${NC}"
echo -e "${BLUE}🌐 Application available at: http://${SERVER_IP}:3000${NC}"

# Show useful commands
echo ""
echo -e "${YELLOW}📝 Useful commands:${NC}"
echo -e "  View logs: ssh root@${SERVER_IP} 'cd /root/innerbright && docker-compose logs -f'"
echo -e "  Check status: ssh root@${SERVER_IP} 'cd /root/innerbright && docker-compose ps'"
echo -e "  Restart: ssh root@${SERVER_IP} 'cd /root/innerbright && docker-compose restart'"

if [[ "$PROFILE" != "default" ]]; then
    echo -e "  Note: Using profile '${PROFILE}' - add --profile ${PROFILE} to docker-compose commands"
fi
