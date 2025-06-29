# 🚀 Hướng Dẫn Triển Khai Production - Innerbright

## 📋 Tổng Quan

Hướng dẫn chi tiết từng bước để triển khai dự án Innerbright lên cloud server production. 

### Kiến Trúc Hệ Thống
```
Internet → Nginx (SSL/Proxy) → Next.js Frontend (3000) + NestJS API (3333)
                              ↓
                        PostgreSQL + MinIO + Redis
```

### Yêu Cầu Server
- **CPU**: 2+ cores (khuyến nghị: 4+ cores)
- **RAM**: 4GB+ (khuyến nghị: 8GB+)
- **Storage**: 20GB+ SSD (khuyến nghị: 50GB+)
- **OS**: Ubuntu 20.04+ / Debian 11+
- **Network**: Public IP với bandwidth ổn định

---

## 🎯 Bước 1: Chuẩn Bị Server Mới

### 1.1 Kết Nối Server
```bash
# SSH vào server với IP hoặc domain
ssh username@your-server-ip

# Hoặc với key file (khuyến nghị)
ssh -i /path/to/your-key.pem username@your-server-ip
```

### 1.2 Cài Đặt Tự Động (Khuyến Nghị)
```bash
# Tải script setup tự động
wget https://raw.githubusercontent.com/yourusername/innerbright/main/setup-cloud-server.sh

# Hoặc nếu đã có code trên server
chmod +x setup-cloud-server.sh
./setup-cloud-server.sh
```

### 1.3 Cài Đặt Thủ Công (Nếu Cần)

#### Update System
```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl wget git htop vim ufw fail2ban unzip
```

#### Cài Docker
```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add user to docker group
sudo usermod -aG docker $USER

# Log out and log back in, then test
docker --version
docker run hello-world
```

#### Cài Docker Compose
```bash
# Docker Compose Plugin (recommended)
sudo apt install docker-compose-plugin

# Or standalone version
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Test
docker compose version
```

---

## 📁 Bước 2: Triển Khai Code

### 2.1 Clone Repository
```bash
# Tạo thư mục project
sudo mkdir -p /opt/innerbright
sudo chown $USER:$USER /opt/innerbright
cd /opt/innerbright

# Clone repository
git clone https://github.com/your-username/innerbright.git .

# Hoặc upload code qua SCP/SFTP
```

### 2.2 Setup Environment Variables
```bash
# Copy environment template
cp .env.example .env

# Edit với editor
nano .env
```

#### Cấu Hình Environment Variables Quan Trọng
```bash
# Database
POSTGRES_DB=innerbright_prod
POSTGRES_USER=innerbright_user
POSTGRES_PASSWORD=your_super_secure_password_here

# Next.js
NEXTAUTH_SECRET=your_nextauth_secret_32_chars_minimum
NEXTAUTH_URL=https://your-domain.com
NODE_ENV=production

# Ports (có thể thay đổi nếu cần)
NEXTJS_PORT=3000
NESTJS_PORT=3333
POSTGRES_PORT=5432
MINIO_PORT=9000

# MinIO Object Storage
MINIO_ROOT_USER=minioadmin
MINIO_ROOT_PASSWORD=your_minio_password_here

# Redis (nếu dùng)
REDIS_PASSWORD=your_redis_password

# SSL & Domain
DOMAIN=your-domain.com
EMAIL=your-email@domain.com
```

### 2.3 Tạo Directories và Permissions
```bash
# Tạo volumes directories
mkdir -p data/postgres data/minio data/redis logs

# Set permissions
sudo chown -R 999:999 data/postgres  # PostgreSQL user
sudo chown -R 1001:1001 data/minio   # MinIO user
chmod -R 755 data

# Make scripts executable
chmod +x *.sh
```

---

## 🔧 Bước 3: Triển Khai Services

### 3.1 Build và Start Services
```bash
# Method 1: Sử dụng script tự động (Khuyến nghị)
./deploy-production.sh

# Method 2: Manual deployment
docker compose up --build -d --remove-orphans
```

### 3.2 Theo Dõi Logs
```bash
# Xem logs tất cả services
docker compose logs -f

# Xem logs từng service
docker compose logs -f nextjs
docker compose logs -f nestjs
docker compose logs -f postgres
```

### 3.3 Kiểm Tra Health Status
```bash
# Check container status
docker compose ps

# Check health endpoints
curl http://localhost:3000/api/health  # Next.js
curl http://localhost:3333/health      # NestJS
```

---

## 🌐 Bước 4: Cấu Hình Domain và SSL

### 4.1 Cấu Hình DNS
Trỏ domain về IP server:
```
A Record: your-domain.com → your-server-ip
CNAME: www.your-domain.com → your-domain.com
```

### 4.2 Cấu Hình Nginx và SSL
```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx

# Get SSL certificate
sudo certbot --nginx -d your-domain.com -d www.your-domain.com

# Update nginx config for production
sudo nano /etc/nginx/sites-available/innerbright
```

#### Nginx Config Sample
```nginx
server {
    listen 80;
    server_name your-domain.com www.your-domain.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name your-domain.com www.your-domain.com;

    ssl_certificate /etc/letsencrypt/live/your-domain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/your-domain.com/privkey.pem;

    # Frontend (Next.js)
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }

    # API (NestJS)
    location /api/ {
        proxy_pass http://localhost:3333/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
```

### 4.3 Enable và Test Nginx
```bash
# Enable site
sudo ln -s /etc/nginx/sites-available/innerbright /etc/nginx/sites-enabled/

# Test config
sudo nginx -t

# Restart nginx
sudo systemctl restart nginx

# Enable auto-start
sudo systemctl enable nginx
```

---

## 🔐 Bước 5: Bảo Mật Server

### 5.1 Cấu Hình Firewall
```bash
# Enable UFW
sudo ufw enable

# Allow essential ports
sudo ufw allow ssh
sudo ufw allow 80/tcp   # HTTP
sudo ufw allow 443/tcp  # HTTPS

# Optional: Allow specific services (chỉ khi cần)
sudo ufw allow 3000/tcp  # Next.js (nếu cần truy cập trực tiếp)
sudo ufw allow 5050/tcp  # PgAdmin (nếu cần)

# Check status
sudo ufw status
```

### 5.2 Cấu Hình Fail2Ban
```bash
# Create jail config
sudo nano /etc/fail2ban/jail.local
```

```ini
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 5

[sshd]
enabled = true
port = ssh
logpath = /var/log/auth.log

[nginx-http-auth]
enabled = true
port = http,https
logpath = /var/log/nginx/error.log
```

```bash
# Restart fail2ban
sudo systemctl restart fail2ban
sudo systemctl enable fail2ban
```

### 5.3 Cấu Hình SSH Security
```bash
# Edit SSH config
sudo nano /etc/ssh/sshd_config
```

```
# Disable root login
PermitRootLogin no

# Change default port (recommended)
Port 2222

# Disable password auth (if using keys)
PasswordAuthentication no
PubkeyAuthentication yes

# Other security settings
PermitEmptyPasswords no
MaxAuthTries 3
ClientAliveInterval 300
ClientAliveCountMax 2
```

```bash
# Restart SSH
sudo systemctl restart ssh
```

---

## 📊 Bước 6: Monitoring và Maintenance

### 6.1 Setup System Monitoring
```bash
# Install monitoring tools
sudo apt install htop iotop nethogs

# Setup log rotation
sudo nano /etc/logrotate.d/innerbright
```

```
/opt/innerbright/logs/*.log {
    daily
    missingok
    rotate 7
    compress
    notifempty
    create 644 root root
}
```

### 6.2 Database Backup Script
```bash
# Create backup script
nano /opt/innerbright/backup-db.sh
```

```bash
#!/bin/bash
BACKUP_DIR="/opt/innerbright/backups"
CONTAINER_NAME="innerbright-postgres-1"
DB_NAME="innerbright_prod"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

# Create backup
docker exec $CONTAINER_NAME pg_dump -U innerbright_user $DB_NAME | gzip > $BACKUP_DIR/backup_$DATE.sql.gz

# Keep only last 7 days
find $BACKUP_DIR -name "backup_*.sql.gz" -mtime +7 -delete

echo "Backup completed: backup_$DATE.sql.gz"
```

```bash
# Make executable and add to crontab
chmod +x /opt/innerbright/backup-db.sh

# Add to crontab (daily backup at 2 AM)
crontab -e
```

```
0 2 * * * /opt/innerbright/backup-db.sh >> /opt/innerbright/logs/backup.log 2>&1
```

### 6.3 Health Check Script
```bash
# Create health check script
nano /opt/innerbright/health-check.sh
```

```bash
#!/bin/bash
SERVICES=("nextjs" "nestjs" "postgres" "minio")
LOG_FILE="/opt/innerbright/logs/health-check.log"

echo "$(date): Starting health check" >> $LOG_FILE

for service in "${SERVICES[@]}"; do
    if docker compose ps $service | grep -q "running\|healthy"; then
        echo "$(date): ✅ $service is healthy" >> $LOG_FILE
    else
        echo "$(date): ❌ $service is unhealthy" >> $LOG_FILE
        # Optional: Send alert email/notification
    fi
done
```

---

## 🔄 Bước 7: CI/CD Setup (Optional)

### 7.1 GitHub Actions Workflow
File đã có sẵn tại `.github/workflows/deploy.yml`

### 7.2 Setup Deploy Keys
```bash
# On server, create deploy user
sudo adduser deploy
sudo usermod -aG docker deploy

# Generate SSH key for GitHub
ssh-keygen -t rsa -b 4096 -C "deploy@your-server"

# Add public key to GitHub Deploy Keys
cat ~/.ssh/id_rsa.pub
```

### 7.3 Environment Secrets
Thêm vào GitHub Secrets:
- `HOST`: Server IP
- `USERNAME`: deploy
- `PRIVATE_KEY`: SSH private key
- `ENV_FILE`: Nội dung file .env

---

## 🚨 Bước 8: Troubleshooting

### 8.1 Common Issues

#### Services Won't Start
```bash
# Check logs
docker compose logs -f

# Check disk space
df -h

# Check memory
free -h

# Restart specific service
docker compose restart nestjs
```

#### Database Connection Issues
```bash
# Check PostgreSQL logs
docker compose logs postgres

# Test connection
docker compose exec postgres psql -U innerbright_user -d innerbright_prod

# Reset database (DEV ONLY!)
docker compose down
docker volume rm innerbright_postgres_data
docker compose up -d
```

#### SSL Certificate Issues
```bash
# Renew certificate
sudo certbot renew

# Check certificate
sudo certbot certificates

# Force renewal
sudo certbot renew --force-renewal
```

### 8.2 Performance Optimization

#### Enable Gzip in Nginx
```nginx
# Add to nginx config
gzip on;
gzip_vary on;
gzip_min_length 1024;
gzip_proxied any;
gzip_comp_level 6;
gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json;
```

#### Docker Resource Limits
```yaml
# In docker-compose.yml
deploy:
  resources:
    limits:
      cpus: '2.0'
      memory: 2G
    reservations:
      cpus: '0.5'
      memory: 512M
```

---

## ✅ Checklist Triển Khai

### Pre-deployment
- [ ] Server đã cập nhật và bảo mật
- [ ] Docker và Docker Compose đã cài đặt
- [ ] Domain đã trỏ về server IP
- [ ] SSL certificate đã được tạo
- [ ] Environment variables đã được cấu hình
- [ ] Firewall đã được thiết lập

### Deployment
- [ ] Code đã được clone/upload
- [ ] Dependencies đã được build
- [ ] Database đã được migrate
- [ ] All services đang chạy healthy
- [ ] Health checks đều pass
- [ ] Logs không có lỗi critical

### Post-deployment
- [ ] Website accessible qua HTTPS
- [ ] API endpoints hoạt động bình thường
- [ ] Database backup script đã setup
- [ ] Monitoring và alerting đã thiết lập
- [ ] Performance đã được tối ưu
- [ ] Documentation đã được cập nhật

---

## 📞 Support

### Logs Locations
- Application: `/opt/innerbright/logs/`
- Docker: `docker compose logs`
- Nginx: `/var/log/nginx/`
- System: `/var/log/syslog`

### Useful Commands
```bash
# Quick status check
docker compose ps
docker stats

# Restart all services
docker compose restart

# Update and rebuild
git pull && docker compose up --build -d

# View resource usage
htop
df -h
docker system df
```

### Emergency Procedures
```bash
# Stop all services
docker compose down

# Emergency backup
./backup-db.sh

# Reset to previous version
git checkout previous-version
docker compose up --build -d
```

---

**🎉 Chúc mừng! Bạn đã triển khai thành công Innerbright lên production server!**

Hãy đảm bảo thường xuyên monitoring, backup và cập nhật hệ thống để duy trì hiệu suất và bảo mật tối ưu.
