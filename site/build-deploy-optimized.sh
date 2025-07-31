#!/bin/bash

# Optimized Build and Deploy Script for Innerbright Site
# Handles PWA builds with CPU optimization for Docker environments

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'  
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
DOCKER_IMAGE_NAME="innerbright-site"
DOCKER_TAG="latest"
SERVER_HOST="116.118.85.41"
SERVER_USER="root"
SSH_KEY="~/.ssh/id_rsa"
REMOTE_PATH="/opt/innerbright"

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to build locally with PWA optimization
build_local() {
    print_status "Building Next.js application locally with PWA optimization..."
    
    # Ensure dependencies are installed
    if [ ! -d "node_modules" ]; then
        print_status "Installing dependencies..."
        if command -v bun > /dev/null 2>&1; then
            bun install
        else
            npm install
        fi
    fi
    
    # Clean previous builds
    rm -rf .next
    
    # Set build environment variables for optimization
    export NODE_ENV=production
    export NEXT_TELEMETRY_DISABLED=1
    export BUILD_SITE_ONLY=true
    export SKIP_ENV_VALIDATION=true
    export DISABLE_PWA_BUILD=true  # Disable PWA during initial build to prevent CPU spikes
    
    print_status "Step 1: Building without PWA to prevent CPU issues..."
    
    if command -v bun > /dev/null 2>&1; then
        NODE_OPTIONS="--max-old-space-size=2048 --max-semi-space-size=1024" bun run build
    else
        NODE_OPTIONS="--max-old-space-size=2048 --max-semi-space-size=1024" npm run build
    fi
    
    if [ $? -ne 0 ]; then
        print_error "Build failed"
        return 1
    fi
    
    # Step 2: Generate PWA files separately if needed
    print_status "Step 2: Generating PWA files..."
    generate_pwa_files
    
    # Verify standalone build
    if [ ! -d ".next/standalone" ]; then
        print_warning ".next/standalone not found, but continuing..."
    fi
    
    if [ ! -d ".next/static" ]; then
        print_warning ".next/static not found, creating fallback..."
        mkdir -p .next/static
    fi
    
    print_success "Local build completed successfully"
    return 0
}

# Function to generate PWA files separately
generate_pwa_files() {
    print_status "Generating PWA service worker and manifest..."
    
    # Check if we need to generate PWA files
    if [ ! -f "public/sw.js" ] || [ ! -f "public/manifest.webmanifest" ]; then
        # Create a minimal service worker if it doesn't exist
        if [ ! -f "public/sw.js" ]; then
            cat > public/sw.js << 'EOF'
self.addEventListener('install', function(event) {
  console.log('Service Worker installing.');
  self.skipWaiting();
});

self.addEventListener('activate', function(event) {
  console.log('Service Worker activating.');
  event.waitUntil(self.clients.claim());
});

self.addEventListener('fetch', function(event) {
  // Simple network-first strategy
  event.respondWith(
    fetch(event.request).catch(function() {
      return caches.match(event.request);
    })
  );
});
EOF
        fi
        
        # Create manifest if it doesn't exist
        if [ ! -f "public/manifest.webmanifest" ]; then
            cat > public/manifest.webmanifest << 'EOF'
{
  "name": "Innerbright",
  "short_name": "Innerbright",
  "description": "Innerbright Application",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#ffffff",
  "theme_color": "#000000",
  "icons": [
    {
      "src": "/icons/icon-192x192.png",
      "sizes": "192x192",
      "type": "image/png"
    },
    {
      "src": "/icons/icon-512x512.png",
      "sizes": "512x512",
      "type": "image/png"
    }
  ]
}
EOF
        fi
    fi
    
    print_success "PWA files generated"
}

# Function to build Docker image
build_docker() {
    print_status "Building Docker image with optimizations..."
    
    # Use optimized build script
    if [ -f "docker-build-optimized.sh" ]; then
        print_status "Using optimized Docker build script..."
        ./docker-build-optimized.sh
    else
        # Fallback to direct Docker build with optimizations
        print_status "Using direct Docker build with optimizations..."
        
        DOCKER_BUILDKIT=1 docker build \
            --build-arg NEXT_PUBLIC_APP_URL="${NEXT_PUBLIC_APP_URL:-http://localhost:3000}" \
            --build-arg NEXT_PUBLIC_MINIO_ENDPOINT="${NEXT_PUBLIC_MINIO_ENDPOINT:-http://localhost:9000}" \
            --build-arg DATABASE_URL="${DATABASE_URL}" \
            --build-arg NEXTAUTH_SECRET="${NEXTAUTH_SECRET}" \
            --progress=plain \
            -t ${DOCKER_IMAGE_NAME}:${DOCKER_TAG} \
            -f Dockerfile \
            .
    fi
    
    if [ $? -eq 0 ]; then
        print_success "Docker image built successfully"
        return 0
    else
        print_error "Docker build failed"
        return 1
    fi
}

# Function to save Docker image
save_docker_image() {
    print_status "Saving Docker image to file..."
    
    docker save ${DOCKER_IMAGE_NAME}:${DOCKER_TAG} | gzip > ${DOCKER_IMAGE_NAME}-${DOCKER_TAG}.tar.gz
    
    if [ $? -eq 0 ]; then
        IMAGE_SIZE=$(du -h ${DOCKER_IMAGE_NAME}-${DOCKER_TAG}.tar.gz | cut -f1)
        print_success "Docker image saved as ${DOCKER_IMAGE_NAME}-${DOCKER_TAG}.tar.gz (${IMAGE_SIZE})"
        return 0
    else
        print_error "Failed to save Docker image"
        return 1
    fi
}

# Function to deploy to server
deploy_to_server() {
    print_status "Deploying to server ${SERVER_HOST}..."
    
    # Check if image file exists
    if [ ! -f "${DOCKER_IMAGE_NAME}-${DOCKER_TAG}.tar.gz" ]; then
        print_error "Docker image file not found. Please build first."
        return 1
    fi
    
    # Upload image to server
    print_status "Uploading Docker image to server..."
    scp -i ${SSH_KEY} ${DOCKER_IMAGE_NAME}-${DOCKER_TAG}.tar.gz ${SERVER_USER}@${SERVER_HOST}:${REMOTE_PATH}/
    
    if [ $? -ne 0 ]; then
        print_error "Failed to upload Docker image"
        return 1
    fi
    
    # Execute deployment on server
    print_status "Executing deployment on server..."
    ssh -i ${SSH_KEY} ${SERVER_USER}@${SERVER_HOST} << EOF
        cd ${REMOTE_PATH}
        
        # Stop existing container
        docker stop innerbright-site 2>/dev/null || true
        docker rm innerbright-site 2>/dev/null || true
        
        # Load new image
        docker load < ${DOCKER_IMAGE_NAME}-${DOCKER_TAG}.tar.gz
        
        # Run new container with resource limits
        docker run -d \
            --name innerbright-site \
            --restart unless-stopped \
            -p 3000:3000 \
            --memory=1g \
            --cpus=1.0 \
            -e NODE_ENV=production \
            ${DOCKER_IMAGE_NAME}:${DOCKER_TAG}
        
        # Clean up
        rm -f ${DOCKER_IMAGE_NAME}-${DOCKER_TAG}.tar.gz
        
        # Show status
        echo "Deployment completed. Container status:"
        docker ps | grep innerbright-site
EOF
    
    if [ $? -eq 0 ]; then
        print_success "Deployment completed successfully"
        return 0
    else
        print_error "Deployment failed"
        return 1
    fi
}

# Function to clean up local files
cleanup() {
    print_status "Cleaning up local files..."
    rm -f ${DOCKER_IMAGE_NAME}-${DOCKER_TAG}.tar.gz
    print_success "Cleanup completed"
}

# Function to show usage
usage() {
    echo "Usage: $0 [build|docker|deploy|full|clean]"
    echo ""
    echo "Commands:"
    echo "  build   - Build locally only"
    echo "  docker  - Build Docker image only"
    echo "  deploy  - Deploy to server (requires existing image)"
    echo "  full    - Complete build and deploy process"
    echo "  clean   - Clean up temporary files"
    echo ""
    echo "Environment variables:"
    echo "  NEXT_PUBLIC_APP_URL      - App URL (default: http://localhost:3000)"
    echo "  NEXT_PUBLIC_MINIO_ENDPOINT - MinIO endpoint"
    echo "  DATABASE_URL             - Database connection string"
    echo "  NEXTAUTH_SECRET          - NextAuth secret"
}

# Main execution logic
case "${1:-full}" in
    "build")
        build_local
        ;;
    "docker")
        build_docker
        ;;
    "deploy")
        save_docker_image && deploy_to_server && cleanup
        ;;
    "full")
        build_local && build_docker && save_docker_image && deploy_to_server && cleanup
        ;;
    "clean")
        cleanup
        ;;
    "help"|"-h"|"--help")
        usage
        ;;
    *)
        print_error "Unknown command: $1"
        usage
        exit 1
        ;;
esac
