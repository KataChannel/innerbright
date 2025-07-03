# KataCore Cloud Server Deployment Guide

## Architecture Overview

**Before (Docker-based):**
- All services (API, Site, Nginx, DB, etc.) running in Docker containers
- Nginx container proxying to other containers

**After (Hybrid):**
- **Nginx**: Runs directly on cloud server (116.118.85.41)
- **Application Services**: Run in Docker containers with exposed ports
- **Database Services**: Still in Docker containers (internal network)

## Services Port Mapping

| Service | Docker Port | Exposed Port | Access |
|---------|-------------|--------------|---------|
| Next.js Site | 3000 | 3000 | nginx → localhost:3000 |
| NestJS API | 3001 | 3001 | nginx → localhost:3001 |
| pgAdmin | 80 | 5050 | nginx → localhost:5050 |
| MinIO API | 9000 | 9000 | nginx → localhost:9000 |
| MinIO Console | 9001 | 9001 | nginx → localhost:9001 |
| PostgreSQL | 5432 | - | Internal only |
| Redis | 6379 | - | Internal only |

## Deployment Steps

### 1. Prepare Cloud Server

```bash
# Upload and run nginx installation script
./scripts/deploy-nginx-server.sh
```

This script will:
- Install nginx, certbot, and required tools
- Configure firewall (UFW)
- Create SSL certificate directories
- Set up basic auth files
- Deploy nginx configuration

### 2. Deploy Docker Services

```bash
# Build and start Docker services
docker-compose -f docker-compose.prod.yml up -d

# Check service status
docker-compose -f docker-compose.prod.yml ps
```

### 3. Configure SSL Certificate

```bash
# SSH to server
ssh root@116.118.85.41

# Get Let's Encrypt certificate
certbot --nginx -d innerbright.vn -d www.innerbright.vn

# Verify auto-renewal
certbot renew --dry-run
```

### 4. Set Admin Passwords

```bash
# SSH to server
ssh root@116.118.85.41

# Set password for MinIO admin access
htpasswd /etc/nginx/.htpasswd minio-admin

# Set password for pgAdmin access  
htpasswd /etc/nginx/.htpasswd pgadmin-admin
```

### 5. Verify Deployment

**Public URLs:**
- Main Site: https://innerbright.vn
- API: https://innerbright.vn/api/
- MinIO Console: https://innerbright.vn/minio/ (password protected)
- pgAdmin: https://innerbright.vn/pgadmin/ (password protected)

**Health Checks:**
```bash
# Check nginx
curl -I https://innerbright.vn/nginx-health

# Check API
curl -I https://innerbright.vn/api/health

# Check site
curl -I https://innerbright.vn
```

## File Changes Summary

### Modified Files:

1. **docker-compose.prod.yml**
   - Removed nginx service
   - Added port mappings for api (3001), site (3000), pgadmin (5050), minio (9000, 9001)
   - Removed nginx volumes

### New Files:

1. **nginx/server/katacore.conf**
   - Nginx configuration for cloud server
   - Upstreams point to localhost ports instead of container names
   - SSL paths updated for system installation

2. **scripts/install-nginx-server.sh**
   - Complete nginx installation and setup script
   - Configures firewall, SSL directories, basic auth
   - Creates helper scripts and error pages

3. **scripts/deploy-nginx-server.sh**
   - Automated deployment script
   - Uploads configuration and deploys to server
   - Handles SSH connection and verification

## Environment Variables

Update your `.env` file with:

```env
# API URLs for external access
NEXT_PUBLIC_API_URL=https://innerbright.vn/api
CORS_ORIGIN=https://innerbright.vn

# MinIO Browser URL
MINIO_BROWSER_REDIRECT_URL=https://innerbright.vn/minio

# Database and Redis (internal Docker network)
POSTGRES_DB=katacore_prod
POSTGRES_USER=katacore_user
POSTGRES_PASSWORD=your_secure_password
REDIS_PASSWORD=your_redis_password

# Admin credentials
PGADMIN_EMAIL=admin@innerbright.vn
PGADMIN_PASSWORD=your_pgadmin_password
MINIO_ROOT_USER=your_minio_user
MINIO_ROOT_PASSWORD=your_minio_password

# Security
JWT_SECRET=your_jwt_secret
```

## Maintenance Commands

### Nginx Management:
```bash
# Test configuration
nginx -t

# Reload configuration
systemctl reload nginx

# View logs
tail -f /var/log/nginx/error.log
tail -f /var/log/nginx/access.log
```

### Docker Management:
```bash
# Update services
docker-compose -f docker-compose.prod.yml pull
docker-compose -f docker-compose.prod.yml up -d

# View logs
docker-compose -f docker-compose.prod.yml logs -f api
docker-compose -f docker-compose.prod.yml logs -f site
```

### SSL Certificate Renewal:
```bash
# Certificates auto-renew, but you can test:
certbot renew --dry-run

# Force renewal if needed:
certbot renew --force-renewal
```

## Troubleshooting

### Common Issues:

1. **502 Bad Gateway**
   - Check if Docker services are running: `docker ps`
   - Verify port mappings: `netstat -tlnp | grep -E ':(3000|3001|5050|9000|9001)'`
   - Check nginx error logs: `tail -f /var/log/nginx/error.log`

2. **SSL Certificate Issues**
   - Ensure domain points to 116.118.85.41
   - Check certificate: `certbot certificates`
   - Verify nginx SSL configuration: `nginx -t`

3. **Admin Panel Access**
   - Verify auth file: `cat /etc/nginx/.htpasswd`
   - Test credentials: `curl -u username:password https://innerbright.vn/minio/`

### Port Conflicts:
If any ports are already in use:
```bash
# Check what's using a port
sudo netstat -tlnp | grep :3000

# Stop conflicting services
sudo systemctl stop service_name
```

## Security Notes

1. **Firewall**: UFW is configured to allow only necessary ports
2. **SSL**: HTTPS enforced with security headers
3. **Admin Access**: Password-protected admin panels
4. **Rate Limiting**: Configured for API and general traffic
5. **Docker Network**: Database services remain internal

This setup provides better security and performance while maintaining easy deployment and management.
