# InnerBright Next.js - Docker Deployment

## Quick Start

### Deploy với Docker Compose

```bash
# Cách 1: Sử dụng script deploy tự động
./deploy.sh

# Cách 2: Manual commands
docker-compose build innerbright-web
docker-compose up -d innerbright-web
```

### Truy cập ứng dụng

- **Web Application**: http://localhost:14000
- **Database**: localhost:14003 (PostgreSQL)
- **PgAdmin**: http://localhost:14002
- **Redis**: localhost:14004

## Docker Commands

### Build & Start
```bash
# Build image
docker-compose build innerbright-web

# Start container
docker-compose up -d innerbright-web

# Start tất cả services
docker-compose up -d
```

### View Logs
```bash
# View logs real-time
docker-compose logs -f innerbright-web

# View last 100 lines
docker-compose logs --tail=100 innerbright-web
```

### Stop & Remove
```bash
# Stop container
docker-compose stop innerbright-web

# Remove container
docker-compose down innerbright-web

# Remove tất cả (bao gồm volumes)
docker-compose down -v
```

### Restart
```bash
# Restart container
docker-compose restart innerbright-web

# Rebuild và restart
docker-compose up -d --build innerbright-web
```

## Environment Variables

Tạo file `.env` để customize:

```env
# Application
NODE_ENV=production
PORT=3000

# Database (nếu cần)
DATABASE_URL=postgresql://postgres:postgres@postgres:5432/innerv2core

# Redis (nếu cần)
REDIS_URL=redis://:123456@redis:6379
```

## Health Check

Container có health check tự động:
- Kiểm tra mỗi 30 giây
- Timeout 10 giây
- Retry 3 lần
- Start period 40 giây

Xem status:
```bash
docker-compose ps
```

## Troubleshooting

### Container không start
```bash
# Xem logs
docker-compose logs innerbright-web

# Xem logs chi tiết
docker logs innerbright-nextjs
```

### Port 14000 đã được sử dụng
Sửa port trong `docker-compose.yml`:
```yaml
ports:
  - "14001:3000"  # Đổi sang port khác
```

### Rebuild sau khi thay đổi code
```bash
docker-compose up -d --build innerbright-web
```

## Production Checklist

- [x] Output mode: standalone
- [x] Multi-stage build (giảm image size)
- [x] Non-root user (security)
- [x] Health check
- [x] Auto-restart policy
- [x] .dockerignore (tối ưu build context)
- [x] Network isolation

## Technical Stack

- **Base Image**: oven/bun:1
- **Framework**: Next.js 16.0.1 with Turbopack
- **Package Manager**: Bun
- **Port**: 14000 (external) → 3000 (internal)
- **Network**: innerv2core-network

## File Structure

```
.
├── Dockerfile              # Multi-stage Docker build
├── docker-compose.yml      # Services orchestration
├── .dockerignore          # Build optimization
├── deploy.sh              # Deployment script
├── next.config.ts         # Next.js config (standalone)
└── DOCKER.md             # This file
```
