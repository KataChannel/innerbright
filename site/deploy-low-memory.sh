#!/bin/bash

# =============================================================================
# Low-Memory Server Deployment Script
# Handles deployment to servers with limited RAM
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

# Configuration
SERVER_HOST="${SERVER_HOST:-116.118.85.41}"
SERVER_USER="${SERVER_USER:-root}"
CONTAINER_NAME="innerbright-site"
IMAGE_NAME="innerbright-site:memory-optimized"

# Banner
echo -e "${BLUE}"
cat << 'EOF'
╔══════════════════════════════════════════════════════════════════════════════╗
║                    🚀 Low-Memory Server Deployment                          ║
║                   Optimized for RAM-constrained servers                     ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Check server resources
check_server_resources() {
    print_status "📊 Checking server resources..."
    
    ssh $SERVER_USER@$SERVER_HOST << 'EOF'
        echo "💾 Memory Status:"
        free -h
        echo ""
        echo "💿 Disk Status:"
        df -h /
        echo ""
        echo "🐳 Docker Status:"
        docker system df 2>/dev/null || echo "Docker not available"
EOF
}

# Strategy 1: Local build + minimal Docker transfer
deploy_local_build() {
    print_status "🏗️  Strategy 1: Local build + minimal Docker transfer"
    
    # Build locally first
    print_status "Building locally with full resources..."
    if ! ./build-memory-optimized.sh build; then
        print_error "Local build failed"
        return 1
    fi
    
    # Create minimal transfer image
    print_status "Creating minimal transfer image..."
    if ! ./build-memory-optimized.sh transfer; then
        print_error "Transfer image creation failed"
        return 1
    fi
    
    # Save and transfer image
    print_status "Transferring image to server..."
    docker save innerbright-site:minimal | ssh $SERVER_USER@$SERVER_HOST 'docker load'
    
    # Deploy on server with memory limits
    print_status "Deploying on server with memory constraints..."
    ssh $SERVER_USER@$SERVER_HOST << EOF
        # Stop existing container
        docker stop $CONTAINER_NAME 2>/dev/null || true
        docker rm $CONTAINER_NAME 2>/dev/null || true
        
        # Clean up to free memory
        docker system prune -f --volumes 2>/dev/null || true
        
        # Start with strict memory limits
        docker run -d \\
            --name $CONTAINER_NAME \\
            --memory=256m \\
            --memory-swap=256m \\
            --cpus=0.5 \\
            --restart unless-stopped \\
            -p 3000:3000 \\
            -e NODE_OPTIONS="--max-old-space-size=128" \\
            innerbright-site:minimal
        
        echo "⏳ Waiting for container to start..."
        sleep 20
        
        # Health check
        if curl -f http://localhost:3000 >/dev/null 2>&1; then
            echo "✅ Deployment successful!"
            docker ps | grep $CONTAINER_NAME
        else
            echo "❌ Health check failed"
            docker logs $CONTAINER_NAME --tail 20
            exit 1
        fi
EOF
    
    return $?
}

# Strategy 2: Server build with extreme limits
deploy_server_build() {
    print_status "🌐 Strategy 2: Server build with extreme memory limits"
    
    # Upload source code
    print_status "Uploading source code..."
    rsync -avz --delete \
        --exclude=node_modules \
        --exclude=.next \
        --exclude=.git \
        ./ $SERVER_USER@$SERVER_HOST:/opt/innerbright/site/
    
    # Build on server with memory monitoring
    ssh $SERVER_USER@$SERVER_HOST << 'EOF'
        cd /opt/innerbright/site
        
        echo "🧹 Aggressive memory cleanup..."
        # Stop all non-essential services
        systemctl stop nginx 2>/dev/null || true
        systemctl stop apache2 2>/dev/null || true
        
        # Clear cache
        sync
        echo 3 > /proc/sys/vm/drop_caches 2>/dev/null || true
        
        # Docker cleanup
        docker system prune -af --volumes 2>/dev/null || true
        docker builder prune -af 2>/dev/null || true
        
        echo "💾 Memory status before build:"
        free -h
        
        echo "🔨 Building with extreme memory limits..."
        # Build with very conservative settings
        timeout 1800s docker build \
            --memory=700m \
            --memory-swap=700m \
            --cpu-quota=40000 \
            --cpu-period=100000 \
            --no-cache \
            --progress=plain \
            --build-arg NODE_OPTIONS="--max-old-space-size=400" \
            --build-arg DISABLE_PWA_BUILD=true \
            --build-arg BUILD_SITE_ONLY=true \
            -f Dockerfile.site-only \
            -t innerbright-site:server-build \
            . || {
            echo "❌ Server build failed due to memory constraints"
            echo "💾 Final memory status:"
            free -h
            exit 1
        }
        
        echo "✅ Server build completed!"
        
        # Start container with runtime limits
        docker stop innerbright-site 2>/dev/null || true
        docker rm innerbright-site 2>/dev/null || true
        
        docker run -d \
            --name innerbright-site \
            --memory=200m \
            --memory-swap=200m \
            --cpus=0.3 \
            --restart unless-stopped \
            -p 3000:3000 \
            -e NODE_OPTIONS="--max-old-space-size=128" \
            innerbright-site:server-build
        
        # Restart essential services
        systemctl start nginx 2>/dev/null || true
        
        echo "⏳ Waiting for application..."
        sleep 25
        
        # Final health check
        if curl -f http://localhost:3000 >/dev/null 2>&1; then
            echo "✅ Server build deployment successful!"
        else
            echo "❌ Health check failed"
            docker logs innerbright-site --tail 20
            exit 1
        fi
EOF
    
    return $?
}

# Strategy 3: Pre-built static export (fallback)
deploy_static_fallback() {
    print_status "📦 Strategy 3: Static export fallback"
    
    # Build static export locally
    print_status "Building static export..."
    export NEXT_OUTPUT=export
    export BUILD_SITE_ONLY=true
    export DISABLE_PWA_BUILD=true
    
    if npm run build; then
        print_status "Deploying static files..."
        
        # Upload static files
        rsync -avz --delete out/ $SERVER_USER@$SERVER_HOST:/var/www/innerbright/
        
        # Configure nginx for static serving
        ssh $SERVER_USER@$SERVER_HOST << 'EOF'
            # Create nginx config for static site
            cat > /etc/nginx/sites-available/innerbright << 'NGINX_EOF'
server {
    listen 3000;
    server_name _;
    root /var/www/innerbright;
    index index.html;
    
    location / {
        try_files $uri $uri.html $uri/ =404;
    }
    
    location /_next/static/ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
NGINX_EOF
            
            # Enable site
            ln -sf /etc/nginx/sites-available/innerbright /etc/nginx/sites-enabled/
            nginx -t && systemctl reload nginx
            
            echo "✅ Static site deployed successfully!"
EOF
        
        return 0
    else
        print_error "Static build failed"
        return 1
    fi
}

# Main deployment logic with fallback strategies
deploy_with_fallback() {
    print_status "🚀 Starting deployment with fallback strategies..."
    
    # Check server resources first
    check_server_resources
    
    print_status "🎯 Attempting Strategy 1: Local build + transfer..."
    if deploy_local_build; then
        print_success "✅ Strategy 1 successful!"
        return 0
    fi
    
    print_warning "⚠️  Strategy 1 failed, trying Strategy 2..."
    if deploy_server_build; then
        print_success "✅ Strategy 2 successful!"
        return 0
    fi
    
    print_warning "⚠️  Strategy 2 failed, falling back to Strategy 3..."
    if deploy_static_fallback; then
        print_success "✅ Strategy 3 (static fallback) successful!"
        return 0
    fi
    
    print_error "❌ All deployment strategies failed!"
    return 1
}

# Monitor deployment
monitor_deployment() {
    print_status "📊 Monitoring deployment..."
    
    ssh $SERVER_USER@$SERVER_HOST << 'EOF'
        echo "🐳 Container Status:"
        docker ps | grep innerbright || echo "No container found"
        
        echo ""
        echo "💾 Memory Usage:"
        free -h
        
        echo ""
        echo "🌐 Service Status:"
        curl -I http://localhost:3000 2>/dev/null || echo "Service not responding"
        
        if docker ps | grep -q innerbright; then
            echo ""
            echo "📊 Container Stats:"
            timeout 10s docker stats --no-stream innerbright-site 2>/dev/null || echo "Stats unavailable"
        fi
EOF
}

# Main execution
case "${1:-deploy}" in
    "deploy")
        deploy_with_fallback
        ;;
    "local")
        deploy_local_build
        ;;
    "server")
        deploy_server_build
        ;;
    "static")
        deploy_static_fallback
        ;;
    "monitor")
        monitor_deployment
        ;;
    "check")
        check_server_resources
        ;;
    *)
        echo "Usage: $0 [deploy|local|server|static|monitor|check]"
        echo ""
        echo "Commands:"
        echo "  deploy  - Smart deployment with fallback strategies"
        echo "  local   - Local build + transfer strategy"
        echo "  server  - Server build with memory limits"
        echo "  static  - Static export fallback"
        echo "  monitor - Monitor current deployment"
        echo "  check   - Check server resources"
        exit 1
        ;;
esac
