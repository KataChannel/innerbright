#!/bin/bash

# KataCore Quick Deployment Fix
# A simplified version for quick fixes during deployment

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

success() { echo -e "${GREEN}✅ $1${NC}"; }
warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
error() { echo -e "${RED}❌ $1${NC}"; exit 1; }

# Check arguments
if [[ $# -eq 0 ]]; then
    error "Usage: $0 <server-host-or-ip>"
fi

SERVER_HOST="$1"

echo "🔧 Quick fixes for $SERVER_HOST..."

# 1. Fix .env.prod for IP deployment
if [[ -f ".env.prod" ]] && [[ "$SERVER_HOST" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    cp .env.prod .env.prod.backup 2>/dev/null || true
    # Use a different approach for sed to avoid permission issues
    sed "s/https:\/\//http:\/\//g; s/ENABLE_SSL=true/ENABLE_SSL=false/g; s/innerbright\.vn/$SERVER_HOST/g; s/your-domain\.com/$SERVER_HOST/g; s/localhost/$SERVER_HOST/g" .env.prod > .env.prod.tmp && mv .env.prod.tmp .env.prod
    success "Fixed .env.prod for IP deployment"
fi

# 2. Create simple Nginx config
mkdir -p nginx/conf.d
cat > nginx/conf.d/simple-ip.conf << 'EOF'
upstream api { server api:3001; }
upstream site { server site:3000; }

server {
    listen 80 default_server;
    server_name _;
    
    location /nginx-health {
        return 200 "OK";
        add_header Content-Type text/plain;
    }
    
    location /api/ {
        proxy_pass http://api/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
    
    location / {
        proxy_pass http://site/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
EOF
success "Created simple Nginx config"

# 3. Fix nginx.conf rate limiting
if [[ -f "nginx/nginx.conf" ]]; then
    sed -i.bak 's/^[[:space:]]*limit_req_zone/#&/' nginx/nginx.conf 2>/dev/null || true
    rm -f nginx/nginx.conf.bak
    success "Fixed rate limiting"
fi

# 4. Set permissions
chmod 600 .env.prod 2>/dev/null || true
chmod +x scripts/*.sh 2>/dev/null || true

success "🎉 Quick fixes completed! Ready to deploy."
echo "Next: bun run deploy:safe --host $SERVER_HOST"
