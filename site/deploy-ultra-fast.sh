#!/bin/bash

# =============================================================================
# Ultra-Fast Cloud Deployment Script
# Build local + Deploy to cloud server optimized for speed
# =============================================================================

set -euo pipefail

readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly NC='\033[0m'

# Load configuration
if [ -f ".env.deploy" ]; then
    source .env.deploy
fi

# Server configuration
CLOUD_USER="${CLOUD_USER:-root}"
CLOUD_HOST="${CLOUD_HOST:-your-server.com}"
CLOUD_PATH="${CLOUD_PATH:-/var/www/innerbright/site}"
SSH_KEY="${SSH_KEY:-~/.ssh/id_rsa}"
DOCKER_IMAGE="${DOCKER_IMAGE:-innerbright-site}"

# Build configuration
BUILD_MEMORY="${BUILD_MEMORY:-4096}"
PARALLEL_JOBS="${PARALLEL_JOBS:-$(nproc)}"

echo -e "${BLUE}🚀 Ultra-Fast Cloud Deployment Pipeline${NC}"
echo -e "${YELLOW}📋 Configuration:${NC}"
echo -e "   Server: ${CLOUD_USER}@${CLOUD_HOST}"
echo -e "   Path: ${CLOUD_PATH}"
echo -e "   Memory: ${BUILD_MEMORY}MB"
echo -e "   Parallel Jobs: ${PARALLEL_JOBS}"
echo ""

# Test server connection
echo -e "${YELLOW}🔗 Testing server connection...${NC}"
if ! ssh -i "$SSH_KEY" -o ConnectTimeout=10 "$CLOUD_USER@$CLOUD_HOST" "echo 'Connection OK'" >/dev/null 2>&1; then
    echo -e "${RED}❌ Cannot connect to server!${NC}"
    echo -e "${YELLOW}💡 Check your SSH key and server configuration${NC}"
    exit 1
fi

# Build locally with optimizations
echo -e "${YELLOW}🏗️  Building locally with optimizations...${NC}"
./build-standalone-optimized.sh

# Verify build
if [ ! -d ".next/standalone" ] || [ ! -d ".next/static" ]; then
    echo -e "${RED}❌ Build verification failed!${NC}"
    exit 1
fi

# Create optimized deployment package
echo -e "${YELLOW}📦 Creating deployment package...${NC}"
cd .next
tar -czf ../deployment.tar.gz standalone/ static/ || {
    echo -e "${RED}❌ Failed to create deployment package${NC}"
    exit 1
}
cd ..

echo -e "${BLUE}📊 Package size: $(du -sh deployment.tar.gz | cut -f1)${NC}"

# Parallel deployment process
echo -e "${YELLOW}☁️  Deploying to cloud server...${NC}"

# Create remote directory structure
ssh -i "$SSH_KEY" "$CLOUD_USER@$CLOUD_HOST" "
    mkdir -p $CLOUD_PATH/{.next/{static,standalone},public,node_modules/{.prisma,@prisma}}
    cd $CLOUD_PATH
    # Stop existing container
    docker stop $DOCKER_IMAGE 2>/dev/null || true
    docker rm $CLOUD_PATH-$DOCKER_IMAGE 2>/dev/null || true
"

# Upload deployment package
echo -e "${YELLOW}📤 Uploading deployment package...${NC}"
rsync -avz --progress \
    -e "ssh -i $SSH_KEY" \
    deployment.tar.gz \
    "$CLOUD_USER@$CLOUD_HOST:$CLOUD_PATH/"

# Upload additional files in parallel
{
    rsync -avz -e "ssh -i $SSH_KEY" public/ "$CLOUD_USER@$CLOUD_HOST:$CLOUD_PATH/public/" &
    rsync -avz -e "ssh -i $SSH_KEY" package.json Dockerfile "$CLOUD_USER@$CLOUD_HOST:$CLOUD_PATH/" &
    
    # Upload Prisma if exists
    if [ -d "node_modules/.prisma" ]; then
        rsync -avz -e "ssh -i $SSH_KEY" node_modules/.prisma/ "$CLOUD_USER@$CLOUD_HOST:$CLOUD_PATH/node_modules/.prisma/" &
        rsync -avz -e "ssh -i $SSH_KEY" node_modules/@prisma/ "$CLOUD_USER@$CLOUD_HOST:$CLOUD_PATH/node_modules/@prisma/" &
    fi
    
    wait
} &

UPLOAD_PID=$!

# Extract deployment package on server
echo -e "${YELLOW}📂 Extracting on server...${NC}"
ssh -i "$SSH_KEY" "$CLOUD_USER@$CLOUD_HOST" "
    cd $CLOUD_PATH
    tar -xzf deployment.tar.gz
    rm deployment.tar.gz
    
    # Set proper permissions
    chown -R 1001:1001 .next/ public/ node_modules/ 2>/dev/null || true
"

# Wait for parallel uploads to complete
wait $UPLOAD_PID

# Build and deploy Docker container
echo -e "${YELLOW}🐳 Building Docker image on server...${NC}"
ssh -i "$SSH_KEY" "$CLOUD_USER@$CLOUD_HOST" "
    cd $CLOUD_PATH
    
    # Build optimized Docker image
    docker build -t $DOCKER_IMAGE:latest . --build-arg BUILDKIT_INLINE_CACHE=1
    
    # Run container with optimized settings
    docker run -d \\
        --name $DOCKER_IMAGE \\
        --restart unless-stopped \\
        --memory=1g \\
        --memory-swap=2g \\
        --cpus=2 \\
        -p 3000:3000 \\
        -e NODE_ENV=production \\
        -e PORT=3000 \\
        -e HOSTNAME=0.0.0.0 \\
        $DOCKER_IMAGE:latest
"

# Cleanup local deployment package
rm -f deployment.tar.gz

# Verify deployment
echo -e "${YELLOW}🔍 Verifying deployment...${NC}"
sleep 5

HEALTH_CHECK=$(ssh -i "$SSH_KEY" "$CLOUD_USER@$CLOUD_HOST" "
    curl -s -o /dev/null -w '%{http_code}' http://localhost:3000/api/health 2>/dev/null || echo '000'
")

if [ "$HEALTH_CHECK" = "200" ]; then
    echo -e "${GREEN}✅ Deployment successful!${NC}"
    echo -e "${BLUE}🌐 Application is running at: http://$CLOUD_HOST:3000${NC}"
    
    # Show deployment stats
    ssh -i "$SSH_KEY" "$CLOUD_USER@$CLOUD_HOST" "
        echo -e '${BLUE}📊 Container Stats:${NC}'
        docker stats $DOCKER_IMAGE --no-stream --format 'table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}'
        
        echo -e '${BLUE}💾 Disk Usage:${NC}'
        du -sh $CLOUD_PATH
        
        echo -e '${BLUE}🐳 Image Size:${NC}'
        docker images $DOCKER_IMAGE:latest --format 'table {{.Repository}}\t{{.Tag}}\t{{.Size}}'
    "
else
    echo -e "${RED}❌ Deployment verification failed!${NC}"
    echo -e "${YELLOW}📋 Checking container logs...${NC}"
    ssh -i "$SSH_KEY" "$CLOUD_USER@$CLOUD_HOST" "docker logs $DOCKER_IMAGE --tail=20"
    exit 1
fi

# Performance optimization recommendations
echo -e "${BLUE}⚡ Performance Summary:${NC}"
echo -e "✅ Standalone build: Optimized"
echo -e "✅ Docker layers: Minimized"
echo -e "✅ Static assets: Cached"
echo -e "✅ Memory usage: Optimized"
echo -e "✅ Container: Running"

echo -e "${GREEN}🎉 Ultra-fast deployment completed successfully!${NC}"
