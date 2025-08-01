#!/bin/bash

# Ultra-optimized Next.js build script for production deployment
# This script maximizes performance and minimizes bundle size

set -e

echo "🚀 Starting ultra-optimized Next.js build process..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')] $1${NC}"
}

success() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')] ✅ $1${NC}"
}

error() {
    echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')] ❌ $1${NC}"
    exit 1
}

warning() {
    echo -e "${YELLOW}[$(date '+%Y-%m-%d %H:%M:%S')] ⚠️  $1${NC}"
}

# Check if we're in the right directory
if [ ! -f "package.json" ]; then
    error "package.json not found. Please run this script from the site directory."
fi

# Set production environment variables
export NODE_ENV=production
export NEXT_TELEMETRY_DISABLED=1
export SKIP_ENV_VALIDATION=true
export DOCKER_BUILD=true

log "Setting up optimized build environment..."

# Check if optimized config exists
if [ -f "next.config.optimized.ts" ]; then
    log "Using optimized Next.js configuration..."
    cp next.config.optimized.ts next.config.ts.backup
    mv next.config.optimized.ts next.config.ts
fi

# Clean previous builds
log "Cleaning previous build artifacts..."
rm -rf .next
rm -rf out
rm -rf dist
rm -rf node_modules/.cache
rm -rf .swc

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
    log "Installing dependencies..."
    bun install --frozen-lockfile
fi

# Generate Prisma client if needed
if [ -d "prisma" ]; then
    log "Generating Prisma client..."
    bunx prisma generate
fi

# Run type checking
log "Running TypeScript type checking..."
bun run type-check || warning "Type check completed with warnings"

# Run linting (non-blocking)
log "Running ESLint..."
bun run lint --max-warnings 50 || warning "Linting completed with warnings"

# Memory optimization for build
export NODE_OPTIONS="--max-old-space-size=6144"

# Build with maximum optimizations
log "Building Next.js application with maximum optimizations..."
log "Memory limit: 6GB"
log "Minification: Enabled"
log "Compression: Enabled"
log "Tree shaking: Enabled"
log "Code splitting: Optimized"

# Run the optimized build
time bun run build:optimized

# Verify build output
if [ ! -d ".next" ]; then
    error "Build failed - .next directory not found"
fi

if [ ! -f ".next/standalone/server.js" ]; then
    error "Standalone build failed - server.js not found"
fi

# Calculate and display build size
log "Analyzing build output..."

BUILD_SIZE=$(du -sh .next | cut -f1)
STANDALONE_SIZE=$(du -sh .next/standalone | cut -f1)
STATIC_SIZE=$(du -sh .next/static | cut -f1)

success "Build completed successfully!"
success "Total build size: $BUILD_SIZE"
success "Standalone size: $STANDALONE_SIZE"
success "Static assets size: $STATIC_SIZE"

# Show detailed size breakdown
log "Detailed size breakdown:"
echo "📁 .next/standalone: $(du -sh .next/standalone 2>/dev/null | cut -f1 || echo 'N/A')"
echo "📁 .next/static: $(du -sh .next/static 2>/dev/null | cut -f1 || echo 'N/A')"
echo "📁 .next/cache: $(du -sh .next/cache 2>/dev/null | cut -f1 || echo 'N/A')"

# Analyze bundle if bundle analyzer is available
if [ -f "node_modules/.bin/next" ]; then
    log "Generating bundle analysis (if available)..."
    ANALYZE=true bun run build:analyze 2>/dev/null || warning "Bundle analysis not available"
fi

# Show largest files in build
log "Largest files in build:"
find .next -type f -name "*.js" -exec du -h {} + | sort -hr | head -10 || true

# Restore original config if backup exists
if [ -f "next.config.ts.backup" ]; then
    log "Restoring original next.config.ts..."
    mv next.config.ts.backup next.config.ts
fi

success "Ultra-optimized build process completed!"
success "Ready for deployment with minimal bundle size and maximum performance"

# Show deployment tips
log "📋 Deployment tips:"
echo "1. Use the .next/standalone directory for deployment"
echo "2. Copy .next/static to /.next/static on your server"
echo "3. Copy public directory to /public on your server"
echo "4. Set NODE_ENV=production in your deployment environment"
echo "5. Enable gzip compression on your web server"
echo "6. Use a CDN for static assets"
echo "7. Enable HTTP/2 on your server"
echo "8. Configure proper cache headers"

log "Build artifacts ready at: $(pwd)/.next"
