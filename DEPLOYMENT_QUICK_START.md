# 🚀 Innerbright Unified Deployment Guide

## Overview
Unified deployment system supporting both prebuilt and build modes with flexible service profiles for 2GB server optimization.

## 📁 Merged Files Overview

### ✅ **docker-compose.yml** (Unified)
- **All services**: PostgreSQL, Redis, MinIO, PgAdmin, Site
- **Resource optimization**: Configurable memory limits for 2GB server
- **Service profiles**: default, redis, minio, pgladmin, full
- **Environment variables**: Comprehensive configuration support

### ✅ **Dockerfile** (Multi-stage)
- **Prebuilt mode**: Ultra-lightweight runtime (recommended)
- **Build mode**: Full build capability with memory optimization
- **Conditional copying**: Based on BUILD_MODE argument

### ✅ **deploy-unified.sh** (All-in-one)
- **Flexible deployment**: Support all modes and profiles
- **Auto-detection**: Smart build validation
- **Resource monitoring**: Real-time stats
- **Error handling**: Comprehensive validation

## 🎯 Quick Start

### 1. **Minimal Setup (Recommended for 2GB)**
```bash
# Prebuilt mode with PostgreSQL only
./deploy-unified.sh

# Or with environment file
cp .env.example .env  # Edit with your values
./deploy-unified.sh
```

### 2. **With Additional Services**
```bash
# Add Redis cache
./deploy-unified.sh --profile redis

# Add MinIO storage  
./deploy-unified.sh --profile minio

# Add PgAdmin interface
./deploy-unified.sh --profile pgadmin

# All services
./deploy-unified.sh --profile full
```

### 3. **Advanced Options**
```bash
# Show help
./deploy-unified.sh --help

# Build mode (requires more server resources)
./deploy-unified.sh --mode build --profile full

# Skip local build (use existing .next)
./deploy-unified.sh --skip-build

# Custom server
./deploy-unified.sh --server 192.168.1.100
```

## 📊 Resource Allocation (2GB Server Optimized)

### **Default Profile** (Total: ~600MB)
- PostgreSQL: 200MB
- Next.js App: 400MB
- **Buffer**: 1.4GB remaining

### **Redis Profile** (+128MB)
- Adds Redis cache with 64MB memory limit

### **MinIO Profile** (+256MB) 
- Adds object storage with 256MB limit

### **Full Profile** (Total: ~1.4GB)
- All services with optimized limits
- Perfect for 2GB server with 600MB buffer

## Result

- 🌐 **Website**: http://116.118.48.208:3000
- 🌐 **Domain**: http://innerbright.vn (if configured)
- 📊 **MinIO Console**: http://116.118.48.208:9001 (if enabled)
- 🛠️ **PgAdmin**: http://116.118.48.208:5050 (if enabled)

## Requirements

- SSH access to server
- Docker installed on server  
- Bun/Node.js locally for prebuilt mode

## Troubleshooting

```bash
# Check logs
ssh root@116.118.48.208 'cd /root/innerbright && docker-compose -f docker-compose.prebuilt.yml logs'

# Restart
ssh root@116.118.48.208 'cd /root/innerbright && docker-compose -f docker-compose.prebuilt.yml restart'
```

See `DEPLOY_GUIDE.md` for detailed documentation.

---

**Previous files backed up:**
- `build-local.sh.backup`
- `deploy-prebuilt-simple.sh.backup`
