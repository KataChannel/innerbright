#!/bin/bash

# 🚀 KataCore Remote Deployment Helper
# Quick deployment script for remote servers

set -euo pipefail

# Configuration - Dynamic parameters
SERVER_IP=""
DOMAIN=""
SSH_USER="root"
SSH_KEY_PATH=""
DEPLOY_TYPE="full"
FORCE_REGEN=false

# Color codes
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

# Logging functions
log() { echo -e "${GREEN}[$(date +'%H:%M:%S')]${NC} $1"; }
info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
success() { echo -e "${GREEN}✅ $1${NC}"; }
warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
error() { echo -e "${RED}❌ $1${NC}"; exit 1; }

show_banner() {
    echo -e "${BLUE}"
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════════════════════╗
║                        🚀 KataCore Remote Deploy                            ║
║                                                                              ║
║    Deploy to any server with dynamic IP and domain configuration           ║
║    Supports both simple (IP only) and full (domain + SSL) deployments     ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    
    if [[ -n "$SERVER_IP" && -n "$DOMAIN" ]]; then
        echo -e "${CYAN}📋 Deployment Details:${NC}"
        echo -e "   📍 Server IP: $SERVER_IP"
        echo -e "   🌍 Domain: $DOMAIN"
        echo -e "   👤 SSH User: $SSH_USER"
        echo -e "   🔐 SSH Key: ${SSH_KEY_PATH:-'default'}"
        echo -e "   🚀 Deploy Type: $DEPLOY_TYPE"
        echo ""
    fi
}

# Show help
show_help() {
    cat << 'EOF'
🚀 KataCore Remote Deployment Script

USAGE:
    ./deploy-remote.sh [OPTIONS] IP DOMAIN

ARGUMENTS:
    IP                  Server IP address (e.g., 116.118.85.41)
    DOMAIN             Domain name (e.g., innerbright.vn)

OPTIONS:
    --user USER        SSH user (default: root)
    --key PATH         SSH private key path (default: ~/.ssh/id_rsa)
    --simple           Simple deployment (no SSL/domain config)
    --force-regen      Force regenerate environment files
    --help             Show this help

EXAMPLES:
    # Full deployment with domain and SSL
    ./deploy-remote.sh 116.118.85.41 innerbright.vn

    # Simple deployment (IP only, no SSL)
    ./deploy-remote.sh --simple 116.118.85.41 innerbright.vn

    # Custom SSH user and key
    ./deploy-remote.sh --user ubuntu --key ~/.ssh/my-key.pem 116.118.85.41 innerbright.vn

    # With force regeneration
    ./deploy-remote.sh --force-regen 116.118.85.41 innerbright.vn

EOF
}

# Parse arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --user)
                SSH_USER="$2"
                shift 2
                ;;
            --key)
                SSH_KEY_PATH="$2"
                shift 2
                ;;
            --simple)
                DEPLOY_TYPE="simple"
                shift
                ;;
            --force-regen)
                FORCE_REGEN=true
                shift
                ;;
            --help)
                show_help
                exit 0
                ;;
            -*)
                error "Unknown option: $1"
                ;;
            *)
                if [[ -z "$SERVER_IP" ]]; then
                    SERVER_IP="$1"
                elif [[ -z "$DOMAIN" ]]; then
                    DOMAIN="$1"
                else
                    error "Too many arguments"
                fi
                shift
                ;;
        esac
    done
    
    # Validate required arguments
    if [[ -z "$SERVER_IP" ]]; then
        error "Server IP is required. Use --help for usage."
    fi
    
    if [[ "$DEPLOY_TYPE" == "full" && -z "$DOMAIN" ]]; then
        error "Domain is required for full deployment. Use --simple for IP-only deployment."
    fi
    
    # Set default SSH key if not provided
    if [[ -z "$SSH_KEY_PATH" ]]; then
        SSH_KEY_PATH="$HOME/.ssh/id_rsa"
    fi
    
    # For simple deployment, use IP as domain
    if [[ "$DEPLOY_TYPE" == "simple" ]]; then
        DOMAIN="$SERVER_IP"
    fi
}

# Validate inputs
validate_inputs() {
    # Validate IP
    if [[ ! $SERVER_IP =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        error "Invalid IP address: $SERVER_IP"
    fi
    
    # Validate domain (only for full deployment)
    if [[ "$DEPLOY_TYPE" == "full" ]]; then
        if [[ ! $DOMAIN =~ ^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$ ]]; then
            error "Invalid domain: $DOMAIN"
        fi
    fi
}

# Check prerequisites
check_prerequisites() {
    log "🔍 Checking prerequisites..."
    
    # Check if SSH key exists
    if [[ ! -f "$SSH_KEY_PATH" ]]; then
        warning "SSH key not found at $SSH_KEY_PATH"
        echo "Available options:"
        echo "1. Create a new SSH key: ssh-keygen -t rsa -b 4096 -C 'your_email@example.com'"
        echo "2. Use existing key: ./deploy-remote.sh --key /path/to/your/key IP DOMAIN"
        echo "3. Use password authentication (not recommended for production)"
        exit 1
    fi
    
    success "SSH key found at $SSH_KEY_PATH"
}
# Check SSH connection
check_ssh_connection() {
    log "🔗 Testing SSH connection to $SSH_USER@$SERVER_IP..."
    
    local ssh_cmd="ssh -i $SSH_KEY_PATH -o ConnectTimeout=10 -o BatchMode=yes"
    
    if $ssh_cmd "$SSH_USER@$SERVER_IP" "echo 'SSH connection successful'" > /dev/null 2>&1; then
        success "SSH connection successful"
        return 0
    else
        error "Cannot connect to $SSH_USER@$SERVER_IP. Please check your SSH key and server access."
    fi
}

# Prepare remote server
prepare_remote_server() {
    log "🛠️  Preparing remote server..."
    
    ssh -i "$SSH_KEY_PATH" "$SSH_USER@$SERVER_IP" << 'EOF'
        set -e
        
        echo "🔄 Updating system..."
        apt update && apt upgrade -y
        
        echo "🐳 Installing Docker..."
        if ! command -v docker &> /dev/null; then
            curl -fsSL https://get.docker.com -o get-docker.sh
            sh get-docker.sh
            systemctl enable docker
            systemctl start docker
            rm get-docker.sh
        fi
        
        echo "🔧 Installing Docker Compose..."
        if ! command -v docker-compose &> /dev/null; then
            curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
            chmod +x /usr/local/bin/docker-compose
        fi
        
        echo "📦 Installing required packages..."
        apt install -y curl wget git nginx certbot python3-certbot-nginx openssl ufw
        
        echo "🔥 Configuring firewall..."
        ufw --force enable
        ufw allow OpenSSH
        ufw allow 80/tcp
        ufw allow 443/tcp
        ufw allow 3000/tcp
        ufw allow 3001/tcp
        ufw allow 9000/tcp
        ufw allow 9001/tcp
        ufw allow 5050/tcp
        
        echo "📁 Creating deployment directory..."
        mkdir -p /opt/katacore
        
        echo "✅ Remote server preparation completed"
EOF
    
    success "Remote server prepared successfully"
}

# Transfer files to remote server
transfer_files() {
    log "📤 Transferring files to remote server..."
    
    # Create a temporary directory for deployment files
    local temp_dir=$(mktemp -d)
    
    # Copy all necessary files to temp directory
    cp -r . "$temp_dir/"
    
    # Remove any existing .env to force regeneration
    if [[ "$FORCE_REGEN" == "true" ]]; then
        rm -f "$temp_dir/.env"
    fi
    
    # Transfer files to remote server
    scp -i "$SSH_KEY_PATH" -r "$temp_dir"/* "$SSH_USER@$SERVER_IP:/opt/katacore/"
    
    # Cleanup
    rm -rf "$temp_dir"
    
    success "Files transferred successfully"
}

# Execute deployment on remote server
execute_deployment() {
    log "🚀 Executing deployment on remote server..."
    
    local deploy_command
    if [[ "$DEPLOY_TYPE" == "simple" ]]; then
        deploy_command="./deploy-startkitv1-clean.sh deploy-simple $SERVER_IP"
    else
        deploy_command="./deploy-startkitv1-clean.sh deploy-full $DOMAIN"
    fi
    
    if [[ "$FORCE_REGEN" == "true" ]]; then
        deploy_command="$deploy_command --force-regen"
    fi
    
    ssh -i "$SSH_KEY_PATH" "$SSH_USER@$SERVER_IP" << EOF
        set -e
        cd /opt/katacore
        
        # Make scripts executable
        chmod +x *.sh
        
        # Clean up any existing containers
        echo "🧹 Cleaning up existing containers..."
        docker-compose -f docker-compose.startkitv1.yml down --remove-orphans 2>/dev/null || true
        docker system prune -f 2>/dev/null || true
        
        # Execute deployment
        echo "🚀 Starting deployment..."
        $deploy_command
        
        echo "✅ Deployment completed!"
EOF
    
    success "Deployment executed successfully"
}

# Show deployment summary
show_deployment_summary() {
    local protocol="https"
    if [[ "$DEPLOY_TYPE" == "simple" ]]; then
        protocol="http"
    fi
    
    echo ""
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                         🎉 DEPLOYMENT SUCCESSFUL!                           ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    echo -e "${CYAN}🌐 Server Information:${NC}"
    echo -e "   📍 IP Address:    $SERVER_IP"
    echo -e "   🌍 Domain:        $DOMAIN"
    echo -e "   👤 User:          $SSH_USER"
    echo -e "   🔐 SSH Key:       $SSH_KEY_PATH"
    echo ""
    
    echo -e "${CYAN}📊 Services:${NC}"
    if [[ "$DEPLOY_TYPE" == "simple" ]]; then
        echo -e "   🌐 Main Site:     http://$SERVER_IP:3000"
        echo -e "   🚀 API:          http://$SERVER_IP:3001"
        echo -e "   📦 MinIO:        http://$SERVER_IP:9000"
        echo -e "   🗄️  pgAdmin:      http://$SERVER_IP:5050"
    else
        echo -e "   🌐 Main Site:     https://$DOMAIN"
        echo -e "   🚀 API:          https://$DOMAIN/api"
        echo -e "   📦 MinIO:        https://$DOMAIN:9000"
        echo -e "   🗄️  pgAdmin:      https://$DOMAIN:5050"
    fi
    echo ""
    
    echo -e "${CYAN}📋 Next Steps:${NC}"
    echo -e "   1. Check services: ssh -i $SSH_KEY_PATH $SSH_USER@$SERVER_IP 'docker ps'"
    echo -e "   2. View logs: ssh -i $SSH_KEY_PATH $SSH_USER@$SERVER_IP 'cd /opt/katacore && docker-compose logs'"
    echo -e "   3. Access your application and configure as needed"
    echo ""
    
    echo -e "${YELLOW}🔐 Important: Check .env file on server for generated passwords${NC}"
    echo -e "   ssh -i $SSH_KEY_PATH $SSH_USER@$SERVER_IP 'cat /opt/katacore/.env'"
}

# Main deployment function
deploy() {
    show_banner
    validate_inputs
    check_prerequisites
    
    log "🚀 Starting remote deployment..."
    
    # Check SSH connection
    check_ssh_connection
    
    # Prepare remote server
    prepare_remote_server
    
    # Transfer files
    transfer_files
    
    # Execute deployment
    execute_deployment
    
    # Show summary
    show_deployment_summary
    
    success "🎉 Remote deployment completed successfully!"
}

# Test SSH connection function
test_connection() {
    show_banner
    validate_inputs
    
    log "🧪 Testing SSH connection..."
    
    if ssh -i "$SSH_KEY_PATH" -o ConnectTimeout=10 "$SSH_USER@$SERVER_IP" "echo 'SSH connection test successful!'"; then
        success "SSH connection works perfectly!"
    else
        error "SSH connection failed"
    fi
}

# Main function
main() {
    # Parse arguments first
    parse_arguments "$@"
    
    # If no arguments provided, show help
    if [[ -z "$SERVER_IP" ]]; then
        show_help
        exit 0
    fi
    
    # Execute deployment
    deploy
}

# Run main function
main "$@"
