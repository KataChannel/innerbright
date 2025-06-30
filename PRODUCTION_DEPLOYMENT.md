# KataCore Production Deployment Guide

## 🚀 Quick Start

### Local Production Deployment
```bash
# 1. Copy environment configuration
cp .env.prod.example .env.prod

# 2. Edit configuration
nano .env.prod

# 3. Deploy locally
bun run deploy:local
```

### Remote Cloud Deployment
```bash
# 1. Set server details
export SERVER_HOST=your-server-ip
export SERVER_USER=root

# 2. Deploy to remote server
bun run deploy:remote
```

## 📋 Prerequisites

### Local Requirements
- Docker & Docker Compose
- Bun.js
- Git

### Remote Server Requirements
- Ubuntu 20.04+ / CentOS 8+ / Debian 11+
- 4GB+ RAM
- 20GB+ storage
- SSH access

## 🏗️ Architecture

### Services Stack
- **Frontend**: Next.js (Port 3000)
- **API**: NestJS with Bun (Port 3001)
- **Database**: PostgreSQL 16 (Port 5432)
- **Cache**: Redis 7 (Port 6379)
- **Storage**: MinIO (Port 9000/9001)
- **Admin**: pgAdmin (Port 8080)
- **Proxy**: Nginx (Port 80/443)

### Docker Containers
```
katacore-nginx-prod        # Reverse proxy & SSL termination
katacore-site-prod         # Next.js frontend
katacore-api-prod          # NestJS API backend
katacore-postgres-prod     # PostgreSQL database
katacore-redis-prod        # Redis cache
katacore-minio-prod        # MinIO object storage
katacore-pgadmin-prod      # Database admin panel
```

## ⚙️ Configuration

### Environment Variables (.env.prod)
```bash
# Database
POSTGRES_DB=katacore_prod
POSTGRES_USER=your_user
POSTGRES_PASSWORD=secure_password

# Redis
REDIS_PASSWORD=secure_redis_password

# MinIO
MINIO_ROOT_USER=minio_admin
MINIO_ROOT_PASSWORD=secure_minio_password

# API
JWT_SECRET=your_super_secret_jwt_key
CORS_ORIGIN=https://yourdomain.com

# Domains
DOMAIN=yourdomain.com
API_DOMAIN=api.yourdomain.com
ADMIN_DOMAIN=admin.yourdomain.com
STORAGE_DOMAIN=storage.yourdomain.com
```

### Domain Setup
1. **Main Site**: `https://yourdomain.com`
2. **API**: `https://api.yourdomain.com`
3. **Admin Panel**: `https://admin.yourdomain.com`
4. **Storage Console**: `https://storage.yourdomain.com`

## 🔒 SSL Configuration

### Option 1: Let's Encrypt (Recommended)
```bash
# Install certbot
sudo apt update && sudo apt install certbot

# Generate certificates
sudo certbot certonly --standalone \
  -d yourdomain.com \
  -d www.yourdomain.com \
  -d api.yourdomain.com \
  -d admin.yourdomain.com \
  -d storage.yourdomain.com

# Copy certificates
sudo cp /etc/letsencrypt/live/yourdomain.com/fullchain.pem ssl/
sudo cp /etc/letsencrypt/live/yourdomain.com/privkey.pem ssl/
```

### Option 2: Self-Signed (Development)
```bash
# Auto-generated during deployment
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout ssl/privkey.pem \
  -out ssl/fullchain.pem
```

## 🚀 Deployment Commands

### Initial Deployment
```bash
# Local deployment
bun run deploy:local

# Remote deployment
SERVER_HOST=your-server-ip bun run deploy:remote
```

### Management Commands
```bash
# View logs
bun run logs

# Monitor services
bun run monitor

# Check status
bun run monitor:status

# Backup database
bun run backup

# Restart services
docker-compose -f docker-compose.prod.yml restart
```

## 📊 Monitoring & Health Checks

### Health Check Endpoints
- **Nginx**: `http://localhost/health`
- **API**: `http://localhost:3001/health`
- **Frontend**: `http://localhost:3000`

### Monitoring Script
```bash
# Single health check
./scripts/monitor.sh --check

# Continuous monitoring
./scripts/monitor.sh --monitor

# Auto-recovery
./scripts/monitor.sh --recover
```

## 💾 Backup & Recovery

### Automated Backups
- **Schedule**: Daily at 2 AM (configurable)
- **Retention**: 7 days (configurable)
- **Location**: `./backups/`

### Manual Backup
```bash
# Create backup
bun run backup

# List backups
ls -la backups/
```

### Recovery
```bash
# Stop services
docker-compose -f docker-compose.prod.yml down

# Restore from backup
docker exec -i katacore-postgres-prod psql -U postgres -d katacore < backups/backup_file.sql

# Start services
docker-compose -f docker-compose.prod.yml up -d
```

## 🔧 Troubleshooting

### Common Issues

#### Container Not Starting
```bash
# Check logs
docker-compose -f docker-compose.prod.yml logs [service_name]

# Check container status
docker ps -a

# Restart specific service
docker-compose -f docker-compose.prod.yml restart [service_name]
```

#### Database Connection Issues
```bash
# Check database health
docker exec katacore-postgres-prod pg_isready -U postgres

# Check connection from API
docker exec katacore-api-prod bun run prisma db push
```

#### SSL Issues
```bash
# Test SSL configuration
nginx -t

# Check certificate validity
openssl x509 -in ssl/fullchain.pem -text -noout
```

### Performance Tuning

#### PostgreSQL
```sql
-- Optimize for production
ALTER SYSTEM SET shared_buffers = '256MB';
ALTER SYSTEM SET effective_cache_size = '1GB';
ALTER SYSTEM SET maintenance_work_mem = '64MB';
SELECT pg_reload_conf();
```

#### Redis
```bash
# Check memory usage
docker exec katacore-redis-prod redis-cli info memory
```

## 🔒 Security

### Firewall Configuration
```bash
# UFW (Ubuntu)
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 80/tcp    # HTTP
sudo ufw allow 443/tcp   # HTTPS
sudo ufw enable

# iptables
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT
```

### Access Control
- **Admin Panel**: IP whitelist recommended
- **MinIO Console**: Secure credentials
- **Database**: Internal network only

## 📈 Scaling

### Horizontal Scaling
```yaml
# docker-compose.prod.yml
api:
  deploy:
    replicas: 3
  
nginx:
  volumes:
    - ./nginx/upstream.conf:/etc/nginx/conf.d/upstream.conf
```

### Vertical Scaling
```yaml
# Increase resources
services:
  postgres:
    deploy:
      resources:
        limits:
          memory: 2G
        reservations:
          memory: 1G
```

## 📞 Support

### Logs Location
- **Application**: `docker-compose logs`
- **Nginx**: `./nginx/logs/`
- **System**: `/var/log/katacore-monitor.log`

### Health Check URLs
- **Main**: `https://yourdomain.com/health`
- **API**: `https://api.yourdomain.com/health`

### Emergency Commands
```bash
# Emergency stop
docker-compose -f docker-compose.prod.yml down

# Emergency restart
docker-compose -f docker-compose.prod.yml restart

# Emergency backup
docker exec katacore-postgres-prod pg_dump -U postgres katacore > emergency_backup.sql
```

## 🔄 Updates

### Application Updates
```bash
# Pull latest code
git pull origin main

# Rebuild and deploy
bun run deploy:local
```

### System Updates
```bash
# Update base images
docker-compose -f docker-compose.prod.yml pull

# Rebuild custom images
bun run docker:prod:build
```

---

**For additional support, check the monitoring logs or contact the development team.**
