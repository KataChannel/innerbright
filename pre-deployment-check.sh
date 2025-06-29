#!/bin/bash

# Pre-deployment System Check for Innerbright
# Run this script before deploying to ensure your server is ready

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
MIN_RAM_MB=3000
MIN_DISK_GB=15
MIN_CPU_CORES=2

echo -e "${BLUE}🔍 Innerbright Pre-Deployment System Check${NC}"
echo -e "${BLUE}==========================================${NC}\n"

# Check functions
check_os() {
    echo -e "${CYAN}📋 Checking Operating System...${NC}"
    
    if [[ ! -f /etc/os-release ]]; then
        echo -e "${RED}❌ Cannot determine OS version${NC}"
        return 1
    fi
    
    . /etc/os-release
    echo -e "${GREEN}✅ OS: $PRETTY_NAME${NC}"
    
    if [[ $ID != "ubuntu" ]] && [[ $ID != "debian" ]]; then
        echo -e "${YELLOW}⚠️  Warning: Optimized for Ubuntu/Debian, but will attempt to continue${NC}"
    fi
    
    # Check if system is up to date
    if command -v apt &> /dev/null; then
        echo -e "${YELLOW}📦 Checking for system updates...${NC}"
        UPDATES=$(apt list --upgradable 2>/dev/null | wc -l)
        if [[ $UPDATES -gt 1 ]]; then
            echo -e "${YELLOW}⚠️  $((UPDATES-1)) package updates available. Consider running: sudo apt update && sudo apt upgrade${NC}"
        else
            echo -e "${GREEN}✅ System is up to date${NC}"
        fi
    fi
}

check_resources() {
    echo -e "\n${CYAN}💻 Checking System Resources...${NC}"
    
    # Check CPU
    CPU_CORES=$(nproc)
    if [[ $CPU_CORES -ge $MIN_CPU_CORES ]]; then
        echo -e "${GREEN}✅ CPU Cores: $CPU_CORES (minimum: $MIN_CPU_CORES)${NC}"
    else
        echo -e "${RED}❌ CPU Cores: $CPU_CORES (minimum required: $MIN_CPU_CORES)${NC}"
        return 1
    fi
    
    # Check RAM
    TOTAL_RAM_MB=$(free -m | awk 'NR==2{print $2}')
    AVAILABLE_RAM_MB=$(free -m | awk 'NR==2{print $7}')
    
    if [[ $TOTAL_RAM_MB -ge $MIN_RAM_MB ]]; then
        echo -e "${GREEN}✅ Total RAM: ${TOTAL_RAM_MB}MB (minimum: ${MIN_RAM_MB}MB)${NC}"
    else
        echo -e "${RED}❌ Total RAM: ${TOTAL_RAM_MB}MB (minimum required: ${MIN_RAM_MB}MB)${NC}"
        return 1
    fi
    
    echo -e "${BLUE}   Available RAM: ${AVAILABLE_RAM_MB}MB${NC}"
    
    # Check Disk Space
    ROOT_DISK_GB=$(df / | awk 'NR==2{print int($4/1024/1024)}')
    
    if [[ $ROOT_DISK_GB -ge $MIN_DISK_GB ]]; then
        echo -e "${GREEN}✅ Available Disk Space: ${ROOT_DISK_GB}GB (minimum: ${MIN_DISK_GB}GB)${NC}"
    else
        echo -e "${RED}❌ Available Disk Space: ${ROOT_DISK_GB}GB (minimum required: ${MIN_DISK_GB}GB)${NC}"
        return 1
    fi
    
    # Check Swap
    SWAP_MB=$(free -m | awk 'NR==3{print $2}')
    if [[ $SWAP_MB -gt 0 ]]; then
        echo -e "${GREEN}✅ Swap Space: ${SWAP_MB}MB${NC}"
    else
        echo -e "${YELLOW}⚠️  No swap space configured. Consider adding swap for better performance.${NC}"
    fi
}

check_network() {
    echo -e "\n${CYAN}🌐 Checking Network Connectivity...${NC}"
    
    # Check internet connectivity
    if ping -c 1 google.com &> /dev/null; then
        echo -e "${GREEN}✅ Internet connectivity: OK${NC}"
    else
        echo -e "${RED}❌ No internet connection${NC}"
        return 1
    fi
    
    # Check DNS resolution
    if nslookup google.com &> /dev/null; then
        echo -e "${GREEN}✅ DNS resolution: OK${NC}"
    else
        echo -e "${RED}❌ DNS resolution failed${NC}"
        return 1
    fi
    
    # Check if common ports are available
    PORTS_TO_CHECK=(22 80 443 3000 3333 5432)
    for port in "${PORTS_TO_CHECK[@]}"; do
        if ss -tuln | grep -q ":$port "; then
            echo -e "${YELLOW}⚠️  Port $port is already in use${NC}"
        else
            echo -e "${GREEN}✅ Port $port is available${NC}"
        fi
    done
}

check_permissions() {
    echo -e "\n${CYAN}🔐 Checking User Permissions...${NC}"
    
    # Check if user has sudo privileges
    if sudo -n true 2>/dev/null; then
        echo -e "${GREEN}✅ User has sudo privileges${NC}"
    else
        echo -e "${RED}❌ User does not have sudo privileges${NC}"
        return 1
    fi
    
    # Check if running as root (not recommended)
    if [[ $EUID -eq 0 ]]; then
        echo -e "${RED}❌ Running as root is not recommended for deployment${NC}"
        return 1
    else
        echo -e "${GREEN}✅ Not running as root${NC}"
    fi
}

check_existing_software() {
    echo -e "\n${CYAN}📦 Checking for Existing Software...${NC}"
    
    # Check Docker
    if command -v docker &> /dev/null; then
        DOCKER_VERSION=$(docker --version | cut -d' ' -f3 | cut -d',' -f1)
        echo -e "${GREEN}✅ Docker installed: $DOCKER_VERSION${NC}"
        
        # Check if Docker is running
        if docker info &> /dev/null; then
            echo -e "${GREEN}✅ Docker daemon is running${NC}"
        else
            echo -e "${YELLOW}⚠️  Docker is installed but not running${NC}"
        fi
        
        # Check if user is in docker group
        if groups | grep -q docker; then
            echo -e "${GREEN}✅ User is in docker group${NC}"
        else
            echo -e "${YELLOW}⚠️  User is not in docker group. Run: sudo usermod -aG docker \$USER${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  Docker not installed${NC}"
    fi
    
    # Check Docker Compose
    if command -v docker-compose &> /dev/null || docker compose version &> /dev/null; then
        if command -v docker-compose &> /dev/null; then
            COMPOSE_VERSION=$(docker-compose --version | cut -d' ' -f3 | cut -d',' -f1)
            echo -e "${GREEN}✅ Docker Compose installed: $COMPOSE_VERSION${NC}"
        else
            COMPOSE_VERSION=$(docker compose version | grep -o 'v[0-9.]*')
            echo -e "${GREEN}✅ Docker Compose (plugin) installed: $COMPOSE_VERSION${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  Docker Compose not installed${NC}"
    fi
    
    # Check Git
    if command -v git &> /dev/null; then
        GIT_VERSION=$(git --version | cut -d' ' -f3)
        echo -e "${GREEN}✅ Git installed: $GIT_VERSION${NC}"
    else
        echo -e "${YELLOW}⚠️  Git not installed${NC}"
    fi
    
    # Check Nginx
    if command -v nginx &> /dev/null; then
        NGINX_VERSION=$(nginx -v 2>&1 | cut -d'/' -f2)
        echo -e "${GREEN}✅ Nginx installed: $NGINX_VERSION${NC}"
    else
        echo -e "${YELLOW}⚠️  Nginx not installed${NC}"
    fi
    
    # Check Certbot
    if command -v certbot &> /dev/null; then
        CERTBOT_VERSION=$(certbot --version | cut -d' ' -f2)
        echo -e "${GREEN}✅ Certbot installed: $CERTBOT_VERSION${NC}"
    else
        echo -e "${YELLOW}⚠️  Certbot not installed${NC}"
    fi
}

check_security() {
    echo -e "\n${CYAN}🔒 Checking Security Configuration...${NC}"
    
    # Check UFW firewall
    if command -v ufw &> /dev/null; then
        UFW_STATUS=$(sudo ufw status | head -1 | awk '{print $2}')
        if [[ $UFW_STATUS == "active" ]]; then
            echo -e "${GREEN}✅ UFW firewall is active${NC}"
        else
            echo -e "${YELLOW}⚠️  UFW firewall is not active${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  UFW firewall not installed${NC}"
    fi
    
    # Check fail2ban
    if command -v fail2ban-server &> /dev/null; then
        if systemctl is-active --quiet fail2ban; then
            echo -e "${GREEN}✅ Fail2ban is active${NC}"
        else
            echo -e "${YELLOW}⚠️  Fail2ban is installed but not active${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  Fail2ban not installed${NC}"
    fi
    
    # Check SSH configuration
    if [[ -f /etc/ssh/sshd_config ]]; then
        ROOT_LOGIN=$(grep "^PermitRootLogin" /etc/ssh/sshd_config | awk '{print $2}')
        if [[ $ROOT_LOGIN == "no" ]]; then
            echo -e "${GREEN}✅ Root SSH login is disabled${NC}"
        else
            echo -e "${YELLOW}⚠️  Root SSH login is enabled (consider disabling)${NC}"
        fi
    fi
}

check_project_requirements() {
    echo -e "\n${CYAN}📁 Checking Project Requirements...${NC}"
    
    # Check if we're in the project directory
    if [[ -f "docker-compose.yml" ]]; then
        echo -e "${GREEN}✅ Found docker-compose.yml${NC}"
    else
        echo -e "${YELLOW}⚠️  docker-compose.yml not found in current directory${NC}"
    fi
    
    if [[ -f "package.json" ]] || [[ -d "site" ]]; then
        echo -e "${GREEN}✅ Project structure detected${NC}"
    else
        echo -e "${YELLOW}⚠️  Project structure not detected${NC}"
    fi
    
    # Check for deployment scripts
    SCRIPTS=("deploy-production.sh" "setup-cloud-server.sh" "one-click-deploy.sh")
    for script in "${SCRIPTS[@]}"; do
        if [[ -f "$script" ]]; then
            if [[ -x "$script" ]]; then
                echo -e "${GREEN}✅ $script is present and executable${NC}"
            else
                echo -e "${YELLOW}⚠️  $script is present but not executable${NC}"
            fi
        else
            echo -e "${YELLOW}⚠️  $script not found${NC}"
        fi
    done
}

generate_report() {
    echo -e "\n${BLUE}📊 System Readiness Report${NC}"
    echo -e "${BLUE}===========================${NC}"
    
    if [[ $CHECKS_FAILED -eq 0 ]]; then
        echo -e "${GREEN}🎉 Your system is ready for Innerbright deployment!${NC}"
        echo -e "\n${CYAN}Next steps:${NC}"
        echo -e "1. Run: ${YELLOW}./one-click-deploy.sh${NC} for automated deployment"
        echo -e "2. Or run: ${YELLOW}./deploy-production.sh${NC} for manual deployment"
        echo -e "3. Follow the prompts to configure your domain and SSL"
    else
        echo -e "${RED}❌ Your system has $CHECKS_FAILED issue(s) that need to be addressed${NC}"
        echo -e "\n${CYAN}Recommended actions:${NC}"
        echo -e "1. Review the warnings and errors above"
        echo -e "2. Run: ${YELLOW}./setup-cloud-server.sh${NC} to automatically fix most issues"
        echo -e "3. Re-run this check after making changes"
    fi
    
    echo -e "\n${CYAN}For detailed deployment instructions, see:${NC}"
    echo -e "• ${YELLOW}PRODUCTION_DEPLOYMENT_MANUAL.md${NC}"
    echo -e "• ${YELLOW}DEPLOYMENT_GUIDE.md${NC}"
}

# Main execution
main() {
    CHECKS_FAILED=0
    
    # Run all checks
    check_os || ((CHECKS_FAILED++))
    check_resources || ((CHECKS_FAILED++))
    check_network || ((CHECKS_FAILED++))
    check_permissions || ((CHECKS_FAILED++))
    check_existing_software || ((CHECKS_FAILED++))
    check_security || ((CHECKS_FAILED++))
    check_project_requirements || ((CHECKS_FAILED++))
    
    # Generate final report
    generate_report
    
    # Exit with appropriate code
    if [[ $CHECKS_FAILED -eq 0 ]]; then
        exit 0
    else
        exit 1
    fi
}

# Run main function
main "$@"
