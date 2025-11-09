# 🚨 Tình trạng hiện tại và giải pháp

## ⚠️ Vấn đề

Server **116.118.48.208** (1 vCPU, 2GB RAM, 10GB NVMe) hiện tại:
- ✅ **PING**: Hoạt động bình thường (3ms latency)
- ❌ **SSH**: Timeout không kết nối được
- ❓ **Nguyên nhân**: Server bị overload do build Next.js trực tiếp trên server yếu

## 🔧 Đã tối ưu

### 1. **Dockerfile mới** - Không build trên server
```dockerfile
# CHỈ COPY pre-built files, KHÔNG build
FROM oven/bun:1-slim AS runner
ENV NODE_OPTIONS="--max-old-space-size=1024"
COPY --chown=nextjs:nodejs frontend/.next/standalone ./
```

### 2. **Docker Compose** - Memory limits
```yaml
innerbright-web:
  deploy:
    resources:
      limits:
        memory: 1024M    # Max 1GB cho Next.js
```

### 3. **Deployment Script** - Build local
- `scripts/deploy-lowspec.sh` - Build locally, upload binary only
- `scripts/95copy.sh` - Auto-detect low-spec và force local build

## 🚑 Giải pháp khẩn cấp

### Option 1: Chờ server tự recover (5-10 phút)
```bash
# Ping test mỗi 30s
watch -n 30 'ping -c 3 116.118.48.208 && ssh -o ConnectTimeout=5 root@116.118.48.208 "echo OK"'
```

### Option 2: Reboot server (nếu có quyền truy cập console)
- Truy cập console/VNC của hosting provider
- Reboot server
- Sau khi reboot, chạy: `./scripts/deploy-lowspec.sh`

### Option 3: Force kill process qua SSH (khi SSH hoạt động lại)
```bash
ssh root@116.118.48.208 "
  pkill -9 -f 'next build'
  pkill -9 -f 'docker.*build'
  pkill -9 -f 'bun'
  docker stop \$(docker ps -q)
  docker system prune -af
  reboot
"
```

## 📋 Quy trình deploy đúng cho server yếu

### ✅ CÁch đúng:
```bash
# 1. Build LOCAL (trên máy mạnh)
bun run build

# 2. Deploy binary đã build
./scripts/deploy-lowspec.sh
```

### ❌ CÁch sai (gây đứng server):
```bash
# KHÔNG build trên server!
ssh root@116.118.48.208 "cd /root/innerbright && docker compose up --build"
```

## 🎯 Memory allocation cho 2GB RAM

| Service        | Memory | Priority |
|----------------|--------|----------|
| Next.js Web    | 1024MB | High     |
| PostgreSQL     | 256MB  | Medium   |
| PgAdmin        | 256MB  | Low      |
| Redis          | 128MB  | Medium   |
| System/Docker  | ~336MB | Critical |
| **TOTAL**      | 2000MB |          |

## 🔍 Monitoring commands

```bash
# Check if SSH is back
ssh -o ConnectTimeout=5 root@116.118.48.208 "echo OK"

# Check server resources  
ssh root@116.118.48.208 "
  echo '=== Memory ==='
  free -h
  echo '=== CPU ==='
  top -bn1 | head -20
  echo '=== Disk ==='
  df -h
  echo '=== Processes ==='
  ps aux | head -20
"

# Check Docker status
ssh root@116.118.48.208 "
  docker ps -a
  docker stats --no-stream
"
```

## 📞 Next Steps

### Nếu SSH vẫn timeout:
1. ✅ Ping OK = Server alive, chỉ SSH overload
2. 🕐 Chờ 5-10 phút để server tự recover
3. 🔄 Nếu không recover, cần reboot qua console

### Khi SSH hoạt động trở lại:
```bash
# 1. Clean up
ssh root@116.118.48.208 "
  docker stop \$(docker ps -aq)
  docker system prune -af
"

# 2. Deploy properly
./scripts/deploy-lowspec.sh
```

## 🎓 Bài học

**Server 1 vCPU, 2GB RAM KHÔNG THỂ build Next.js!**

- ❌ Build process cần ~2GB RAM chỉ riêng cho Node.js
- ❌ Turbopack build cần multi-threading
- ❌ Docker build thêm overhead nữa
- ✅ **Phải build trên máy local mạnh, chỉ upload binary**

---

*Tạo bởi: Low-Spec Server Optimization v1.0*
*Date: 2025-11-09*