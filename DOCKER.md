# � Innerbright Cloud Deployment Guide

## 📋 Tổng quan

Dự án Innerbright được thiết kế để triển khai tối ưu trên cloud server với:

### 🏗️ Kiến trúc
- **Frontend**: Next.js 14+ với App Router
- **Backend**: NestJS API với TypeScript  
- **Database**: PostgreSQL 15 với optimizations
- **Storage**: MinIO cho object storage
- **Cache**: Redis (optional)
- **Proxy**: Nginx reverse proxy
- **Monitoring**: Health checks tự động

### ✨ Tính năng tối ưu hóa
- ✅ **Multi-stage Docker builds** giảm 70% image size
- ✅ **Health checks** tự động với recovery
- ✅ **Resource limits** để tránh memory leaks
- ✅ **Log rotation** tự động
- ✅ **Security headers** và rate limiting
- ✅ **SSL/TLS** ready với Let's Encrypt
- ✅ **Zero-downtime deployments**
- ✅ **Database migrations** tự động
- ✅ **Backup & restore** scripts

## 🚀 Quick Start

### 1. Clone và Setup
```bash
git clone <repository>
cd innerbright

# Copy environment template
cp .env.example .env

# Update environment variables
nano .env
```

### 2. Development Deployment
```bash
# Start all services
./docker-dev.sh

# Or manually
docker-compose --profile dev up -d
```

### 3. Production Deployment
```bash
# Deploy to production
./deploy-production.sh

# Or with specific profile
docker-compose --profile proxy up -d
```

## 🔧 Environment Configuration

### Production Environment Variables
```bash
# Database
POSTGRES_DB=innerbright
POSTGRES_USER=postgres
POSTGRES_PASSWORD=your_secure_password
POSTGRES_PORT=5432

# Application
NEXTJS_PORT=3000
NESTJS_PORT=3333
NEXTAUTH_SECRET=your_32_char_secret
NEXTAUTH_URL=https://yourdomain.com
JWT_SECRET=your_jwt_secret

# Storage
MINIO_ACCESS_KEY=your_minio_key
MINIO_SECRET_KEY=your_minio_secret

# SSL (Optional)
HTTPS_PORT=443
SSL_CERT_PATH=/etc/letsencrypt/live/yourdomain.com
```

## 🌐 Cloud Server Setup

### Minimum Requirements
- **CPU**: 2 cores
- **RAM**: 4GB
- **Storage**: 20GB SSD
- **OS**: Ubuntu 20.04+ / CentOS 8+ / Debian 11+

### Recommended for Production
- **CPU**: 4+ cores
- **RAM**: 8GB+
- **Storage**: 50GB+ SSD
- **Network**: 1Gbps

### Server Preparation
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install Docker Compose
sudo apt install docker-compose-plugin

# Create project directory
sudo mkdir -p /opt/innerbright
sudo chown $USER:$USER /opt/innerbright

# Clone project
cd /opt/innerbright
git clone <repository> .
```

## 🔒 Security Setup

### 1. SSL Certificate (Let's Encrypt)
```bash
# Install Certbot
sudo apt install certbot

# Get certificate
sudo certbot certonly --webroot \
  -w /opt/innerbright/certbot/www \
  -d yourdomain.com

# Auto-renewal
echo "0 12 * * * /usr/bin/certbot renew --quiet" | sudo crontab -
```

### 2. Firewall Configuration
```bash
# Enable UFW
sudo ufw enable

# Allow SSH
sudo ufw allow ssh

# Allow HTTP/HTTPS
sudo ufw allow 80
sudo ufw allow 443

# Allow specific ports if needed
sudo ufw allow 3000  # Next.js (if direct access needed)
sudo ufw allow 3333  # NestJS API (if direct access needed)
```

### 3. Security Hardening
```bash
# Disable root login
sudo sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config

# Change SSH port (recommended)
sudo sed -i 's/#Port 22/Port 2222/' /etc/ssh/sshd_config

# Restart SSH
sudo systemctl restart ssh
```

## � Monitoring & Management

### Service Management
```bash
# Check service status
./manage.sh status

# View logs
./manage.sh logs [service_name]

# Health checks
./manage.sh health

# Database backup
./manage.sh backup

# Restore database
./manage.sh restore backup_file.sql
```

### Resource Monitoring
```bash
# Real-time resource usage
docker stats

# Disk usage
docker system df

# Service logs
docker-compose logs -f --tail=100 [service]
```

## � CI/CD Deployment

### GitHub Actions Setup
1. **Repository Secrets** (Settings → Secrets):
   ```
   PRODUCTION_HOST=your.server.ip
   PRODUCTION_USER=ubuntu
   PRODUCTION_SSH_KEY=your_private_key
   PRODUCTION_PORT=22
   SLACK_WEBHOOK_URL=your_slack_webhook (optional)
   ```

2. **Server Setup**:
   ```bash
   # Add GitHub Actions public key to server
   echo "ssh-rsa AAAA..." >> ~/.ssh/authorized_keys
   
   # Setup deployment directory
   sudo mkdir -p /opt/innerbright
   sudo chown $USER:$USER /opt/innerbright
   ```

3. **Auto Deployment**:
   - Push to `main` branch triggers deployment
   - Zero-downtime rolling updates
   - Automatic rollback on failure

## 🗄️ Database Management

### Backup Strategy
```bash
# Daily automated backup
echo "0 2 * * * cd /opt/innerbright && ./manage.sh backup" | crontab -

# Manual backup
./manage.sh backup

# Backup with compression
docker-compose exec postgres pg_dump -U postgres innerbright | gzip > backup_$(date +%Y%m%d).sql.gz
```

### Performance Optimization
PostgreSQL is configured with optimized settings:
- `shared_buffers=256MB`
- `effective_cache_size=1GB`
- `work_mem=4MB`
- `maintenance_work_mem=64MB`
- Connection pooling ready

## � Troubleshooting

### Common Issues

#### 1. Service Won't Start
```bash
# Check logs
./manage.sh logs [service]

# Check container status
docker-compose ps

# Restart specific service
docker-compose restart [service]
```

#### 2. Database Connection Issues
```bash
# Check PostgreSQL status
./manage.sh db

# Verify connection string
docker-compose exec nextjs env | grep DATABASE_URL

# Reset database (⚠️ Data loss)
docker-compose down
docker volume rm innerbright_postgres_data
docker-compose up -d
```

#### 3. Memory Issues
```bash
# Check memory usage
free -h
docker stats

# Increase swap if needed
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

#### 4. SSL Certificate Issues
```bash
# Check certificate status
sudo certbot certificates

# Renew certificate
sudo certbot renew

# Test configuration
nginx -t
```

## 📈 Performance Optimization

### 1. Database Optimization
```sql
-- Enable extensions
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

-- Monitor slow queries
SELECT query, calls, total_time, mean_time 
FROM pg_stat_statements 
ORDER BY total_time DESC LIMIT 10;
```

### 2. Nginx Optimization
- Gzip compression enabled
- Static file caching (1 year)
- Rate limiting configured
- Connection pooling

### 3. Application Optimization
- Next.js standalone output
- Node.js production mode
- Environment variable optimization
- Health check endpoints

## 🔧 Advanced Configuration

### Load Balancing (Multiple Servers)
```yaml
# docker-compose.override.yml
services:
  nginx:
    volumes:
      - ./nginx/nginx-lb.conf:/etc/nginx/nginx.conf:ro
```

### Database Clustering
```yaml
# For high availability
services:
  postgres-primary:
    image: postgres:15-alpine
    # Primary configuration
    
  postgres-replica:
    image: postgres:15-alpine
    # Replica configuration
```

### Monitoring Stack
```yaml
# Add to docker-compose.yml
services:
  prometheus:
    image: prom/prometheus
    
  grafana:
    image: grafana/grafana
```

## 📞 Support

### Health Check Endpoints
- **Frontend**: `http://localhost:3000/api/health`
- **Backend**: `http://localhost:3333/health`
- **Database**: `pg_isready` command
- **MinIO**: `http://localhost:9000/minio/health/live`

### Log Locations
- **Application**: Docker container logs
- **Nginx**: `/var/log/nginx/`
- **System**: `/var/log/syslog`

### Emergency Contacts
- DevOps Team: devops@company.com
- Database Admin: dba@company.com
- Security Team: security@company.com

---

## 🎯 Production Checklist

Before going live:

- [ ] Update all default passwords
- [ ] Configure SSL certificates
- [ ] Set up monitoring alerts
- [ ] Configure automated backups
- [ ] Test disaster recovery
- [ ] Security audit completed
- [ ] Performance testing done
- [ ] Documentation updated
- [ ] Team training completed

---

**🚀 Ready for production deployment!**
