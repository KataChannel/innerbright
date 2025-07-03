# 🚀 KataCore Automated Server Setup Guide

This comprehensive guide shows you how to deploy KataCore on your cloud server (116.118.85.41) with **automated Nginx configuration**, **SSL certificates**, and **Docker containers**.

## ✨ What's New in v2

- **🌐 Automated Nginx Setup**: Complete reverse proxy configuration with SSL
- **🔐 Automatic SSL Certificates**: Let's Encrypt integration 
- **🛡️ Enhanced Security**: Firewall configuration and rate limiting
- **📊 Health Monitoring**: Built-in health checks and monitoring
- **🎛️ Single Command Deployment**: Everything automated in one script

## 🎯 Deployment Options

### Option 1: Complete First-Time Setup (Recommended)

For brand new servers or first-time deployment:

```bash
# Download the project
git clone <your-repo-url>
cd KataCore

# Make scripts executable
chmod +x deploy-complete.sh setup-nginx-server.sh

# Complete server setup (requires root for Nginx/SSL)
sudo ./deploy-complete.sh --first-time --autopush --verbose
```

This will:
- ✅ Generate secure passwords for all services
- ✅ Deploy Docker containers (API + Site)
- ✅ Install and configure Nginx
- ✅ Setup SSL certificates with Let's Encrypt
- ✅ Configure firewall
- ✅ Create monitoring tools
- ✅ Commit and push changes to git

### Option 2: Container Deployment Only

If you already have Nginx configured:

```bash
# Simple deployment with auto-generated passwords
./deploy-simple.sh

# With git autopush
./deploy-simple.sh --autopush

# Force regenerate all passwords
./deploy-simple.sh --force-regen --autopush
```

### Option 3: Nginx Setup Only

If you need to setup/update only Nginx configuration:

```bash
# Setup Nginx with SSL (requires root)
sudo ./setup-nginx-server.sh
```

## 🔧 Configuration

### Environment Variables

The scripts automatically update your `.env` file with:

```env
# Domain Configuration
DOMAIN=innerbright.vn
SERVER_IP=116.118.85.41
EMAIL=admin@innerbright.vn

# Auto-generated Secure Passwords
POSTGRES_PASSWORD=<24-char-secure-password>
REDIS_PASSWORD=<20-char-secure-password>
MINIO_ROOT_PASSWORD=<20-char-secure-password>
PGADMIN_PASSWORD=<16-char-secure-password>
JWT_SECRET=<64-char-base64-secret>
GRAFANA_ADMIN_PASSWORD=<16-char-secure-password>

# Service URLs
NEXT_PUBLIC_API_URL=https://innerbright.vn/api
CORS_ORIGIN=https://innerbright.vn
```

### Prerequisites

**Before running the scripts:**

1. **Domain Setup**: Ensure `innerbright.vn` and `www.innerbright.vn` point to `116.118.85.41`
2. **Server Access**: SSH access to the server
3. **Ports Open**: 22 (SSH), 80 (HTTP), 443 (HTTPS)
4. **Git Config** (for autopush):
   ```bash
   git config --global user.name "Your Name"
   git config --global user.email "your.email@example.com"
   ```

## 📋 Step-by-Step Deployment

### Step 1: Prepare Your Server

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker (if not installed)
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Install Docker Compose
sudo apt install docker-compose -y
```

### Step 2: Deploy KataCore

```bash
# Clone your repository
git clone <your-repo-url>
cd KataCore

# First-time complete setup
sudo ./deploy-complete.sh --first-time --autopush --verbose
```

### Step 3: Verify Deployment

```bash
# Check system status
katacore-status

# Test services
curl https://innerbright.vn/nginx-health
curl https://innerbright.vn/api/health
curl https://innerbright.vn/
```

## 🔍 Monitoring and Management

### System Status

```bash
# Check overall system status
katacore-status

# Check container status
docker-compose -f docker-compose.prod.yml ps

# View container logs
docker-compose -f docker-compose.prod.yml logs -f api
docker-compose -f docker-compose.prod.yml logs -f site

# Check Nginx status
sudo systemctl status nginx
sudo nginx -t
```

### SSL Certificate Management

```bash
# Check certificate status
sudo certbot certificates

# Test certificate renewal
sudo certbot renew --dry-run

# Force certificate renewal
sudo certbot renew --force-renewal
```

### Service URLs

After successful deployment:

- **🌐 Main Site**: https://innerbright.vn
- **🔗 API**: https://innerbright.vn/api
- **🏥 Health Check**: https://innerbright.vn/nginx-health

## 🛠️ Advanced Configuration

### Custom Domain

To use a different domain, update your `.env` file:

```env
DOMAIN=your-domain.com
SERVER_IP=your-server-ip
EMAIL=admin@your-domain.com
```

Then run:
```bash
sudo ./setup-nginx-server.sh
```

### Container Management

```bash
# Restart all containers
docker-compose -f docker-compose.prod.yml restart

# Rebuild and restart specific container
docker-compose -f docker-compose.prod.yml build api
docker-compose -f docker-compose.prod.yml up -d api

# Scale containers (if needed)
docker-compose -f docker-compose.prod.yml up -d --scale api=2
```

### Nginx Configuration

The Nginx configuration includes:

- **Rate Limiting**: API (30 req/s), General (10 req/s)
- **SSL/TLS**: TLS 1.2/1.3 with secure ciphers
- **Security Headers**: HSTS, CSP, XSS protection
- **Compression**: Gzip for static assets
- **Caching**: Aggressive caching for static files

To modify Nginx configuration:
```bash
sudo nano /etc/nginx/sites-available/innerbright.vn
sudo nginx -t
sudo systemctl reload nginx
```

## 🚨 Troubleshooting

### Common Issues

#### 1. SSL Certificate Issues
```bash
# Check DNS
dig innerbright.vn
dig www.innerbright.vn

# Manual certificate setup
sudo certbot --nginx -d innerbright.vn -d www.innerbright.vn --force-renewal
```

#### 2. Container Connection Issues
```bash
# Check if containers are running
docker ps

# Check container networks
docker network ls
docker network inspect katacore-prod-network
```

#### 3. Nginx Configuration Issues
```bash
# Test configuration
sudo nginx -t

# Check logs
sudo tail -f /var/log/nginx/error.log
sudo tail -f /var/log/nginx/access.log
```

#### 4. Firewall Issues
```bash
# Check firewall status
sudo ufw status

# Allow required ports
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
```

### Recovery Commands

```bash
# Reset containers
docker-compose -f docker-compose.prod.yml down
docker system prune -f
./deploy-simple.sh

# Reset Nginx
sudo rm /etc/nginx/sites-enabled/innerbright.vn
sudo ./setup-nginx-server.sh

# Reset SSL
sudo certbot delete --cert-name innerbright.vn
sudo ./setup-nginx-server.sh
```

## 📊 Performance Optimization

### Container Resources

The deployment includes optimized resource limits:

```yaml
# API Container
resources:
  limits:
    memory: 1G
  reservations:
    memory: 512M

# Site Container  
resources:
  limits:
    memory: 512M
  reservations:
    memory: 256M
```

### Nginx Optimization

- **Worker Processes**: Auto-scaled based on CPU cores
- **Keepalive Connections**: Optimized for Docker containers
- **Compression**: Enabled for all text-based content
- **Static File Caching**: 1-year cache for assets

## 🔄 Maintenance

### Regular Tasks

```bash
# Update containers (weekly)
git pull
./deploy-simple.sh --autopush

# Check SSL certificate expiry (monthly)
sudo certbot certificates

# Review logs (daily)
sudo tail -100 /var/log/nginx/access.log
docker-compose -f docker-compose.prod.yml logs --tail=100
```

### Backup Procedures

```bash
# Backup environment configuration
cp .env .env.backup.$(date +%Y%m%d)

# Backup Nginx configuration
sudo cp /etc/nginx/sites-available/innerbright.vn /etc/nginx/sites-available/innerbright.vn.backup.$(date +%Y%m%d)

# Export container data
docker-compose -f docker-compose.prod.yml exec api pg_dump > backup.sql
```

## 🎯 Next Steps

1. **Monitor Performance**: Use `katacore-status` regularly
2. **Setup Monitoring**: Consider adding Grafana/Prometheus
3. **Backup Strategy**: Implement regular database backups
4. **CDN Setup**: Consider CloudFlare for better performance
5. **Load Balancing**: Scale containers as needed

---

**🎉 Congratulations!** Your KataCore application is now deployed with enterprise-grade configuration including SSL, security headers, rate limiting, and monitoring.

For support or questions, check the documentation or create an issue in the repository.
