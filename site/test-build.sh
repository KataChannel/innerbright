#!/bin/bash

# 🚀 Quick Build Test Script
set -e

echo "🔍 Testing build process..."

# Check if we're in the right directory
if [[ ! -f "package.json" ]] || [[ ! -f "next.config.ts" ]]; then
    echo "❌ Please run this script from the site directory"
    exit 1
fi

# Clean previous build
echo "🧹 Cleaning previous build..."
rm -rf .next

# Install dependencies if needed
if [[ ! -d "node_modules" ]]; then
    echo "📦 Installing dependencies..."
    if command -v bun &> /dev/null; then
        bun install
    else
        npm install
    fi
fi

# Set environment and build
echo "🔨 Building application..."
export BUILD_SITE_ONLY=true
export NEXT_TELEMETRY_DISABLED=1
export NODE_ENV=production

if command -v bun &> /dev/null; then
    echo "Using Bun for build..."
    bun run build:site-only
else
    echo "Using npm for build..."
    npm run build:site-only
fi

# Verify build
if [[ -d ".next/standalone" ]]; then
    echo "✅ Standalone build: OK"
else
    echo "❌ Standalone build: FAILED"
    exit 1
fi

if [[ -d ".next/static" ]]; then
    echo "✅ Static build: OK"
else
    echo "⚠️  Static build: Not found (creating empty)"
    mkdir -p .next/static
fi

if [[ -f ".next/standalone/server.js" ]]; then
    echo "✅ Server.js: OK"
else
    echo "❌ Server.js: NOT FOUND"
    exit 1
fi

# Show build info
echo ""
echo "📊 Build Information:"
echo "   Build size: $(du -sh .next 2>/dev/null | cut -f1)"
echo "   Standalone: $(du -sh .next/standalone 2>/dev/null | cut -f1)"
echo "   Static: $(du -sh .next/static 2>/dev/null | cut -f1)"
echo ""
echo "✅ Build test completed successfully!"
echo "🚀 Ready for Docker build and deployment"
