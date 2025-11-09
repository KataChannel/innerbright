# 🚀 InnerBright Deployment Guide

## Quick Deploy Commands

```bash
# 📦 Quick Deploy (recommended)
./scripts/95copy.sh

# 🔨 Deploy with fresh build
./scripts/95copy.sh --build

# ♻️ Just restart services
./scripts/95copy.sh --restart

# ✅ Verify build before deploy
./scripts/95copy.sh --verify

# 🩹 Fix mode (critical files only)
./scripts/95copy.sh --fix
```

## 🐛 Troubleshooting

### If deployment fails or hangs:

```bash
# 1. Run diagnostics
./scripts/debug-deploy.sh

# 2. Check specific issues
./scripts/debug-deploy.sh ssh      # SSH connection
./scripts/debug-deploy.sh docker   # Docker on server  
./scripts/debug-deploy.sh network  # Network connectivity
./scripts/debug-deploy.sh status   # Current deployment
```

### Quick Fixes:

```bash
# ❌ Build missing
bun run build

# ❌ Symlink missing  
ln -s . frontend

# ❌ SSH issues
ssh-add ~/.ssh/id_rsa

# ❌ Server hanging
ssh root@116.118.48.208 'docker system prune -af'

# ❌ Force redeploy
./scripts/95copy.sh --build
```

## 📊 Deployment Status

- **Website**: http://116.118.48.208:14000
- **Deploy Time**: ~1-2 minutes
- **Build Size**: 1377 files (~14MB)

## ⚡ Performance Features

- ✅ Optimized rsync with excludes (10min timeout)
- ✅ Docker build timeout controls (5min)
- ✅ Multi-stage Docker builds
- ✅ Standalone Next.js output
- ✅ Health checks & error handling

## Prerequisites

1. **Build output exists** (.next/standalone, .next/static, public)
2. **SSH access** to server (root@116.118.48.208)  
3. **Docker & Docker Compose** installed on server
4. **Rsync** installed locally

## 📋 Detailed Commands

### 1. Deploy with fresh build
```bash
./scripts/95copy.sh --build
```
- ✅ Build Next.js application với Bun
- ✅ Verify build output
- ✅ Upload lên server qua rsync (timeout: 10min)
- ✅ Rebuild và restart Docker container (timeout: 5min)
- ✅ Health check & show deployment summary

### 2. Deploy existing build (fast)
```bash
./scripts/95copy.sh
```
- ✅ Verify build output có sẵn
- ✅ Upload lên server (optimized rsync)
- ✅ Restart Docker container

### 3. Verify build only
```bash
./scripts/95copy.sh --verify
```
- ✅ Check local build completeness
- ✅ Show build statistics  
- ⚠️ No deployment performed

### 4. Fix mode (emergency)
```bash
./scripts/95copy.sh --fix
```
Deploy critical files only:
- frontend/.next/standalone/
- frontend/.next/static/
- frontend/public/
## 🔄 Deployment Flow

```
┌─────────────────┐
│  Local Machine  │
└────────┬────────┘
         │ 1. Build (optional)
         │ 2. Verify
         │ 3. Rsync (10min timeout)
         ▼
┌─────────────────────────────┐
│  Server: 116.118.48.208     │
│  Directory: /root/innerbright │
└────────┬────────────────────┘
         │ 4. Docker rebuild (5min timeout)
         │ 5. Container restart
         │ 6. Health check
         ▼
┌─────────────────────────────┐
│  http://116.118.48.208:14000 │
│  InnerBright Application    │
└─────────────────────────────┘
```

## 📁 File Structure

### Local (after build)
```
/chikiet/kata2025/blognextjsfullstack/
├── frontend/              # Symlink to current directory
│   ├── .next/
│   │   ├── standalone/   # Node.js server files (1377 files)
│   │   └── static/       # Static assets (22 files)
│   └── public/           # Public assets (14 files)
├── scripts/
│   ├── 95copy.sh        # Main deployment script
│   └── debug-deploy.sh  # Debug & diagnostics tool
└── docker-compose.yml   # Docker config
```

### Remote (on server)
```
/root/innerbright/
├── frontend/
│   ├── .next/
│   │   ├── standalone/  # Ready-to-run Node.js app
│   │   └── static/      # Optimized static assets
│   └── public/          # Images, fonts, etc.
├── docker-compose.yml   # Service orchestration
└── Dockerfile          # Container definition
```

## 🐳 Docker Services

After deployment, these containers will be running:

### InnerBright Web (Port 14000)
```bash
# Check status
docker compose ps innerbright-web

# View logs  
docker compose logs -f innerbright-web

# Health check
curl -s http://116.118.48.208:14000
```

### PostgreSQL (Port 14003)
```bash
# Check database
docker compose ps postgres
docker compose logs postgres
```

### Redis (Port 14004) 
```bash
# Check cache
docker compose ps redis
docker compose logs redis
```

### PgAdmin (Port 14002)
```bash
# Web interface
docker compose ps pgadmin
# Access: http://116.118.48.208:14002
```

## ⚠️ Troubleshooting

### 🚨 Common Issues

#### ❌ Missing build output
```bash
# Solution: Build first
bun run build
./scripts/95copy.sh --verify
```

#### ❌ SSH connection failed  
```bash
# Test connection
./scripts/debug-deploy.sh ssh

# Manual test
ssh root@116.118.48.208

# Check SSH key
ssh-add ~/.ssh/id_rsa
```

#### ❌ Deployment hangs
```bash
# Use debug tool
./scripts/debug-deploy.sh

# Check server resources
./scripts/debug-deploy.sh status

# Force kill hanging processes
ssh root@116.118.48.208 'pkill -f rsync; pkill -f docker'
```

#### ❌ Docker services won't start
```bash
# Check server manually
ssh root@116.118.48.208
cd /root/innerbright

# View all services
docker compose ps

# Check specific logs
docker compose logs innerbright-web
docker compose logs postgres

# Restart all services
docker compose down && docker compose up -d
```

#### ❌ Port 14000 not accessible
```bash
# Check if service is bound to port
ssh root@116.118.48.208 'netstat -tulpn | grep 14000'

# Check firewall
ssh root@116.118.48.208 'ufw status'

# Open port if needed
ssh root@116.118.48.208 'ufw allow 14000/tcp'
```
ssh root@116.118.48.208 'cd /root/innerbright && docker compose logs innerbright-web --tail 100'

# Rebuild container
ssh root@116.118.48.208 'cd /root/innerbright && docker compose up -d --build innerbright-web'
```

## Build Output Verification

Script sẽ tự động verify các files sau tồn tại:

✅ **frontend/.next/standalone/** (~1377 files)
- Node.js server files
- Dependencies
- Application code

## ✅ Build Output Details

✅ **frontend/.next/standalone/** (~1377 files)
- Node.js server files
- Required dependencies
- Application runtime

✅ **frontend/.next/static/** (~22 files)
- CSS files (optimized)
- JS chunks (code-split)
- Build manifests & maps

✅ **frontend/public/** (~14 files)
- Static assets
- Images, fonts, icons
- PWA manifest.json

## 🚫 Rsync Excludes

Script automatically excludes:
- `node_modules/` (dependencies)
- `.git/`, `.github/` (version control)
- `.next/cache/` (build cache)
- `.vscode/`, `.idea/` (editor files)
- `.env*` files (security)
- `*.log` files (logs)
- Temporary & backup files

## 🌐 Production URLs

After successful deployment:

| Service | URL | Status |
|---------|-----|---------|
| **Web App** | http://116.118.48.208:14000 | 🟢 Primary |
| **PgAdmin** | http://116.118.48.208:14002 | 🟡 Admin |
| **PostgreSQL** | 116.118.48.208:14003 | 🔵 Database |
| **Redis** | 116.118.48.208:14004 | 🟠 Cache |

## 🔧 Advanced Usage

### Custom deployment target
```bash
# Edit scripts/95copy.sh variables:
SERVER_IP="your-server-ip"
SERVER_USER="your-user"  
REMOTE_DIR="/your/deploy/path"
```

### Monitor deployment
```bash
# Real-time logs
ssh root@116.118.48.208 'cd /root/innerbright && docker compose logs -f innerbright-web'

# System resources
ssh root@116.118.48.208 'htop'

# Disk usage
ssh root@116.118.48.208 'df -h; docker system df'
```

### Performance tuning
```bash
# Clean up Docker images
ssh root@116.118.48.208 'docker system prune -af'

# Restart with fresh build
./scripts/95copy.sh --build

# Emergency quick fix
./scripts/95copy.sh --fix
```

---

## 📞 Support

**🐛 Deployment issues?**
```bash
./scripts/debug-deploy.sh
```

**⚡ Need fast deploy?**
```bash
./scripts/95copy.sh --fix
```

**🔍 Want to check everything?**
```bash
./scripts/debug-deploy.sh all
```

*Latest update: Optimized for 116.118.48.208 with timeout controls*
docker compose logs -f innerbright-web
```

### Rollback deployment
```bash
# SSH to server and restore from backup
ssh root@116.118.48.208
cd /root/innerbright
# Restore previous version
# Then restart
docker compose up -d --build innerbright-web
```

## Security Notes

1. **Environment Variables**: .env files are excluded from rsync
2. **SSH Keys**: Use SSH keys instead of passwords
3. **Server Access**: Only authorized users should have SSH access
4. **Docker Security**: Containers run as non-root users

## Performance

| Task | Time |
|------|------|
| Build (Bun) | ~6s |
| Verify | <1s |
| Rsync upload | ~10-30s (depends on files changed) |
| Docker rebuild | ~30-60s |
| **Total** | ~1-2 minutes |

## Support

For issues or questions:
1. Check logs: `docker compose logs innerbright-web`
2. Verify build: `./scripts/95copy.sh --verify`
3. Try fix mode: `./scripts/95copy.sh --fix`
4. Rebuild: `./scripts/95copy.sh --build`

---

**Last Updated**: 2025-01-09
**Script Version**: 95copy.sh
**Project**: InnerBright Training & Coaching
