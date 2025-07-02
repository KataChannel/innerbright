#!/bin/bash

# Demo script to show how nginx configuration is generated dynamically
# This demonstrates the new enhanced nginx configuration capabilities

set -euo pipefail

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${CYAN}🔧 KataCore Dynamic Nginx Configuration Demo${NC}"
echo ""

# Demo function to show configuration generation
demo_nginx_config() {
    local server_host="$1"
    local domain="${2:-}"
    
    echo -e "${YELLOW}📋 Configuration for:${NC}"
    echo "  Server Host: $server_host"
    echo "  Domain: ${domain:-'(IP-based deployment)'}"
    echo ""
    
    # Determine configuration based on input
    local host_url="${domain:-$server_host}"
    local protocol="http"
    local enable_ssl="false"
    local cors_origin="*"
    local listen_directives="listen 80 default_server;"
    local server_names="_"
    local ssl_configuration=""
    local ssl_redirect_block=""
    
    # Enhanced configuration for domain-based deployment
    if [[ -n "$domain" ]] && [[ "$domain" != "$server_host" ]]; then
        protocol="https"
        enable_ssl="true"
        cors_origin="$protocol://$domain"
        listen_directives="listen 443 ssl http2; listen [::]:443 ssl http2;"
        server_names="$domain www.$domain"
        
        # SSL configuration block
        ssl_configuration="
    # SSL Configuration
    ssl_certificate /etc/nginx/ssl/fullchain.pem;
    ssl_certificate_key /etc/nginx/ssl/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;"
        
        # HTTP to HTTPS redirect block
        ssl_redirect_block="
# HTTP to HTTPS redirect
server {
    listen 80;
    server_name $domain www.$domain;
    location / {
        return 301 https://\$host\$request_uri;
    }
}"
    else
        # IP-based deployment - simpler configuration
        cors_origin="$protocol://$host_url"
        listen_directives="listen 80 default_server;"
        server_names="_"
    fi
    
    echo -e "${GREEN}✅ Generated Configuration:${NC}"
    echo "  Protocol: $protocol"
    echo "  SSL Enabled: $enable_ssl"
    echo "  CORS Origin: $cors_origin"
    echo "  Listen: $listen_directives"
    echo "  Server Names: $server_names"
    echo ""
    
    # Show a snippet of the generated config
    echo -e "${CYAN}📄 Nginx Config Snippet:${NC}"
    cat << EOF
server {
    $listen_directives
    server_name $server_names;
$ssl_configuration
    
    # CORS configuration
    add_header Access-Control-Allow-Origin "$cors_origin" always;
    
    # API routes
    location /api/ {
        proxy_pass http://katacore_api/;
        # ... proxy headers ...
    }
    
    # Frontend routes
    location / {
        proxy_pass http://katacore_site;
        # ... proxy headers ...
    }
}
EOF
    
    if [[ -n "$ssl_redirect_block" ]]; then
        echo ""
        echo -e "${CYAN}📄 SSL Redirect Block:${NC}"
        echo "$ssl_redirect_block"
    fi
    
    echo ""
    echo "=================="
    echo ""
}

# Demo different scenarios
echo -e "${GREEN}🎯 Demo 1: IP-based Deployment${NC}"
demo_nginx_config "192.168.1.100"

echo -e "${GREEN}🎯 Demo 2: Domain-based Deployment${NC}"
demo_nginx_config "192.168.1.100" "myapp.com"

echo -e "${GREEN}🎯 Demo 3: Production Domain${NC}"
demo_nginx_config "116.118.85.41" "innerbright.vn"

echo -e "${CYAN}💡 Key Features:${NC}"
echo "  ✅ Automatic SSL configuration for domains"
echo "  ✅ HTTP to HTTPS redirect for domains"
echo "  ✅ Simple HTTP configuration for IP addresses"
echo "  ✅ Dynamic CORS configuration"
echo "  ✅ Template-based generation"
echo "  ✅ Backup of existing configurations"
echo ""

echo -e "${GREEN}🚀 To use in deployment:${NC}"
echo "  # IP-based deployment"
echo "  ./startkit-deployer.sh --host 192.168.1.100"
echo ""
echo "  # Domain-based deployment with SSL"
echo "  ./startkit-deployer.sh --host myserver.com --domain myapp.com"
echo ""
