#!/bin/bash

# =============================================================================
# Fast rsync script for .next build artifacts
# Optimized for minimal transfer and maximum speed
# =============================================================================

set -euo pipefail

# Colors
readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m'

# Configuration
CLOUD_USER="${CLOUD_USER:-root}"
CLOUD_HOST="${CLOUD_HOST:-116.118.85.41}"
CLOUD_PATH="${CLOUD_PATH:-/var/www/innerbright/site}"
SSH_KEY="${SSH_KEY:-~/.ssh/id_rsa}"

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_info "🚀 Fast sync .next build artifacts to cloud server..."

# Verify build exists
if [ ! -d ".next" ]; then
    log_warning "⚠️  .next directory not found. Building first..."
    DISABLE_PWA_BUILD=true npm run build
fi

# Create remote directories
log_info "📁 Creating remote directory structure..."
ssh -i $SSH_KEY $CLOUD_USER@$CLOUD_HOST "mkdir -p $CLOUD_PATH/{.next/static,public}"

# Optimized rsync with compression and progress
log_info "📦 Syncing standalone application..."
rsync -avz --delete --progress --compress-level=6 \
    --exclude='*.map' \
    --exclude='cache/' \
    --exclude='node_modules/' \
    --exclude='.git/' \
    -e "ssh -i $SSH_KEY -o Compression=yes -o CompressionLevel=6" \
    .next/standalone/ \
    $CLOUD_USER@$CLOUD_HOST:$CLOUD_PATH/

log_info "🎨 Syncing static assets..."
rsync -avz --delete --progress --compress-level=6 \
    -e "ssh -i $SSH_KEY -o Compression=yes" \
    .next/static/ \
    $CLOUD_USER@$CLOUD_HOST:$CLOUD_PATH/.next/static/

log_info "🌐 Syncing public files..."
rsync -avz --delete --progress \
    --exclude='*.DS_Store' \
    --exclude='Thumbs.db' \
    -e "ssh -i $SSH_KEY" \
    public/ \
    $CLOUD_USER@$CLOUD_HOST:$CLOUD_PATH/public/

# Sync minimal config files
log_info "⚙️  Syncing essential files..."
rsync -avz --progress \
    -e "ssh -i $SSH_KEY" \
    package.json Dockerfile \
    $CLOUD_USER@$CLOUD_HOST:$CLOUD_PATH/

# Show transfer stats
log_info "📊 Transfer completed. Remote directory size:"
ssh -i $SSH_KEY $CLOUD_USER@$CLOUD_HOST "du -sh $CLOUD_PATH"

log_success "✅ Fast sync completed successfully!"
echo -e "${BLUE}📡 Files synced to: $CLOUD_USER@$CLOUD_HOST:$CLOUD_PATH${NC}"
echo -e "${BLUE}💡 Next: Run 'make deploy-cloud' to build Docker and start container${NC}"
