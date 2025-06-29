# 🚀 Innerbright - Hướng Dẫn Triển Khai Production Hoàn Chỉnh

## 📋 Tổng Quan Hệ Thống

Innerbright là một ứng dụng full-stack được xây dựng với:

### 🏗️ Kiến Trúc
- **Frontend**: Next.js 14 (TypeScript, Tailwind CSS)
- **Backend**: NestJS API (TypeScript, REST API)
- **Database**: PostgreSQL 15 
- **Storage**: MinIO Object Storage
- **Cache**: Redis (Optional)
- **Proxy**: Nginx với SSL/TLS
- **Admin**: PgAdmin (Optional)
- **Containerization**: Docker & Docker Compose

### 🌐 Luồng Dữ Liệu
```
Internet → Nginx (SSL/443) → Next.js (3000) + NestJS API (3333)
                                    ↓
                              PostgreSQL (5432) + MinIO (9000) + Redis (6379)
```

---

## 🎯 Triển Khai Nhanh (Khuyến Nghị)

### Bước 1: Kiểm Tra Hệ Thống
```bash
# Tải về và chạy kiểm tra hệ thống
./pre-deployment-check.sh
```

### Bước 2: Triển Khai Tự Động
```bash
# Triển khai hoàn toàn tự động (khuyến nghị cho người mới)
./one-click-deploy.sh
```

### Bước 3: Quản Lý Hệ Thống
```bash
# Mở console quản lý
./manage-production.sh
```

**🎉 Xong! Ứng dụng của bạn đã sẵn sàng!**

---

## 📚 Scripts và Công Cụ Có Sẵn

### 🔧 Scripts Triển Khai

| Script | Mô Tả | Khi Nào Sử Dụng |
|--------|-------|------------------|
| `pre-deployment-check.sh` | Kiểm tra hệ thống trước triển khai | Trước khi bắt đầu triển khai |
| `one-click-deploy.sh` | Triển khai hoàn toàn tự động | Lần đầu tiên setup production |
| `setup-cloud-server.sh` | Chuẩn bị server mới | Server Ubuntu/Debian mới |
| `deploy-production.sh` | Triển khai thủ công chi tiết | Khi cần kiểm soát từng bước |
| `quick-setup.sh` | Setup nhanh với tương tác | Setup nhanh nhưng có kiểm soát |

### 📊 Scripts Quản Lý

| Script | Mô Tả | Tính Năng Chính |
|--------|-------|-----------------|
| `manage-production.sh` | Console quản lý chính | 20+ tính năng quản lý |
| `docker-dev.sh` | Chạy development | Development environment |
| `docker-build.sh` | Build và test | Build containers locally |

### 🛠️ Công Cụ Hỗ Trợ

| File | Mô Tả | Mục Đích |
|------|-------|----------|
| `docker-compose.yml` | Cấu hình services | Production services |
| `.env.example` | Template environment | Cấu hình production |
| `nginx.conf` | Cấu hình Nginx | Reverse proxy + SSL |

---

## 📖 Hướng Dẫn Chi Tiết

### 📘 Cho Người Mới Bắt Đầu
1. **[PRODUCTION_DEPLOYMENT_MANUAL.md](./PRODUCTION_DEPLOYMENT_MANUAL.md)** - Hướng dẫn chi tiết từng bước
2. **[DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md)** - Hướng dẫn tổng quan

### 📙 Cho Người Có Kinh Nghiệm
1. **[DOCKER.md](./DOCKER.md)** - Tài liệu kỹ thuật Docker
2. **Scripts** - Sử dụng trực tiếp các scripts

---

## 🚀 Hướng Dẫn Triển Khai Từng Loại

### 🥇 Option 1: One-Click Deployment (Khuyến Nghị)
**Dành cho**: Người muốn triển khai nhanh và đơn giản

```bash
# 1. Kiểm tra hệ thống
./pre-deployment-check.sh

# 2. Nếu có lỗi, chạy setup tự động
./setup-cloud-server.sh

# 3. Triển khai hoàn toàn tự động
./one-click-deploy.sh
```

**Ưu điểm**: 
- ✅ Hoàn toàn tự động
- ✅ Có validation và backup
- ✅ Setup SSL tự động
- ✅ Cấu hình bảo mật tự động

**Nhược điểm**: 
- ❌ Ít kiểm soát chi tiết

### 🥈 Option 2: Manual Deployment
**Dành cho**: Người muốn kiểm soát từng bước

```bash
# 1. Chuẩn bị server
./setup-cloud-server.sh

# 2. Cấu hình thủ công
cp .env.example .env
nano .env

# 3. Triển khai thủ công
./deploy-production.sh
```

**Ưu điểm**: 
- ✅ Kiểm soát hoàn toàn
- ✅ Hiểu rõ từng bước
- ✅ Tùy chỉnh chi tiết

**Nhược điểm**: 
- ❌ Mất thời gian hơn
- ❌ Cần kiến thức Linux/Docker

### 🥉 Option 3: Development Setup
**Dành cho**: Phát triển và testing

```bash
# Development environment
./docker-dev.sh

# Build và test local
./docker-build.sh
```

---

## ⚙️ Cấu Hình Environment Variables

### 🔐 Biến Bắt Buộc

```bash
# Database
POSTGRES_DB=innerbright_prod
POSTGRES_USER=innerbright_user
POSTGRES_PASSWORD=your_super_secure_password

# Authentication
NEXTAUTH_SECRET=your_32_character_secret_minimum
NEXTAUTH_URL=https://your-domain.com

# Domain & SSL
DOMAIN=your-domain.com
EMAIL=your-email@domain.com

# Storage
MINIO_ROOT_USER=admin
MINIO_ROOT_PASSWORD=your_minio_password
```

### 🔧 Biến Tùy Chọn

```bash
# Ports (mặc định)
NEXTJS_PORT=3000
NESTJS_PORT=3333
POSTGRES_PORT=5432
MINIO_PORT=9000
PGADMIN_PORT=5050
REDIS_PORT=6379

# Optional Services
ENABLE_PGADMIN=y
ENABLE_REDIS=y
```

---

## 📊 Quản Lý Production

### 🖥️ Management Console
```bash
./manage-production.sh
```

**Tính năng có sẵn**:
- 📊 Service Status & Health Check
- 🔄 Start/Stop/Restart Services  
- 💾 Database Backup & Restore
- 📋 View & Clean Logs
- 🔧 Update Application
- 🏗️ Rebuild Containers
- 📈 System Resources Monitoring
- 🔒 Security Status
- 🔑 SSL Certificate Management
- ⚙️ Configuration Management

### 📈 Monitoring

#### Health Checks
```bash
# Kiểm tra tự động
curl https://your-domain.com/api/health      # Next.js
curl https://your-domain.com/api/health      # NestJS API
```

#### Logs
```bash
# View logs
docker compose logs -f                        # Tất cả services
docker compose logs -f nextjs                 # Chỉ Next.js  
docker compose logs -f nestjs                 # Chỉ NestJS
```

#### Resource Usage
```bash
# System resources
htop
df -h
free -h

# Docker resources  
docker stats
docker system df
```

---

## 🔐 Bảo Mật Production

### 🛡️ Tự Động Được Cấu Hình

✅ **UFW Firewall** - Chỉ mở port cần thiết (80, 443, SSH)
✅ **Fail2ban** - Chống brute force attack
✅ **SSL/TLS** - Let's Encrypt certificate tự động
✅ **Security Headers** - XSS, CSRF protection
✅ **Non-root Docker** - Containers chạy với user thường
✅ **Environment Variables** - Sensitive data được bảo vệ

### 🔒 Khuyến Nghị Thêm

```bash
# Đổi SSH port (optional)
sudo nano /etc/ssh/sshd_config
# Port 2222

# Disable password authentication (nếu dùng SSH keys)
# PasswordAuthentication no

# Setup monitoring
# Cài đặt monitoring tools như Grafana, Prometheus
```

---

## 💾 Backup & Recovery

### 🔄 Backup Tự Động
- **Database**: Backup hàng ngày lúc 2:00 AM
- **Files**: Retention 7 ngày
- **Location**: `/opt/innerbright/backups/`

### 📁 Manual Backup
```bash
# Database backup
./manage-production.sh  # Option 5

# Or direct command
cd /opt/innerbright
./backup-db.sh
```

### 🔄 Restore
```bash
# Database restore
./manage-production.sh  # Option 6

# List backups
ls -la /opt/innerbright/backups/
```

---

## 🔄 Updates & Maintenance

### 🆙 Update Application
```bash
# Automatic update (recommended)
./manage-production.sh  # Option 11

# Manual update
cd /opt/innerbright
git pull
docker compose up --build -d
```

### 🧹 System Maintenance
```bash
# Clean system
./manage-production.sh  # Option 10

# Manual cleanup
docker system prune -f
sudo apt autoremove
```

### 🔑 SSL Certificate Renewal
```bash
# Automatic (cron job đã setup)
# Manual renewal
sudo certbot renew
```

---

## 🚨 Troubleshooting

### ❓ Common Issues

#### 🔴 Services Won't Start
```bash
# Check logs
docker compose logs

# Check resources
df -h
free -h

# Restart services
docker compose restart
```

#### 🔴 Database Connection Failed
```bash
# Check PostgreSQL
docker compose logs postgres

# Test connection
docker compose exec postgres psql -U user -d database
```

#### 🔴 SSL Certificate Issues
```bash
# Check certificate
sudo certbot certificates

# Renew certificate
sudo certbot renew --force-renewal
```

#### 🔴 Port Already in Use
```bash
# Find process using port
sudo lsof -i :3000

# Kill process
sudo kill -9 PID
```

### 📞 Getting Help

1. **Check logs**: `./manage-production.sh` → Option 13
2. **Health check**: `./manage-production.sh` → Option 8
3. **System resources**: `./manage-production.sh` → Option 15

---

## 📁 Cấu Trúc Thư Mục Production

```
/opt/innerbright/                    # Main project directory
├── api/                            # NestJS backend
├── site/                           # Next.js frontend  
├── data/                           # Persistent data
│   ├── postgres/                   # PostgreSQL data
│   ├── minio/                      # MinIO data
│   └── redis/                      # Redis data
├── logs/                           # Application logs
├── backups/                        # Database backups
├── docker-compose.yml              # Services configuration
├── .env                           # Environment variables
└── *.sh                           # Management scripts
```

---

## 🎛️ Service Ports

| Service | Internal Port | External Port | Access |
|---------|---------------|---------------|---------|
| Next.js | 3000 | 80/443 (via Nginx) | Public |
| NestJS | 3333 | 80/443 (via Nginx) | Public (/api) |
| PostgreSQL | 5432 | - | Internal only |
| MinIO | 9000 | - | Internal only |
| Redis | 6379 | - | Internal only |
| PgAdmin | 5050 | 5050 (optional) | Admin only |
| Nginx | 80/443 | 80/443 | Public |

---

## 🌟 Best Practices

### ✅ DO
- ✅ Sử dụng strong passwords
- ✅ Enable firewall
- ✅ Setup regular backups  
- ✅ Monitor system resources
- ✅ Keep system updated
- ✅ Use HTTPS only
- ✅ Monitor logs regularly
- ✅ Test backups periodically

### ❌ DON'T  
- ❌ Run as root user
- ❌ Use default passwords
- ✗ Skip SSL certificate
- ❌ Ignore security updates
- ❌ Expose database ports
- ❌ Skip monitoring setup
- ❌ Forget to backup
- ❌ Use HTTP in production

---

## 📊 Performance Optimization

### 🚀 Next.js Optimizations
- ✅ Static generation enabled
- ✅ Image optimization
- ✅ Bundle analysis
- ✅ Compression enabled

### 🎯 NestJS Optimizations  
- ✅ Connection pooling
- ✅ Caching layer
- ✅ Request validation
- ✅ Rate limiting ready

### 🗄️ Database Optimizations
- ✅ Connection pooling
- ✅ Query optimization
- ✅ Index optimization
- ✅ Backup optimization

### 🌐 Infrastructure Optimizations
- ✅ Nginx gzip compression
- ✅ SSL/TLS optimization
- ✅ CDN ready
- ✅ Health checks enabled

---

## 🆘 Emergency Procedures

### 🚨 Service Down
```bash
# 1. Check service status
./manage-production.sh  # Option 1

# 2. View logs  
docker compose logs -f

# 3. Restart services
docker compose restart

# 4. If still failing, restore from backup
./manage-production.sh  # Option 6
```

### 🚨 Database Corruption
```bash
# 1. Stop services
docker compose down

# 2. Restore from backup
./manage-production.sh  # Option 6

# 3. Start services
docker compose up -d
```

### 🚨 Full System Recovery
```bash
# 1. Backup current state
./backup-db.sh

# 2. Re-run deployment
./one-click-deploy.sh

# 3. Restore data if needed
./manage-production.sh  # Option 6
```

---

## 📞 Support & Community

### 📚 Documentation
- **Technical Docs**: `DOCKER.md`
- **Deployment Guide**: `DEPLOYMENT_GUIDE.md`  
- **Production Manual**: `PRODUCTION_DEPLOYMENT_MANUAL.md`

### 🛠️ Tools
- **Management Console**: `./manage-production.sh`
- **Health Check**: `./pre-deployment-check.sh`
- **One-Click Deploy**: `./one-click-deploy.sh`

### 📊 Monitoring Dashboards
- **System**: htop, df, free
- **Docker**: docker stats
- **Application**: Health endpoints
- **Logs**: Docker logs + System logs

---

## 🎉 Tóm Tắt

**Innerbright Production Deployment** cung cấp:

✅ **Triển khai hoàn toàn tự động** với one-click deployment
✅ **Bảo mật production-ready** với SSL, firewall, fail2ban  
✅ **Monitoring và alerting** tích hợp sẵn
✅ **Backup tự động** với retention policies
✅ **Management console** với 20+ tính năng
✅ **Health checks** cho tất cả services
✅ **Documentation chi tiết** cho mọi use case
✅ **Best practices** được áp dụng sẵn

**🚀 Bắt đầu ngay**: `./pre-deployment-check.sh` → `./one-click-deploy.sh` → `./manage-production.sh`

---

*Được phát triển với ❤️ cho Innerbright Production Deployment*
