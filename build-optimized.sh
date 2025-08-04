#!/bin/bash
# Build script tối ưu cho production

set -e

echo "🚀 Building optimized Next.js production image..."

# Clean previous builds
echo "🧹 Cleaning previous builds..."
docker system prune -f
docker builder prune -f

# Build with cache optimization
echo "📦 Building with multi-stage optimization..."
docker-compose build site --no-cache --parallel

# Verify image size
echo "📊 Image size information:"
docker images innerbright/site:latest --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"

# Test container startup
echo "🔍 Testing container startup..."
docker-compose up site --detach
sleep 10

# Health check
echo "❤️ Performing health check..."
if curl -f http://localhost:${SITE_PORT:-3000}/ > /dev/null 2>&1; then
    echo "✅ Site is healthy and running!"
else
    echo "❌ Health check failed!"
    docker-compose logs site
    exit 1
fi

# Cleanup test container
docker-compose down site

echo "🎉 Build completed successfully!"
echo "📝 Deployment tips:"
echo "   - Image size optimized with multi-stage build"
echo "   - Use BuildKit for faster builds: DOCKER_BUILDKIT=1"
echo "   - Layer caching enabled for dependencies"
echo "   - Security: non-root user, minimal base image"
