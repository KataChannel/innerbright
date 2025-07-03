#!/bin/bash

# KataCore Nginx Server Setup Script v2
# Automated Nginx configuration for cloud server 116.118.85.41
# First-time deployment with SSL setup

set -e

# Color codes for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m' # No Color

# Configuration
DOMAIN="${DOMAIN:-innerbright.vn}"
WWW_DOMAIN="www.${DOMAIN}"
SERVER_IP="${SERVER_IP:-116.118.85.41}"
EMAIL="${EMAIL:-admin@${DOMAIN}}"
NGINX_SITES_AVAILABLE="/etc/nginx/sites-available"
NGINX_SITES_ENABLED="/etc/nginx/sites-enabled"
SSL_DIR="/etc/ssl/certs/katacore"
SSL_PRIVATE_DIR="/etc/ssl/private/katacore"

# Logging functions
log() {
    echo -e "${GREEN}[$(date +'%H:%M:%S')]${NC} $1"
}

info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}" >&2
    exit 1
}

# Show banner
show_banner() {
    echo -e "${BLUE}"
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════════════════════╗
║                🌐 KataCore Nginx Server Setup v2                            ║
║                                                                              ║
║    Automated Nginx • SSL Setup • First-time Deployment                      ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        error "This script must be run as root. Use: sudo $0"
    fi
}

# Install Nginx if not present
install_nginx() {
    log "🔧 Installing and configuring Nginx..."
    
    if ! command -v nginx >/dev/null 2>&1; then
        info "Installing Nginx..."
        apt update
        apt install nginx -y
        success "Nginx installed successfully"
    else
        info "Nginx already installed"
    fi
    
    # Enable and start Nginx
    systemctl enable nginx
    systemctl start nginx
    
    success "Nginx service configured"
}

# Create SSL directories
create_ssl_dirs() {
    log "🔐 Creating SSL directories..."
    
    mkdir -p "$SSL_DIR"
    mkdir -p "$SSL_PRIVATE_DIR"
    mkdir -p "/var/www/certbot"
    
    # Set proper permissions
    chmod 755 "$SSL_DIR"
    chmod 700 "$SSL_PRIVATE_DIR"
    chmod 755 "/var/www/certbot"
    
    success "SSL directories created"
}

# Create Nginx configuration
create_nginx_config() {
    log "📝 Creating Nginx configuration for $DOMAIN..."
    
    cat > "$NGINX_SITES_AVAILABLE/$DOMAIN" << EOF
# KataCore Nginx Configuration for $DOMAIN
# Server: $SERVER_IP
# Auto-generated on $(date)

# Rate limiting zones
limit_req_zone \$binary_remote_addr zone=general:10m rate=10r/s;
limit_req_zone \$binary_remote_addr zone=api:10m rate=30r/s;
limit_conn_zone \$binary_remote_addr zone=perip:10m;

# Upstream definitions
upstream katacore_api {
    server 127.0.0.1:3001;
    keepalive 32;
    keepalive_requests 100;
    keepalive_timeout 60s;
}

upstream katacore_site {
    server 127.0.0.1:3000;
    keepalive 32;
    keepalive_requests 100;
    keepalive_timeout 60s;
}

# HTTP server block - Initial setup and Let's Encrypt
server {
    listen 80;
    listen [::]:80;
    server_name $DOMAIN $WWW_DOMAIN;
    
    # Security headers for HTTP
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-Robots-Tag "noindex, nofollow" always;
    
    # Let's Encrypt ACME challenge
    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
        try_files \$uri =404;
    }
    
    # Health check endpoint
    location /nginx-health {
        access_log off;
        return 200 "healthy\\n";
        add_header Content-Type text/plain;
    }
    
    # API proxy (HTTP)
    location /api/ {
        limit_req zone=api burst=10 nodelay;
        
        proxy_pass http://katacore_api/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
        proxy_buffering off;
        
        # CORS headers
        add_header Access-Control-Allow-Origin "http://$DOMAIN" always;
        add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS" always;
        add_header Access-Control-Allow-Headers "Content-Type, Authorization, X-Requested-With" always;
        
        if (\$request_method = 'OPTIONS') {
            return 204;
        }
    }
    
    # Site proxy (HTTP)
    location / {
        limit_req zone=general burst=20 nodelay;
        limit_conn perip 20;
        
        proxy_pass http://katacore_site;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
        
        # Enable Gzip compression
        gzip on;
        gzip_vary on;
        gzip_min_length 1024;
        gzip_comp_level 6;
        gzip_types text/plain text/css application/json application/javascript text/xml application/xml text/javascript;
    }
    
    # Error pages
    error_page 404 /404.html;
    error_page 500 502 503 504 /50x.html;
    
    location = /404.html {
        internal;
        return 404 "Page not found\\n";
        add_header Content-Type text/plain;
    }
    
    location = /50x.html {
        internal;
        return 500 "Server error\\n";
        add_header Content-Type text/plain;
    }
}
EOF
    
    success "Nginx configuration created"
}

# Enable site
enable_site() {
    log "🔗 Enabling Nginx site..."
    
    # Remove default site if exists
    if [[ -L "$NGINX_SITES_ENABLED/default" ]]; then
        rm "$NGINX_SITES_ENABLED/default"
        info "Removed default site"
    fi
    
    # Create symlink
    if [[ ! -L "$NGINX_SITES_ENABLED/$DOMAIN" ]]; then
        ln -s "$NGINX_SITES_AVAILABLE/$DOMAIN" "$NGINX_SITES_ENABLED/"
        success "Site enabled"
    else
        info "Site already enabled"
    fi
}

# Test Nginx configuration
test_nginx() {
    log "🧪 Testing Nginx configuration..."
    
    if nginx -t; then
        success "Nginx configuration is valid"
    else
        error "Nginx configuration test failed"
    fi
}

# Reload Nginx
reload_nginx() {
    log "🔄 Reloading Nginx..."
    
    systemctl reload nginx
    success "Nginx reloaded successfully"
}

# Install Certbot
install_certbot() {
    log "🔒 Installing Certbot for SSL..."
    
    if ! command -v certbot >/dev/null 2>&1; then
        info "Installing Certbot..."
        apt update
        apt install certbot python3-certbot-nginx -y
        success "Certbot installed successfully"
    else
        info "Certbot already installed"
    fi
}

# Setup SSL with Let's Encrypt
setup_ssl() {
    log "🔐 Setting up SSL certificates..."
    
    info "Obtaining SSL certificate for $DOMAIN and $WWW_DOMAIN..."
    
    # Run certbot
    if certbot --nginx -d "$DOMAIN" -d "$WWW_DOMAIN" --non-interactive --agree-tos --email "$EMAIL" --redirect; then
        success "SSL certificate obtained and configured successfully"
        
        # Update CORS origin to HTTPS
        sed -i "s|http://$DOMAIN|https://$DOMAIN|g" "$NGINX_SITES_AVAILABLE/$DOMAIN"
        
        # Reload Nginx to apply SSL changes
        systemctl reload nginx
        success "Nginx configuration updated for HTTPS"
    else
        warning "SSL certificate setup failed. You can run it manually later:"
        echo "sudo certbot --nginx -d $DOMAIN -d $WWW_DOMAIN"
    fi
}

# Setup firewall
setup_firewall() {
    log "🔥 Configuring firewall..."
    
    if command -v ufw >/dev/null 2>&1; then
        # Allow SSH, HTTP, HTTPS
        ufw allow ssh
        ufw allow 80/tcp
        ufw allow 443/tcp
        
        # Allow Docker container ports (for internal access)
        ufw allow from 172.16.0.0/12 to any port 3000
        ufw allow from 172.16.0.0/12 to any port 3001
        
        # Enable firewall
        echo "y" | ufw enable
        
        success "Firewall configured"
    else
        warning "UFW not available, please configure firewall manually"
    fi
}

# Create monitoring script
create_monitoring() {
    log "📊 Creating monitoring script..."
    
    cat > "/usr/local/bin/katacore-status" << 'EOF'
#!/bin/bash

echo "🚀 KataCore System Status"
echo "========================="
echo ""

# Nginx status
echo "📊 Nginx Status:"
systemctl is-active nginx
echo ""

# Docker containers
echo "🐳 Docker Containers:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo ""

# Service health checks
echo "🏥 Health Checks:"
echo -n "API (3001): "
if curl -f http://localhost:3001/health >/dev/null 2>&1; then
    echo "✅ Healthy"
else
    echo "❌ Unhealthy"
fi

echo -n "Site (3000): "
if curl -f http://localhost:3000 >/dev/null 2>&1; then
    echo "✅ Healthy"
else
    echo "❌ Unhealthy"
fi

echo -n "Nginx: "
if curl -f http://localhost/nginx-health >/dev/null 2>&1; then
    echo "✅ Healthy"
else
    echo "❌ Unhealthy"
fi

echo ""
echo "🔗 Service URLs:"
echo "  • Site: https://innerbright.vn"
echo "  • API: https://innerbright.vn/api"
echo "  • Health: https://innerbright.vn/nginx-health"
EOF
    
    chmod +x "/usr/local/bin/katacore-status"
    success "Monitoring script created: /usr/local/bin/katacore-status"
}

# Show completion summary
show_summary() {
    echo ""
    success "🎉 KataCore Nginx Setup Completed!"
    echo ""
    
    echo -e "${BLUE}📋 Configuration Summary:${NC}"
    echo -e "  🌐 Domain: ${CYAN}$DOMAIN${NC}"
    echo -e "  🌐 WWW Domain: ${CYAN}$WWW_DOMAIN${NC}"
    echo -e "  🖥️  Server IP: ${CYAN}$SERVER_IP${NC}"
    echo -e "  📧 Email: ${CYAN}$EMAIL${NC}"
    echo ""
    
    echo -e "${BLUE}🔗 Service URLs:${NC}"
    echo -e "  🌐 Site: ${CYAN}https://$DOMAIN${NC}"
    echo -e "  🔗 API: ${CYAN}https://$DOMAIN/api${NC}"
    echo -e "  🏥 Health: ${CYAN}https://$DOMAIN/nginx-health${NC}"
    echo ""
    
    echo -e "${BLUE}📊 Management Commands:${NC}"
    echo -e "  🔍 Check status: ${CYAN}katacore-status${NC}"
    echo -e "  🔄 Reload Nginx: ${CYAN}sudo systemctl reload nginx${NC}"
    echo -e "  🧪 Test config: ${CYAN}sudo nginx -t${NC}"
    echo -e "  📜 View logs: ${CYAN}sudo tail -f /var/log/nginx/access.log${NC}"
    echo ""
    
    echo -e "${BLUE}🔐 SSL Certificate:${NC}"
    echo -e "  🔒 Auto-renewal: ${CYAN}sudo certbot renew --dry-run${NC}"
    echo -e "  📅 Check expiry: ${CYAN}sudo certbot certificates${NC}"
    echo ""
    
    echo -e "${BLUE}🚀 Next Steps:${NC}"
    echo -e "  1. Deploy your KataCore containers with: ${CYAN}./deploy-simple.sh${NC}"
    echo -e "  2. Test the setup: ${CYAN}katacore-status${NC}"
    echo -e "  3. Monitor logs: ${CYAN}sudo tail -f /var/log/nginx/access.log${NC}"
    echo ""
    
    warning "Make sure your KataCore containers are running on ports 3000 and 3001!"
    info "DNS should point $DOMAIN and $WWW_DOMAIN to $SERVER_IP"
}

# Main execution function
main() {
    show_banner
    
    # Parse environment variables or use defaults
    if [[ -f .env ]]; then
        source .env
        info "Loaded configuration from .env file"
    fi
    
    info "Domain: $DOMAIN"
    info "Server IP: $SERVER_IP"
    info "Email: $EMAIL"
    echo ""
    
    # Execute setup steps
    check_root
    install_nginx
    create_ssl_dirs
    create_nginx_config
    enable_site
    test_nginx
    reload_nginx
    install_certbot
    setup_ssl
    setup_firewall
    create_monitoring
    show_summary
}

# Run main function
main "$@"
