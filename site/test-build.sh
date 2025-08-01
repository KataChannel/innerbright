#!/bin/bash

# =============================================================================
# Quick Build Test - Verify build output for deployment
# =============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

print_status "🧪 Testing build configuration and output..."

# Check if we're in the right directory
if [ ! -f "package.json" ]; then
    print_error "Not in Next.js project directory"
    exit 1
fi

# Test 1: Quick build test
print_status "🔨 Test 1: Quick build with standalone output..."

# Set environment for standalone build
export NODE_ENV=production
export NEXT_TELEMETRY_DISABLED=1
export BUILD_SITE_ONLY=true
export DISABLE_PWA_BUILD=true
export STANDALONE_BUILD=true
export NODE_OPTIONS="--max-old-space-size=1024"

# Clean previous build
rm -rf .next

print_status "Starting build..."
if timeout 300s npm run build; then
    print_success "✅ Build completed"
else
    print_error "❌ Build failed or timed out"
    exit 1
fi

# Test 2: Check build output
print_status "🔍 Test 2: Checking build output..."

echo "📁 Build directory contents:"
ls -la .next/ || echo "No .next directory"

if [ -d ".next/standalone" ]; then
    print_success "✅ Standalone build output found"
    echo "📦 Standalone contents:"
    ls -la .next/standalone/ | head -10
else
    print_warning "⚠️  No standalone output, checking regular build..."
    if [ -f ".next/BUILD_ID" ]; then
        print_success "✅ Regular build output found"
    else
        print_error "❌ No valid build output found"
        exit 1
    fi
fi

if [ -d ".next/static" ]; then
    print_success "✅ Static assets found"
else
    print_warning "⚠️  No static assets directory"
fi

if [ -d "public" ]; then
    print_success "✅ Public directory exists"
else
    print_warning "⚠️  No public directory"
fi

# Test 3: Create and test minimal Docker image
print_status "🐳 Test 3: Creating test Docker image..."

if [ -d ".next/standalone" ]; then
    # Create test Dockerfile
    cat > Dockerfile.test << 'EOF'
FROM node:20-alpine
WORKDIR /app
RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nextjs
COPY .next/standalone ./
COPY .next/static ./.next/static  
COPY public ./public
USER nextjs
EXPOSE 3000
ENV NODE_ENV=production
CMD ["node", "server.js"]
EOF
else
    # Regular build Dockerfile
    cat > Dockerfile.test << 'EOF'
FROM node:20-alpine
WORKDIR /app
RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nextjs && \
    npm install -g next
COPY package.json ./
COPY .next ./.next
COPY public ./public
USER nextjs
EXPOSE 3000
ENV NODE_ENV=production
CMD ["npx", "next", "start"]
EOF
fi

# Build test image
if docker build -f Dockerfile.test -t innerbright-test:latest . >/dev/null 2>&1; then
    print_success "✅ Test Docker image created successfully"
    
    # Get image size
    IMAGE_SIZE=$(docker images --format "{{.Size}}" innerbright-test:latest)
    print_status "📦 Image size: $IMAGE_SIZE"
    
    # Clean up
    docker rmi innerbright-test:latest >/dev/null 2>&1 || true
    rm -f Dockerfile.test
else
    print_error "❌ Failed to create test Docker image"
    rm -f Dockerfile.test
    exit 1
fi

# Test 4: Memory usage check
print_status "📊 Test 4: Build memory usage summary..."
if command -v free >/dev/null 2>&1; then
    free -h
else
    echo "Memory info not available"
fi

# Summary
print_status "📋 Test Results Summary:"
echo "  - Build: ✅ Success"
if [ -d ".next/standalone" ]; then
    echo "  - Output: ✅ Standalone (optimal for Docker)"
else
    echo "  - Output: ⚠️  Regular (will work but larger image)"
fi
echo "  - Docker: ✅ Image creation successful"
echo "  - Ready: ✅ Can proceed with deployment"

print_success "🎉 All tests passed! Ready for deployment."

echo ""
print_status "💡 Next steps:"
echo "  1. Deploy locally: ./deploy-low-memory.sh local"
echo "  2. Deploy to server: ./deploy-low-memory.sh deploy"  
echo "  3. Monitor: ./deploy-low-memory.sh monitor"
