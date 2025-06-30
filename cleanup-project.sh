#!/bin/bash

# KataCore Project Cleanup Script
# Làm sạch và tổ chức lại toàn bộ dự án

set -e

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
}

log "🧹 BẮTĐẦU LÀM SẠCH KATACORE PROJECT"
echo "==================================="

# Backup trước khi cleanup
log "💾 Tạo backup trước khi cleanup..."
BACKUP_DIR="backup_$(date +'%Y%m%d_%H%M%S')"
mkdir -p "$BACKUP_DIR"

# Backup các files quan trọng
cp -r scripts/ "$BACKUP_DIR/" 2>/dev/null || true
cp *.md "$BACKUP_DIR/" 2>/dev/null || true
cp *.json "$BACKUP_DIR/" 2>/dev/null || true
cp *.yml "$BACKUP_DIR/" 2>/dev/null || true
cp *.sh "$BACKUP_DIR/" 2>/dev/null || true

success "Backup tạo tại: $BACKUP_DIR"

# 1. Xóa các file documentation cũ và duplicate
log "📄 Cleaning up documentation files..."
FILES_TO_REMOVE=(
    "AUTO_DEPLOYMENT_COMPLETE.md"
    "BUN_PATH_FIX_SUMMARY.md"
    "DEPLOYMENT_USAGE_GUIDE.md"
    "DOCKER_AUTO_INSTALL_COMPLETE.md"
    "DOCKER_AUTO_INSTALL.md"
    "DOCKER_COMPOSE_MANAGEMENT.md"
    "DOCKER_COMPOSE_SNAP_FIX.md"
    "GIT_AUTO_PUSH_COMPLETE.md"
    "GIT_AUTO_PUSH.md"
    "REMOTE_DEPLOYMENT_FIX_COMPLETE.md"
    "REMOTE_DEPLOYMENT_TROUBLESHOOTING.md"
    "SETUP_SUMMARY.md"
    "SNAP_FIX_COMPLETE.md"
    "QUICK_REFERENCE.md"
    "FIX_AND_DEPLOY.sh"
    "FIX_FILE_MISSING.sh"
    "FIX_THU_CONG.sh"
    "HUONG_DAN_FIX.sh"
)

for file in "${FILES_TO_REMOVE[@]}"; do
    if [ -f "$file" ]; then
        rm "$file"
        success "Removed: $file"
    fi
done

# 2. Dọn dẹp scripts cũ không cần thiết
log "🔧 Cleaning up old scripts..."
SCRIPTS_TO_REMOVE=(
    "scripts/test-snap-docker-compose.sh"
    "scripts/test-snap-fix-remote.sh"
    "scripts/fix-snap-compose.sh"
    "scripts/test-variable-escaping.sh"
    "scripts/test-docker-install.sh"
    "scripts/test-remote-deploy.sh"
    "scripts/manage-compose-prod.sh"
)

for script in "${SCRIPTS_TO_REMOVE[@]}"; do
    if [ -f "$script" ]; then
        rm "$script"
        success "Removed: $script"
    fi
done

# 3. Tối ưu hóa docker-compose files
log "🐳 Optimizing Docker Compose files..."

# Giữ lại file chính, xóa file dev riêng biệt
if [ -f "docker-compose.dev.yml" ]; then
    rm "docker-compose.dev.yml"
    success "Removed docker-compose.dev.yml (will use profiles instead)"
fi

# 4. Cập nhật package.json - xóa scripts cũ
log "📦 Cleaning up package.json scripts..."

# 5. Tạo cấu trúc thư mục sạch
log "📁 Creating clean directory structure..."
mkdir -p {logs,backups,ssl,nginx/logs,tmp}

# 6. Cập nhật .gitignore
log "📝 Updating .gitignore..."
cat > .gitignore << 'EOF'
# Dependencies
node_modules/
*/node_modules/

# Build outputs
.next/
dist/
build/

# Environment files
.env
.env.local
.env.development.local
.env.test.local
.env.production.local
.env.prod

# Logs
logs/
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Runtime data
pids/
*.pid
*.seed
*.pid.lock

# Coverage directory used by tools like istanbul
coverage/
*.lcov

# nyc test coverage
.nyc_output

# Dependency directories
jspm_packages/

# Optional npm cache directory
.npm

# Optional eslint cache
.eslintcache

# Optional REPL history
.node_repl_history

# Output of 'npm pack'
*.tgz

# Yarn Integrity file
.yarn-integrity

# parcel-bundler cache (https://parceljs.org/)
.cache
.parcel-cache

# next.js build output
.next

# nuxt.js build output
.nuxt

# vuepress build output
.vuepress/dist

# Serverless directories
.serverless

# FuseBox cache
.fusebox/

# DynamoDB Local files
.dynamodb/

# TernJS port file
.tern-port

# Docker
.dockerignore

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# Project specific
backups/
backup_*/
ssl/
tmp/
*.bak
*.backup

# Database
*.sqlite
*.sqlite3
*.db

# Prisma
prisma/migrations/
EOF

success "Updated .gitignore"

# 7. Dọn dẹp node_modules
log "🗑️  Cleaning node_modules..."
find . -name "node_modules" -type d -exec rm -rf {} + 2>/dev/null || true
find . -name "bun.lockb" -exec rm -f {} + 2>/dev/null || true

success "Cleaned node_modules"

# 8. Hiển thị kết quả
log "📊 CLEANUP SUMMARY"
echo "=================="
echo "📁 Current directory structure:"
tree -L 2 -I 'node_modules|.git' . || ls -la

echo ""
echo "📝 Remaining files:"
echo "- Core: $(ls *.{json,yml,ts,js} 2>/dev/null | wc -l) files"
echo "- Scripts: $(ls scripts/ 2>/dev/null | wc -l) files"
echo "- Docs: $(ls *.md 2>/dev/null | wc -l) files"

echo ""
success "🎉 Project cleanup completed!"
log "💾 Backup saved in: $BACKUP_DIR"
log "🔄 Run 'bun install' in api/ and site/ to reinstall dependencies"
