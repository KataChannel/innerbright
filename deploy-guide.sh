#!/bin/bash

# 🚀 KataCore StartKit v2 - Deploy Guide
# Hướng dẫn deploy từng bước để tránh lỗi

set -euo pipefail

readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

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
    echo -e "${RED}❌ $1${NC}"
}

show_banner() {
    echo -e "${BLUE}"
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════════════════════╗
║                     📋 KataCore StartKit v2 - Deploy Guide                  ║
║                                                                              ║
║                     Hướng dẫn deploy từng bước tránh lỗi                    ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# Kiểm tra prerequisites
check_prerequisites() {
    log "🔍 Kiểm tra prerequisites..."
    
    local missing_tools=()
    
    # Kiểm tra Bun
    if ! command -v bun >/dev/null 2>&1; then
        missing_tools+=("bun.js")
        error "Bun.js chưa được cài đặt. Vui lòng cài từ: https://bun.sh"
    else
        success "Bun.js $(bun --version) ✓"
    fi
    
    # Kiểm tra Git
    if ! command -v git >/dev/null 2>&1; then
        missing_tools+=("git")
        error "Git chưa được cài đặt"
    else
        success "Git ✓"
    fi
    
    # Kiểm tra SSH
    if ! command -v ssh >/dev/null 2>&1; then
        missing_tools+=("ssh")
        error "SSH client chưa được cài đặt"
    else
        success "SSH client ✓"
    fi
    
    # Kiểm tra các file script
    local required_scripts=("startkit-deployer.sh" "quick-start-v2.sh" "scripts/ssh-keygen-setup.sh")
    for script in "${required_scripts[@]}"; do
        if [[ ! -f "$script" ]]; then
            error "Script không tồn tại: $script"
            exit 1
        elif [[ ! -x "$script" ]]; then
            warning "Script không executable: $script"
            chmod +x "$script"
            success "Đã fix permission cho: $script"
        else
            success "Script OK: $script ✓"
        fi
    done
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        error "Thiếu tools: ${missing_tools[*]}"
        exit 1
    fi
}

# Kiểm tra project structure
check_project_structure() {
    log "🔍 Kiểm tra cấu trúc project..."
    
    local required_dirs=("api" "site" "scripts" "nginx")
    local required_files=("package.json" "docker-compose.prod.yml" "README.md")
    
    for dir in "${required_dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            error "Thư mục không tồn tại: $dir"
            exit 1
        else
            success "Thư mục OK: $dir ✓"
        fi
    done
    
    for file in "${required_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            error "File không tồn tại: $file"
            exit 1
        else
            success "File OK: $file ✓"
        fi
    done
}

# Install dependencies
install_dependencies() {
    log "📦 Cài đặt dependencies..."
    
    info "Cài đặt root dependencies..."
    bun install
    
    info "Cài đặt API dependencies..."
    cd api && bun install && cd ..
    
    info "Cài đặt Site dependencies..."
    cd site && bun install && cd ..
    
    success "Dependencies đã được cài đặt!"
}

# Hướng dẫn chuẩn bị server
show_server_requirements() {
    echo ""
    info "📋 YÊU CẦU SERVER:"
    echo "   • Ubuntu 20.04+ / Debian 11+ / CentOS 8+"
    echo "   • RAM: Tối thiểu 2GB (khuyến nghị 4GB+)"
    echo "   • Disk: Tối thiểu 20GB trống"
    echo "   • CPU: Tối thiểu 1 core (khuyến nghị 2+ cores)"
    echo "   • Network: Port 22 (SSH), 80 (HTTP), 443 (HTTPS) mở"
    echo "   • Root access hoặc sudo user"
    echo ""
    
    info "🔐 CHUẨN BỊ THÔNG TIN:"
    echo "   • IP address của server"
    echo "   • SSH username (root hoặc ubuntu)"
    echo "   • SSH password hoặc private key"
    echo "   • Domain name (nếu muốn SSL)"
    echo ""
}

# Hướng dẫn deploy
show_deploy_options() {
    echo ""
    info "🚀 TÙY CHỌN DEPLOY:"
    echo ""
    echo "1️⃣  DEPLOY VỚI IP (HTTP) - Dành cho test/development"
    echo "   ./startkit-deployer.sh --host YOUR_SERVER_IP"
    echo ""
    echo "2️⃣  DEPLOY VỚI DOMAIN + SSL (HTTPS) - Dành cho production"
    echo "   ./startkit-deployer.sh --host YOUR_SERVER_IP --domain yourdomain.com"
    echo ""
    echo "3️⃣  DEPLOY INTERACTIVE - Wizard hướng dẫn từng bước"
    echo "   ./quick-start-v2.sh"
    echo ""
    echo "4️⃣  CẬP NHẬT DEPLOYMENT HIỆN TẠI"
    echo "   ./startkit-deployer.sh --host YOUR_SERVER_IP --update"
    echo ""
    echo "5️⃣  DEPLOY LẠI HOÀN TOÀN (XÓA DATA CŨ)"
    echo "   ./startkit-deployer.sh --host YOUR_SERVER_IP --clean"
    echo ""
}

# Hướng dẫn SSH setup
show_ssh_setup() {
    echo ""
    info "🔑 THIẾT LẬP SSH KEY (Tùy chọn nhưng khuyến nghị):"
    echo ""
    echo "• Tạo SSH key cho root user:"
    echo "  ./scripts/ssh-keygen-setup.sh --host YOUR_SERVER_IP --user root"
    echo ""
    echo "• Tạo SSH key cho ubuntu user:"
    echo "  ./scripts/ssh-keygen-setup.sh --host YOUR_SERVER_IP --user ubuntu"
    echo ""
    echo "• Tạo SSH key với port custom:"
    echo "  ./scripts/ssh-keygen-setup.sh --host YOUR_SERVER_IP --user ubuntu --port 2222"
    echo ""
    echo "• Xem tất cả options:"
    echo "  ./scripts/ssh-keygen-setup.sh --help"
    echo ""
}

# Troubleshooting
show_troubleshooting() {
    echo ""
    warning "🔧 XỬ LÝ LỖI THƯỜNG GẶP:"
    echo ""
    echo "❌ SSH Connection refused:"
    echo "   • Kiểm tra IP address đúng chưa"
    echo "   • Kiểm tra port SSH (thường là 22)"
    echo "   • Kiểm tra firewall server có mở port SSH"
    echo ""
    echo "❌ Permission denied:"
    echo "   • Kiểm tra username (root/ubuntu)"
    echo "   • Kiểm tra password hoặc SSH key"
    echo "   • Thử tạo SSH key mới"
    echo ""
    echo "❌ Docker installation failed:"
    echo "   • Server có internet connection không"
    echo "   • User có sudo permission không"
    echo "   • Thử chạy lại với --verbose để xem log chi tiết"
    echo ""
    echo "❌ SSL certificate failed:"
    echo "   • Domain đã point về IP server chưa"
    echo "   • DNS propagation có hoàn thành chưa (check: dig yourdomain.com)"
    echo "   • Port 80 và 443 có mở không"
    echo ""
    echo "❌ Application không start:"
    echo "   • Kiểm tra RAM server đủ không (tối thiểu 2GB)"
    echo "   • Kiểm tra disk space đủ không"
    echo "   • Xem log: docker-compose logs -f"
    echo ""
}

# Interactive deployment
interactive_deploy() {
    echo ""
    log "🚀 Bắt đầu deploy interactive..."
    
    # Thu thập thông tin
    read -p "Nhập IP address server: " server_ip
    if [[ -z "$server_ip" ]]; then
        error "IP address là bắt buộc!"
        exit 1
    fi
    
    read -p "Nhập username SSH (root/ubuntu) [root]: " ssh_user
    ssh_user=${ssh_user:-root}
    
    read -p "Nhập port SSH [22]: " ssh_port
    ssh_port=${ssh_port:-22}
    
    read -p "Có muốn setup SSL với domain không? (y/N): " setup_ssl
    
    domain=""
    if [[ "$setup_ssl" =~ ^[Yy]$ ]]; then
        read -p "Nhập domain name: " domain
        if [[ -z "$domain" ]]; then
            warning "Không có domain, sẽ deploy với HTTP"
        fi
    fi
    
    # Xác nhận thông tin
    echo ""
    info "📋 XÁC NHẬN THÔNG TIN DEPLOY:"
    echo "   🖥️  Server: $ssh_user@$server_ip:$ssh_port"
    if [[ -n "$domain" ]]; then
        echo "   🌐 Domain: $domain (HTTPS)"
    else
        echo "   🌐 Protocol: HTTP (chỉ IP)"
    fi
    echo ""
    
    read -p "Xác nhận deploy với thông tin trên? (y/N): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        warning "Deploy bị hủy bởi user"
        exit 0
    fi
    
    # Thực hiện deploy
    echo ""
    log "🚀 Bắt đầu deploy..."
    
    if [[ -n "$domain" ]]; then
        info "Deploying với SSL..."
        ./startkit-deployer.sh --host "$server_ip" --user "$ssh_user" --port "$ssh_port" --domain "$domain" --verbose
    else
        info "Deploying với HTTP..."
        ./startkit-deployer.sh --host "$server_ip" --user "$ssh_user" --port "$ssh_port" --verbose
    fi
}

# Quick commands
show_quick_commands() {
    echo ""
    info "⚡ QUICK COMMANDS:"
    echo ""
    echo "🔥 Deploy nhanh với IP:"
    echo "   ./startkit-deployer.sh --host IP_ADDRESS"
    echo ""
    echo "🔒 Deploy nhanh với SSL:"
    echo "   ./startkit-deployer.sh --host IP_ADDRESS --domain YOUR_DOMAIN"
    echo ""
    echo "⬆️ Update deployment:"
    echo "   ./startkit-deployer.sh --host IP_ADDRESS --update"
    echo ""
    echo "🧹 Clean deploy:"
    echo "   ./startkit-deployer.sh --host IP_ADDRESS --clean"
    echo ""
    echo "🎯 Interactive wizard:"
    echo "   ./quick-start-v2.sh"
    echo ""
    echo "🔑 Setup SSH key:"
    echo "   ./scripts/ssh-keygen-setup.sh --host IP_ADDRESS"
    echo ""
}

# Main menu
main() {
    show_banner
    
    echo ""
    info "Chọn hành động:"
    echo "1. 🔍 Kiểm tra prerequisites và project"
    echo "2. 📦 Cài đặt dependencies"
    echo "3. 📋 Xem yêu cầu server và hướng dẫn"
    echo "4. 🚀 Deploy interactive (khuyến nghị)"
    echo "5. ⚡ Xem quick commands"
    echo "6. 🔧 Xem troubleshooting"
    echo "7. ❌ Thoát"
    echo ""
    
    read -p "Chọn option (1-7): " choice
    
    case $choice in
        1)
            check_prerequisites
            check_project_structure
            success "✅ Project sẵn sàng deploy!"
            ;;
        2)
            install_dependencies
            ;;
        3)
            show_server_requirements
            show_deploy_options
            show_ssh_setup
            ;;
        4)
            check_prerequisites
            interactive_deploy
            ;;
        5)
            show_quick_commands
            ;;
        6)
            show_troubleshooting
            ;;
        7)
            info "Thoát chương trình"
            exit 0
            ;;
        *)
            error "Option không hợp lệ"
            exit 1
            ;;
    esac
}

main "$@"
