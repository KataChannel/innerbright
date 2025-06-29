#!/bin/bash

# Innerbright Cloud Server Optimization Script
# Run this script on a fresh cloud server (Ubuntu/Debian)

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🚀 Innerbright Cloud Server Optimization${NC}"
echo -e "${BLUE}===========================================${NC}"

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   echo -e "${RED}❌ This script should not be run as root${NC}"
   exit 1
fi

# Update system
echo -e "${YELLOW}📦 Updating system packages...${NC}"
sudo apt update && sudo apt upgrade -y

# Install essential packages
echo -e "${YELLOW}📦 Installing essential packages...${NC}"
sudo apt install -y \
    curl \
    wget \
    git \
    htop \
    vim \
    ufw \
    fail2ban \
    unzip \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release

# Install Docker
echo -e "${YELLOW}🐳 Installing Docker...${NC}"
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    rm get-docker.sh
    echo -e "${GREEN}✅ Docker installed${NC}"
else
    echo -e "${GREEN}✅ Docker already installed${NC}"
fi

# Install Docker Compose
echo -e "${YELLOW}🐳 Installing Docker Compose...${NC}"
if ! command -v docker-compose &> /dev/null; then
    sudo apt install -y docker-compose-plugin
    echo -e "${GREEN}✅ Docker Compose installed${NC}"
else
    echo -e "${GREEN}✅ Docker Compose already installed${NC}"
fi

# Configure firewall
echo -e "${YELLOW}🔥 Configuring firewall...${NC}"
sudo ufw --force reset
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw --force enable
echo -e "${GREEN}✅ Firewall configured${NC}"

# Configure fail2ban
echo -e "${YELLOW}🔒 Configuring fail2ban...${NC}"
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
echo -e "${GREEN}✅ Fail2ban configured${NC}"

# Optimize system performance
echo -e "${YELLOW}⚡ Optimizing system performance...${NC}"

# Increase file limits
sudo tee -a /etc/security/limits.conf > /dev/null <<EOF
* soft nofile 65536
* hard nofile 65536
* soft nproc 65536
* hard nproc 65536
EOF

# Optimize kernel parameters
sudo tee -a /etc/sysctl.conf > /dev/null <<EOF

# Innerbright optimizations
vm.max_map_count=262144
vm.swappiness=10
net.core.somaxconn=65535
net.ipv4.tcp_max_syn_backlog=65535
net.core.netdev_max_backlog=65535
net.ipv4.ip_local_port_range=1024 65535
net.ipv4.tcp_fin_timeout=30
net.ipv4.tcp_keepalive_time=120
net.ipv4.tcp_keepalive_intvl=30
net.ipv4.tcp_keepalive_probes=3
EOF

sudo sysctl -p

# Create swap file if not exists
if [ ! -f /swapfile ]; then
    echo -e "${YELLOW}💾 Creating swap file...${NC}"
    sudo fallocate -l 2G /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
    echo -e "${GREEN}✅ Swap file created${NC}"
fi

# Install monitoring tools
echo -e "${YELLOW}📊 Installing monitoring tools...${NC}"
sudo apt install -y \
    iotop \
    nethogs \
    ncdu \
    tree

# Create project directory
echo -e "${YELLOW}📁 Creating project directory...${NC}"
sudo mkdir -p /opt/innerbright
sudo chown $USER:$USER /opt/innerbright
echo -e "${GREEN}✅ Project directory created: /opt/innerbright${NC}"

# Setup log rotation
echo -e "${YELLOW}📝 Configuring log rotation...${NC}"
sudo tee /etc/logrotate.d/innerbright > /dev/null <<EOF
/opt/innerbright/logs/*.log {
    daily
    missingok
    rotate 14
    compress
    delaycompress
    notifempty
    create 644 $USER $USER
}
EOF

# Setup automatic updates
echo -e "${YELLOW}🔄 Configuring automatic security updates...${NC}"
sudo apt install -y unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades

# Setup backup directory
echo -e "${YELLOW}💾 Creating backup directory...${NC}"
sudo mkdir -p /opt/backups
sudo chown $USER:$USER /opt/backups

# Setup cron job for system maintenance
echo -e "${YELLOW}⏰ Setting up maintenance cron jobs...${NC}"
(crontab -l 2>/dev/null; echo "0 3 * * 0 docker system prune -f") | crontab -
(crontab -l 2>/dev/null; echo "0 2 * * * cd /opt/innerbright && ./manage.sh backup") | crontab -

# Install SSL certificate tool
echo -e "${YELLOW}🔐 Installing Certbot for SSL...${NC}"
sudo apt install -y certbot python3-certbot-nginx
echo -e "${GREEN}✅ Certbot installed${NC}"

# Configure timezone
echo -e "${YELLOW}🕐 Setting timezone...${NC}"
sudo timedatectl set-timezone Asia/Ho_Chi_Minh
echo -e "${GREEN}✅ Timezone set to Asia/Ho_Chi_Minh${NC}"

# Setup .bashrc aliases
echo -e "${YELLOW}⚡ Setting up useful aliases...${NC}"
cat >> ~/.bashrc << 'EOF'

# Innerbright aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Docker aliases
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias dlog='docker-compose logs -f'
alias dup='docker-compose up -d'
alias ddown='docker-compose down'
alias drestart='docker-compose restart'

# System monitoring
alias ports='netstat -tuln'
alias topcpu='ps auxf | sort -nr -k 3 | head -10'
alias topmem='ps auxf | sort -nr -k 4 | head -10'

# Innerbright specific
alias ib='cd /opt/innerbright'
alias iblog='cd /opt/innerbright && ./manage.sh logs'
alias ibstatus='cd /opt/innerbright && ./manage.sh status'
alias ibhealth='cd /opt/innerbright && ./manage.sh health'
EOF

# Create deployment checklist
echo -e "${YELLOW}📋 Creating deployment checklist...${NC}"
cat > /opt/innerbright/DEPLOYMENT_CHECKLIST.md << 'EOF'
# 🚀 Innerbright Deployment Checklist

## Pre-deployment
- [ ] Server optimized with setup-cloud-server.sh
- [ ] Domain DNS pointing to server IP
- [ ] Firewall configured (ports 80, 443, SSH)
- [ ] SSL certificate ready
- [ ] Environment variables set in .env
- [ ] Database backup available

## Deployment Steps
1. [ ] Clone repository to /opt/innerbright
2. [ ] Copy .env.example to .env and configure
3. [ ] Run ./deploy-production.sh
4. [ ] Verify all services are healthy
5. [ ] Test application functionality
6. [ ] Setup SSL certificate if needed
7. [ ] Configure monitoring alerts

## Post-deployment
- [ ] Verify backups are working
- [ ] Test disaster recovery
- [ ] Monitor resource usage
- [ ] Setup log rotation
- [ ] Document access credentials
- [ ] Train team on management scripts

## Security Checklist
- [ ] Change all default passwords
- [ ] Disable root SSH login
- [ ] Enable SSH key authentication only
- [ ] Configure fail2ban
- [ ] Enable automatic security updates
- [ ] Setup monitoring alerts
- [ ] Regular security audits scheduled

## Monitoring Setup
- [ ] Health check endpoints working
- [ ] Log aggregation configured  
- [ ] Performance monitoring active
- [ ] Backup verification automated
- [ ] Alert channels configured
EOF

echo -e "${GREEN}🎉 Server optimization completed!${NC}"
echo -e "${BLUE}===========================================${NC}"
echo -e "${GREEN}Next steps:${NC}"
echo -e "1. ${YELLOW}Logout and login again to use Docker without sudo${NC}"
echo -e "2. ${YELLOW}Clone your project to /opt/innerbright${NC}"
echo -e "3. ${YELLOW}Configure .env file${NC}"
echo -e "4. ${YELLOW}Run ./deploy-production.sh${NC}"
echo -e "5. ${YELLOW}Setup SSL certificate with certbot${NC}"
echo -e ""
echo -e "${BLUE}Useful commands:${NC}"
echo -e "  ${GREEN}ib${NC}         - Go to project directory"
echo -e "  ${GREEN}ibstatus${NC}   - Check service status"
echo -e "  ${GREEN}ibhealth${NC}   - Check service health"
echo -e "  ${GREEN}iblog${NC}      - View logs"
echo -e ""
echo -e "${YELLOW}⚠️  Remember to reboot the server to apply all optimizations${NC}"
echo -e "${GREEN}🚀 Server is ready for Innerbright deployment!${NC}"
