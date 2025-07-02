#!/bin/bash

# Quick SSH Key Setup for KataCore
# Simplified wrapper for easy SSH key generation and deployment

set -euo pipefail

# Colors
readonly GREEN='\033[0;32m'
readonly CYAN='\033[0;36m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m'

show_banner() {
    echo -e "${CYAN}"
    cat << 'EOF'
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║    🔐 KataCore SSH Key Quick Setup                       ║
║                                                           ║
║    Generate and deploy SSH keys for cloud servers        ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

show_help() {
    echo "Quick SSH Key Setup for KataCore"
    echo ""
    echo "Usage:"
    echo "  $0                           # Interactive setup"
    echo "  $0 <server-ip>               # Quick setup with IP"
    echo "  $0 <server-ip> <username>    # Setup with custom user"
    echo ""
    echo "Examples:"
    echo "  $0 192.168.1.100"
    echo "  $0 myserver.com ubuntu"
    echo "  $0 droplet.digitalocean.com root"
    echo ""
}

interactive_setup() {
    echo -e "${CYAN}🔍 Interactive SSH Key Setup${NC}"
    echo ""
    
    # Get server details
    read -p "Enter server IP or domain: " server_host
    
    echo ""
    echo "Common users by cloud provider:"
    echo "  • AWS EC2 (Ubuntu): ubuntu"
    echo "  • AWS EC2 (Amazon Linux): ec2-user"
    echo "  • DigitalOcean: root"
    echo "  • Google Cloud: gce-user"
    echo "  • Azure: azureuser"
    echo "  • Generic VPS: root"
    echo ""
    
    read -p "Enter SSH username [root]: " server_user
    server_user=${server_user:-root}
    
    read -p "Enter SSH port [22]: " server_port
    server_port=${server_port:-22}
    
    echo ""
    echo "Key types:"
    echo "  • ed25519 (recommended - modern, secure, fast)"
    echo "  • rsa (traditional - widely supported)"
    echo ""
    
    read -p "Choose key type [ed25519]: " key_type
    key_type=${key_type:-ed25519}
    
    read -p "Enter key name [katacore-deploy]: " key_name
    key_name=${key_name:-katacore-deploy}
    
    echo ""
    echo -e "${YELLOW}📋 Configuration Summary:${NC}"
    echo "  Server: $server_host:$server_port"
    echo "  User: $server_user"
    echo "  Key Type: $key_type"
    echo "  Key Name: $key_name"
    echo ""
    
    read -p "Continue with setup? [Y/n]: " confirm
    confirm=${confirm:-Y}
    
    if [[ "$confirm" =~ ^[Yy] ]]; then
        setup_ssh_key "$server_host" "$server_user" "$server_port" "$key_type" "$key_name"
    else
        echo "Setup cancelled."
        exit 0
    fi
}

setup_ssh_key() {
    local host="$1"
    local user="$2"
    local port="$3"
    local type="$4"
    local name="$5"
    
    local script_path="$(dirname "$0")/ssh-keygen-setup.sh"
    
    if [[ ! -f "$script_path" ]]; then
        echo "❌ SSH setup script not found: $script_path"
        exit 1
    fi
    
    echo -e "${CYAN}🚀 Setting up SSH key...${NC}"
    
    bash "$script_path" \
        --setup \
        --host "$host" \
        --user "$user" \
        --port "$port" \
        --key-type "$type" \
        --key-name "$name"
}

main() {
    show_banner
    
    case ${#} in
        0)
            interactive_setup
            ;;
        1)
            if [[ "$1" == "--help" || "$1" == "-h" ]]; then
                show_help
                exit 0
            fi
            setup_ssh_key "$1" "root" "22" "ed25519" "katacore-deploy"
            ;;
        2)
            setup_ssh_key "$1" "$2" "22" "ed25519" "katacore-deploy"
            ;;
        *)
            echo "❌ Too many arguments. Use --help for usage information."
            exit 1
            ;;
    esac
    
    echo ""
    echo -e "${GREEN}✅ SSH key setup completed!${NC}"
    echo ""
    echo -e "${CYAN}🚀 Next steps:${NC}"
    echo "  1. Test connection: ssh $1"
    echo "  2. Deploy KataCore: ./startkit-deployer.sh --host $1"
    echo ""
}

main "$@"
