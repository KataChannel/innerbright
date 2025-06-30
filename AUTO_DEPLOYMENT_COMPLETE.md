# KataCore Auto Deployment System - Complete Setup

## 🎯 Overview

Đã hoàn thiện hệ thống auto deployment cho KataCore với Docker Compose bao gồm:
- **PostgreSQL 16** - Database chính
- **Redis 7** - Cache và session store  
- **MinIO** - Object storage (S3 compatible)
- **PgAdmin** - Database management
- **Nginx** - Reverse proxy và SSL termination
- **NestJS API** - Backend với Bun.js
- **Next.js Site** - Frontend React application

## 📁 Files Created/Updated

### Docker Configuration
- `docker-compose.prod.yml` - Production Docker Compose
- `.env.prod.example` - Environment variables template
- `nginx/conf.d/katacore.prod.conf` - Production Nginx config

### Deployment Scripts
- `scripts/deploy-cloud.sh` - Main deployment script (local/remote)
- `scripts/backup.sh` - Database backup automation
- `scripts/monitor.sh` - Health monitoring and alerts
- `scripts/test-deploy.sh` - Test deployment locally

### CI/CD Pipeline
- `.github/workflows/deploy.yml` - GitHub Actions workflow
- Auto build, test, and deploy on push/PR

### Documentation
- `PRODUCTION_DEPLOYMENT.md` - Complete deployment guide

## 🚀 Quick Start Commands

### Local Development
```bash
# Test build
bun run test-deploy

# Start development
bun run dev

# Build for production
bun run build
```

### Production Deployment

#### Local Production Test
```bash
# Copy environment config
cp .env.prod.example .env.prod

# Edit configuration
nano .env.prod

# Test deployment locally
bun run deploy:local
```

#### Remote Cloud Deployment
```bash
# Set server details
export SERVER_HOST=your-server-ip
export SERVER_USER=root

# Deploy to remote server
bun run deploy:remote
```

### Management Commands
```bash
# Monitor services
bun run monitor

# Check status
bun run monitor:status

# View logs
bun run logs

# Backup database
bun run backup

# Restart services
docker-compose -f docker-compose.prod.yml restart
```

## 🏗️ Architecture

### Service Stack
```
Nginx (80/443) → Frontend (3000) + API (3001)
                 ↓
PostgreSQL (5432) + Redis (6379) + MinIO (9000/9001)
                 ↓
PgAdmin (8080) for database management
```

### Container Names (Production)
- `katacore-nginx-prod` - Reverse proxy
- `katacore-site-prod` - Next.js frontend  
- `katacore-api-prod` - NestJS API
- `katacore-postgres-prod` - PostgreSQL database
- `katacore-redis-prod` - Redis cache
- `katacore-minio-prod` - MinIO storage
- `katacore-pgadmin-prod` - Database admin

## ⚙️ Configuration

### Environment Variables (.env.prod)
```bash
# Database
POSTGRES_DB=katacore_prod
POSTGRES_USER=your_user
POSTGRES_PASSWORD=secure_password

# Redis
REDIS_PASSWORD=secure_redis_password

# MinIO Object Storage
MINIO_ROOT_USER=minio_admin
MINIO_ROOT_PASSWORD=secure_minio_password

# API Configuration
JWT_SECRET=your_super_secret_jwt_key
CORS_ORIGIN=https://yourdomain.com

# Frontend
NEXT_PUBLIC_API_URL=https://api.yourdomain.com

# Domain Setup
DOMAIN=yourdomain.com
API_DOMAIN=api.yourdomain.com
ADMIN_DOMAIN=admin.yourdomain.com
STORAGE_DOMAIN=storage.yourdomain.com
```

### Multi-Domain Setup
1. **Main Site**: `https://yourdomain.com`
2. **API Endpoint**: `https://api.yourdomain.com`  
3. **Admin Panel**: `https://admin.yourdomain.com`
4. **Storage Console**: `https://storage.yourdomain.com`

## 🔒 Security Features

### SSL/TLS Configuration
- Let's Encrypt integration
- Self-signed certificates for development
- HTTP to HTTPS redirects
- Security headers (HSTS, CSP, etc.)

### Access Control
- Rate limiting (API: 10r/s, General: 1r/s)
- IP whitelisting for admin panels
- Firewall configuration scripts
- Container isolation

### Backup & Recovery
- Automated daily backups (2 AM)
- 7-day retention policy
- Compressed SQL dumps
- One-click restore process

## 📊 Monitoring & Health Checks

### Health Endpoints
- **Nginx**: `http://localhost/health`
- **API**: `http://localhost:3001/health`
- **Frontend**: `http://localhost:3000`

### Monitoring Script Features
- Container health checks
- Service endpoint testing
- Resource usage monitoring
- Auto-recovery capabilities
- Alert notifications (Slack/Discord/Email)

### Log Management
- Centralized logging with JSON format
- Log rotation (10MB files, 3 file retention)
- Service-specific log access
- Real-time log streaming

## 🔄 CI/CD Pipeline

### GitHub Actions Workflow
1. **Build & Test** - Bun build, tests, lint
2. **Docker Build** - Multi-arch image builds
3. **Security Scan** - Trivy vulnerability scanning
4. **Staging Deploy** - Auto deploy to staging
5. **Production Deploy** - Manual approval required

### Deployment Stages
- **Development** - Local development with hot reload
- **Staging** - Auto deploy from main branch
- **Production** - Manual trigger with approval

## 🛠️ Troubleshooting

### Common Issues

#### Container Not Starting
```bash
# Check logs
docker-compose -f docker-compose.prod.yml logs [service]

# Check container status  
docker ps -a

# Restart service
docker-compose -f docker-compose.prod.yml restart [service]
```

#### Database Connection Issues
```bash
# Check database health
docker exec katacore-postgres-prod pg_isready -U postgres

# Run migrations
docker-compose -f docker-compose.prod.yml up prisma-migrate
```

#### SSL Certificate Issues
```bash
# Test Nginx config
docker exec katacore-nginx-prod nginx -t

# Regenerate certificates
./scripts/deploy-cloud.sh --local
```

### Performance Optimization

#### Database Tuning
- Shared buffers: 256MB
- Effective cache size: 1GB
- Connection pooling via Prisma

#### Redis Configuration  
- Memory optimization
- Persistence settings
- Connection limits

#### Nginx Optimization
- Gzip compression
- Static file caching
- Connection keep-alive
- Worker process tuning

## 📈 Scaling Options

### Horizontal Scaling
```yaml
# docker-compose.prod.yml
services:
  api:
    deploy:
      replicas: 3
    
  nginx:
    volumes:
      - ./nginx/upstream.conf:/etc/nginx/conf.d/upstream.conf
```

### Load Balancing
- Nginx upstream configuration
- Health check integration
- Session stickiness options
- Auto-scaling with Docker Swarm

### Database Scaling
- Read replicas setup
- Connection pooling
- Query optimization
- Index management

## 🔧 Maintenance

### Regular Tasks
- **Daily**: Automated backups
- **Weekly**: Security updates
- **Monthly**: Performance review
- **Quarterly**: Disaster recovery testing

### Update Process
```bash
# Update application
git pull origin main
bun run deploy:local

# Update base images
docker-compose -f docker-compose.prod.yml pull
docker-compose -f docker-compose.prod.yml up -d
```

### Backup & Restore
```bash
# Manual backup
bun run backup

# Restore from backup
docker exec -i katacore-postgres-prod psql -U postgres -d katacore < backup.sql
```

## 📞 Support & Emergency

### Emergency Commands
```bash
# Emergency stop
docker-compose -f docker-compose.prod.yml down

# Emergency restart
docker-compose -f docker-compose.prod.yml restart

# Emergency backup
docker exec katacore-postgres-prod pg_dump -U postgres katacore > emergency.sql
```

### Log Locations
- **Application**: `docker-compose logs`
- **Nginx**: `./nginx/logs/`
- **System**: `/tmp/katacore-monitor.log`

### Contact Information
- **Development Team**: [Your team contact]
- **Infrastructure**: [Your infrastructure contact]
- **Emergency**: [Emergency contact]

---

## ✅ Deployment Checklist

### Pre-deployment
- [ ] Environment variables configured
- [ ] SSL certificates ready
- [ ] DNS records updated
- [ ] Firewall rules configured
- [ ] Backup strategy in place

### Post-deployment
- [ ] Health checks passing
- [ ] SSL certificates valid
- [ ] Monitoring alerts configured
- [ ] Backup job scheduled
- [ ] Documentation updated

### Go-Live
- [ ] Performance testing completed
- [ ] Security scan passed
- [ ] Team training completed
- [ ] Rollback plan ready
- [ ] Success metrics defined

---

**🎉 KataCore Auto Deployment System is now ready for production use!**

For additional support or questions, refer to `PRODUCTION_DEPLOYMENT.md` or contact the development team.
