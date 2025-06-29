# 🌟 Innerbright - Training & Coaching Platform

InnerBright Training & Coaching tự hào là thành viên chính thức và uy tín của Hiệp hội NLP Hoa Kỳ (ABNLP) trong suốt 5 năm liên tiếp.

## 🏗️ Kiến Trúc Hệ Thống

- **Frontend**: Next.js 14 + TypeScript + Tailwind CSS
- **Backend**: NestJS + TypeScript + REST API
- **Database**: PostgreSQL 15
- **Storage**: MinIO Object Storage
- **Cache**: Redis
- **Proxy**: Nginx với SSL/TLS
- **Containerization**: Docker + Docker Compose

## 🚀 Triển Khai Nhanh

### Development
```bash
# Start development environment
./docker-dev.sh
```

### Production
```bash
# 1. Kiểm tra hệ thống
./pre-deployment-check.sh

# 2. Triển khai tự động (khuyến nghị)
./one-click-deploy.sh

# 3. Quản lý production
./manage-production.sh
```

## 📚 Tài Liệu Triển Khai

- **[📖 Hướng Dẫn Triển Khai Hoàn Chỉnh](./README_DEPLOYMENT.md)** - Tổng quan tất cả các options
- **[📘 Production Deployment Manual](./PRODUCTION_DEPLOYMENT_MANUAL.md)** - Chi tiết từng bước 
- **[📙 Deployment Guide](./DEPLOYMENT_GUIDE.md)** - Hướng dẫn kỹ thuật
- **[🐳 Docker Documentation](./DOCKER.md)** - Tài liệu Docker

## 🛠️ Scripts Có Sẵn

| Script | Mô Tả | Sử Dụng |
|--------|-------|---------|
| `pre-deployment-check.sh` | Kiểm tra hệ thống | Trước triển khai |
| `one-click-deploy.sh` | Triển khai tự động | Production setup |
| `manage-production.sh` | Quản lý production | Sau triển khai |
| `setup-cloud-server.sh` | Setup server mới | Server preparation |
| `deploy-production.sh` | Triển khai thủ công | Manual deployment |
| `docker-dev.sh` | Development env | Development |
| `docker-build.sh` | Build local | Testing |
| **`quick-deploy.sh`** | **Deploy nhanh** | **One-line deploy** |
| **`git-deploy.sh`** | **Git operations** | **Auto git push** |
| **`server-connect.sh`** | **Connect server** | **Auto SSH login** |
| **`full-deploy.sh`** | **Full pipeline** | **Complete workflow** |

## 🚀 Quick Deploy Commands

### Simplest Deploy (Khuyến nghị)
```bash
# Deploy với message tự động
./quick-deploy.sh

# Deploy với custom message
./quick-deploy.sh "fix login bug"
```

### Git Operations Only
```bash
# Auto git add, commit, push
./git-deploy.sh

# Với custom commit message
./git-deploy.sh "update authentication"
```

### Server Connection
```bash
# Connect to server
./server-connect.sh

# Setup server config lần đầu
./server-connect.sh setup

# Deploy và connect
./server-connect.sh deploy
```

### Full Pipeline
```bash
# Complete workflow: git + server update + health check
./full-deploy.sh "major update"
```

## 🔧 Development

```bash
# Install dependencies
cd site && npm install
cd api && npm install

# Start development
./docker-dev.sh

# Build for production
./docker-build.sh
```

## 🌐 Production URLs

- **Website**: https://innerbright.vn
- **API**: https://innerbright.vn/api
- **Admin**: https://innerbright.vn/admin

## 📊 Management

Sau khi triển khai, sử dụng management console:

```bash
./manage-production.sh
```

**Tính năng**:
- ✅ Service monitoring
- ✅ Database backup/restore
- ✅ Log management
- ✅ SSL certificate management
- ✅ System resource monitoring
- ✅ Application updates

## 🔐 Bảo Mật

- ✅ SSL/TLS encryption
- ✅ UFW Firewall
- ✅ Fail2ban protection
- ✅ Security headers
- ✅ Non-root containers
- ✅ Environment variable protection

## 💾 Backup

- ✅ Automatic daily database backups
- ✅ 7-day retention policy
- ✅ Manual backup/restore tools
- ✅ Point-in-time recovery

## 📞 Support

Để được hỗ trợ triển khai hoặc sử dụng:

1. Xem [README_DEPLOYMENT.md](./README_DEPLOYMENT.md) cho hướng dẫn đầy đủ
2. Chạy `./manage-production.sh` để truy cập management console
3. Kiểm tra logs với `docker compose logs -f`

---

*Powered by Docker, secured by best practices, managed by automation*