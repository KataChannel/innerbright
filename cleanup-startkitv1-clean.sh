#!/bin/bash

# 🧹 KataCore StartKit v1 Clean - Cleanup Script
# Remove all old deployment files and keep only the clean v1 system

set -e

# Color codes
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

# Logging functions
log() { echo -e "${GREEN}[$(date +'%H:%M:%S')]${NC} $1"; }
info() { echo -e "${CYAN}ℹ️  $1${NC}"; }
success() { echo -e "${GREEN}✅ $1${NC}"; }
warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
error() { echo -e "${RED}❌ $1${NC}"; exit 1; }

# Show banner
show_banner() {
    echo -e "${BLUE}"
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════════════════════╗
║               🧹 KataCore StartKit v1 Clean - Cleanup                       ║
║                                                                              ║
║               Converting to Clean Minimal Deployment                        ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# Files to keep (StartKit v1 Clean)
KEEP_FILES=(
    # Core StartKit v1 Clean files
    "deploy-startkitv1-clean.sh"
    "docker-compose.startkitv1-clean.yml"
    "test-startkitv1-clean.sh"
    "cleanup-startkitv1-clean.sh"
    "README-startkitv1-clean.md"
    
    # Environment files
    ".env"
    ".env.example"
    ".gitignore"
    
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
    "deploy-startkitv1.sh"
    "deploy-complete.sh"
    "deploy-simple.sh"
    "deploy-guide.sh"
    "startkit-deployer.sh"
    "setup-nginx-server.sh"
    "autopush-git.sh"
    "cleanup-startkitv1.sh"
    "cleanup-v2.sh"
    "test-deployment.sh"
    "test-startkitv1.sh"
    
    # Old quick start scripts
    "quick-start.sh"
    "quick-start-v2.sh"
    "quick-start-server.sh"
    "quick-push.sh"
    "quick-start.sh.v1-backup"
    
    # Old docker files
    "docker-compose.local.yml"
    "docker-compose.prod.yml"
    "docker-compose.startkitv1.yml"
    
    # Old environment files
    ".env.startkitv1"
    ".env.prod.template"
    
    # Old documentation
    "README-startkitv1.md"
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

# Backup old files
backup_old_files() {
    log "📦 Creating backup of old deployment system..."
    
    local backup_dir="backup-old-deployment-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$backup_dir"
    
    local backup_count=0
    
    for file in "${REMOVE_FILES[@]}"; do
        if [[ -e "$file" ]]; then
            if [[ -d "$file" ]]; then
                cp -r "$file" "$backup_dir/"
                ((backup_count++))
            else
                cp "$file" "$backup_dir/"
                ((backup_count++))
            fi
        fi
    done
    
    if [[ $backup_count -gt 0 ]]; then
        success "Backed up $backup_count items to $backup_dir"
    else
        info "No files to backup"
        rmdir "$backup_dir"
    fi
}

# Remove old files
remove_old_files() {
    log "🗑️  Removing old deployment files..."
    
    local removed_count=0
    
    for file in "${REMOVE_FILES[@]}"; do
        if [[ -e "$file" ]]; then
            if [[ -d "$file" ]]; then
                rm -rf "$file"
                success "Removed directory: $file"
                ((removed_count++))
            else
                rm -f "$file"
                success "Removed file: $file"
                ((removed_count++))
            fi
        fi
    done
    
    if [[ $removed_count -gt 0 ]]; then
        success "Removed $removed_count old files/directories"
    else
        info "No old files to remove"
    fi
}

# Update README.md to point to clean version
update_main_readme() {
    log "📝 Updating main README.md..."
    
    if [[ -f "README.md" ]]; then
        # Add reference to clean version at the top
        cat > "README.md" << 'EOF'
# KataCore StartKit v1 Clean

🚀 **Clean, minimal, and production-ready deployment system**

## Quick Start

```bash
# Make executable
chmod +x deploy-startkitv1-clean.sh

# Simple deployment (IP-based)
./deploy-startkitv1-clean.sh deploy-simple YOUR_IP

# Full deployment (Domain + SSL)
./deploy-startkitv1-clean.sh deploy-full YOUR_DOMAIN

# Guided deployment
./deploy-startkitv1-clean.sh deploy-guide
```

## Features

- ✅ **Auto-generate secure environment** on first deployment
- ✅ **Complete Docker stack** (API, Site, PostgreSQL, Redis, MinIO, pgAdmin)
- ✅ **Nginx reverse proxy** with SSL support
- ✅ **Single command deployment**
- ✅ **Two deployment modes** (Simple IP / Full Domain)
- ✅ **Git integration** with auto-commit

## Documentation

See [README-startkitv1-clean.md](README-startkitv1-clean.md) for complete documentation.

## Services

| Service | Internal | External |
|---------|----------|----------|
| Next.js Site | :3000 | https://domain.com |
| NestJS API | :3001 | https://domain.com/api |
| PostgreSQL | :5432 | Internal only |
| Redis | :6379 | Internal only |
| MinIO | :9000 | https://domain.com/minio |
| pgAdmin | :5050 | https://domain.com/pgadmin |

## Support

```bash
# Test deployment
./deploy-startkitv1-clean.sh test-deployment

# View help
./deploy-startkitv1-clean.sh --help

# Cleanup
./deploy-startkitv1-clean.sh cleanup
```

---

**KataCore StartKit v1 Clean** - Production deployment made simple! 🚀
EOF
        success "Updated main README.md"
    fi
}

# Create new package.json with clean scripts
update_package_json() {
    log "📦 Updating package.json..."
    
    if [[ -f "package.json" ]]; then
        # Update package.json with clean scripts
        cat > "package.json" << 'EOF'
{
  "name": "katacore-startkitv1-clean",
  "version": "1.0.0",
  "description": "KataCore StartKit v1 Clean - Production-ready deployment system",
  "main": "deploy-startkitv1-clean.sh",
  "scripts": {
    "deploy:simple": "./deploy-startkitv1-clean.sh deploy-simple",
    "deploy:full": "./deploy-startkitv1-clean.sh deploy-full",
    "deploy:guide": "./deploy-startkitv1-clean.sh deploy-guide",
    "test": "./test-startkitv1-clean.sh",
    "cleanup": "./cleanup-startkitv1-clean.sh",
    "dev:api": "cd api && npm run dev",
    "dev:site": "cd site && npm run dev",
    "build:api": "cd api && npm run build",
    "build:site": "cd site && npm run build",
    "start": "docker-compose -f docker-compose.startkitv1-clean.yml up -d",
    "stop": "docker-compose -f docker-compose.startkitv1-clean.yml down",
    "logs": "docker-compose -f docker-compose.startkitv1-clean.yml logs -f"
  },
  "keywords": [
    "katacore",
    "startkit",
    "deployment",
    "docker",
    "nginx",
    "production"
  ],
  "author": "KataCore Team",
  "license": "MIT",
  "repository": {
    "type": "git",
    "url": "https://github.com/katacore/startkitv1-clean"
  },
  "devDependencies": {
    "bun": "latest"
  }
}
EOF
        success "Updated package.json with clean scripts"
    fi
}

# Create .gitignore
create_gitignore() {
    log "📝 Creating .gitignore..."
    
    cat > ".gitignore" << 'EOF'
# Environment files
.env
.env.local
.env.production

# Logs
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*
logs/

# Runtime data
pids
*.pid
*.seed
*.pid.lock

# Coverage directory used by tools like istanbul
coverage/

# nyc test coverage
.nyc_output

# Dependency directories
node_modules/
jspm_packages/

# Optional npm cache directory
.npm

# Optional eslint cache
.eslintcache

# Output of 'npm pack'
*.tgz

# Yarn Integrity file
.yarn-integrity

# dotenv environment variables file
.env

# next.js build output
.next

# Nuxt.js build / generate output
.nuxt
dist

# Gatsby files
.cache/
public

# Storybook build outputs
.out
.storybook-out

# IDE files
.vscode/
.idea/
*.swp
*.swo

# OS files
.DS_Store
Thumbs.db

# Docker
docker-compose.override.yml

# Backup files
backup-*/
*.backup

# SSL certificates
*.crt
*.key
*.pem

# Nginx configs (generated)
nginx-startkitv1.conf
EOF
    
    success "Created .gitignore"
}

# Show cleanup summary
show_cleanup_summary() {
    echo ""
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                           🎉 CLEANUP COMPLETE!                              ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    echo -e "${CYAN}📊 KataCore StartKit v1 Clean is now ready!${NC}"
    echo ""
    
    echo -e "${CYAN}🚀 Quick Start:${NC}"
    echo -e "   chmod +x deploy-startkitv1-clean.sh"
    echo -e "   ./deploy-startkitv1-clean.sh deploy-simple YOUR_IP"
    echo -e "   ./deploy-startkitv1-clean.sh deploy-full YOUR_DOMAIN"
    echo ""
    
    echo -e "${CYAN}📋 Available Commands:${NC}"
    echo -e "   deploy-simple IP        - Simple deployment with IP"
    echo -e "   deploy-full DOMAIN      - Full deployment with domain + SSL"
    echo -e "   deploy-guide            - Interactive guided deployment"
    echo -e "   test-deployment         - Test current deployment"
    echo -e "   cleanup                 - Clean up deployment"
    echo ""
    
    echo -e "${CYAN}📖 Documentation:${NC}"
    echo -e "   README-startkitv1-clean.md - Complete documentation"
    echo -e "   ./deploy-startkitv1-clean.sh --help - Command help"
    echo ""
    
    echo -e "${CYAN}🔧 Test Your Setup:${NC}"
    echo -e "   ./test-startkitv1-clean.sh"
    echo ""
}

# Confirm cleanup
confirm_cleanup() {
    echo -e "${YELLOW}⚠️  This will remove all old deployment files and keep only the clean v1 system.${NC}"
    echo ""
    echo "Files to be removed:"
    for file in "${REMOVE_FILES[@]}"; do
        if [[ -e "$file" ]]; then
            echo "  - $file"
        fi
    done
    echo ""
    
    read -p "Do you want to continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        info "Cleanup cancelled"
        exit 0
    fi
}

# Main cleanup function
main() {
    show_banner
    
    # Confirm cleanup
    confirm_cleanup
    
    # Make scripts executable
    chmod +x deploy-startkitv1-clean.sh 2>/dev/null || true
    chmod +x test-startkitv1-clean.sh 2>/dev/null || true
    chmod +x cleanup-startkitv1-clean.sh 2>/dev/null || true
    
    # Backup old files
    backup_old_files
    
    # Remove old files
    remove_old_files
    
    # Update configuration files
    update_main_readme
    update_package_json
    create_gitignore
    
    # Show summary
    show_cleanup_summary
    
    success "KataCore StartKit v1 Clean is ready for deployment!"
}

# Run main function
main "$@"
