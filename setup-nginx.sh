#!/bin/bash

# 🌐 Nginx Configuration Setup Script
# Automatically configures nginx based on deployment type

set -euo pipefail

# Color codes
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# Logging functions
log() { echo -e "${GREEN}[$(date +'%H:%M:%S')]${NC} $1"; }
info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
success() { echo -e "${GREEN}✅ $1${NC}"; }
warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
error() { echo -e "${RED}❌ $1${NC}"; exit 1; }

# Configuration variables
DOMAIN=""
USE_SSL=false
NGINX_DIR="./nginx"
CONF_DIR="$NGINX_DIR/conf.d"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --domain)
            DOMAIN="$2"
            shift 2
            ;;
        --ssl)
            USE_SSL=true
            shift
            ;;
        --help)
            cat << 'EOF'
🌐 Nginx Configuration Setup

USAGE:
    ./setup-nginx.sh --domain DOMAIN [--ssl]

OPTIONS:
    --domain DOMAIN    Domain name for the site
    --ssl             Enable SSL configuration
    --help            Show this help

EXAMPLES:
    # Basic HTTP configuration
    ./setup-nginx.sh --domain innerbright.vn

    # HTTPS configuration with SSL
    ./setup-nginx.sh --domain innerbright.vn --ssl
EOF
            exit 0
            ;;
        *)
            error "Unknown option: $1"
            ;;
    esac
done

# Validate required parameters
if [[ -z "$DOMAIN" ]]; then
    error "Domain is required. Use --help for usage."
fi

log "🌐 Setting up Nginx configuration for $DOMAIN..."

# Create directories if they don't exist
mkdir -p "$CONF_DIR"
mkdir -p "$NGINX_DIR/ssl"
mkdir -p "./certbot/conf"
mkdir -p "./certbot/www"

if [[ "$USE_SSL" == "true" ]]; then
    info "Setting up SSL configuration..."
    
    # Generate SSL configuration from template
    sed "s/DOMAIN_NAME/$DOMAIN/g" "$CONF_DIR/ssl-template.conf" > "$CONF_DIR/$DOMAIN.conf"
    
    # Remove default configuration if it exists
    rm -f "$CONF_DIR/default.conf"
    
    success "SSL configuration created for $DOMAIN"
    
    # Create initial certificate request script
    cat > "./scripts/get-ssl-cert.sh" << 'EOF'
#!/bin/bash
DOMAIN=$1
if [[ -z "$DOMAIN" ]]; then
    echo "Usage: $0 DOMAIN"
    exit 1
fi

echo "🔒 Requesting SSL certificate for $DOMAIN..."
docker-compose exec certbot certbot certonly \
    --webroot \
    --webroot-path=/var/www/certbot \
    --email admin@$DOMAIN \
    --agree-tos \
    --no-eff-email \
    -d $DOMAIN

echo "🔄 Reloading nginx..."
docker-compose exec nginx nginx -s reload
EOF
    
    chmod +x "./scripts/get-ssl-cert.sh"
    
    info "To get SSL certificate, run: ./scripts/get-ssl-cert.sh $DOMAIN"
    
else
    info "Setting up HTTP configuration..."
    
    # Update default configuration with domain
    sed -i "s/server_name localhost;/server_name $DOMAIN;/" "$CONF_DIR/default.conf"
    
    success "HTTP configuration updated for $DOMAIN"
fi

# Create nginx test script
cat > "./scripts/test-nginx.sh" << 'EOF'
#!/bin/bash
echo "🧪 Testing nginx configuration..."

if docker-compose exec nginx nginx -t; then
    echo "✅ Nginx configuration is valid"
    echo "🔄 Reloading nginx..."
    docker-compose exec nginx nginx -s reload
    echo "✅ Nginx reloaded successfully"
else
    echo "❌ Nginx configuration test failed"
    exit 1
fi
EOF

chmod +x "./scripts/test-nginx.sh"

# Create directory for scripts if it doesn't exist
mkdir -p "./scripts"

success "🌐 Nginx configuration setup completed!"

echo ""
echo -e "${BLUE}📋 Next Steps:${NC}"
if [[ "$USE_SSL" == "true" ]]; then
    echo "1. Start the services: docker-compose up -d"
    echo "2. Get SSL certificate: ./scripts/get-ssl-cert.sh $DOMAIN"
    echo "3. Test configuration: ./scripts/test-nginx.sh"
    echo ""
    echo -e "${YELLOW}⚠️  Make sure your domain $DOMAIN points to this server's IP${NC}"
else
    echo "1. Start the services: docker-compose up -d"
    echo "2. Test configuration: ./scripts/test-nginx.sh"
    echo "3. Access your site at: http://$DOMAIN"
fi

echo ""
echo -e "${GREEN}🌐 Nginx will be available at:${NC}"
if [[ "$USE_SSL" == "true" ]]; then
    echo -e "  🌍 Site: https://$DOMAIN"
    echo -e "  🔌 API: https://$DOMAIN/api"
    echo -e "  📦 MinIO: https://$DOMAIN/minio"
    echo -e "  🗄️  pgAdmin: https://$DOMAIN/pgadmin"
else
    echo -e "  🌍 Site: http://$DOMAIN"
    echo -e "  🔌 API: http://$DOMAIN/api"
    echo -e "  📦 MinIO: http://$DOMAIN/minio"
    echo -e "  🗄️  pgAdmin: http://$DOMAIN/pgadmin"
fi
