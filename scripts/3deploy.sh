#!/bin/bash

# ==============================================================================
# INNERBRIGHT DEPLOYMENT - OPTIMIZED FOR LOW-SPEC SERVER
# Server: 116.118.48.208 (1 vCPU, 2GB RAM, 10GB NVMe)
# Strategy: Build LOCAL → Upload BINARY → NO compilation on server
# ==============================================================================

set -e

SERVER_IP="116.118.48.208"
SERVER_USER="root"
REMOTE_DIR="/root/innerbright"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

echo ""
echo "═══════════════════════════════════════════════════════"
echo "🚀 INNERBRIGHT DEPLOYMENT - LOW-SPEC SERVER MODE"
echo "═══════════════════════════════════════════════════════"
log_warning "Server: ${SERVER_IP} (1 vCPU, 2GB RAM, 10GB NVMe)"
log_warning "Strategy: Build locally → Upload binary → No server build"
echo "═══════════════════════════════════════════════════════"
echo ""

# Step 1: Local git operations (optional)
if [[ -d ".git" ]]; then
    log_info "📝 Step 1: Git operations..."
    git add . 2>/dev/null || true
    git commit -m "deploy: $(date +%Y%m%d-%H%M%S)" 2>/dev/null || true
    git push 2>/dev/null || log_warning "Git push skipped (no remote or already up to date)"
    log_success "Git operations completed"
else
    log_info "📝 Step 1: No git repository, skipping..."
fi

# Step 2: Build locally (CRITICAL for low-spec server)
log_info "📦 Step 2: Building locally (this protects server from overload)..."
echo "   Building with Bun + Turbopack..."

if ! bun run build; then
    log_error "Local build failed"
    log_error "Fix build errors before deploying"
    exit 1
fi

log_success "✅ Local build completed successfully"
echo "   Build output:"
echo "   - .next/standalone: $(find .next/standalone -type f 2>/dev/null | wc -l) files"
echo "   - .next/static: $(find .next/static -type f 2>/dev/null | wc -l) files"
echo "   - public: $(find public -type f 2>/dev/null | wc -l) files"

# Verify build output
if [[ ! -d ".next/standalone" ]]; then
    log_error "Build output missing: .next/standalone"
    log_error "Check next.config.ts has: output: 'standalone'"
    exit 1
fi

# Create symlink if needed
if [[ ! -L "frontend" ]]; then
    log_info "Creating frontend symlink..."
    ln -s . frontend
fi

# Step 3: Test server connectivity
log_info "🔍 Step 3: Testing server connectivity..."

if ! timeout 10 ping -c 2 "${SERVER_IP}" >/dev/null 2>&1; then
    log_error "Server ${SERVER_IP} is not reachable"
    log_error "Check your network connection or server status"
    exit 1
fi

log_success "✅ Server is reachable (ping OK)"

# Test SSH with timeout
log_info "Testing SSH connection..."
if ! timeout 30 ssh -o ConnectTimeout=30 "${SERVER_USER}@${SERVER_IP}" "echo 'SSH OK'" >/dev/null 2>&1; then
    log_error "SSH connection failed or timeout"
    log_error "Server may be overloaded or SSH service down"
    log_info "Try: ssh ${SERVER_USER}@${SERVER_IP} to debug manually"
    exit 1
fi

log_success "✅ SSH connection OK"

# Step 4: Upload pre-built files
log_info "📤 Step 4: Uploading pre-built files to server..."
log_info "   This may take 30-60 seconds depending on network..."

# Calculate upload size
UPLOAD_SIZE=$(du -sh . 2>/dev/null | cut -f1)
log_info "   Total size: ${UPLOAD_SIZE}"

rsync -avz --timeout=600 \
  --exclude 'node_modules' \
  --exclude '.git' \
  --exclude '.github' \
  --exclude '.next/cache' \
  --exclude '*.log' \
  --exclude '.env*' \
  --exclude 'scripts/test-*.sh' \
  --exclude 'scripts/debug-*.sh' \
  --exclude 'scripts/kill-*.sh' \
  --exclude 'scripts/*.backup' \
  --exclude '.vscode' \
  --exclude '.idea' \
  --delete \
  --progress \
  ./ "${SERVER_USER}@${SERVER_IP}:${REMOTE_DIR}/" || {
    log_error "File upload failed"
    log_error "Check SSH connection and disk space on server"
    exit 1
}

log_success "✅ Files uploaded successfully"

# Step 5: Deploy on server (NO BUILD, just copy files to Docker)
log_info "🐳 Step 5: Deploying on server (no compilation)..."

ssh -o ConnectTimeout=60 "${SERVER_USER}@${SERVER_IP}" bash -s << 'REMOTE_EOF'
    set -e
    cd /root/innerbright
    
    echo "=== Server Resources Before Deploy ==="
    free -h
    df -h / | tail -1
    
    echo ""
    echo "=== Checking disk space ==="
    DISK_USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
    if [ $DISK_USAGE -gt 90 ]; then
        echo "❌ Disk usage at ${DISK_USAGE}% - Cleanup needed"
        docker system prune -af
    fi
    
    echo ""
    echo "=== Stopping existing containers ==="
    docker compose down innerbright-web --timeout=30 2>/dev/null || true
    
    echo ""
    echo "=== Building Docker image from PRE-BUILT files ==="
    echo "   (NO Next.js compilation, just copying files)"
    timeout 180 docker compose build --no-cache innerbright-web || {
        echo "ERROR: Docker image build failed"
        exit 1
    }
    
    echo ""
    echo "=== Starting optimized container ==="
    docker compose up -d innerbright-web || {
        echo "ERROR: Container start failed"
        docker compose logs innerbright-web --tail 30
        exit 1
    }
    
    echo ""
    echo "=== Waiting for container to be ready (20s) ==="
    sleep 20
    
    echo ""
    echo "=== Container Status ==="
    docker compose ps innerbright-web
    
    echo ""
    echo "=== Quick cleanup in background ==="
    nohup docker image prune -af > /dev/null 2>&1 &
    
    echo ""
    echo "=== Server Resources After Deploy ==="
    free -h
    df -h / | tail -1
    
    echo ""
    echo "✅ Deployment completed on server"
REMOTE_EOF

if [[ $? -ne 0 ]]; then
    log_error "Deployment on server failed"
    exit 1
fi

log_success "✅ Docker container started"

# Step 6: Health check
log_info "🏥 Step 6: Health check..."
sleep 10

if timeout 15 curl -s --connect-timeout 10 "http://${SERVER_IP}:14000" >/dev/null 2>&1; then
    log_success "✅ Application is responding!"
    log_success "🌐 Website: http://${SERVER_IP}:14000"
else
    log_warning "⚠️  Application may still be starting"
    log_info "Wait 30 seconds and check: http://${SERVER_IP}:14000"
fi

# Show summary
echo ""
echo "═══════════════════════════════════════════════════════"
log_success "🎉 DEPLOYMENT COMPLETED SUCCESSFULLY"
echo "═══════════════════════════════════════════════════════"
echo ""
log_success "🌐 Website: http://${SERVER_IP}:14000"
log_info "📊 PgAdmin: http://${SERVER_IP}:14002"
log_info "🗄️  PostgreSQL: ${SERVER_IP}:14003"
log_info "💾 Redis: ${SERVER_IP}:14004"
echo ""
echo "═══════════════════════════════════════════════════════"
echo ""
log_info "💡 Useful commands:"
echo "   • Check logs: ssh root@${SERVER_IP} 'docker compose logs -f innerbright-web'"
echo "   • Check status: ssh root@${SERVER_IP} 'docker compose ps'"
echo "   • Monitor resources: ssh root@${SERVER_IP} 'htop'"
echo "   • Restart only: ssh root@${SERVER_IP} 'cd ${REMOTE_DIR} && docker compose restart innerbright-web'"
echo ""
log_success "Deployment time: Build locally → Upload binary → Run on server"
log_success "This approach prevents server overload on low-spec hardware!"
echo ""