#!/bin/bash

# Default values for innerbright.vn
DEFAULT_SERVER_NAME="innerbright.vn"
DEFAULT_PROXY_IP="127.0.0.1"
DEFAULT_PROXY_PORT="3000"
DEFAULT_ENABLE_SSL="y"
DEFAULT_CLOUD_IP="116.118.48.208"
DEFAULT_CLOUD_USER="root"

# Get user input with default values
read -e -p "Enter server name [$DEFAULT_SERVER_NAME]: " -i "$DEFAULT_SERVER_NAME" SERVER_NAME
read -e -p "Enter proxy IP address [$DEFAULT_PROXY_IP]: " -i "$DEFAULT_PROXY_IP" PROXY_IP
read -e -p "Enter proxy port [$DEFAULT_PROXY_PORT]: " -i "$DEFAULT_PROXY_PORT" PROXY_PORT
read -e -p "Enable SSL? (y/n) [$DEFAULT_ENABLE_SSL]: " -i "$DEFAULT_ENABLE_SSL" ENABLE_SSL
read -e -p "Enter cloud server IP [$DEFAULT_CLOUD_IP]: " -i "$DEFAULT_CLOUD_IP" CLOUD_IP
read -e -p "Enter cloud server username [$DEFAULT_CLOUD_USER]: " -i "$DEFAULT_CLOUD_USER" CLOUD_USER

# Use defaults if user pressed enter without input
SERVER_NAME=${SERVER_NAME:-$DEFAULT_SERVER_NAME}
PROXY_IP=${PROXY_IP:-$DEFAULT_PROXY_IP}
PROXY_PORT=${PROXY_PORT:-$DEFAULT_PROXY_PORT}
ENABLE_SSL=${ENABLE_SSL:-$DEFAULT_ENABLE_SSL}
CLOUD_IP=${CLOUD_IP:-$DEFAULT_CLOUD_IP}
CLOUD_USER=${CLOUD_USER:-$DEFAULT_CLOUD_USER}

# Create temporary nginx config locally with optimized settings
mkdir -p /tmp/nginx-config
cat > /tmp/nginx-config/$SERVER_NAME << EOF
# HTTP server - redirect to HTTPS
server {
    listen 80;
    listen [::]:80;
    server_name $SERVER_NAME www.$SERVER_NAME;
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    
    # Redirect all HTTP requests to HTTPS
    return 301 https://\$server_name\$request_uri;
}

# HTTPS server
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name $SERVER_NAME www.$SERVER_NAME;

    # SSL Configuration (will be managed by certbot)
    ssl_certificate /etc/letsencrypt/live/$SERVER_NAME/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$SERVER_NAME/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    # Security headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self' data:; connect-src 'self'; frame-ancestors 'self';" always;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types
        text/plain
        text/css
        text/xml
        text/javascript
        application/json
        application/javascript
        application/xml+rss
        application/atom+xml
        image/svg+xml;

    # Rate limiting
    limit_req_zone \$binary_remote_addr zone=api:10m rate=10r/s;
    limit_req_zone \$binary_remote_addr zone=general:10m rate=50r/s;

    # Proxy settings
    proxy_http_version 1.1;
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection 'upgrade';
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
    proxy_set_header X-Forwarded-Host \$server_name;
    proxy_cache_bypass \$http_upgrade;
    proxy_read_timeout 86400;

    # Main location block
    location / {
        limit_req zone=general burst=100 nodelay;
        proxy_pass http://$PROXY_IP:$PROXY_PORT;
    }

    # API routes with stricter rate limiting
    location /api/ {
        limit_req zone=api burst=20 nodelay;
        proxy_pass http://$PROXY_IP:$PROXY_PORT;
    }

    # Static files caching
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)\$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        proxy_pass http://$PROXY_IP:$PROXY_PORT;
    }

    # Next.js specific routes
    location /_next/static/ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        proxy_pass http://$PROXY_IP:$PROXY_PORT;
    }

    # Health check endpoint
    location /health {
        access_log off;
        proxy_pass http://$PROXY_IP:$PROXY_PORT;
    }

    # Block common attack vectors
    location ~ /\. {
        deny all;
        access_log off;
        log_not_found off;
    }

    location ~ ~\$ {
        deny all;
        access_log off;
        log_not_found off;
    }

    # Logging
    access_log /var/log/nginx/$SERVER_NAME.access.log;
    error_log /var/log/nginx/$SERVER_NAME.error.log;
}
EOF

# Copy configuration to cloud server and apply it
echo "Copying nginx config to cloud server..."
scp /tmp/nginx-config/$SERVER_NAME $CLOUD_USER@$CLOUD_IP:/tmp/

ssh $CLOUD_USER@$CLOUD_IP << REMOTE_SCRIPT
# Install nginx if not present
if ! command -v nginx &> /dev/null; then
    sudo apt update && sudo apt install -y nginx
fi

# Install certbot if not present
if ! command -v certbot &> /dev/null; then
    sudo apt update && sudo apt install -y certbot python3-certbot-nginx
fi

# Create necessary directories
sudo mkdir -p /etc/nginx/sites-available /etc/nginx/sites-enabled /var/log/nginx

# Backup existing config if exists
if [ -f /etc/nginx/sites-available/$SERVER_NAME ]; then
    sudo cp /etc/nginx/sites-available/$SERVER_NAME /etc/nginx/sites-available/$SERVER_NAME.backup.\$(date +%Y%m%d_%H%M%S)
fi

# Move new config
sudo mv /tmp/$SERVER_NAME /etc/nginx/sites-available/
sudo rm -f /etc/nginx/sites-enabled/$SERVER_NAME
sudo ln -s /etc/nginx/sites-available/$SERVER_NAME /etc/nginx/sites-enabled/

# Remove default nginx config if exists
sudo rm -f /etc/nginx/sites-enabled/default

# Test nginx configuration
sudo nginx -t
if [ \$? -eq 0 ]; then
    sudo systemctl enable nginx
    sudo systemctl reload nginx
    echo "Nginx configuration applied successfully"
else
    echo "Nginx configuration test failed"
    exit 1
fi
REMOTE_SCRIPT

if [ $? -eq 0 ]; then
    echo "Configuration applied to cloud server successfully"
else
    echo "Failed to apply configuration to cloud server"
    exit 1
fi

# Configure SSL if requested
if [[ $ENABLE_SSL == "y" || $ENABLE_SSL == "Y" ]]; then
    echo "Installing SSL certificate on cloud server..."
    
    # First create temporary HTTP-only config for domain verification
    ssh $CLOUD_USER@$CLOUD_IP << SSL_SCRIPT
# Create temporary HTTP-only config for SSL verification
sudo tee /etc/nginx/sites-available/$SERVER_NAME.temp << 'TEMP_EOF'
server {
    listen 80;
    listen [::]:80;
    server_name $SERVER_NAME www.$SERVER_NAME;

    location /.well-known/acme-challenge/ {
        root /var/www/html;
    }

    location / {
        proxy_pass http://$PROXY_IP:$PROXY_PORT;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
TEMP_EOF

# Apply temporary config
sudo rm -f /etc/nginx/sites-enabled/$SERVER_NAME
sudo ln -s /etc/nginx/sites-available/$SERVER_NAME.temp /etc/nginx/sites-enabled/$SERVER_NAME.temp
sudo nginx -t && sudo systemctl reload nginx

# Create webroot directory
sudo mkdir -p /var/www/html

# Install SSL certificate
sudo certbot --nginx -d $SERVER_NAME -d www.$SERVER_NAME --non-interactive --agree-tos --email admin@$SERVER_NAME --redirect

if [ \$? -eq 0 ]; then
    echo "SSL certificate installed successfully"
    
    # Remove temporary config and apply the full SSL config
    sudo rm -f /etc/nginx/sites-enabled/$SERVER_NAME.temp
    sudo rm -f /etc/nginx/sites-available/$SERVER_NAME.temp
    sudo ln -s /etc/nginx/sites-available/$SERVER_NAME /etc/nginx/sites-enabled/
    
    # Test and reload with SSL config
    sudo nginx -t && sudo systemctl reload nginx
    
    # Test SSL renewal
    sudo certbot renew --dry-run
    
    # Set up auto-renewal cron job
    (crontab -l 2>/dev/null; echo "0 12 * * * /usr/bin/certbot renew --quiet") | crontab -
    
    echo "SSL certificate setup completed with auto-renewal configured"
else
    echo "SSL certificate installation failed"
    exit 1
fi
SSL_SCRIPT
    else
        echo "SSL certificate installation failed"
    fi
fi

# Clean up temporary file
rm -f /tmp/nginx-config/$SERVER_NAME
