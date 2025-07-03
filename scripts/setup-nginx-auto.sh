#!/bin/bash

# KataCore Automated Nginx Setup Script
# For first-time deployment to server 116.118.85.41
# Automatically configures Nginx with SSL for innerbright.vn

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
DOMAIN="innerbright.vn"
WWW_DOMAIN="www.innerbright.vn"
SERVER_IP="116.118.85.41"
EMAIL="admin@innerbright.vn"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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
║                   🌐 KataCore Nginx Auto-Setup                              ║
║                                                                              ║
║        Automatic Nginx configuration with SSL for innerbright.vn            ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        error "This script must be run as root. Please use sudo."
    fi
}

# Check if Nginx is installed
check_nginx() {
    log "🔍 Checking Nginx installation..."
    
    if ! command -v nginx >/dev/null 2>&1; then
        info "Nginx not found, installing..."
        apt update
        apt install nginx -y
        success "Nginx installed successfully"
    else
        info "Nginx already installed"
    fi
    
    # Ensure Nginx is running
    if ! systemctl is-active --quiet nginx; then
        info "Starting Nginx service..."
        systemctl start nginx
        systemctl enable nginx
        success "Nginx service started and enabled"
    else
        info "Nginx service is already running"
    fi
}

# Create Nginx site configuration
create_nginx_config() {
    log "📝 Creating Nginx configuration for $DOMAIN..."
    
    # Backup existing configuration if it exists
    if [ -f "/etc/nginx/sites-available/$DOMAIN" ]; then
        info "Backing up existing configuration..."
        cp "/etc/nginx/sites-available/$DOMAIN" "/etc/nginx/sites-available/$DOMAIN.backup-$(date +%Y%m%d-%H%M%S)"
    fi
    
    # Create the configuration
    cat > "/etc/nginx/sites-available/$DOMAIN" << 'EOF'
server {
    listen 80;
    server_name innerbright.vn www.innerbright.vn;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;

    # Rate limiting
    limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
    limit_req_zone $binary_remote_addr zone=site:10m rate=30r/s;

    # API proxy with rate limiting
    location /api/ {
        limit_req zone=api burst=20 nodelay;
        
        proxy_pass http://localhost:3001/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        
        # Timeout settings
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
        
        # Buffer settings
        proxy_buffering on;
        proxy_buffer_size 4k;
        proxy_buffers 8 4k;
        proxy_busy_buffers_size 8k;
    }

    # Health check endpoint
    location /health {
        proxy_pass http://localhost:3001/health;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # No caching for health checks
        proxy_cache_bypass 1;
        proxy_no_cache 1;
    }

    # Site proxy with rate limiting
    location / {
        limit_req zone=site burst=50 nodelay;
        
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        
        # Timeout settings
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
        
        # Buffer settings
        proxy_buffering on;
        proxy_buffer_size 4k;
        proxy_buffers 8 4k;
        proxy_busy_buffers_size 8k;
    }

    # Static file handling for better performance
    location ~* \.(css|js|jpg|jpeg|png|gif|ico|svg|woff|woff2|ttf|eot)$ {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Cache static files
        expires 1y;
        add_header Cache-Control "public, immutable";
        add_header X-Cache-Status "STATIC";
    }

    # Deny access to sensitive files
    location ~ /\. {
        deny all;
        access_log off;
        log_not_found off;
    }

    # Deny access to backup files
    location ~ ~$ {
        deny all;
        access_log off;
        log_not_found off;
    }
}
EOF
    
    success "Nginx configuration created for $DOMAIN"
}

# Enable the site
enable_site() {
    log "🔗 Enabling Nginx site..."
    
    # Create symbolic link
    if [ -L "/etc/nginx/sites-enabled/$DOMAIN" ]; then
        info "Site already enabled"
    else
        ln -sf "/etc/nginx/sites-available/$DOMAIN" "/etc/nginx/sites-enabled/"
        success "Site enabled successfully"
    fi
    
    # Remove default site if it exists
    if [ -f "/etc/nginx/sites-enabled/default" ]; then
        rm "/etc/nginx/sites-enabled/default"
        success "Default site removed"
    fi
}

# Test and reload Nginx
test_and_reload_nginx() {
    log "🧪 Testing Nginx configuration..."
    
    if nginx -t; then
        success "Nginx configuration is valid"
        
        log "🔄 Reloading Nginx..."
        systemctl reload nginx
        success "Nginx reloaded successfully"
    else
        error "Nginx configuration test failed"
    fi
}

# Install Certbot
install_certbot() {
    log "🔒 Installing Certbot..."
    
    if ! command -v certbot >/dev/null 2>&1; then
        info "Installing Certbot..."
        apt update
        apt install certbot python3-certbot-nginx -y
        success "Certbot installed successfully"
    else
        info "Certbot already installed"
    fi
}

# Setup SSL certificate
setup_ssl() {
    log "🔐 Setting up SSL certificate..."
    
    # Check if DNS is pointing to the server
    info "Checking DNS resolution for $DOMAIN..."
    if ! host "$DOMAIN" >/dev/null 2>&1; then
        warning "DNS resolution failed for $DOMAIN"
        info "Please ensure DNS is pointing to $SERVER_IP before continuing"
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            info "SSL setup skipped. You can run it later with:"
            echo "  sudo certbot --nginx -d $DOMAIN -d $WWW_DOMAIN"
            return 0
        fi
    fi
    
    # Setup SSL certificate
    info "Requesting SSL certificate..."
    if certbot --nginx -d "$DOMAIN" -d "$WWW_DOMAIN" --non-interactive --agree-tos --email "$EMAIL" --redirect; then
        success "SSL certificate configured successfully"
        
        # Setup auto-renewal
        info "Setting up SSL certificate auto-renewal..."
        if ! crontab -l 2>/dev/null | grep -q "certbot renew"; then
            (crontab -l 2>/dev/null; echo "0 12 * * * /usr/bin/certbot renew --quiet") | crontab -
            success "SSL auto-renewal configured"
        else
            info "SSL auto-renewal already configured"
        fi
    else
        warning "SSL setup failed. You may need to:"
        echo "  1. Ensure DNS is pointing to $SERVER_IP"
        echo "  2. Check firewall settings (ports 80 and 443)"
        echo "  3. Run manually: sudo certbot --nginx -d $DOMAIN -d $WWW_DOMAIN"
    fi
}

# Setup firewall
setup_firewall() {
    log "🛡️  Setting up firewall..."
    
    if command -v ufw >/dev/null 2>&1; then
        info "Configuring UFW firewall..."
        ufw allow 22/tcp comment "SSH"
        ufw allow 80/tcp comment "HTTP"
        ufw allow 443/tcp comment "HTTPS"
        ufw allow 3000/tcp comment "Next.js Site"
        ufw allow 3001/tcp comment "NestJS API"
        
        # Enable UFW if not already enabled
        if ! ufw status | grep -q "Status: active"; then
            ufw --force enable
            success "UFW firewall enabled and configured"
        else
            ufw reload
            success "UFW firewall rules updated"
        fi
    else
        warning "UFW not found. Please configure firewall manually:"
        echo "  - Allow ports: 22, 80, 443, 3000, 3001"
    fi
}

# Create monitoring script
create_monitoring_script() {
    log "📊 Creating monitoring script..."
    
    cat > "/usr/local/bin/katacore-monitor.sh" << 'EOF'
#!/bin/bash

# KataCore Service Monitor
# Checks if API and Site are running

API_URL="http://localhost:3001/health"
SITE_URL="http://localhost:3000"

echo "=== KataCore Service Monitor ==="
echo "Timestamp: $(date)"
echo ""

# Check API
echo "🔍 Checking API..."
if curl -f -s "$API_URL" >/dev/null 2>&1; then
    echo "✅ API is running (Port 3001)"
else
    echo "❌ API is not responding (Port 3001)"
fi

# Check Site
echo "🔍 Checking Site..."
if curl -f -s "$SITE_URL" >/dev/null 2>&1; then
    echo "✅ Site is running (Port 3000)"
else
    echo "❌ Site is not responding (Port 3000)"
fi

# Check Nginx
echo "🔍 Checking Nginx..."
if systemctl is-active --quiet nginx; then
    echo "✅ Nginx is running"
else
    echo "❌ Nginx is not running"
fi

# Check SSL certificate
echo "🔍 Checking SSL certificate..."
if [ -f "/etc/letsencrypt/live/innerbright.vn/fullchain.pem" ]; then
    EXPIRY=$(openssl x509 -enddate -noout -in /etc/letsencrypt/live/innerbright.vn/fullchain.pem | cut -d= -f2)
    echo "✅ SSL certificate valid until: $EXPIRY"
else
    echo "⚠️  SSL certificate not found"
fi

echo ""
echo "=== End Monitor ==="
EOF
    
    chmod +x "/usr/local/bin/katacore-monitor.sh"
    success "Monitoring script created at /usr/local/bin/katacore-monitor.sh"
}

# Show summary
show_summary() {
    echo ""
    success "🎉 Nginx setup completed successfully!"
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
    echo -e "  🏥 Health: ${CYAN}https://$DOMAIN/health${NC}"
    echo ""
    
    echo -e "${BLUE}🛠️  Management Commands:${NC}"
    echo -e "  🧪 Test config: ${CYAN}sudo nginx -t${NC}"
    echo -e "  🔄 Reload: ${CYAN}sudo systemctl reload nginx${NC}"
    echo -e "  📊 Monitor: ${CYAN}sudo /usr/local/bin/katacore-monitor.sh${NC}"
    echo -e "  🔒 Check SSL: ${CYAN}sudo certbot certificates${NC}"
    echo -e "  🔄 Renew SSL: ${CYAN}sudo certbot renew${NC}"
    echo ""
    
    echo -e "${BLUE}🔥 Next Steps:${NC}"
    echo -e "  1. Deploy KataCore containers: ${CYAN}./deploy-simple.sh${NC}"
    echo -e "  2. Test the website: ${CYAN}curl -I https://$DOMAIN${NC}"
    echo -e "  3. Run monitoring: ${CYAN}sudo /usr/local/bin/katacore-monitor.sh${NC}"
    echo ""
    
    echo -e "${GREEN}✅ Server ready for KataCore deployment!${NC}"
}

# Main execution
main() {
    show_banner
    
    info "Starting Nginx setup for KataCore..."
    echo "Domain: $DOMAIN"
    echo "Server: $SERVER_IP"
    echo ""
    
    check_root
    check_nginx
    create_nginx_config
    enable_site
    test_and_reload_nginx
    install_certbot
    setup_ssl
    setup_firewall
    create_monitoring_script
    show_summary
}

# Run main function
main "$@"
