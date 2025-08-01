#!/bin/bash

# =============================================================================
# System Health Check & Optimization Validator
# Kiểm tra tình trạng build và deployment
# =============================================================================

set -euo pipefail

readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly NC='\033[0m'

echo -e "${BLUE}🔍 Innerbright Build & Deploy Health Check${NC}"
echo ""

# Check build requirements
echo -e "${YELLOW}🔧 Checking build requirements...${NC}"

# Check Node.js
if command -v node >/dev/null 2>&1; then
    NODE_VERSION=$(node --version)
    echo -e "✅ Node.js: $NODE_VERSION"
else
    echo -e "❌ Node.js not found"
fi

# Check Bun
if command -v bun >/dev/null 2>&1; then
    BUN_VERSION=$(bun --version)
    echo -e "✅ Bun: $BUN_VERSION"
else
    echo -e "⚠️  Bun not found (npm will be used)"
fi

# Check Docker
if command -v docker >/dev/null 2>&1; then
    DOCKER_VERSION=$(docker --version)
    echo -e "✅ Docker: $DOCKER_VERSION"
else
    echo -e "❌ Docker not found"
fi

# Check memory availability
TOTAL_MEM=$(free -m | awk 'NR==2{printf "%.0f", $2}' 2>/dev/null || echo "Unknown")
AVAILABLE_MEM=$(free -m | awk 'NR==2{printf "%.0f", $7}' 2>/dev/null || echo "Unknown")
echo -e "💾 Memory: ${AVAILABLE_MEM}MB available / ${TOTAL_MEM}MB total"

if [ "$AVAILABLE_MEM" != "Unknown" ] && [ "$AVAILABLE_MEM" -lt 2048 ]; then
    echo -e "⚠️  Warning: Low memory detected. Consider increasing memory limit."
fi

echo ""

# Check project structure
echo -e "${YELLOW}📁 Checking project structure...${NC}"

REQUIRED_FILES=(
    "next.config.ts"
    "package.json"
    "Dockerfile"
    "src/app"
    "public"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ -e "$file" ]; then
        echo -e "✅ $file"
    else
        echo -e "❌ $file (missing)"
    fi
done

echo ""

# Check scripts
echo -e "${YELLOW}📜 Checking deployment scripts...${NC}"

SCRIPTS=(
    "build-standalone-optimized.sh"
    "build-docker-optimized.sh"
    "deploy-ultra-fast.sh"
    "quick-sync.sh"
)

for script in "${SCRIPTS[@]}"; do
    if [ -f "$script" ]; then
        if [ -x "$script" ]; then
            echo -e "✅ $script (executable)"
        else
            echo -e "⚠️  $script (not executable)"
            chmod +x "$script"
        fi
    else
        echo -e "❌ $script (missing)"
    fi
done

echo ""

# Check configuration
echo -e "${YELLOW}⚙️  Checking configuration...${NC}"

if [ -f ".env.deploy" ]; then
    echo -e "✅ .env.deploy found"
    
    # Check if template values are still there
    if grep -q "your-server.com" .env.deploy 2>/dev/null; then
        echo -e "⚠️  .env.deploy contains template values - please customize"
    fi
else
    echo -e "⚠️  .env.deploy not found"
    if [ -f ".env.deploy.example" ]; then
        echo -e "💡 Run: cp .env.deploy.example .env.deploy"
    fi
fi

# Check next.config.ts
if grep -q "output: 'standalone'" next.config.ts 2>/dev/null; then
    echo -e "✅ Standalone output configured"
else
    echo -e "❌ Standalone output not configured in next.config.ts"
fi

echo ""

# Performance recommendations
echo -e "${YELLOW}⚡ Performance recommendations...${NC}"

CPU_CORES=$(nproc 2>/dev/null || echo "Unknown")
echo -e "🖥️  CPU cores: $CPU_CORES"

if [ "$CPU_CORES" != "Unknown" ]; then
    if [ "$CPU_CORES" -ge 4 ]; then
        echo -e "✅ Sufficient CPU cores for parallel builds"
    else
        echo -e "⚠️  Consider using build:fast for single-core systems"
    fi
fi

# Check disk space
DISK_SPACE=$(df -h . | awk 'NR==2 {print $4}' 2>/dev/null || echo "Unknown")
echo -e "💽 Available disk space: $DISK_SPACE"

echo ""

# Build test
echo -e "${YELLOW}🧪 Testing build configuration...${NC}"

# Test package.json scripts
if grep -q "build:cloud-optimized" package.json 2>/dev/null; then
    echo -e "✅ Cloud-optimized build script found"
else
    echo -e "❌ Cloud-optimized build script missing"
fi

if grep -q "build:docker-safe" package.json 2>/dev/null; then
    echo -e "✅ Docker-safe build script found"
else
    echo -e "❌ Docker-safe build script missing"
fi

echo ""

# Summary and recommendations
echo -e "${BLUE}📋 Summary & Recommendations${NC}"
echo ""

echo -e "${GREEN}Quick Start Commands:${NC}"
echo "  make setup           # Initial setup"
echo "  make build           # Build standalone"
echo "  make deploy          # Deploy to cloud"
echo "  make quick-sync      # Quick updates"
echo ""

echo -e "${GREEN}Memory-Optimized Builds:${NC}"
echo "  Low memory (< 2GB):  BUILD_MEMORY=1024 make build"
echo "  Standard (2-4GB):    BUILD_MEMORY=2048 make build"
echo "  High memory (> 4GB): BUILD_MEMORY=4096 make build"
echo ""

echo -e "${GREEN}Deployment Options:${NC}"
echo "  Full deployment:     make deploy"
echo "  Development sync:    make quick-sync"
echo "  Docker only:         make build-docker"
echo ""

# Final status
echo -e "${BLUE}🎯 System Status:${NC}"
if command -v docker >/dev/null 2>&1 && [ -f "next.config.ts" ] && [ -f "package.json" ]; then
    echo -e "${GREEN}✅ Ready for deployment!${NC}"
else
    echo -e "${YELLOW}⚠️  Some requirements missing - check above${NC}"
fi

echo -e "${BLUE}🚀 Run 'make help' for available commands${NC}"
