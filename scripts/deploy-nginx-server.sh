#!/bin/bash

# KataCore Server Deployment Script
# Deploys nginx configuration to cloud server 116.118.85.41

set -e

SERVER_IP="116.118.85.41"
SERVER_USER="${SERVER_USER:-root}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "🚀 KataCore Server Nginx Deployment"
echo "===================================="
echo "Server: $SERVER_IP"
echo "User: $SERVER_USER"
echo ""

# Check if SSH key exists
if [ ! -f ~/.ssh/id_rsa ]; then
    echo "⚠️  SSH key not found. Please set up SSH key authentication first."
    echo "Run: ssh-keygen -t rsa -b 4096 -C 'your_email@example.com'"
    echo "Then: ssh-copy-id $SERVER_USER@$SERVER_IP"
    exit 1
fi

# Test SSH connection
echo "🔗 Testing SSH connection..."
if ! ssh -o ConnectTimeout=10 -o BatchMode=yes "$SERVER_USER@$SERVER_IP" "echo 'SSH connection successful'" 2>/dev/null; then
    echo "❌ Cannot connect to server. Please check:"
    echo "   - Server IP: $SERVER_IP"
    echo "   - SSH key setup"
    echo "   - Server accessibility"
    exit 1
fi

echo "✅ SSH connection successful"

# Check if nginx is installed on server
echo "🔍 Checking nginx installation on server..."
if ! ssh "$SERVER_USER@$SERVER_IP" "which nginx" >/dev/null 2>&1; then
    echo "⚠️  Nginx not found on server. Installing..."
    echo "📤 Uploading nginx installation script..."
    scp "$PROJECT_ROOT/scripts/install-nginx-server.sh" "$SERVER_USER@$SERVER_IP:/tmp/"
    echo "🚀 Running nginx installation..."
    ssh "$SERVER_USER@$SERVER_IP" "chmod +x /tmp/install-nginx-server.sh && /tmp/install-nginx-server.sh"
fi

# Upload nginx configuration
echo "📤 Uploading nginx configuration..."
scp "$PROJECT_ROOT/nginx/server/katacore.conf" "$SERVER_USER@$SERVER_IP:/tmp/"

# Deploy configuration
echo "🚀 Deploying nginx configuration..."
ssh "$SERVER_USER@$SERVER_IP" "deploy-katacore-nginx /tmp/katacore.conf"

# Check nginx status
echo "📊 Checking nginx status..."
ssh "$SERVER_USER@$SERVER_IP" "systemctl status nginx --no-pager"

echo ""
echo "✅ Deployment Complete!"
echo "======================"
echo ""
echo "📋 Server Configuration:"
echo "- Nginx is running on $SERVER_IP"
echo "- HTTP Port: 80 (redirects to HTTPS)"
echo "- HTTPS Port: 443"
echo "- Site: https://innerbright.vn"
echo ""
echo "🔧 Docker Services Expected on:"
echo "- API (NestJS): localhost:3001"
echo "- Site (Next.js): localhost:3000"
echo "- pgAdmin: localhost:5050"
echo "- MinIO API: localhost:9000"
echo "- MinIO Console: localhost:9001"
echo ""
echo "🔐 Admin Access:"
echo "- MinIO Console: https://innerbright.vn/minio/"
echo "- pgAdmin: https://innerbright.vn/pgadmin/"
echo "- Set passwords: ssh $SERVER_USER@$SERVER_IP 'htpasswd /etc/nginx/.htpasswd admin'"
echo ""
echo "🔒 SSL Certificate:"
echo "- Currently using self-signed certificate"
echo "- Get real certificate: ssh $SERVER_USER@$SERVER_IP 'certbot --nginx -d innerbright.vn -d www.innerbright.vn'"
echo ""
