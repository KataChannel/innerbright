# 🚀 Hướng Dẫn Triển Khai Cloud Server - Innerbright

## 📋 Tổng Quan

Hướng dẫn chi tiết triển khai dự án Innerbright lên cloud server với:
- **Frontend**: Next.js 14 (Port 3000)
- **Backend**: NestJS API (Port 3333)  
- **Database**: PostgreSQL 15 (Port 5432)
- **Storage**: MinIO Object Storage (Port 9000)
- **Proxy**: Nginx với SSL (Port 80/443)
- **Admin**: PgAdmin (Port 5050)

---

## 🎯 Bước 1: Chuẩn Bị Server

### Yêu Cầu Tối Thiểu
```
CPU: 2 cores
RAM: 4GB  
Storage: 20GB SSD
OS: Ubuntu 20.04+
Network: Stable internet
```

### Yêu Cầu Khuyến Nghị Production
```
CPU: 4+ cores
RAM: 8GB+
Storage: 50GB+ SSD  
Backup: Daily automated
Monitoring: 24/7
```

### Kết Nối Server
```bash
# SSH vào server
ssh username@your-server-ip

# Hoặc với key file
ssh -i your-key.pem username@your-server-ip
```

---

## 🔧 Bước 2: Cài Đặt Dependencies

### 2.1 Update System
```bash
# Update packages
sudo apt update && sudo apt upgrade -y

# Install essential tools
sudo apt install -y curl wget git unzip htop nano ufw
```

### 2.2 Install Docker & Docker Compose
```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add user to docker group
sudo usermod -aG docker $USER

# Install Docker Compose
sudo apt install docker-compose-plugin

# Verify installation
docker --version
docker compose version

# Test Docker
docker run hello-world
```

### 2.3 Install Node.js (Optional - for debugging)
```bash
# Install Node.js 20
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verify
node --version
npm --version
```

---

## 📁 Bước 3: Setup Project

### 3.1 Create Project Directory
```bash
# Create deployment directory
sudo mkdir -p /opt/innerbright
sudo chown $USER:$USER /opt/innerbright

# Navigate to directory
cd /opt/innerbright
```

### 3.2 Clone Repository
```bash
# Clone project (replace with your repo URL)
git clone https://github.com/your-username/innerbright.git .

# Or upload files via SCP
# scp -r ./innerbright/* username@server-ip:/opt/innerbright/
```

### 3.3 Set Permissions
```bash
# Make scripts executable
chmod +x *.sh
chmod +x site/*.sh

# Set proper ownership
sudo chown -R $USER:$USER /opt/innerbright
```

---

## 🌍 Bước 4: Cấu Hình Environment

### 4.1 Create Environment File
```bash
# Copy template
cp .env.example .env

# Edit environment variables
nano .env
```

### 4.2 Production Environment Variables
```env
# Database Configuration
POSTGRES_DB=innerbright_prod
POSTGRES_USER=innerbright_user
POSTGRES_PASSWORD=your_super_secure_password_here
POSTGRES_PORT=5432

# Application Ports
NEXTJS_PORT=3000
NESTJS_PORT=3333

# NextAuth Configuration
NEXTAUTH_SECRET=your_32_character_secret_key_here
NEXTAUTH_URL=https://yourdomain.com

# JWT Secret
JWT_SECRET=your_jwt_secret_key_here

# MinIO Storage
MINIO_ACCESS_KEY=your_minio_access_key
MINIO_SECRET_KEY=your_minio_secret_key
MINIO_PORT=9000
MINIO_CONSOLE_PORT=9001

# PgAdmin (Remove in production)
PGADMIN_EMAIL=admin@yourdomain.com
PGADMIN_PASSWORD=your_pgadmin_password
PGADMIN_PORT=5050

# SSL Configuration (if using HTTPS)
HTTPS_PORT=443
HTTP_PORT=80

# Redis (Optional)
REDIS_PORT=6379
```

### 4.3 Generate Secure Secrets
```bash
# Generate NEXTAUTH_SECRET (32 characters)
openssl rand -base64 32

# Generate JWT_SECRET  
openssl rand -base64 64

# Generate PostgreSQL password
openssl rand -base64 16
```

---

## 🔒 Bước 5: Cấu Hình Security

### 5.1 Firewall Setup
```bash
# Enable UFW firewall
sudo ufw enable

# Allow SSH (important!)
sudo ufw allow ssh
sudo ufw allow 22

# Allow HTTP/HTTPS
sudo ufw allow 80
sudo ufw allow 443

# Allow application ports (if needed for direct access)
sudo ufw allow 3000  # Next.js
sudo ufw allow 3333  # NestJS

# Check firewall status
sudo ufw status
```

### 5.2 SSH Security Hardening
```bash
# Backup SSH config
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup

# Edit SSH config
sudo nano /etc/ssh/sshd_config

# Recommended changes:
# PermitRootLogin no
# PasswordAuthentication no (if using SSH keys)
# Port 2222 (change default port)

# Restart SSH service
sudo systemctl restart ssh
```

### 5.3 Fail2Ban (Optional)
```bash
# Install Fail2Ban
sudo apt install fail2ban

# Configure
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

---

## 🚀 Bước 6: Triển Khai Application

### 6.1 Development Deployment (Test First)
```bash
# Start development stack
./docker-dev.sh

# Or manually
docker compose --profile dev up -d

# Check status
docker compose ps

# View logs
docker compose logs -f
```

### 6.2 Production Deployment
```bash
# Build and deploy production
./deploy-production.sh

# Or manually step by step:

# 1. Build images
docker compose build

# 2. Start database first
docker compose up -d postgres

# 3. Run migrations
docker compose up prisma-migrate

# 4. Start all services
docker compose --profile proxy up -d

# 5. Check health
curl http://localhost:3000/api/health
curl http://localhost:3333/health
```

### 6.3 Verify Deployment
```bash
# Check all containers
docker compose ps

# Check resource usage
docker stats

# Test endpoints
curl -f http://localhost:3000
curl -f http://localhost:3333/health
curl -f http://localhost:9000/minio/health/live

# Check logs
docker compose logs nextjs
docker compose logs nestjs
docker compose logs postgres
```

---

## 🌐 Bước 7: Domain & SSL Setup

### 7.1 Domain Configuration
```bash
# Point your domain to server IP
# Add A record: yourdomain.com → YOUR_SERVER_IP
# Add A record: www.yourdomain.com → YOUR_SERVER_IP
```

### 7.2 SSL Certificate (Let's Encrypt)
```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx

# Get SSL certificate
sudo certbot certonly --webroot \
  -w /opt/innerbright/certbot/www \
  -d yourdomain.com \
  -d www.yourdomain.com

# Auto renewal
echo "0 12 * * * /usr/bin/certbot renew --quiet" | sudo crontab -

# Test renewal
sudo certbot renew --dry-run
```

### 7.3 Update Environment for HTTPS
```bash
# Update .env file
nano .env

# Change NEXTAUTH_URL
NEXTAUTH_URL=https://yourdomain.com

# Restart services
docker compose restart nextjs
```

---

## 📊 Bước 8: Monitoring & Maintenance

### 8.1 Setup Health Monitoring
```bash
# Create monitoring script
nano /opt/innerbright/monitor.sh
```

```bash
#!/bin/bash
# Health monitoring script

echo "🔍 Checking service health..."

# Check Next.js
if curl -f http://localhost:3000/api/health > /dev/null 2>&1; then
    echo "✅ Next.js: Healthy"
else
    echo "❌ Next.js: Unhealthy"
fi

# Check NestJS
if curl -f http://localhost:3333/health > /dev/null 2>&1; then
    echo "✅ NestJS: Healthy"
else
    echo "❌ NestJS: Unhealthy"
fi

# Check PostgreSQL
if docker compose exec -T postgres pg_isready -U postgres > /dev/null 2>&1; then
    echo "✅ PostgreSQL: Healthy"
else
    echo "❌ PostgreSQL: Unhealthy"
fi

# Check disk space
df -h /
```

```bash
# Make executable
chmod +x /opt/innerbright/monitor.sh

# Setup cron job for monitoring
echo "*/5 * * * * cd /opt/innerbright && ./monitor.sh >> /var/log/innerbright-health.log" | crontab -
```

### 8.2 Backup Strategy
```bash
# Create backup script
nano /opt/innerbright/backup.sh
```

```bash
#!/bin/bash
# Database backup script

BACKUP_DIR="/opt/innerbright/backups"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/innerbright_backup_$DATE.sql"

# Create backup directory
mkdir -p $BACKUP_DIR

# Backup database
docker compose exec -T postgres pg_dump -U postgres innerbright_prod > $BACKUP_FILE

# Compress backup
gzip $BACKUP_FILE

# Keep only last 7 days of backups
find $BACKUP_DIR -name "*.sql.gz" -mtime +7 -delete

echo "✅ Backup completed: $BACKUP_FILE.gz"
```

```bash
# Make executable
chmod +x /opt/innerbright/backup.sh

# Setup daily backup at 2 AM
echo "0 2 * * * cd /opt/innerbright && ./backup.sh" | crontab -
```

### 8.3 Log Management
```bash
# Setup log rotation
sudo nano /etc/logrotate.d/innerbright
```

```
/opt/innerbright/logs/*.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
    create 644 root root
}
```

---

## 🔄 Bước 9: CI/CD Setup (Optional)

### 9.1 GitHub Actions Secrets
Trong GitHub repository → Settings → Secrets:
```
PRODUCTION_HOST=your.server.ip
PRODUCTION_USER=ubuntu
PRODUCTION_SSH_KEY=your_private_ssh_key
PRODUCTION_PORT=22
```

### 9.2 Server Deployment Key
```bash
# On server, add GitHub Actions public key
nano ~/.ssh/authorized_keys

# Add the public key from GitHub Actions
```

### 9.3 Auto Deployment Setup
```bash
# Create deployment script
nano /opt/innerbright/deploy.sh
```

```bash
#!/bin/bash
# Auto deployment script

echo "🚀 Starting deployment..."

# Pull latest code
git pull origin main

# Rebuild and restart services
docker compose down
docker compose build --no-cache
docker compose up -d

# Health check
sleep 30
if curl -f http://localhost:3000/api/health && curl -f http://localhost:3333/health; then
    echo "✅ Deployment successful!"
else
    echo "❌ Deployment failed!"
    exit 1
fi
```

---

## 🛠️ Bước 10: Testing & Verification

### 10.1 Functional Testing
```bash
# Test frontend
curl -I http://your-domain.com
curl http://your-domain.com/api/health

# Test backend API
curl http://your-domain.com/api/some-endpoint

# Test database connection
docker compose exec postgres psql -U postgres -d innerbright_prod -c "SELECT version();"

# Test file upload (MinIO)
curl http://your-domain.com:9000/minio/health/live
```

### 10.2 Performance Testing
```bash
# Install Apache Bench
sudo apt install apache2-utils

# Test frontend performance
ab -n 100 -c 10 http://your-domain.com/

# Test API performance  
ab -n 100 -c 10 http://your-domain.com/api/health

# Monitor resource usage
htop
docker stats
```

### 10.3 Security Testing
```bash
# SSL test
curl -I https://your-domain.com

# Port scan
nmap -p 22,80,443,3000,3333 your-server-ip

# Check for open ports
sudo netstat -tlnp
```

---

## 📋 Bước 11: Production Checklist

### Pre-Launch Checklist
- [ ] Server requirements met
- [ ] All dependencies installed  
- [ ] Environment variables configured
- [ ] Security hardening completed
- [ ] SSL certificate installed
- [ ] Database optimized and secured
- [ ] Backup strategy implemented
- [ ] Monitoring setup
- [ ] Health checks working
- [ ] Performance tested
- [ ] Security audit completed
- [ ] Documentation updated
- [ ] Team trained on deployment process

### Post-Launch Monitoring
- [ ] Service health checks (daily)
- [ ] Database backups (daily) 
- [ ] SSL certificate renewal (monthly)
- [ ] Security updates (weekly)
- [ ] Performance monitoring (ongoing)
- [ ] Log analysis (weekly)
- [ ] Disk space monitoring (weekly)

---

## 🚨 Troubleshooting

### Common Issues & Solutions

#### 1. Services Won't Start
```bash
# Check logs
docker compose logs [service-name]

# Check system resources
free -h
df -h

# Restart specific service
docker compose restart [service-name]
```

#### 2. Database Connection Issues
```bash
# Check PostgreSQL logs
docker compose logs postgres

# Verify connection string
docker compose exec nextjs env | grep DATABASE_URL

# Test connection
docker compose exec postgres psql -U postgres -d innerbright_prod
```

#### 3. SSL Certificate Issues
```bash
# Check certificate status
sudo certbot certificates

# Renew certificate
sudo certbot renew

# Check Nginx config
nginx -t
```

#### 4. Out of Memory
```bash
# Check memory usage
free -h
docker stats

# Add swap space
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

#### 5. Disk Space Issues
```bash
# Check disk usage
df -h

# Clean Docker
docker system prune -af

# Clean logs
sudo journalctl --vacuum-time=7d
```

---

## 📞 Support

### Emergency Commands
```bash
# Stop all services
docker compose down

# Emergency restart
docker compose restart

# View real-time logs
docker compose logs -f

# Access container shell
docker compose exec [service-name] sh
```

### Contact Information
- **DevOps**: devops@company.com
- **Database**: dba@company.com  
- **Security**: security@company.com

---

## 🎉 Deployment Complete!

Congratulations! Your Innerbright application is now running on the cloud server.

### Access URLs:
- **Frontend**: https://yourdomain.com
- **API**: https://yourdomain.com/api
- **Health Check**: https://yourdomain.com/api/health
- **MinIO Console**: https://yourdomain.com:9001
- **PgAdmin**: https://yourdomain.com:5050 (if enabled)

### Next Steps:
1. Setup monitoring alerts
2. Configure automated backups
3. Setup CDN (optional)
4. Performance optimization
5. Security audit
6. Load testing

**🚀 Your application is live and ready for users!**
