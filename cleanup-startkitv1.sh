#!/bin/bash

# 🧹 KataCore StartKit v1 - Cleanup Script
# Remove old complex deployment files and keep only clean v1 files

set -e

# Color codes
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

log() { echo -e "${GREEN}[$(date +'%H:%M:%S')]${NC} $1"; }
info() { echo -e "${CYAN}ℹ️  $1${NC}"; }
success() { echo -e "${GREEN}✅ $1${NC}"; }
warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
error() { echo -e "${RED}❌ $1${NC}"; exit 1; }

show_banner() {
    echo -e "${BLUE}"
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════════════════════╗
║               🧹 KataCore StartKit v1 - Cleanup                             ║
║                                                                              ║
║               Converting to Clean Minimal Deployment                        ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# Files to keep for StartKit v1
KEEP_FILES=(
    # Core StartKit v1 files
    "deploy-startkitv1.sh"
    ".env.startkitv1"
    "docker-compose.startkitv1.yml"
    "README-startkitv1.md"
    "test-startkitv1.sh"
    
    # Essential project files
    "package.json"
    "bun.lock"
    "LICENSE"
    "README.md"
    "CHANGELOG.md"
    
    # Source code directories
    "api/"
    "site/"
    "docs/"
)

# Files to remove (old deployment system)
REMOVE_FILES=(
    # Old deployment scripts
    "deploy-complete.sh"
    "deploy-simple.sh"
    "deploy-guide.sh"
    "startkit-deployer.sh"
    "setup-nginx-server.sh"
    "autopush-git.sh"
    "cleanup-v2.sh"
    "test-deployment.sh"
    
    # Old quick start scripts
    "quick-start.sh"
    "quick-start-v2.sh"
    "quick-start-server.sh"
    "quick-push.sh"
    "quick-start.sh.v1-backup"
    
    # Old docker files
    "docker-compose.local.yml"
    "docker-compose.prod.yml"
    
    # Old documentation
    "DEPLOYMENT_GUIDE_SERVER.md"
    "DEPLOYMENT_README.md"
    "DEPLOYMENT_SUMMARY.md"
    "NGINX_AUTOMATION_GUIDE.md"
    "NGINX_AUTOMATION_SUMMARY.md"
    "NGINX_SETUP_GUIDE.md"
    "OPTIMIZATION_SUMMARY.md"
    "SIMPLE_DEPLOYMENT.md"
    
    # Old configuration directories
    "nginx/"
    "scripts/"
    "ssl-temp/"
)

# Backup old files before removal
backup_old_files() {
    log "📦 Creating backup of old deployment system..."
    
    local backup_dir="backup-old-deployment-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$backup_dir"
    
    for file in "${REMOVE_FILES[@]}"; do
        if [[ -e "$file" ]]; then
            if [[ -d "$file" ]]; then
                cp -r "$file" "$backup_dir/"
            else
                cp "$file" "$backup_dir/"
            fi
            success "Backed up: $file"
        fi
    done
    
    success "Backup created in: $backup_dir"
}

# Remove old files
remove_old_files() {
    log "🗑️  Removing old deployment files..."
    
    for file in "${REMOVE_FILES[@]}"; do
        if [[ -e "$file" ]]; then
            if [[ -d "$file" ]]; then
                rm -rf "$file"
                success "Removed directory: $file"
            else
                rm -f "$file"
                success "Removed file: $file"
            fi
        fi
    done
}

# Rename StartKit v1 files to standard names
setup_startkitv1_files() {
    log "🔄 Setting up StartKit v1 files..."
    
    # Copy template to standard .env.example
    if [[ -f ".env.startkitv1" ]]; then
        cp ".env.startkitv1" ".env.example"
        success "Created .env.example from StartKit v1 template"
    fi
    
    # Copy docker-compose file to standard name
    if [[ -f "docker-compose.startkitv1.yml" ]]; then
        cp "docker-compose.startkitv1.yml" "docker-compose.prod.yml"
        success "Created docker-compose.prod.yml from StartKit v1"
    fi
    
    # Rename main deployment script
    if [[ -f "deploy-startkitv1.sh" ]]; then
        cp "deploy-startkitv1.sh" "deploy.sh"
        chmod +x "deploy.sh"
        success "Created deploy.sh (main deployment script)"
    fi
    
    # Rename test script
    if [[ -f "test-startkitv1.sh" ]]; then
        cp "test-startkitv1.sh" "test.sh"
        chmod +x "test.sh"
        success "Created test.sh (test suite)"
    fi
}

# Update README.md with StartKit v1 info
update_readme() {
    log "📝 Updating README.md with StartKit v1 information..."
    
    cat > "README.md" << 'EOF'
# 🚀 KataCore StartKit v1

**Clean, minimal, and production-ready deployment system for modern web applications.**

## Features

✅ **Auto-generate secure passwords** on first deployment  
✅ **Docker deployment** for all services (API, Site, PostgreSQL, Redis, MinIO, pgAdmin)  
✅ **Nginx reverse proxy** with SSL support  
✅ **Dynamic IP/Domain** configuration  
✅ **Two deployment modes**: Simple (IP-based) and Full (Domain with SSL)  
✅ **Git integration** with auto-commit and push  

## Quick Start

```bash
# Make deployment script executable
chmod +x deploy.sh

# Simple deployment with IP
./deploy.sh deploy --ip 116.118.85.41

# Full deployment with domain + SSL
sudo ./deploy.sh full-deploy --domain innerbright.vn

# With options
./deploy.sh deploy --ip 116.118.85.41 --autopush --force-regen --verbose
```

## Architecture

- **API (NestJS)**: Port 3001 - Backend application
- **Site (Next.js)**: Port 3000 - Frontend application  
- **PostgreSQL**: Port 5432 - Database
- **Redis**: Port 6379 - Cache and sessions
- **MinIO**: Ports 9000/9001 - Object storage
- **pgAdmin**: Port 5050 - Database management

## Commands

| Command | Description |
|---------|-------------|
| `deploy --ip <IP>` | Simple deployment with IP |
| `full-deploy --domain <DOMAIN>` | Complete production setup with SSL |
| `--force-regen` | Force regenerate all passwords |
| `--autopush` | Auto commit and push to git |
| `--verbose` | Enable detailed logging |
| `--dry-run` | Preview changes without execution |

## Testing

```bash
# Run test suite
./test.sh

# Test deployment (dry run)
./deploy.sh deploy --ip 127.0.0.1 --dry-run --verbose
```

## Documentation

See `README-startkitv1.md` for complete documentation.

---

**KataCore StartKit v1** - Ready for production! 🚀
EOF
    
    success "Updated README.md"
}

# Show final status
show_final_status() {
    echo ""
    success "🎉 KataCore StartKit v1 Cleanup Completed!"
    echo ""
    
    echo -e "${BLUE}📁 Current Structure:${NC}"
    ls -la | grep -E "(deploy|test|docker-compose|\.env|README)" || true
    echo ""
    
    echo -e "${BLUE}🚀 Ready to Use:${NC}"
    echo -e "  • Main script: ${GREEN}deploy.sh${NC}"
    echo -e "  • Test suite: ${GREEN}test.sh${NC}"
    echo -e "  • Environment: ${GREEN}.env.example${NC}"
    echo -e "  • Docker config: ${GREEN}docker-compose.prod.yml${NC}"
    echo -e "  • Documentation: ${GREEN}README-startkitv1.md${NC}"
    echo ""
    
    echo -e "${BLUE}💡 Next Steps:${NC}"
    echo -e "  1. Run tests: ${YELLOW}./test.sh${NC}"
    echo -e "  2. Deploy: ${YELLOW}./deploy.sh deploy --ip <YOUR_IP>${NC}"
    echo -e "  3. Full setup: ${YELLOW}sudo ./deploy.sh full-deploy --domain <YOUR_DOMAIN>${NC}"
    echo ""
}

# Confirm cleanup
confirm_cleanup() {
    echo ""
    warning "This will remove all old deployment files and keep only StartKit v1 files."
    warning "A backup will be created before removal."
    echo ""
    read -p "Continue with cleanup? (y/N): " -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        info "Cleanup cancelled."
        exit 0
    fi
}

# Main execution
main() {
    show_banner
    confirm_cleanup
    backup_old_files
    remove_old_files
    setup_startkitv1_files
    update_readme
    show_final_status
}

main "$@"
