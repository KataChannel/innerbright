# 🌐 KataCore Nginx Automation Guide

This guide covers the automated Nginx setup for KataCore deployment on server **116.118.85.41** with domain **innerbright.vn**.

## ✨ Features

- **🔧 Automated Installation**: Installs and configures Nginx automatically
- **🔒 SSL/TLS Setup**: Automatic Let's Encrypt certificate configuration
- **🛡️ Security Headers**: Built-in security headers and rate limiting
- **📊 Health Monitoring**: Health check endpoints and monitoring script
- **🔥 Firewall Config**: Automatic UFW firewall configuration
- **⚡ Performance Optimization**: Proxy buffering and caching
- **📝 Logging**: Comprehensive access and error logging

## 🚀 Quick Start

### Automatic Setup (Recommended)
```bash
# Complete first-time deployment with Nginx
sudo ./deploy-simple.sh --first-time

# Only setup Nginx (without containers)
sudo ./deploy-simple.sh --setup-nginx

# Manual Nginx setup
sudo ./scripts/setup-nginx-auto.sh
```

### Manual Configuration
```bash
# Create Nginx config
sudo nano /etc/nginx/sites-available/innerbright.vn

# Enable site
sudo ln -s /etc/nginx/sites-available/innerbright.vn /etc/nginx/sites-enabled/

# Test configuration
sudo nginx -t

# Reload Nginx
sudo systemctl reload nginx

# Setup SSL
sudo certbot --nginx -d innerbright.vn -d www.innerbright.vn
```

## 📋 Nginx Configuration

### Complete Configuration File
```nginx
server {
    listen 80;
    server_name innerbright.vn www.innerbright.vn;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;

    # Rate limiting
    limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
    limit_req_zone $binary_remote_addr zone=site:10m rate=30r/s;

    # API proxy with rate limiting
    location /api/ {
        limit_req zone=api burst=20 nodelay;
        
        proxy_pass http://localhost:3001/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        
        # Timeout settings
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
        
        # Buffer settings
        proxy_buffering on;
        proxy_buffer_size 4k;
        proxy_buffers 8 4k;
        proxy_busy_buffers_size 8k;
    }

    # Health check endpoint
    location /health {
        proxy_pass http://localhost:3001/health;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # No caching for health checks
        proxy_cache_bypass 1;
        proxy_no_cache 1;
    }

    # Site proxy with rate limiting
    location / {
        limit_req zone=site burst=50 nodelay;
        
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        
        # Timeout settings
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
        
        # Buffer settings
        proxy_buffering on;
        proxy_buffer_size 4k;
        proxy_buffers 8 4k;
        proxy_busy_buffers_size 8k;
    }

    # Static file handling for better performance
    location ~* \.(css|js|jpg|jpeg|png|gif|ico|svg|woff|woff2|ttf|eot)$ {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Cache static files
        expires 1y;
        add_header Cache-Control "public, immutable";
        add_header X-Cache-Status "STATIC";
    }

    # Deny access to sensitive files
    location ~ /\. {
        deny all;
        access_log off;
        log_not_found off;
    }

    # Deny access to backup files
    location ~ ~$ {
        deny all;
        access_log off;
        log_not_found off;
    }
}
```

## 🔒 SSL Configuration

### Automatic SSL Setup
The script automatically configures Let's Encrypt SSL certificates:

```bash
# SSL is setup automatically with:
sudo certbot --nginx -d innerbright.vn -d www.innerbright.vn --non-interactive --agree-tos --email admin@innerbright.vn --redirect
```

### SSL Auto-Renewal
```bash
# Auto-renewal is configured via cron job:
0 12 * * * /usr/bin/certbot renew --quiet

# Manual renewal test:
sudo certbot renew --dry-run

# Check certificate status:
sudo certbot certificates
```

## 🛡️ Security Features

### Firewall Configuration
```bash
# Ports automatically opened:
- 22/tcp   (SSH)
- 80/tcp   (HTTP)
- 443/tcp  (HTTPS)
- 3000/tcp (Next.js Site)
- 3001/tcp (NestJS API)

# Check firewall status:
sudo ufw status
```

### Rate Limiting
- **API requests**: 10 requests/second with burst of 20
- **Site requests**: 30 requests/second with burst of 50
- **Protection against**: DDoS, brute force, API abuse

### Security Headers
- **X-Frame-Options**: Prevents clickjacking
- **X-Content-Type-Options**: Prevents MIME sniffing
- **X-XSS-Protection**: XSS attack protection
- **Referrer-Policy**: Controls referrer information

## 📊 Monitoring

### Health Check Script
The setup creates a monitoring script at `/usr/local/bin/katacore-monitor.sh`:

```bash
# Run monitoring
sudo /usr/local/bin/katacore-monitor.sh

# Output example:
=== KataCore Service Monitor ===
Timestamp: Wed Jul  3 09:30:00 UTC 2025

🔍 Checking API...
✅ API is running (Port 3001)
🔍 Checking Site...
✅ Site is running (Port 3000)
🔍 Checking Nginx...
✅ Nginx is running
🔍 Checking SSL certificate...
✅ SSL certificate valid until: Aug 31 23:59:59 2025 GMT
```

## 🎯 Service URLs

After setup, your services will be available at:

- **🌐 Main Site**: https://innerbright.vn
- **🌐 WWW Site**: https://www.innerbright.vn
- **🔗 API**: https://innerbright.vn/api
- **🏥 Health Check**: https://innerbright.vn/health

## 🔧 Management Commands

### Nginx Commands
```bash
# Test configuration
sudo nginx -t

# Reload configuration
sudo systemctl reload nginx

# Restart Nginx
sudo systemctl restart nginx

# Check status
sudo systemctl status nginx

# View logs
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

### SSL Commands
```bash
# Check certificates
sudo certbot certificates

# Renew certificates
sudo certbot renew

# Test renewal
sudo certbot renew --dry-run

# View certificate details
sudo openssl x509 -in /etc/letsencrypt/live/innerbright.vn/fullchain.pem -text -noout
```

### Firewall Commands
```bash
# Check firewall status
sudo ufw status

# Allow new port
sudo ufw allow <port>/tcp

# Deny port
sudo ufw deny <port>/tcp

# Reset firewall
sudo ufw --force reset
```

## 🚨 Troubleshooting

### Common Issues

#### Nginx Won't Start
```bash
# Check configuration
sudo nginx -t

# Check port conflicts
sudo lsof -i :80
sudo lsof -i :443

# Check logs
sudo journalctl -u nginx
```

#### SSL Certificate Issues
```bash
# Check DNS resolution
nslookup innerbright.vn
dig innerbright.vn A

# Test certificate manually
sudo certbot --nginx -d innerbright.vn -d www.innerbright.vn --dry-run

# Check certificate files
sudo ls -la /etc/letsencrypt/live/innerbright.vn/
```

#### Domain Not Resolving
```bash
# Check if DNS points to correct IP
curl -I http://innerbright.vn
ping innerbright.vn

# Verify server IP
curl ifconfig.me
```

#### Rate Limiting Issues
```bash
# Check if being rate limited
curl -I https://innerbright.vn

# View Nginx error logs
sudo tail -f /var/log/nginx/error.log | grep limit_req
```

## 📝 Configuration Files

### Main Files Created/Modified
- `/etc/nginx/sites-available/innerbright.vn` - Main Nginx configuration
- `/etc/nginx/sites-enabled/innerbright.vn` - Enabled site symlink
- `/usr/local/bin/katacore-monitor.sh` - Monitoring script
- `/etc/letsencrypt/live/innerbright.vn/` - SSL certificates

### Backup Files
- Configuration backups are created with timestamp: `innerbright.vn.backup-YYYYMMDD-HHMMSS`

## 🎊 Next Steps

After Nginx setup:

1. **Deploy Containers**: Run `./deploy-simple.sh`
2. **Test Website**: Visit `https://innerbright.vn`
3. **Test API**: Visit `https://innerbright.vn/api`
4. **Check Health**: Visit `https://innerbright.vn/health`
5. **Monitor Services**: Run `/usr/local/bin/katacore-monitor.sh`

## 💡 Pro Tips

- Always test Nginx configuration with `sudo nginx -t` before reloading
- Use the monitoring script to check service health regularly
- SSL certificates auto-renew, but test with `--dry-run` occasionally
- Monitor Nginx logs for any issues or attacks
- Keep firewall rules updated as needed

---

**🌐 Your Nginx setup is now complete and ready for production!**
