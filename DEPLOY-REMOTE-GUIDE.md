# 🚀 KataCore Remote Deployment Guide

## Tổng quan
Script `deploy-remote.sh` giúp bạn deploy KataCore lên server remote một cách dễ dàng với IP và domain linh hoạt.

## Yêu cầu
- Server Linux với SSH access
- Docker & Docker Compose sẽ được tự động cài đặt
- SSH key hoặc password access
- Domain đã point về server IP (nếu dùng SSL)

## Cách sử dụng

### 1. Cấu hình SSH Key (khuyên dùng)
```bash
# Tạo SSH key nếu chưa có
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"

# Copy public key lên server
ssh-copy-id root@116.118.85.41
```

### 2. Deploy với Domain và SSL (Full)
```bash
# Deploy full với domain và SSL
./deploy-remote.sh 116.118.85.41 innerbright.vn

# Custom SSH user và key
./deploy-remote.sh --user ubuntu --key ~/.ssh/my-key.pem 116.118.85.41 innerbright.vn

# Force regenerate environment files
./deploy-remote.sh --force-regen 116.118.85.41 innerbright.vn
```

### 3. Deploy Simple (chỉ Docker, không SSL)
```bash
# Deploy simple (chỉ Docker)
./deploy-remote.sh --simple 116.118.85.41 innerbright.vn

# Hoặc không cần domain
./deploy-remote.sh --simple 116.118.85.41
```

### 4. Test Connection
```bash
# Test SSH connection trước khi deploy
ssh root@116.118.85.41 "echo 'Connection OK'"
```

## Các tùy chọn

| Option | Mô tả | Ví dụ |
|--------|-------|--------|
| `--user USER` | SSH user (default: root) | `--user ubuntu` |
| `--key PATH` | SSH private key path | `--key ~/.ssh/my-key.pem` |
| `--simple` | Deploy simple (không SSL) | `--simple` |
| `--force-regen` | Force regenerate .env | `--force-regen` |
| `--help` | Show help | `--help` |

## Ví dụ cụ thể

### Ví dụ 1: Deploy với root user
```bash
./deploy-remote.sh 116.118.85.41 innerbright.vn
```

### Ví dụ 2: Deploy với Ubuntu user và custom key
```bash
./deploy-remote.sh --user ubuntu --key ~/.ssh/aws-key.pem 116.118.85.41 innerbright.vn
```

### Ví dụ 3: Deploy simple (chỉ Docker)
```bash
./deploy-remote.sh --simple 116.118.85.41
```

### Ví dụ 4: Deploy với force regenerate
```bash
./deploy-remote.sh --force-regen 116.118.85.41 innerbright.vn
```

## Các services được deploy

Sau khi deploy thành công, các services sẽ available tại:

### Full deployment (với SSL)
- 🌐 Main Site: `https://innerbright.vn`
- 🚀 API: `https://innerbright.vn/api`
- 📦 MinIO: `https://innerbright.vn:9000`
- 🗄️ pgAdmin: `https://innerbright.vn:5050`

### Simple deployment (chỉ Docker)
- 🌐 Main Site: `http://116.118.85.41:3000`
- 🚀 API: `http://116.118.85.41:3001`
- 📦 MinIO: `http://116.118.85.41:9000`
- 🗄️ pgAdmin: `http://116.118.85.41:5050`

## Troubleshooting

### 1. SSH Connection Failed
```bash
# Kiểm tra SSH key
ls -la ~/.ssh/
chmod 600 ~/.ssh/id_rsa

# Test connection
ssh root@116.118.85.41
```

### 2. Permission Denied
```bash
# Sử dụng custom user
./deploy-remote.sh --user ubuntu --key ~/.ssh/my-key.pem 116.118.85.41 innerbright.vn
```

### 3. Domain không point đúng
```bash
# Kiểm tra DNS
nslookup innerbright.vn
dig innerbright.vn

# Deploy simple nếu domain chưa sẵn sàng
./deploy-remote.sh --simple 116.118.85.41
```

### 4. Xem logs trên server
```bash
# SSH vào server
ssh root@116.118.85.41

# Xem docker containers
docker ps

# Xem logs
cd /opt/katacore
docker-compose logs
```

## Sau khi deploy thành công

1. **Check services:**
   ```bash
   ssh root@116.118.85.41 'docker ps'
   ```

2. **View logs:**
   ```bash
   ssh root@116.118.85.41 'cd /opt/katacore && docker-compose logs'
   ```

3. **Check environment:**
   ```bash
   ssh root@116.118.85.41 'cat /opt/katacore/.env'
   ```

4. **Restart services nếu cần:**
   ```bash
   ssh root@116.118.85.41 'cd /opt/katacore && docker-compose restart'
   ```

## Lưu ý quan trọng

- 🔐 Passwords được auto-generate và lưu trong file `.env` trên server
- 🔥 Firewall sẽ được tự động cấu hình
- 📦 Docker & Docker Compose sẽ được tự động cài đặt
- 🌐 Nginx và SSL certificate sẽ được tự động setup (full deployment)
- 📁 Tất cả files sẽ được copy vào `/opt/katacore` trên server

---

**Hỗ trợ:** Nếu gặp vấn đề, hãy check logs và đảm bảo server có đủ resources (RAM >= 2GB, Disk >= 10GB).
