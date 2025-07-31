#!/bin/bash

# Script cải tiến để deploy nginx config cho Innerbright
# Với xử lý lỗi và logging tốt hơn

set -e  # Exit on any error

SERVER_IP="116.118.49.243"
SERVER_USER="root"
CONFIG_FILE="app.innerbright.vn"
LOG_FILE="nginx-deploy.log"

# Function để log
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Function để kiểm tra file
check_config_file() {
    if [ ! -f "./$CONFIG_FILE" ]; then
        log "❌ Lỗi: File $CONFIG_FILE không tồn tại!"
        exit 1
    fi
    log "✅ File cấu hình $CONFIG_FILE đã sẵn sàng"
}

# Function để kiểm tra kết nối SSH
check_ssh_connection() {
    log "🔍 Kiểm tra kết nối SSH tới $SERVER_USER@$SERVER_IP..."
    
    if timeout 10s ssh -o ConnectTimeout=5 -o BatchMode=yes "$SERVER_USER@$SERVER_IP" 'echo "SSH OK"' &>/dev/null; then
        log "✅ Kết nối SSH thành công"
        return 0
    else
        log "❌ Không thể kết nối SSH. Vui lòng kiểm tra:"
        log "   - SSH key hoặc password"
        log "   - Địa chỉ IP: $SERVER_IP"
        log "   - Firewall settings"
        return 1
    fi
}

# Function để copy file
copy_config() {
    log "📋 Đang copy file cấu hình..."
    
    if scp -o ConnectTimeout=10 "./$CONFIG_FILE" "$SERVER_USER@$SERVER_IP:/tmp/"; then
        log "✅ Copy file thành công"
        return 0
    else
        log "❌ Lỗi copy file"
        return 1
    fi
}

# Function để cài đặt nginx
install_nginx() {
    log "🔧 Cài đặt và cấu hình nginx..."
    
    ssh "$SERVER_USER@$SERVER_IP" << 'REMOTE_SCRIPT'
set -e

# Update package list
apt update

# Install nginx if not exists
if ! command -v nginx &> /dev/null; then
    echo "Installing nginx..."
    apt install -y nginx
    systemctl enable nginx
else
    echo "Nginx already installed"
fi

# Create directories if not exist
mkdir -p /etc/nginx/sites-available /etc/nginx/sites-enabled

# Check if config file already exists
if [ -f "/etc/nginx/sites-available/app.innerbright.vn" ]; then
    echo "⚠️  File cấu hình đã tồn tại tại /etc/nginx/sites-available/app.innerbright.vn"
    echo "✅ Bỏ qua việc ghi đè file và tiếp tục..."
else
    # Move config file if not exists
    if [ -f "/tmp/app.innerbright.vn" ]; then
        mv /tmp/app.innerbright.vn /etc/nginx/sites-available/
        echo "Config file moved successfully"
    else
        echo "Error: Config file not found in /tmp/"
        exit 1
    fi
fi

# Create symbolic link
ln -sf /etc/nginx/sites-available/app.innerbright.vn /etc/nginx/sites-enabled/

# Remove default site
rm -f /etc/nginx/sites-enabled/default

# Test nginx config
if nginx -t; then
    echo "Nginx config is valid"
else
    echo "Nginx config is invalid!"
    exit 1
fi

# Restart nginx
systemctl restart nginx
systemctl status nginx --no-pager

echo "Nginx configuration completed successfully"
REMOTE_SCRIPT

    if [ $? -eq 0 ]; then
        log "✅ Nginx cài đặt và cấu hình thành công"
        return 0
    else
        log "❌ Lỗi cài đặt nginx"
        return 1
    fi
}

# Function để cài đặt SSL
install_ssl() {
    log "🔒 Cài đặt SSL certificate..."
    
    ssh "$SERVER_USER@$SERVER_IP" << 'SSL_SCRIPT'
# Install certbot if not exists
if ! command -v certbot &> /dev/null; then
    echo "Installing certbot..."
    apt install -y certbot python3-certbot-nginx
else
    echo "Certbot already installed"
fi

# Install SSL certificate
echo "Installing SSL certificate for app.innerbright.vn..."
certbot --nginx -d app.innerbright.vn --non-interactive --agree-tos --email it@innerbright.vn

# Test auto-renewal
certbot renew --dry-run

echo "SSL certificate installed successfully"
SSL_SCRIPT

    if [ $? -eq 0 ]; then
        log "✅ SSL certificate cài đặt thành công"
        return 0
    else
        log "❌ Lỗi cài đặt SSL certificate"
        return 1
    fi
}

# Main execution
main() {
    log "🚀 Bắt đầu deploy nginx cho Innerbright"
    
    # Check config file
    check_config_file
    
    # Check SSH connection
    if ! check_ssh_connection; then
        log "❌ Deploy thất bại do không thể kết nối SSH"
        exit 1
    fi
    
    # Copy configuration
    if ! copy_config; then
        log "❌ Deploy thất bại do lỗi copy file"
        exit 1
    fi
    
    # Install and configure nginx
    if ! install_nginx; then
        log "❌ Deploy thất bại do lỗi cài đặt nginx"
        exit 1
    fi
    
    # Install SSL (optional)
    read -p "Bạn có muốn cài đặt SSL certificate? (y/n): " -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        install_ssl
    fi
    
    log "🎉 Deploy hoàn tất thành công!"
    log "🌐 Website: https://app.innerbright.vn"
    log "📋 Log file: $LOG_FILE"
}

# Trap để cleanup khi script bị interrupt
trap 'log "❌ Script bị interrupt"; exit 1' INT TERM

# Run main function
main "$@"
