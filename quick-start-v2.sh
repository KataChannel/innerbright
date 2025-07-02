#!/bin/bash

# KataCore StartKit v2 - Quick Start
# Guided setup cho deployment nhanh

set -euo pipefail

readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m'

show_banner() {
    echo -e "${BLUE}"
    cat << 'BANNER'
╔══════════════════════════════════════════════════════════════════════════════╗
║                     🚀 KataCore StartKit v2 Quick Start                     ║
║                                                                              ║
║                     Auto-deployment với SSL và Environment                  ║
╚══════════════════════════════════════════════════════════════════════════════╝
BANNER
    echo -e "${NC}"
}

main() {
    show_banner
    
    echo -e "${GREEN}Chọn option deployment:${NC}"
    echo "1. 🚀 Deploy lần đầu (chỉ IP server)"
    echo "2. 🔒 Deploy với SSL (IP + domain)"  
    echo "3. ⬆️ Cập nhật deployment hiện tại"
    echo "4. 🧹 Clean deployment (xóa data cũ)"
    echo ""
    
    read -p "Chọn option (1-4): " choice
    
    case $choice in
        1)
            read -p "Nhập IP server: " server_ip
            echo "🚀 Deploying với IP: $server_ip"
            ./startkit-deployer.sh --host "$server_ip"
            ;;
        2)
            read -p "Nhập IP server: " server_ip
            read -p "Nhập domain: " domain
            echo "🔒 Deploying với SSL: $server_ip -> $domain"
            ./startkit-deployer.sh --host "$server_ip" --domain "$domain"
            ;;
        3)
            read -p "Nhập IP server: " server_ip
            echo "⬆️ Updating deployment: $server_ip"
            ./startkit-deployer.sh --host "$server_ip" --update
            ;;
        4)
            read -p "Nhập IP server: " server_ip
            echo "🧹 Clean deployment: $server_ip"
            ./startkit-deployer.sh --host "$server_ip" --clean
            ;;
        *)
            echo "❌ Option không hợp lệ"
            exit 1
            ;;
    esac
}

main "$@"
