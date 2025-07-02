#!/bin/bash

# KataCore StartKit v2 - Cleanup Script
# Tối giản hóa codebase bằng cách xóa các file không cần thiết

set -euo pipefail

readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly NC='\033[0m'

log() {
    echo -e "${GREEN}[$(date +'%H:%M:%S')]${NC} $1"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

show_banner() {
    echo -e "${GREEN}"
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════════════════════╗
║                     🧹 KataCore StartKit v2 Cleanup                         ║
║                                                                              ║
║                     Tối giản hóa codebase cho v2                            ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# Danh sách file và thư mục cần xóa (không cần thiết cho v2)
cleanup_files() {
    log "🧹 Bắt đầu tối giản hóa codebase..."
    
    # Xóa các script deployer cũ (v1)
    local old_deployers=(
        "universal-deployer.sh"
        "quick-deploy.sh"
        "demo-nginx-config.sh"
        "fix-env-prod.sh"
        "quick-ssh-setup.sh"
        "test-config-system.sh"
        "test-env-gen.sh"
        "local-test.sh"
    )
    
    for file in "${old_deployers[@]}"; do
        if [[ -f "$file" ]]; then
            warning "Xóa deployer cũ: $file"
            rm -f "$file"
        fi
    done
    
    # Xóa các helper script không cần thiết
    local scripts_to_remove=(
        "scripts/pre-deploy-check.sh"
        "scripts/post-deploy-verify.sh"
        "scripts/ssh-keygen-setup.sh" 
        "scripts/validate-env.sh"
        "scripts/cleanup-deploy.sh"
        "scripts/fix-first-deployment.sh"
        "scripts/quick-deployment-fix.sh"
    )
    
    for script in "${scripts_to_remove[@]}"; do
        if [[ -f "$script" ]]; then
            warning "Xóa helper script: $script"
            rm -f "$script"
        fi
    done
    
    # Xóa backup configs nginx cũ
    if [[ -d "nginx/conf.d/backup" ]]; then
        warning "Xóa nginx backup configs"
        rm -rf "nginx/conf.d/backup"
    fi
    
    # Xóa các file backup nginx cũ
    find nginx/conf.d/ -name "*.backup*" -delete 2>/dev/null || true
    find nginx/conf.d/ -name "*-20*" -delete 2>/dev/null || true
    
    # Xóa các file env backup cũ
    find . -maxdepth 1 -name ".env.prod.backup*" -delete 2>/dev/null || true
    
    # Xóa các file log cũ
    find . -name "*.log" -delete 2>/dev/null || true
    
    # Xóa cache directories cũ
    rm -rf .deploy-cache 2>/dev/null || true
    rm -rf .deploy-logs 2>/dev/null || true
    
    # Xóa file docs không cần thiết
    local docs_to_remove=(
        "docs/SSH_SETUP_GUIDE.md"
        "docs/CUSTOMIZATION.md"
        "DEPLOYMENT_GUIDE.md"
        "ENHANCED_CONFIG_SUMMARY.md"
    )
    
    for doc in "${docs_to_remove[@]}"; do
        if [[ -f "$doc" ]]; then
            warning "Xóa documentation cũ: $doc"
            rm -f "$doc"
        fi
    done
    
    success "Hoàn thành tối giản hóa codebase"
}

# Tạo file .gitignore tối giản
create_minimal_gitignore() {
    log "📝 Tạo .gitignore tối giản..."
    
    cat > .gitignore << 'EOF'
# KataCore StartKit v2 - Minimal .gitignore

# Environment files
.env
.env.local
.env.prod
.env.prod.backup*
*.env.backup*

# Dependencies
node_modules/
.bun

# Build outputs
.next/
dist/
build/

# Logs
*.log
logs/

# Deployment
.deploy-cache/
.deploy-logs/
deploy-temp-*/
ssl-temp/

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Docker
.dockerignore

# Runtime
.pid
.seed
*.seed
*.tgz
EOF
    
    success ".gitignore tối giản đã được tạo"
}

# Cập nhật CHANGELOG
update_changelog() {
    log "📝 Cập nhật CHANGELOG cho v2..."
    
    # Backup changelog cũ nếu có
    if [[ -f "CHANGELOG.md" ]]; then
        cp "CHANGELOG.md" "CHANGELOG.md.v1-backup"
    fi
    
    cat > CHANGELOG.md << 'EOF'
# Changelog - KataCore StartKit v2

## [2.0.0] - 2025-01-02

### 🚀 Major Changes - StartKit v2
- **Auto-Environment Generation**: Tự động tạo `.env.prod` với credentials an toàn
- **Auto-SSL Configuration**: Tự động cấu hình SSL certificate với Let's Encrypt  
- **Smart Deployment Detection**: Tự động phát hiện deployment lần đầu vs update
- **Minimal Configuration**: Chỉ cần IP server và domain
- **Update Management**: Cập nhật NextJS/NestJS/Prisma tự động
- **Enhanced Security**: Auto-generate password 16-64 ký tự

### ✨ New Features
- Single command deployment: `./startkit-deployer.sh --host IP --domain DOMAIN`
- Auto-detect first deployment vs updates
- Auto-generate secure environment variables
- Auto-configure SSL certificates and renewal
- Smart update management (only update what changed)
- Simplified codebase (removed 80% of helper scripts)

### 🔧 Improvements
- Consolidated deployment logic into single script
- Removed redundant helper scripts
- Streamlined configuration process
- Enhanced error handling and logging
- Better deployment status reporting

### 🗑️ Removed (Deprecated in v2)
- `universal-deployer.sh` (replaced by `startkit-deployer.sh`)
- `quick-deploy.sh` and related scripts
- Multiple helper scripts in `scripts/` directory
- Manual environment configuration
- Complex deployment modes

### 📝 Migration Guide from v1 to v2
1. Use new deployment command: `./startkit-deployer.sh --host IP --domain DOMAIN`
2. Remove old `.env.prod` file (will be auto-generated)
3. Update npm scripts to use new deployer
4. SSL now auto-configured (no manual setup needed)

---

## [1.0.0] - Previous Version
- Legacy deployment system
- Manual environment configuration
- Multiple deployment scripts
- Manual SSL setup
EOF
    
    success "CHANGELOG.md đã được cập nhật cho v2"
}

# Tạo quick start script mới cho v2
create_quick_start_v2() {
    log "📝 Tạo quick-start script mới cho v2..."
    
    cat > quick-start-v2.sh << 'EOF'
#!/bin/bash

# KataCore StartKit v2 - Quick Start
# Guided setup cho deployment nhanh

set -euo pipefail

readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m'

show_banner() {
    echo -e "${BLUE}"
    cat << 'BANNER'
╔══════════════════════════════════════════════════════════════════════════════╗
║                     🚀 KataCore StartKit v2 Quick Start                     ║
║                                                                              ║
║                     Auto-deployment với SSL và Environment                  ║
╚══════════════════════════════════════════════════════════════════════════════╝
BANNER
    echo -e "${NC}"
}

main() {
    show_banner
    
    echo -e "${GREEN}Chọn option deployment:${NC}"
    echo "1. 🚀 Deploy lần đầu (chỉ IP server)"
    echo "2. 🔒 Deploy với SSL (IP + domain)"  
    echo "3. ⬆️ Cập nhật deployment hiện tại"
    echo "4. 🧹 Clean deployment (xóa data cũ)"
    echo ""
    
    read -p "Chọn option (1-4): " choice
    
    case $choice in
        1)
            read -p "Nhập IP server: " server_ip
            echo "🚀 Deploying với IP: $server_ip"
            ./startkit-deployer.sh --host "$server_ip"
            ;;
        2)
            read -p "Nhập IP server: " server_ip
            read -p "Nhập domain: " domain
            echo "🔒 Deploying với SSL: $server_ip -> $domain"
            ./startkit-deployer.sh --host "$server_ip" --domain "$domain"
            ;;
        3)
            read -p "Nhập IP server: " server_ip
            echo "⬆️ Updating deployment: $server_ip"
            ./startkit-deployer.sh --host "$server_ip" --update
            ;;
        4)
            read -p "Nhập IP server: " server_ip
            echo "🧹 Clean deployment: $server_ip"
            ./startkit-deployer.sh --host "$server_ip" --clean
            ;;
        *)
            echo "❌ Option không hợp lệ"
            exit 1
            ;;
    esac
}

main "$@"
EOF
    
    chmod +x quick-start-v2.sh
    success "quick-start-v2.sh đã được tạo"
}

# Main function
main() {
    show_banner
    
    log "🧹 Bắt đầu tối giản hóa KataCore StartKit v2..."
    
    # Backup file quan trọng trước khi cleanup
    if [[ -f "quick-start.sh" ]]; then
        cp "quick-start.sh" "quick-start.sh.v1-backup"
        warning "Backup quick-start.sh v1"
    fi
    
    cleanup_files
    create_minimal_gitignore
    update_changelog
    create_quick_start_v2
    
    echo ""
    success "🎉 Hoàn thành tối giản hóa StartKit v2!"
    echo ""
    echo -e "${GREEN}📋 Tóm tắt thay đổi:${NC}"
    echo "   ✅ Xóa các deployer script cũ (v1)"
    echo "   ✅ Xóa helper scripts không cần thiết" 
    echo "   ✅ Xóa backup files và logs cũ"
    echo "   ✅ Tạo .gitignore tối giản"
    echo "   ✅ Cập nhật CHANGELOG cho v2"
    echo "   ✅ Tạo quick-start-v2.sh mới"
    echo ""
    echo -e "${YELLOW}🚀 Sử dụng StartKit v2:${NC}"
    echo "   • Deploy lần đầu: ./startkit-deployer.sh --host YOUR_IP"
    echo "   • Deploy với SSL: ./startkit-deployer.sh --host YOUR_IP --domain YOUR_DOMAIN"
    echo "   • Quick start: ./quick-start-v2.sh"
}

main "$@"
