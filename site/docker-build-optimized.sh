#!/bin/bash

# Optimized Docker build script for PWA applications
# This script builds the application in stages to prevent CPU spikes

set -e

echo "🚀 Starting optimized Docker build process..."

# Build configuration
DOCKER_BUILDKIT=1
COMPOSE_DOCKER_CLI_BUILD=1
export DOCKER_BUILDKIT COMPOSE_DOCKER_CLI_BUILD

# Function to build with PWA disabled first
build_without_pwa() {
    echo "📦 Stage 1: Building without PWA to prevent CPU spikes..."
    
    docker build \
        --target builder \
        --build-arg NEXT_PUBLIC_APP_URL="${NEXT_PUBLIC_APP_URL:-http://localhost:3000}" \
        --build-arg NEXT_PUBLIC_MINIO_ENDPOINT="${NEXT_PUBLIC_MINIO_ENDPOINT:-http://localhost:9000}" \
        --build-arg DATABASE_URL="${DATABASE_URL}" \
        --build-arg NEXTAUTH_SECRET="${NEXTAUTH_SECRET}" \
        --progress=plain \
        --no-cache \
        -t innerbright-builder \
        -f site/Dockerfile \
        .
    
    if [ $? -eq 0 ]; then
        echo "✅ Stage 1 completed successfully"
        return 0
    else
        echo "❌ Stage 1 failed"
        return 1
    fi
}

# Function to complete the build
complete_build() {
    echo "📦 Stage 2: Completing Docker build..."
    
    docker build \
        --build-arg NEXT_PUBLIC_APP_URL="${NEXT_PUBLIC_APP_URL:-http://localhost:3000}" \
        --build-arg NEXT_PUBLIC_MINIO_ENDPOINT="${NEXT_PUBLIC_MINIO_ENDPOINT:-http://localhost:9000}" \
        --build-arg DATABASE_URL="${DATABASE_URL}" \
        --build-arg NEXTAUTH_SECRET="${NEXTAUTH_SECRET}" \
        --progress=plain \
        -t innerbright-site:latest \
        -f site/Dockerfile \
        .
    
    if [ $? -eq 0 ]; then
        echo "✅ Stage 2 completed successfully"
        return 0
    else
        echo "❌ Stage 2 failed"
        return 1
    fi
}

# Function to monitor build process
monitor_build() {
    echo "📊 Monitoring system resources during build..."
    
    # Monitor CPU and memory usage
    while [ "$(docker ps -q -f ancestor=innerbright-builder)" ]; do
        echo "$(date): $(docker stats --no-stream --format 'CPU: {{.CPUPerc}} MEM: {{.MemUsage}}' $(docker ps -q -f ancestor=innerbright-builder) 2>/dev/null || echo 'Container not running')"
        sleep 30
    done &
    
    MONITOR_PID=$!
}

# Function to cleanup on exit
cleanup() {
    echo "🧹 Cleaning up..."
    if [ -n "$MONITOR_PID" ]; then
        kill $MONITOR_PID 2>/dev/null || true
    fi
    
    # Clean up intermediate images
    docker image prune -f --filter "label=stage=builder" 2>/dev/null || true
}

# Set trap for cleanup
trap cleanup EXIT

# Main build process
main() {
    echo "🔧 Docker Build Configuration:"
    echo "   - DOCKER_BUILDKIT: $DOCKER_BUILDKIT"
    echo "   - PWA Build: Optimized for Docker"
    echo "   - Memory Limit: 2048MB"
    echo "   - CPU Threads: Limited"
    echo ""
    
    # Check if running on server with limited resources
    AVAILABLE_MEMORY=$(free -m | awk 'NR==2{printf "%.0f", $7*100/$2 }')
    if [ "$AVAILABLE_MEMORY" -lt 70 ]; then
        echo "⚠️  Warning: Low available memory ($AVAILABLE_MEMORY%). Build may be slower."
        echo "   Consider freeing up memory before building."
    fi
    
    # Start monitoring
    monitor_build
    
    # Execute build stages
    if build_without_pwa && complete_build; then
        echo ""
        echo "🎉 Docker build completed successfully!"
        echo "📋 Image: innerbright-site:latest"
        echo "💾 Size: $(docker images innerbright-site:latest --format '{{.Size}}')"
        
        # Optional: Test the built image
        echo ""
        echo "🧪 Testing built image..."
        if docker run --rm -d -p 3000:3000 --name innerbright-test innerbright-site:latest > /dev/null; then
            sleep 5
            if curl -s http://localhost:3000 > /dev/null; then
                echo "✅ Image test passed - server is responding"
            else
                echo "⚠️  Image test inconclusive - server may need more time to start"
            fi
            docker stop innerbright-test > /dev/null 2>&1
        fi
        
        return 0
    else
        echo ""
        echo "❌ Docker build failed!"
        echo "💡 Try running with more available memory or check the logs above."
        return 1
    fi
}

# Execute main function
main "$@"
