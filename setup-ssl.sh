#!/bin/bash

# SSL Setup Script for Innerbright.vn
# This script sets up SSL certificates using Let's Encrypt

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
DOMAIN="innerbright.vn"
EMAIL="${SSL_EMAIL:-admin@innerbright.vn}"
WEBROOT="/var/www/html"

echo -e "${GREEN}🔒 Starting SSL setup for ${DOMAIN}${NC}"

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   print_error "This script must be run as root"
   exit 1
fi

# Install certbot if not installed
if ! command -v certbot &> /dev/null; then
    print_status "Installing certbot..."
    if command -v apt-get &> /dev/null; then
        apt-get update
        apt-get install -y certbot python3-certbot-nginx
    elif command -v yum &> /dev/null; then
        yum install -y certbot python3-certbot-nginx
    else
        print_error "Package manager not supported. Please install certbot manually."
        exit 1
    fi
fi

# Create webroot directory
print_status "Creating webroot directory..."
mkdir -p $WEBROOT
chown -R www-data:www-data $WEBROOT 2>/dev/null || chown -R nginx:nginx $WEBROOT 2>/dev/null || true

# Stop nginx temporarily if running
print_status "Stopping nginx temporarily..."
docker-compose stop nginx 2>/dev/null || true

# Obtain SSL certificate
print_status "Obtaining SSL certificate for ${DOMAIN}..."
certbot certonly \
    --standalone \
    --non-interactive \
    --agree-tos \
    --email $EMAIL \
    --domains $DOMAIN \
    --domains www.$DOMAIN

# Check if certificate was obtained successfully
if [ ! -f "/etc/letsencrypt/live/$DOMAIN/fullchain.pem" ]; then
    print_error "Failed to obtain SSL certificate"
    exit 1
fi

# Set up auto-renewal
print_status "Setting up auto-renewal..."
if ! crontab -l 2>/dev/null | grep -q "certbot renew"; then
    (crontab -l 2>/dev/null; echo "0 12 * * * /usr/bin/certbot renew --quiet --post-hook 'docker-compose -f /chikiet/Innerbright/innerbright/docker-compose.yml restart nginx'") | crontab -
fi

# Start nginx again
print_status "Starting nginx with SSL..."
cd /chikiet/Innerbright/innerbright
docker-compose up -d nginx

# Test SSL configuration
print_status "Testing SSL configuration..."
sleep 10
if curl -s -I https://$DOMAIN | grep -q "200 OK"; then
    print_status "✅ SSL setup completed successfully!"
    print_status "Your site is now available at: https://$DOMAIN"
else
    print_warning "SSL certificate installed but site may not be fully accessible yet."
    print_warning "Please check nginx configuration and DNS settings."
fi

# Display certificate information
print_status "Certificate information:"
certbot certificates

echo -e "${GREEN}🎉 SSL setup complete!${NC}"
echo -e "Certificate will auto-renew via cron job."
echo -e "To manually renew: certbot renew"
echo -e "To test renewal: certbot renew --dry-run"
