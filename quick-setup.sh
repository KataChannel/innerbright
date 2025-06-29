#!/bin/bash

# Quick Production Setup Script for Innerbright
# Run this after server setup to quickly deploy the application

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}"
echo "================================================"
echo "    ⚡ INNERBRIGHT QUICK SETUP"
echo "================================================"
echo -e "${NC}"

# Function to generate secure password
generate_password() {
    openssl rand -base64 32 | tr -d "=+/" | cut -c1-${1:-32}
}

# Function to setup environment
setup_environment() {
    echo -e "${BLUE}🔧 Setting up environment variables...${NC}"
    
    if [ ! -f ".env" ]; then
        if [ -f ".env.example" ]; then
            cp .env.example .env
        else
            echo -e "${RED}❌ .env.example not found${NC}"
            exit 1
        fi
    fi
    
    # Generate secure passwords
    POSTGRES_PASS=$(generate_password 32)
    NEXTAUTH_SECRET=$(generate_password 32)
    JWT_SECRET=$(generate_password 64)
    MINIO_ACCESS=$(generate_password 16)
    MINIO_SECRET=$(generate_password 32)
    
    # Update .env file
    sed -i "s/CHANGE_THIS_TO_SECURE_PASSWORD_32_CHARS/$POSTGRES_PASS/g" .env
    sed -i "s/CHANGE_THIS_32_CHARACTER_SECRET_KEY/$NEXTAUTH_SECRET/g" .env
    sed -i "s/CHANGE_THIS_JWT_SECRET_KEY_64_CHARS/$JWT_SECRET/g" .env
    sed -i "s/your_minio_access_key_here/$MINIO_ACCESS/g" .env
    sed -i "s/your_minio_secret_key_here/$MINIO_SECRET/g" .env
    
    echo -e "${GREEN}✅ Environment configured with secure passwords${NC}"
}

# Function to configure domain
configure_domain() {
    echo -e "${BLUE}🌐 Domain configuration...${NC}"
    
    read -p "Enter your domain (or press Enter for localhost): " DOMAIN
    DOMAIN=${DOMAIN:-localhost}
    
    if [ "$DOMAIN" != "localhost" ]; then
        # Update NEXTAUTH_URL in .env
        sed -i "s/https:\/\/yourdomain.com/https:\/\/$DOMAIN/g" .env
        
        echo -e "${GREEN}✅ Domain set to: $DOMAIN${NC}"
        echo -e "${YELLOW}⚠️  Make sure your domain DNS points to this server IP${NC}"
        
        # Ask about SSL
        read -p "Setup SSL certificate with Let's Encrypt? (y/n): " SETUP_SSL
        if [ "$SETUP_SSL" = "y" ] || [ "$SETUP_SSL" = "Y" ]; then
            setup_ssl $DOMAIN
        fi
    else
        echo -e "${YELLOW}Using localhost for development${NC}"
    fi
}

# Function to setup SSL
setup_ssl() {
    local domain=$1
    echo -e "${BLUE}🔒 Setting up SSL certificate...${NC}"
    
    # Install certbot if not installed
    if ! command -v certbot &> /dev/null; then
        echo -e "${YELLOW}Installing certbot...${NC}"
        sudo apt update
        sudo apt install -y certbot
    fi
    
    # Get certificate
    echo -e "${YELLOW}Getting SSL certificate for $domain...${NC}"
    sudo certbot certonly --standalone \
        --non-interactive \
        --agree-tos \
        --email admin@$domain \
        -d $domain \
        -d www.$domain
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ SSL certificate obtained${NC}"
        
        # Setup auto-renewal
        echo "0 12 * * * /usr/bin/certbot renew --quiet" | sudo crontab -
        echo -e "${GREEN}✅ Auto-renewal configured${NC}"
    else
        echo -e "${RED}❌ Failed to get SSL certificate${NC}"
    fi
}

# Function to deploy application
deploy_application() {
    echo -e "${BLUE}🚀 Deploying application...${NC}"
    
    # Check if deploy script exists
    if [ -f "./deploy-production.sh" ]; then
        chmod +x ./deploy-production.sh
        ./deploy-production.sh
    else
        echo -e "${YELLOW}Running manual deployment...${NC}"
        
        # Build and start services
        docker compose build --no-cache
        docker compose up -d postgres
        
        # Wait for database
        echo -e "${YELLOW}⏳ Waiting for database...${NC}"
        sleep 30
        
        # Run migrations
        docker compose up prisma-migrate
        
        # Start all services
        docker compose up -d
        
        echo -e "${GREEN}✅ Application deployed${NC}"
    fi
}

# Function to verify deployment
verify_deployment() {
    echo -e "${BLUE}🔍 Verifying deployment...${NC}"
    
    sleep 30
    
    # Check services
    if curl -f http://localhost:3000/api/health > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Frontend is healthy${NC}"
    else
        echo -e "${RED}❌ Frontend health check failed${NC}"
    fi
    
    if curl -f http://localhost:3333/health > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Backend is healthy${NC}"
    else
        echo -e "${RED}❌ Backend health check failed${NC}"
    fi
    
    # Show service status
    echo -e "${BLUE}📊 Service Status:${NC}"
    docker compose ps
}

# Function to setup monitoring
setup_monitoring() {
    echo -e "${BLUE}📊 Setting up monitoring...${NC}"
    
    # Create monitoring script
    cat > ./monitor-services.sh << 'EOF'
#!/bin/bash
# Service monitoring script

echo "🔍 Service Health Check - $(date)"
echo "=================================="

# Check Next.js
if curl -f http://localhost:3000/api/health > /dev/null 2>&1; then
    echo "✅ Next.js: Healthy"
else
    echo "❌ Next.js: Unhealthy"
fi

# Check NestJS
if curl -f http://localhost:3333/health > /dev/null 2>&1; then
    echo "✅ NestJS: Healthy"
else
    echo "❌ NestJS: Unhealthy"
fi

# Check PostgreSQL
if docker compose exec -T postgres pg_isready -U postgres > /dev/null 2>&1; then
    echo "✅ PostgreSQL: Healthy"
else
    echo "❌ PostgreSQL: Unhealthy"
fi

# Check MinIO
if curl -f http://localhost:9000/minio/health/live > /dev/null 2>&1; then
    echo "✅ MinIO: Healthy"
else
    echo "❌ MinIO: Unhealthy"
fi

# System resources
echo ""
echo "💻 System Resources:"
echo "Memory: $(free -h | awk 'NR==2{printf "%.1fG/%.1fG (%.0f%%)", $3/1024/1024, $2/1024/1024, $3*100/$2}')"
echo "Disk: $(df -h / | awk 'NR==2{printf "%s/%s (%s)", $3, $2, $5}')"

echo "=================================="
EOF

    chmod +x ./monitor-services.sh
    
    # Setup cron job for monitoring
    (crontab -l 2>/dev/null; echo "*/5 * * * * cd $(pwd) && ./monitor-services.sh >> ./logs/health.log 2>&1") | crontab -
    
    # Create logs directory
    mkdir -p ./logs
    
    echo -e "${GREEN}✅ Monitoring setup complete${NC}"
}

# Function to setup backups
setup_backups() {
    echo -e "${BLUE}💾 Setting up automated backups...${NC}"
    
    # Create backup script
    cat > ./backup-database.sh << 'EOF'
#!/bin/bash
# Database backup script

BACKUP_DIR="./backups/$(date +%Y%m%d)"
mkdir -p $BACKUP_DIR

# Backup database
docker compose exec -T postgres pg_dump -U postgres ${POSTGRES_DB:-innerbright} > $BACKUP_DIR/database_$(date +%H%M%S).sql

# Compress backup
gzip $BACKUP_DIR/database_*.sql

# Keep only last 7 days
find ./backups -type d -mtime +7 -exec rm -rf {} +

echo "✅ Backup completed: $BACKUP_DIR"
EOF

    chmod +x ./backup-database.sh
    
    # Setup daily backup at 2 AM
    (crontab -l 2>/dev/null; echo "0 2 * * * cd $(pwd) && ./backup-database.sh") | crontab -
    
    echo -e "${GREEN}✅ Daily backups configured${NC}"
}

# Function to show final information
show_final_info() {
    echo -e "${GREEN}"
    echo "================================================"
    echo "    🎉 QUICK SETUP COMPLETED!"
    echo "================================================"
    echo -e "${NC}"
    
    echo -e "${BLUE}🌐 Access URLs:${NC}"
    if [ -f ".env" ]; then
        source .env
        if [ "$NEXTAUTH_URL" != "https://yourdomain.com" ]; then
            echo -e "  Frontend: ${GREEN}$NEXTAUTH_URL${NC}"
        else
            echo -e "  Frontend: ${GREEN}http://localhost:3000${NC}"
        fi
    fi
    echo -e "  Backend API: ${GREEN}http://localhost:3333${NC}"
    echo -e "  MinIO Console: ${GREEN}http://localhost:9001${NC}"
    
    echo ""
    echo -e "${BLUE}🛠️  Management Commands:${NC}"
    echo -e "  Check health: ${YELLOW}./monitor-services.sh${NC}"
    echo -e "  View logs: ${YELLOW}docker compose logs -f${NC}"
    echo -e "  Backup DB: ${YELLOW}./backup-database.sh${NC}"
    echo -e "  Restart: ${YELLOW}docker compose restart${NC}"
    
    echo ""
    echo -e "${BLUE}📁 Important Files:${NC}"
    echo -e "  Environment: ${YELLOW}.env${NC}"
    echo -e "  Logs: ${YELLOW}./logs/${NC}"
    echo -e "  Backups: ${YELLOW}./backups/${NC}"
    
    echo ""
    echo -e "${GREEN}🚀 Your Innerbright application is live!${NC}"
}

# Main execution
main() {
    # Check requirements
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}❌ Docker not found. Please run setup-cloud-server.sh first${NC}"
        exit 1
    fi
    
    # Run setup steps
    setup_environment
    configure_domain
    deploy_application
    verify_deployment
    setup_monitoring
    setup_backups
    show_final_info
}

# Run main function
main
