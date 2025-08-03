#!/bin/bash

# =============================================================================
# NO-PWA Build Script - Tắt hoàn toàn PWA để tối ưu performance
# =============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Helper functions
print_status() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

print_status "🚫 Building Next.js WITHOUT PWA (Performance Optimized)"

# Clean previous builds
print_status "🧹 Cleaning previous builds..."
rm -rf .next
rm -rf node_modules/.cache
rm -rf public/sw.js
rm -rf public/workbox-*.js
rm -rf public/swe-worker-*.js

# Environment variables to DISABLE PWA
export NODE_ENV=production
export NEXT_TELEMETRY_DISABLED=1
export DISABLE_PWA_BUILD=true
export BUILD_SITE_ONLY=true
export SKIP_ENV_VALIDATION=true

# Memory optimization
export NODE_OPTIONS="--max-old-space-size=4096 --max-semi-space-size=1024"

print_status "🔧 Environment Settings:"
echo "  - PWA: DISABLED"
echo "  - NODE_ENV: $NODE_ENV"
echo "  - Memory: 4GB heap limit"
echo "  - Site-only: Enabled"

# Build without PWA
print_status "🔨 Building Next.js (NO PWA)..."

if command -v bun >/dev/null 2>&1; then
    print_status "Using Bun for faster build..."
    time bun run build
else
    print_status "Using npm..."
    time npm run build
fi

# Verify build
if [ -d ".next" ]; then
    print_success "✅ Build completed successfully!"
    
    # Show build info
    BUILD_SIZE=$(du -sh .next | cut -f1)
    print_status "📦 Build size: $BUILD_SIZE"
    
    # Check if standalone exists
    if [ -d ".next/standalone" ]; then
        STANDALONE_SIZE=$(du -sh .next/standalone | cut -f1)
        print_status "📦 Standalone size: $STANDALONE_SIZE"
    fi
    
    # Verify NO PWA files exist
    if [ ! -f "public/sw.js" ]; then
        print_success "✅ PWA service worker NOT generated (as expected)"
    else
        print_warning "⚠️  PWA files still exist - check configuration"
    fi
    
    print_status "🎯 Build Summary:"
    echo "  - PWA: ❌ Disabled"
    echo "  - Service Worker: ❌ Not generated" 
    echo "  - Build size: $BUILD_SIZE"
    echo "  - Memory usage: Optimized"
    
else
    print_error "❌ Build failed!"
    exit 1
fi

print_success "🎉 NO-PWA build completed successfully!"
echo ""
echo "💡 To start the application:"
echo "  npm run start"
echo "  # or"
echo "  bun run start"
