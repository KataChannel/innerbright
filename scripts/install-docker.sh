#!/bin/bash

# KataCore Docker Auto-Installation Script
# This script automatically installs Docker and Docker Compose on various Linux distributions

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging functions
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
    exit 1
}

# Detect OS
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$NAME
        VER=$VERSION_ID
    elif type lsb_release >/dev/null 2>&1; then
        OS=$(lsb_release -si)
        VER=$(lsb_release -sr)
    elif [ -f /etc/lsb-release ]; then
        . /etc/lsb-release
        OS=$DISTRIB_ID
        VER=$DISTRIB_RELEASE
    elif [ -f /etc/debian_version ]; then
        OS=Debian
        VER=$(cat /etc/debian_version)
    elif [ -f /etc/SuSe-release ]; then
        OS=openSUSE
    elif [ -f /etc/redhat-release ]; then
        OS=RedHat
    else
        OS=$(uname -s)
        VER=$(uname -r)
    fi
    
    log "Detected OS: $OS $VER"
}

# Check if running as root or with sudo
check_privileges() {
    if [ "$EUID" -ne 0 ]; then
        if ! command -v sudo &> /dev/null; then
            error "This script requires root privileges or sudo. Please run as root or install sudo."
        fi
        SUDO="sudo"
        log "Running with sudo privileges"
    else
        SUDO=""
        log "Running as root"
    fi
}

# Install Docker on Ubuntu/Debian
install_docker_ubuntu_debian() {
    log "Installing Docker on Ubuntu/Debian..."
    
    # Update package index
    $SUDO apt-get update
    
    # Install packages to allow apt to use a repository over HTTPS
    $SUDO apt-get install -y \
        ca-certificates \
        curl \
        gnupg \
        lsb-release
    
    # Add Docker's official GPG key
    $SUDO mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | $SUDO gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    
    # Set up the repository
    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) stable" | $SUDO tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Update package index again
    $SUDO apt-get update
    
    # Install Docker Engine
    $SUDO apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    
    success "Docker installed successfully on Ubuntu/Debian"
}

# Install Docker on CentOS/RHEL/Fedora
install_docker_centos_rhel() {
    log "Installing Docker on CentOS/RHEL/Fedora..."
    
    # Install required packages
    $SUDO yum install -y yum-utils
    
    # Add Docker repository
    $SUDO yum-config-manager \
        --add-repo \
        https://download.docker.com/linux/centos/docker-ce.repo
    
    # Install Docker Engine
    $SUDO yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    
    success "Docker installed successfully on CentOS/RHEL/Fedora"
}

# Install Docker on Amazon Linux
install_docker_amazon_linux() {
    log "Installing Docker on Amazon Linux..."
    
    # Update packages
    $SUDO yum update -y
    
    # Install Docker
    $SUDO yum install -y docker
    
    # Install Docker Compose
    $SUDO curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    $SUDO chmod +x /usr/local/bin/docker-compose
    
    success "Docker installed successfully on Amazon Linux"
}

# Install Docker on macOS (using Docker Desktop)
install_docker_macos() {
    log "macOS detected. Please install Docker Desktop manually:"
    echo "1. Download Docker Desktop from: https://www.docker.com/products/docker-desktop"
    echo "2. Run the installer"
    echo "3. Start Docker Desktop"
    echo "4. Verify installation with: docker --version"
    
    warning "Manual installation required for macOS"
    exit 1
}

# Generic Docker installation using convenience script
install_docker_generic() {
    log "Installing Docker using convenience script..."
    
    # Download and run Docker's convenience script
    curl -fsSL https://get.docker.com -o get-docker.sh
    $SUDO sh get-docker.sh
    rm get-docker.sh
    
    # Install Docker Compose
    $SUDO curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    $SUDO chmod +x /usr/local/bin/docker-compose
    
    success "Docker installed successfully using generic method"
}

# Start and enable Docker service
start_docker_service() {
    log "Starting Docker service..."
    
    # Start Docker service
    if command -v systemctl &> /dev/null; then
        $SUDO systemctl start docker
        $SUDO systemctl enable docker
        success "Docker service started and enabled"
    elif command -v service &> /dev/null; then
        $SUDO service docker start
        success "Docker service started"
    else
        warning "Could not start Docker service automatically. Please start it manually."
    fi
}

# Add current user to docker group
add_user_to_docker_group() {
    if [ "$SUDO" = "sudo" ]; then
        local current_user=$(whoami)
        log "Adding user $current_user to docker group..."
        $SUDO usermod -aG docker "$current_user"
        success "User $current_user added to docker group"
        warning "Please log out and log back in to use Docker without sudo"
    fi
}

# Verify Docker installation
verify_docker_installation() {
    log "Verifying Docker installation..."
    
    # Check Docker version
    if command -v docker &> /dev/null; then
        docker_version=$(docker --version)
        success "Docker installed: $docker_version"
    else
        error "Docker installation failed - docker command not found"
    fi
    
    # Check Docker Compose version
    if command -v docker-compose &> /dev/null; then
        compose_version=$(docker-compose --version)
        success "Docker Compose installed: $compose_version"
    elif docker compose version &> /dev/null; then
        compose_version=$(docker compose version)
        success "Docker Compose (plugin) installed: $compose_version"
    else
        error "Docker Compose installation failed"
    fi
    
    # Test Docker functionality (if not running as root)
    if [ "$SUDO" != "" ]; then
        log "Testing Docker functionality..."
        if $SUDO docker run --rm hello-world &> /dev/null; then
            success "Docker is working correctly"
        else
            warning "Docker installed but test failed. You may need to restart your session."
        fi
    fi
}

# Main installation function
install_docker() {
    log "🐳 Starting Docker auto-installation..."
    
    # Check if Docker is already installed
    if command -v docker &> /dev/null && (command -v docker-compose &> /dev/null || docker compose version &> /dev/null 2>&1); then
        success "Docker and Docker Compose are already installed"
        docker --version
        if command -v docker-compose &> /dev/null; then
            docker-compose --version
        else
            docker compose version
        fi
        return 0
    fi
    
    # Detect OS and check privileges
    detect_os
    check_privileges
    
    # Install based on OS
    case "$OS" in
        "Ubuntu"*|"Debian"*)
            install_docker_ubuntu_debian
            ;;
        "CentOS"*|"Red Hat"*|"Fedora"*)
            install_docker_centos_rhel
            ;;
        "Amazon Linux"*)
            install_docker_amazon_linux
            ;;
        "Darwin"*)
            install_docker_macos
            ;;
        *)
            log "OS not specifically supported, trying generic installation..."
            install_docker_generic
            ;;
    esac
    
    # Start Docker service
    start_docker_service
    
    # Add user to docker group
    add_user_to_docker_group
    
    # Verify installation
    verify_docker_installation
    
    success "🎉 Docker installation completed successfully!"
    
    if [ "$SUDO" = "sudo" ]; then
        echo ""
        warning "IMPORTANT: Please log out and log back in (or restart your terminal)"
        warning "to use Docker without sudo, then re-run your deployment command."
        echo ""
    fi
}

# Handle command line arguments
case "${1:-install}" in
    "install"|"--install")
        install_docker
        ;;
    "check"|"--check")
        if command -v docker &> /dev/null && (command -v docker-compose &> /dev/null || docker compose version &> /dev/null 2>&1); then
            success "Docker and Docker Compose are installed"
            exit 0
        else
            error "Docker or Docker Compose not found"
        fi
        ;;
    "verify"|"--verify")
        verify_docker_installation
        ;;
    "help"|"--help"|"-h")
        echo "Docker Auto-Installation Script"
        echo ""
        echo "Usage: $0 [OPTION]"
        echo ""
        echo "Options:"
        echo "  install, --install    Install Docker and Docker Compose (default)"
        echo "  check, --check        Check if Docker is installed"
        echo "  verify, --verify      Verify Docker installation"
        echo "  help, --help          Show this help message"
        ;;
    *)
        error "Unknown option: $1. Use --help for usage information."
        ;;
esac
