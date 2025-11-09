# 🚀 Quick Deployment Guide

## Sử dụng script 3deploy.sh (Recommended)

Script này được tối ưu cho **server yếu** (1 vCPU, 2GB RAM):

```bash
./scripts/3deploy.sh
```

### Script sẽ tự động:

1. ✅ **Git operations** (optional) - commit và push code
2. ✅ **Build locally** - Build Next.js trên máy của bạn (không build trên server)
3. ✅ **Test connectivity** - Kiểm tra server có hoạt động không
4. ✅ **Upload files** - Rsync pre-built files lên server
5. ✅ **Deploy Docker** - Build image và start container (không compile code)
6. ✅ **Health check** - Verify application đang chạy

### Output mẫu:

```
═══════════════════════════════════════════════════════
🚀 INNERBRIGHT DEPLOYMENT - LOW-SPEC SERVER MODE
═══════════════════════════════════════════════════════
[WARNING] Server: 116.118.48.208 (1 vCPU, 2GB RAM, 10GB NVMe)
[WARNING] Strategy: Build locally → Upload binary → No server build
═══════════════════════════════════════════════════════

[INFO] 📝 Step 1: Git operations...
[SUCCESS] Git operations completed

[INFO] 📦 Step 2: Building locally (this protects server from overload)...
   Building with Bun + Turbopack...
[SUCCESS] ✅ Local build completed successfully

[INFO] 🔍 Step 3: Testing server connectivity...
[SUCCESS] ✅ Server is reachable (ping OK)
[SUCCESS] ✅ SSH connection OK

[INFO] 📤 Step 4: Uploading pre-built files to server...
[SUCCESS] ✅ Files uploaded successfully

[INFO] 🐳 Step 5: Deploying on server (no compilation)...
[SUCCESS] ✅ Docker container started

[INFO] 🏥 Step 6: Health check...
[SUCCESS] ✅ Application is responding!
[SUCCESS] 🌐 Website: http://116.118.48.208:14000

═══════════════════════════════════════════════════════
[SUCCESS] 🎉 DEPLOYMENT COMPLETED SUCCESSFULLY
═══════════════════════════════════════════════════════
```

## Tại sao phải build local?

❌ **KHÔNG** build trên server yếu vì:
- Next.js build cần ~2GB RAM (server chỉ có 2GB total)
- Turbopack cần nhiều CPU cores
- Docker build thêm overhead
- **Kết quả**: Server bị hang, SSH timeout

✅ **Build local** thì:
- Máy của bạn mạnh hơn, build nhanh (5-10s)
- Upload chỉ mất 30-60s
- Server chỉ cần copy files vào Docker (rất nhẹ)
- **Kết quả**: Deploy thành công, không crash

## Troubleshooting

### Nếu SSH timeout:
```bash
# Wait và retry
sleep 60
./scripts/3deploy.sh
```

### Nếu upload fails:
```bash
# Check disk space trên server
ssh root@116.118.48.208 "df -h"

# Clean up nếu cần
ssh root@116.118.48.208 "docker system prune -af"
```

### Monitor server:
```bash
# Check logs
ssh root@116.118.48.208 "docker compose logs -f innerbright-web"

# Check resources
ssh root@116.118.48.208 "htop"
```

## Alternative Scripts

- `./scripts/95copy.sh` - Main deployment với nhiều options
- `./scripts/deploy-lowspec.sh` - Similar to 3deploy.sh
- `./scripts/debug-deploy.sh` - Diagnostic tool

---

**✨ Tip**: Luôn chạy `bun run build` local trước khi deploy để đảm bảo không có lỗi build!