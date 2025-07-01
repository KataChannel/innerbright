# 🚀 KataCore Safe Deployment Guide

Hướng dẫn triển khai an toàn KataCore để tránh lỗi lần đầu tiên.

## 📋 Checklist Triển Khai An Toàn

### Bước 1: Kiểm tra Pre-deployment
```bash
# Chạy kiểm tra trước khi triển khai
bun run pre-deploy
# hoặc
./scripts/pre-deploy-check.sh
```

### Bước 2: Cleanup (tùy chọn)
```bash
# Nếu đã từng triển khai và gặp lỗi
bun run cleanup
# hoặc
./scripts/cleanup-deploy.sh
```

### Bước 3: Triển Khai An Toàn
```bash
# Triển khai với kiểm tra tự động
bun run deploy:safe --host YOUR_SERVER_IP

# Hoặc triển khai với cleanup trước
bun run deploy:clean --host YOUR_SERVER_IP

# Hoặc triển khai thủ công
./startkit-deployer.sh --host YOUR_SERVER_IP
```

## 🔧 Các Cải Tiến Đã Thực Hiện

### 1. **Health Check Improvements**
- ✅ Thêm `curl` và `wget` vào tất cả containers
- ✅ Health check fallback với multiple tools
- ✅ Improved health check timeouts và retries

### 2. **Environment Management**
- ✅ Auto-detect và replace placeholder values
- ✅ Intelligent environment file generation
- ✅ IP-based configuration for non-domain deployments
- ✅ Proper permission setting (600) cho .env.prod

### 3. **Nginx Configuration**
- ✅ Simple IP-based configuration để tránh conflicts
- ✅ Automatic cleanup of conflicting configs
- ✅ Fallback configurations
- ✅ Health check endpoint

### 4. **Pre-deployment Checks**
- ✅ Validate environment variables
- ✅ Check Docker installation
- ✅ Verify project structure
- ✅ Check for placeholder values
- ✅ Prepare proper configurations

### 5. **Cleanup và Preparation**
- ✅ Automatic container cleanup
- ✅ Configuration backup
- ✅ Conflict resolution
- ✅ Permission setting

### 6. **Post-deployment Verification**
- ✅ Service accessibility tests
- ✅ Health status checks
- ✅ Error log analysis
- ✅ Comprehensive verification report

## 🐛 Các Lỗi Đã Được Khắc Phục

### ❌ Environment Variables Not Set
**Đã khắc phục:** Auto-generation và intelligent replacement của placeholder values

### ❌ Health Check Failures
**Đã khắc phục:** Include curl/wget trong containers, fallback health checks

### ❌ Nginx Configuration Conflicts
**Đã khắc phục:** Simple IP-based config, automatic conflict cleanup

### ❌ Docker Build Failures
**Đã khắc phục:** Improved Dockerfiles với proper dependencies

### ❌ Container Startup Issues
**Đã khắc phục:** Better dependency management, health check timing

## 📝 Script Commands

### Pre-deployment
```bash
bun run pre-deploy          # Kiểm tra trước triển khai
bun run env:validate        # Validate environment variables
bun run env:create-template # Tạo environment template
```

### Deployment
```bash
bun run deploy:safe         # Triển khai an toàn với pre-check
bun run deploy:clean        # Cleanup + deploy
bun run deploy:universal    # Triển khai thông thường
```

### Maintenance
```bash
bun run cleanup            # Cleanup containers và configs
bun run deploy:history     # Xem deployment history
bun run deploy:cache:clear # Clear deployment cache
```

## 🔍 Troubleshooting

### Nếu Triển Khai Thất Bại

1. **Chạy cleanup:**
   ```bash
   bun run cleanup
   ```

2. **Kiểm tra environment:**
   ```bash
   bun run env:validate
   ```

3. **Triển khai lại:**
   ```bash
   bun run deploy:safe --host YOUR_SERVER_IP --verbose
   ```

### Kiểm tra Status

```bash
# Trên server
ssh root@YOUR_SERVER_IP "cd /opt/katacore && docker compose ps"

# Xem logs
ssh root@YOUR_SERVER_IP "cd /opt/katacore && docker compose logs -f"
```

## 🎯 Kết Quả Mong Đợi

Sau khi triển khai thành công:

- ✅ **Frontend:** http://YOUR_SERVER_IP
- ✅ **API:** http://YOUR_SERVER_IP/api/health
- ✅ **MinIO Console:** http://YOUR_SERVER_IP:9001
- ✅ **pgAdmin:** http://YOUR_SERVER_IP:8080
- ✅ **Nginx Health:** http://YOUR_SERVER_IP/nginx-health

## 🔐 Security Features

- Environment files với permissions 600
- Secure password generation
- No hardcoded credentials
- Proper user isolation trong containers
- Rate limiting và security headers

## 📞 Hỗ Trợ

Nếu vẫn gặp lỗi:

1. Chạy `bun run deploy:safe --host YOUR_IP --verbose` để xem logs chi tiết
2. Kiểm tra Docker status trên server
3. Xem logs của từng container
4. Sử dụng scripts troubleshooting được cung cấp

---

**Lưu ý:** Các cải tiến này đảm bảo triển khai lần đầu tiên sẽ thành công mà không gặp các lỗi phổ biến.
