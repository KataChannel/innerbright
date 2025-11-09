# 🚀 InnerBright Deployment - Quick Start

## ✨ Sử dụng nhanh

### 1. Menu tương tác (Recommended)
```bash
./deploy.sh
```

Menu sẽ hiển thị:
- 🚀 Deploy to Remote Server
- 🐳 Deploy Local Docker  
- ✅ Verify Build
- 🔧 Fix Mode

### 2. Deploy trực tiếp

#### Deploy với build mới
```bash
./scripts/95copy.sh --build
```

#### Deploy build hiện có
```bash
./scripts/95copy.sh
```

#### Verify build
```bash
./scripts/95copy.sh --verify
```

#### Fix mode (production issues)
```bash
./scripts/95copy.sh --fix
```

## 📋 Chi tiết

Xem file [DEPLOYMENT.md](./DEPLOYMENT.md) để biết:
- Deployment flow chi tiết
- File structure
- Troubleshooting
- Docker services
- Advanced usage

## 🔧 Cấu hình

### Server Production
- **IP**: 116.118.48.208
- **User**: root
- **Directory**: /root/innerbright
- **Port**: 14000

### Services
| Service | Port |
|---------|------|
| Web App | 14000 |
| PostgreSQL | 14003 |
| PgAdmin | 14002 |
| Redis | 14004 |

## ⚡ Deploy Flow

```
Build → Verify → Upload → Docker Rebuild → Done
  6s      <1s     10-30s       30-60s        ✅
```

**Total time**: ~1-2 phút

## 🐛 Troubleshooting

### Lỗi build
```bash
./scripts/95copy.sh --build
```

### Lỗi upload
```bash
# Check SSH
ssh root@116.118.48.208
```

### Lỗi Docker
```bash
# Check logs
ssh root@116.118.48.208 'cd /root/innerbright && docker compose logs innerbright-web'
```

## 📚 Documentation

- [DEPLOYMENT.md](./DEPLOYMENT.md) - Hướng dẫn chi tiết
- [DOCKER.md](./DOCKER.md) - Docker configuration
- [README.md](./README.md) - Project overview

---

**Quick Links**:
- Production: http://116.118.48.208:14000
- Local: http://localhost:14000
