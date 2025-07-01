# 🚀 KataCore Deployment System

Hệ thống deploy hoàn toàn tự động với hỗ trợ xử lý lỗi thông minh cho KataCore.

## ✨ Tính Năng

- 🎯 **Deploy Tự Động**: Tự động detect và deploy lên bất kỳ server nào
- 🔧 **Retry Logic**: Tự động retry khi gặp lỗi với exponential backoff  
- 🛠️ **Troubleshooting**: Chẩn đoán và fix lỗi tự động
- 📊 **Monitoring**: Theo dõi status và logs realtime
- 🔐 **Security**: Tự động generate secure passwords và SSL certificates
- ⚡ **Optimization**: Intelligent change detection và incremental deployment

## 🎯 Cách Sử Dụng Nhanh

### 1. Chạy Deploy Manager (Khuyến nghị)
```bash
./deploy-manager.sh
```

### 2. Deploy Trực Tiếp
```bash
# Deploy đơn giản
./universal-deployer.sh --host YOUR_SERVER_IP

# Deploy với options
./universal-deployer.sh --host YOUR_SERVER_IP --user ubuntu --domain yourdomain.com --clean
```

### 3. Quản Lý Server
```bash
# Thêm server mới
./deploy-helper.sh add

# Deploy đến server đã lưu
./deploy-helper.sh deploy production

# Xem status
./deploy-helper.sh status production

# Xem logs
./deploy-helper.sh logs production
```

### 4. Troubleshooting
```bash
# Kiểm tra môi trường local
./troubleshoot.sh check-local

# Test SSH connection
./troubleshoot.sh ssh-test YOUR_SERVER_IP

# Kiểm tra server requirements
./troubleshoot.sh check-server YOUR_SERVER_IP

# Fix lỗi thường gặp
./troubleshoot.sh fix-issues YOUR_SERVER_IP
```

## 📋 Yêu Cầu Hệ Thống

### Local Machine
- Bash shell
- SSH client
- rsync, curl, openssl
- Git (optional)

### Server
- Ubuntu/Debian/CentOS
- Minimum 2GB RAM, 20GB disk
- SSH access (port 22)
- Internet connection

## 🔧 Cấu Hình

### 1. Chuẩn Bị SSH Key
```bash
# Tạo SSH key
ssh-keygen -t rsa -b 4096 -C "katacore-deploy"

# Copy key lên server
ssh-copy-id user@your-server-ip
```

### 2. Cấu Hình Environment
```bash
# Tạo environment template
./universal-deployer.sh --create-env-template --domain yourdomain.com

# Edit file .env.prod.example theo nhu cầu
nano .env.prod.example
```

### 3. Cấu Hình Domain (Optional)
```bash
# Deploy với domain
./universal-deployer.sh --host YOUR_SERVER_IP --domain yourdomain.com
```

## 🚀 Các Chế Độ Deploy

### 1. Quick Deploy (Mặc Định)
```bash
./universal-deployer.sh --host YOUR_SERVER_IP
```

### 2. Clean Deploy
```bash
./universal-deployer.sh --host YOUR_SERVER_IP --clean
```

### 3. Force Rebuild
```bash
./universal-deployer.sh --host YOUR_SERVER_IP --force-rebuild
```

### 4. Setup Only
```bash
./universal-deployer.sh --host YOUR_SERVER_IP --setup-only
```

### 5. Deploy Only
```bash
./universal-deployer.sh --host YOUR_SERVER_IP --deploy-only
```

## 📊 Monitoring

### Xem Status
```bash
# Toàn bộ system
./deploy-helper.sh status server-name

# Specific service
./troubleshoot.sh logs server-name api
```

### Xem Logs
```bash
# Realtime logs
./deploy-helper.sh logs server-name

# Specific service
./troubleshoot.sh logs server-name postgres
```

### Deployment History
```bash
# Xem lịch sử deploy
ssh user@server "cd /opt/katacore && cat .deploy-cache/deployment-history.log"
```

## 🛠️ Troubleshooting

### Lỗi SSH Connection
```bash
# Diagnose SSH
./troubleshoot.sh ssh-test YOUR_SERVER_IP

# Check server requirements  
./troubleshoot.sh check-server YOUR_SERVER_IP
```

### Lỗi Docker
```bash
# Fix Docker permissions
./troubleshoot.sh fix-issues YOUR_SERVER_IP
```

### Lỗi Disk Space
```bash
# Clean up
./troubleshoot.sh clean YOUR_SERVER_IP
```

### Lỗi Firewall
```bash
# Fix firewall rules
./troubleshoot.sh fix-issues YOUR_SERVER_IP
```

## 🔐 Security Features

- Tự động generate secure passwords
- SSL certificates (self-signed hoặc Let's Encrypt)
- Firewall configuration
- Fail2ban protection (optional)

## ⚡ Optimization Features

- Intelligent change detection
- Incremental deployment
- Docker layer caching
- Deployment history tracking
- Hot reload support

## 📁 File Structure

```
KataCore/
├── deploy-manager.sh          # Main deployment manager
├── universal-deployer.sh      # Core deployment script
├── deploy-helper.sh          # Server management helper
├── troubleshoot.sh           # Troubleshooting utilities
├── .deploy-servers          # Saved server configurations
├── .deploy-cache/           # Deployment cache
│   ├── deployment-history.log
│   ├── deploy-info.json
│   └── file-checksums
└── .deploy-logs/           # Deployment logs
    └── deploy_*.log
```

## 🆘 Hỗ Trợ

### Quick Commands
```bash
# Interactive menu
./deploy-manager.sh

# Help
./universal-deployer.sh --help
./deploy-helper.sh help
./troubleshoot.sh help
```

### Common Issues

1. **SSH Connection Failed**
   - Check SSH key: `ssh-copy-id user@server`
   - Check firewall: port 22 open
   - Test connection: `./troubleshoot.sh ssh-test IP`

2. **Docker Permission Denied**
   - Run: `./troubleshoot.sh fix-issues IP`
   - Or manually: `sudo usermod -aG docker $USER`

3. **Deployment Failed**
   - Check logs: `./deploy-helper.sh logs server-name`
   - Clean deploy: `./universal-deployer.sh --host IP --clean`

4. **Out of Disk Space**
   - Clean system: `./troubleshoot.sh clean IP`
   - Check space: `df -h`

### Contact
- GitHub Issues: [KataCore Repository]
- Email: support@katacore.com

## 📄 License

MIT License - see LICENSE file for details.

---

**Happy Deploying! 🚀**
