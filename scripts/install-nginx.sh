#!/bin/bash

# KataCore Nginx Installation and Configuration Script
# For server 116.118.85.41 with domain innerbright.vn
# This script automates the complete Nginx setup process

set -e

# Configuration
DOMAIN="innerbright.vn"
WWW_DOMAIN="www.innerbright.vn"
SERVER_IP="116.118.85.41"
EMAIL="admin@innerbright.vn"

echo "🌐 Setting up Nginx for KataCore..."
echo "Domain: $DOMAIN"
echo "Server: $SERVER_IP"
echo ""

# Create Nginx site configuration
echo "📝 Creating Nginx configuration..."
sudo tee /etc/nginx/sites-available/$DOMAIN > /dev/null << 'EOF'
server {
    listen 80;
    server_name innerbright.vn www.innerbright.vn;

    # API proxy
    location /api/ {
        proxy_pass http://localhost:3001/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }

    # Site proxy
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
EOF

echo "✅ Nginx configuration created"

# Enable the site
echo "🔗 Enabling Nginx site..."
sudo ln -sf /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/

# Remove default site if it exists
if [ -f /etc/nginx/sites-enabled/default ]; then
    sudo rm /etc/nginx/sites-enabled/default
    echo "✅ Removed default site"
fi

# Test Nginx configuration
echo "🧪 Testing Nginx configuration..."
sudo nginx -t

if [ $? -eq 0 ]; then
    echo "✅ Nginx configuration is valid"
else
    echo "❌ Nginx configuration test failed"
    exit 1
fi

# Reload Nginx
echo "🔄 Reloading Nginx..."
sudo systemctl reload nginx
echo "✅ Nginx reloaded successfully"

# Install Certbot if not present
echo "🔒 Installing Certbot..."
sudo apt update
sudo apt install certbot python3-certbot-nginx -y
echo "✅ Certbot installed"

# Setup SSL certificate
echo "🔐 Setting up SSL certificate..."
sudo certbot --nginx -d $DOMAIN -d $WWW_DOMAIN --non-interactive --agree-tos --email $EMAIL --redirect

if [ $? -eq 0 ]; then
    echo "✅ SSL certificate configured successfully"
else
    echo "⚠️  SSL setup failed. You may need to:"
    echo "  1. Ensure DNS is pointing to $SERVER_IP"
    echo "  2. Run manually: sudo certbot --nginx -d $DOMAIN -d $WWW_DOMAIN"
fi

echo ""
echo "🎉 Nginx setup completed!"
echo ""
echo "📋 Service URLs:"
echo "  🌐 Site: https://$DOMAIN"
echo "  🔗 API: https://$DOMAIN/api"
echo ""
echo "💡 Management commands:"
echo "  • Test config: sudo nginx -t"
echo "  • Reload: sudo systemctl reload nginx"
echo "  • Check SSL: sudo certbot certificates"
echo "  • Renew SSL: sudo certbot renew"
echo ""
echo "✅ Ready for KataCore deployment!"

