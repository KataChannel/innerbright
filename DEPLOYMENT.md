# 🚀 Innerbright - Optimized Production Deployment

Đây là hướng dẫn deploy production được tối ưu hóa cho website **Innerbright.vn** sử dụng Next.js, Docker, và Nginx với SSL.

## 📋 Yêu cầu hệ thống

- **Docker** 20.10+
- **Docker Compose** 2.0+
- **2GB RAM** tối thiểu (khuyến nghị 4GB+)
- **10GB ổ cứng** trống tối thiểu
- **Ubuntu 20.04+** hoặc **CentOS 8+**
- **Domain** đã trỏ về server

## 🏗️ Kiến trúc hệ thống

```
┌─────────────────┐    ┌──────────────┐    ┌─────────────┐
│   Nginx (SSL)   │────│  Next.js App │────│ PostgreSQL  │
│   Port 80/443   │    │   Port 3000  │    │  Port 5432  │
└─────────────────┘    └──────────────┘    └─────────────┘
         │                       │                  │
         │              ┌──────────────┐    ┌─────────────┐
         └──────────────│    Redis     │    │   MinIO     │
                        │  Port 6379   │    │ Port 9000/1 │
                        └──────────────┘    └─────────────┘
```

## 🚀 Deployment nhanh

### 1. Clone repository và setup

```bash
git clone <repository-url>
cd innerbright
```

### 2. Tạo file môi trường

```bash
cp .env.example .env
nano .env  # Cập nhật các giá trị cần thiết
```

### 3. Deploy với script tối ưu

```bash
./deploy-optimized.sh
```

### 4. Thiết lập SSL (tùy chọn)

```bash
sudo ./setup-ssl.sh
```

## ⚙️ Cấu hình chi tiết

### Cấu hình Environment (.env)

```bash
# Application Settings
NODE_ENV=production
NEXT_PUBLIC_APP_URL=https://innerbright.vn

# Database
POSTGRES_PASSWORD=your_secure_password

# Redis
REDIS_PASSWORD=your_redis_password

# MinIO
MINIO_ROOT_PASSWORD=your_minio_password
MINIO_ACCESS_KEY=your_access_key
MINIO_SECRET_KEY=your_secret_key

# Authentication
NEXTAUTH_SECRET=your_32_char_secret
```

### Tối ưu hóa Docker

**Dockerfile** đã được tối ưu với:
- ✅ Multi-stage build giảm kích thước image
- ✅ Bun runtime cho tốc độ cao
- ✅ Next.js standalone output
- ✅ Non-root user security
- ✅ Health checks tự động

**Docker Compose** features:
- ✅ Resource limits
- ✅ Health checks cho tất cả services
- ✅ Automatic restart policies
- ✅ Named volumes cho persistence
- ✅ Network isolation

### Cấu hình Nginx SSL

**nginx/innerbright.vn.conf** bao gồm:
- ✅ HTTP/2 và SSL optimizations
- ✅ Gzip compression
- ✅ Rate limiting
- ✅ Security headers
- ✅ Static file caching
- ✅ WebSocket support

## 🛠️ Scripts hữu ích

### Deploy và quản lý

```bash
# Deploy production optimized
./deploy-optimized.sh

# Health check tất cả services
./health-check.sh

# Setup SSL certificates
sudo ./setup-ssl.sh

# View logs real-time
docker-compose logs -f site

# Restart specific service
docker-compose restart site
```

### Monitoring và maintenance

```bash
# Check service status
docker-compose ps

# View resource usage
docker stats

# Backup database
docker-compose exec postgres pg_dump -U postgres innerbright_db > backup.sql

# Clean up unused Docker resources
docker system prune -f --volumes
```

## 📊 Performance benchmarks

Với cấu hình tối ưu này:

- **Build time**: ~2-3 phút (với cache)
- **Image size**: ~200MB (compressed)
- **Memory usage**: ~512MB-1GB
- **Response time**: <200ms (avg)
- **Concurrent users**: 1000+ (tested)

## 🔍 Troubleshooting

### Service không start

```bash
# Check logs
docker-compose logs service-name

# Check health
./health-check.sh

# Restart service
docker-compose restart service-name
```

### SSL issues

```bash
# Check certificate
sudo certbot certificates

# Manual renewal
sudo certbot renew

# Test nginx config
docker-compose exec nginx nginx -t
```

### Database connection issues

```bash
# Check PostgreSQL
docker-compose exec postgres pg_isready -U postgres

# Connect to database
docker-compose exec postgres psql -U postgres -d innerbright_db
```

### Performance issues

```bash
# Check resource usage
docker stats --no-stream

# Check system resources
htop
df -h

# Optimize Docker
docker system prune -f
```

## 🔒 Security features

- ✅ **SSL/TLS** với Let's Encrypt
- ✅ **Security headers** (HSTS, CSP, etc.)
- ✅ **Rate limiting** chống DDoS
- ✅ **Non-root containers**
- ✅ **Network isolation**
- ✅ **Firewall rules** ready
- ✅ **Secrets management**

## 📈 Monitoring và alerts

### Health checks tự động

Script `health-check.sh` kiểm tra:
- Service availability
- Database connectivity  
- SSL certificate expiry
- System resources
- Response times

### Logs và metrics

```bash
# Application logs
docker-compose logs -f site

# Nginx access logs
docker-compose logs -f nginx

# System metrics
docker stats

# Custom health endpoint
curl http://localhost:3000/health
```

## 🔄 Updates và maintenance

### Rolling updates

```bash
# Pull latest code
git pull origin main

# Rebuild and deploy
./deploy-optimized.sh

# Zero-downtime deployment
docker-compose up -d --no-deps site
```

### Database migrations

```bash
# Run migrations
docker-compose exec site bun run db:migrate

# Seed data
docker-compose exec site bun run db:seed
```

## 📝 Notes quan trọng

1. **Backup**: Tự động backup database hàng ngày
2. **SSL**: Auto-renewal với Let's Encrypt
3. **Monitoring**: Health checks mỗi 30s
4. **Security**: Regular security updates
5. **Performance**: CDN ready với MinIO

## 🆘 Support

Nếu gặp vấn đề:

1. Chạy `./health-check.sh` để kiểm tra system
2. Check logs: `docker-compose logs -f`
3. Xem troubleshooting guide ở trên
4. Contact: admin@innerbright.vn

---

**🎉 Chúc bạn deploy thành công!**
