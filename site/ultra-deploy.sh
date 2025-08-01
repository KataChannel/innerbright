#!/bin/bash

# =============================================================================
# Ultra-Optimized Deployment Script
# Build locally → Minimal Docker image → Fast cloud deploy
# =============================================================================

set -euo pipefail

# Configuration
readonly CLOUD_HOST="116.118.85.41"
readonly CLOUD_USER="root"
readonly SSH_KEY="~/.ssh/id_rsa"
readonly CLOUD_PATH="/opt/innerbright/site"
readonly CONTAINER_NAME="innerbright-site"

# Colors
readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m'

log() { echo -e "${BLUE}[$(date +'%H:%M:%S')]${NC} $1"; }
success() { echo -e "${GREEN}✅${NC} $1"; }
warning() { echo -e "${YELLOW}⚠️${NC} $1"; }

# Step 1: Ultra-fast local build
log "🔨 Building Next.js standalone (optimized)..."
rm -rf .next node_modules/.cache

time env \
    DISABLE_PWA_BUILD=true \
    NODE_ENV=production \
    NEXT_TELEMETRY_DISABLED=1 \
    NODE_OPTIONS="--max-old-space-size=4096" \
    npm run build

if [ ! -d ".next/standalone" ]; then
    echo "❌ Build failed - no standalone output"
    exit 1
fi

BUILD_SIZE=$(du -sh .next | cut -f1)
success "Local build completed ($BUILD_SIZE)"

# Step 2: Ultra-fast sync with optimized rsync
log "⚡ Syncing to cloud (optimized transfer)..."

# Create build package locally for faster transfer
tar -czf build.tar.gz .next/standalone .next/static public package.json Dockerfile

# Single optimized rsync
time rsync -avz --progress --compress-level=9 \
    -e "ssh -i $SSH_KEY -o Compression=yes -o CompressionLevel=9" \
    build.tar.gz \
    $CLOUD_USER@$CLOUD_HOST:/tmp/

# Extract and deploy on server
ssh -i $SSH_KEY $CLOUD_USER@$CLOUD_HOST "
    cd $CLOUD_PATH
    
    # Stop existing container
    docker stop $CONTAINER_NAME 2>/dev/null || true
    docker rm $CONTAINER_NAME 2>/dev/null || true
    
    # Extract build
    tar -xzf /tmp/build.tar.gz
    rm /tmp/build.tar.gz
    
    # Build minimal Docker image (~50MB)
    docker build -t $CONTAINER_NAME:latest .
    
    # Run with minimal resources
    docker run -d \
        --name $CONTAINER_NAME \
        --restart unless-stopped \
        -p 3000:3000 \
        --memory=256m \
        --memory-swap=256m \
        --cpus='0.3' \
        $CONTAINER_NAME:latest
    
    # Cleanup
    docker image prune -f
    
    # Wait and check
    sleep 5
    docker ps --filter name=$CONTAINER_NAME --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
"

# Cleanup local files
rm -f build.tar.gz

# Step 3: Verify deployment
log "🔍 Verifying deployment..."
sleep 10

if ssh -i $SSH_KEY $CLOUD_USER@$CLOUD_HOST "curl -s http://localhost:3000 >/dev/null"; then
    success "Deployment successful!"
    
    # Show final stats
    FINAL_SIZE=$(ssh -i $SSH_KEY $CLOUD_USER@$CLOUD_HOST "docker images $CONTAINER_NAME:latest --format '{{.Size}}'")
    echo ""
    echo "📊 Deployment Stats:"
    echo "  • Build size: $BUILD_SIZE"
    echo "  • Docker image: $FINAL_SIZE"
    echo "  • Memory limit: 256MB"
    echo "  • CPU limit: 0.3 cores"
    echo ""
    echo "🌐 App running at: http://$CLOUD_HOST:3000"
else
    echo "❌ Deployment verification failed"
    ssh -i $SSH_KEY $CLOUD_USER@$CLOUD_HOST "docker logs $CONTAINER_NAME --tail=10"
    exit 1
fi
