#!/bin/bash

# Nginx Installation and Setup Script for KataCore Cloud Server
# Server: 116.118.85.41
# This script installs and configures nginx on the cloud server

set -e

echo "🚀 KataCore Nginx Server Setup"
echo "==============================="

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "❌ This script must be run as root"
   exit 1
fi

# Update system packages
echo "📦 Updating system packages..."
apt update && apt upgrade -y

# Install nginx
echo "📦 Installing Nginx..."
apt install -y nginx

# Install certbot for SSL certificates
echo "📦 Installing Certbot for SSL..."
apt install -y certbot python3-certbot-nginx

# Install additional tools
echo "📦 Installing additional tools..."
apt install -y apache2-utils curl wget htop ufw

# Create directories
echo "📁 Creating necessary directories..."
mkdir -p /etc/ssl/certs/katacore
mkdir -p /etc/ssl/private/katacore
mkdir -p /var/www/certbot
mkdir -p /var/www/html

# Set proper permissions
chmod 755 /etc/ssl/certs/katacore
chmod 700 /etc/ssl/private/katacore

# Backup default nginx config
echo "💾 Backing up default nginx configuration..."
cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.backup
cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default.backup

# Create main nginx configuration
echo "⚙️ Creating main nginx configuration..."
cat > /etc/nginx/nginx.conf << 'EOF'
user www-data;
worker_processes auto;
pid /run/nginx.pid;
error_log /var/log/nginx/error.log warn;

events {
    worker_connections 1024;
    use epoll;
    multi_accept on;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    # Logging Format
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';

    access_log /var/log/nginx/access.log main;

    # Performance Settings
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    client_max_body_size 50M;
    server_tokens off;
    
    # Gzip Compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types
        application/atom+xml
        application/javascript
        application/json
        application/ld+json
        application/manifest+json
        application/rss+xml
        application/vnd.geo+json
        application/vnd.ms-fontobject
        application/x-font-ttf
        application/x-web-app-manifest+json
        application/xhtml+xml
        application/xml
        font/opentype
        image/bmp
        image/svg+xml
        image/x-icon
        text/cache-manifest
        text/css
        text/plain
        text/vcard
        text/vnd.rim.location.xloc
        text/vtt
        text/x-component
        text/x-cross-domain-policy;

    # Security Headers (global)
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;

    # Include site configurations
    include /etc/nginx/conf.d/*.conf;
    include /etc/nginx/sites-enabled/*;
}
EOF

# Remove default site
echo "🗑️ Removing default nginx site..."
rm -f /etc/nginx/sites-enabled/default

# Create katacore site configuration directory
mkdir -p /etc/nginx/sites-available
mkdir -p /etc/nginx/sites-enabled

# Copy katacore configuration (will be created later)
echo "⚙️ KataCore site configuration will be deployed separately..."

# Create basic error pages
echo "📄 Creating basic error pages..."
cat > /var/www/html/404.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>404 - Page Not Found</title>
    <style>
        body { font-family: Arial, sans-serif; text-align: center; padding: 50px; }
        h1 { color: #333; }
    </style>
</head>
<body>
    <h1>404 - Page Not Found</h1>
    <p>The page you are looking for does not exist.</p>
</body>
</html>
EOF

cat > /var/www/html/50x.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Server Error</title>
    <style>
        body { font-family: Arial, sans-serif; text-align: center; padding: 50px; }
        h1 { color: #333; }
    </style>
</head>
<body>
    <h1>Server Error</h1>
    <p>There was an error processing your request.</p>
</body>
</html>
EOF

# Create htpasswd file for admin access (you'll need to set passwords)
echo "🔒 Creating admin authentication file..."
echo "# Admin users for KataCore" > /etc/nginx/.htpasswd
echo "# Use: htpasswd /etc/nginx/.htpasswd username"
echo "# Example: htpasswd /etc/nginx/.htpasswd admin"

# Configure firewall
echo "🔥 Configuring UFW firewall..."
ufw --force enable
ufw allow ssh
ufw allow 'Nginx Full'
ufw allow 22
ufw allow 80
ufw allow 443

# Test nginx configuration
echo "✅ Testing nginx configuration..."
nginx -t

# Enable and start nginx
echo "🚀 Starting nginx service..."
systemctl enable nginx
systemctl start nginx

# Create SSL certificate placeholder
echo "🔐 Creating SSL certificate directories..."
mkdir -p /etc/ssl/certs/katacore
mkdir -p /etc/ssl/private/katacore

# Create self-signed certificate for initial setup
echo "🔐 Creating temporary self-signed certificate..."
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/katacore/privkey.pem \
    -out /etc/ssl/certs/katacore/fullchain.pem \
    -subj "/C=VN/ST=HoChiMinhCity/L=HoChiMinhCity/O=KataCore/OU=IT/CN=innerbright.vn"

chmod 600 /etc/ssl/private/katacore/privkey.pem
chmod 644 /etc/ssl/certs/katacore/fullchain.pem

# Create deployment script
echo "📝 Creating nginx deployment helper script..."
cat > /usr/local/bin/deploy-katacore-nginx << 'EOF'
#!/bin/bash

# KataCore Nginx Configuration Deployment Script
# Usage: deploy-katacore-nginx <config-file>

if [[ $EUID -ne 0 ]]; then
   echo "❌ This script must be run as root"
   exit 1
fi

if [ -z "$1" ]; then
    echo "Usage: deploy-katacore-nginx <config-file>"
    echo "Example: deploy-katacore-nginx katacore.conf"
    exit 1
fi

CONFIG_FILE="$1"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Configuration file not found: $CONFIG_FILE"
    exit 1
fi

echo "🚀 Deploying KataCore Nginx Configuration"
echo "=========================================="

# Backup current configuration
BACKUP_FILE="/etc/nginx/sites-available/katacore.conf.backup-$(date +%Y%m%d-%H%M%S)"
if [ -f "/etc/nginx/sites-available/katacore.conf" ]; then
    echo "💾 Backing up current configuration to $BACKUP_FILE"
    cp /etc/nginx/sites-available/katacore.conf "$BACKUP_FILE"
fi

# Copy new configuration
echo "📋 Copying new configuration..."
cp "$CONFIG_FILE" /etc/nginx/sites-available/katacore.conf

# Enable site
echo "✅ Enabling KataCore site..."
ln -sf /etc/nginx/sites-available/katacore.conf /etc/nginx/sites-enabled/

# Test configuration
echo "🧪 Testing nginx configuration..."
if nginx -t; then
    echo "✅ Configuration test passed"
    echo "🔄 Reloading nginx..."
    systemctl reload nginx
    echo "✅ Nginx reloaded successfully!"
else
    echo "❌ Configuration test failed"
    if [ -f "$BACKUP_FILE" ]; then
        echo "🔄 Restoring backup configuration..."
        cp "$BACKUP_FILE" /etc/nginx/sites-available/katacore.conf
        nginx -t && systemctl reload nginx
    fi
    exit 1
fi

echo "🎉 KataCore Nginx configuration deployed successfully!"
EOF

chmod +x /usr/local/bin/deploy-katacore-nginx

echo ""
echo "✅ Nginx Setup Complete!"
echo "========================"
echo ""
echo "📋 Next Steps:"
echo "1. Copy your KataCore nginx configuration to the server"
echo "2. Deploy it using: deploy-katacore-nginx katacore.conf"
echo "3. Set up admin passwords: htpasswd /etc/nginx/.htpasswd admin"
echo "4. Obtain real SSL certificates: certbot --nginx -d innerbright.vn -d www.innerbright.vn"
echo "5. Start your Docker containers on ports 3000, 3001, 5050, 9000, 9001"
echo ""
echo "🔧 Useful Commands:"
echo "- Test config: nginx -t"
echo "- Reload nginx: systemctl reload nginx"
echo "- Check status: systemctl status nginx"
echo "- View logs: tail -f /var/log/nginx/error.log"
echo ""
