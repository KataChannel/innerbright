# 🚀 KataCore StartKit v1 - Clean & Minimal

## Overview

**KataCore StartKit v1 Clean** is a production-ready deployment system that provides:

- ✅ **Auto-generate secure environment** on first deployment
- ✅ **Complete Docker stack** (API, Site, PostgreSQL, Redis, MinIO, pgAdmin)
- ✅ **Nginx reverse proxy** with SSL support
- ✅ **Dynamic IP/Domain configuration**
- ✅ **Two deployment modes**: Simple (IP) and Full (Domain + SSL)
- ✅ **Single command deployment**
- ✅ **Git integration** with auto-commit

## Quick Start

### Prerequisites

```bash
# Install Docker and Docker Compose
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER

# Install Nginx (for full deployment)
sudo apt update && sudo apt install -y nginx

# Make script executable
chmod +x deploy-startkitv1-clean.sh
```

### Deployment Commands

```bash
# Simple deployment with IP (Docker only)
./deploy-startkitv1-clean.sh deploy-simple 116.118.85.41

# Full deployment with domain + SSL
./deploy-startkitv1-clean.sh deploy-full yourdomain.com

# Guided deployment (interactive)
./deploy-startkitv1-clean.sh deploy-guide

# With additional options
./deploy-startkitv1-clean.sh deploy-full yourdomain.com --force-regen --auto-push --verbose
```

## Deployment Modes

### 1. Simple Deployment (`deploy-simple`)
- ✅ Docker containers only
- ✅ IP address access
- ✅ No Nginx configuration
- ✅ Perfect for development/testing

**Example:**
```bash
./deploy-startkitv1-clean.sh deploy-simple 192.168.1.100
```

**Access:**
- Site: `http://192.168.1.100:3000`
- API: `http://192.168.1.100:3001`
- MinIO: `http://192.168.1.100:9000`
- pgAdmin: `http://192.168.1.100:5050`

### 2. Full Deployment (`deploy-full`)
- ✅ Docker containers + Nginx
- ✅ Domain with SSL certificates
- ✅ Production-ready configuration
- ✅ Security headers and optimizations

**Example:**
```bash
./deploy-startkitv1-clean.sh deploy-full yourdomain.com
```

**Access:**
- Site: `https://yourdomain.com`
- API: `https://yourdomain.com/api`
- MinIO: `https://yourdomain.com/minio`
- pgAdmin: `https://yourdomain.com/pgadmin`

## Available Commands

```bash
# Deployment commands
./deploy-startkitv1-clean.sh deploy-simple IP_ADDRESS
./deploy-startkitv1-clean.sh deploy-full DOMAIN_NAME
./deploy-startkitv1-clean.sh deploy-guide

# Utility commands
./deploy-startkitv1-clean.sh generate-env
./deploy-startkitv1-clean.sh test-deployment
./deploy-startkitv1-clean.sh cleanup

# Help
./deploy-startkitv1-clean.sh --help
```

## Command Options

- `--force-regen`: Force regenerate passwords and secrets
- `--auto-push`: Auto commit and push changes to git
- `--verbose`: Enable detailed logging
- `--dry-run`: Show what would be done without executing

## Environment Variables

The deployment script automatically generates secure environment variables:

```bash
# Security (auto-generated)
POSTGRES_PASSWORD=<secure-32-char-password>
REDIS_PASSWORD=<secure-32-char-password>
JWT_SECRET=<secure-64-char-secret>
MINIO_ROOT_PASSWORD=<secure-32-char-password>
PGADMIN_DEFAULT_PASSWORD=<secure-24-char-password>

# Configuration (auto-configured)
DATABASE_URL=postgresql://user:password@postgres:5432/katacore_prod
REDIS_URL=redis://:password@redis:6379
NEXT_PUBLIC_API_URL=https://yourdomain.com/api
CORS_ORIGIN=https://yourdomain.com
```

## Services Included

| Service | Port | Internal | External Access |
|---------|------|----------|-----------------|
| **Next.js Site** | 3000 | ✅ | `https://domain.com` |
| **NestJS API** | 3001 | ✅ | `https://domain.com/api` |
| **PostgreSQL** | 5432 | ✅ | Internal only |
| **Redis** | 6379 | ✅ | Internal only |
| **MinIO** | 9000 | ✅ | `https://domain.com/minio` |
| **pgAdmin** | 5050 | ✅ | `https://domain.com/pgadmin` |

## File Structure

```
KataCore/
├── deploy-startkitv1-clean.sh          # Main deployment script
├── docker-compose.startkitv1-clean.yml # Docker services
├── .env                                 # Auto-generated environment
├── nginx-startkitv1.conf               # Auto-generated Nginx config
├── api/                                 # NestJS API source
├── site/                                # Next.js site source
└── README-startkitv1-clean.md          # This file
```

## Security Features

- 🔐 **Auto-generated passwords** (32+ characters)
- 🔒 **SSL/TLS certificates** via Let's Encrypt
- 🛡️ **Security headers** (HSTS, CSP, etc.)
- 🚫 **Rate limiting** for API endpoints
- 🔥 **Firewall-ready** configuration
- 📊 **Health checks** for all services

## Monitoring & Maintenance

### Check service health
```bash
./deploy-startkitv1-clean.sh test-deployment
```

### View logs
```bash
docker-compose -f docker-compose.startkitv1-clean.yml logs -f
```

### Update deployment
```bash
# Update code and redeploy
git pull
./deploy-startkitv1-clean.sh deploy-full yourdomain.com
```

### Backup database
```bash
docker-compose -f docker-compose.startkitv1-clean.yml exec postgres pg_dump -U katacore_user katacore_prod > backup.sql
```

## Troubleshooting

### Common Issues

1. **Port conflicts**
   ```bash
   # Check if ports are in use
   sudo netstat -tulpn | grep :3000
   ```

2. **SSL certificate issues**
   ```bash
   # Check certificate status
   sudo certbot certificates
   ```

3. **Service not starting**
   ```bash
   # Check service logs
   docker-compose -f docker-compose.startkitv1-clean.yml logs service_name
   ```

### Reset deployment
```bash
# Clean everything and start fresh
./deploy-startkitv1-clean.sh cleanup
./deploy-startkitv1-clean.sh deploy-full yourdomain.com --force-regen
```

## Production Checklist

- [ ] Domain DNS pointing to server IP
- [ ] Server firewall configured (ports 80, 443, 22)
- [ ] SSL certificates obtained and valid
- [ ] Database backups configured
- [ ] Monitoring setup (optional)
- [ ] Environment variables secured
- [ ] Git repository access configured

## Support

For issues or questions:
1. Check the troubleshooting section
2. Run `./deploy-startkitv1-clean.sh test-deployment`
3. Review logs with `docker-compose logs`
4. Check service health endpoints

---

**KataCore StartKit v1 Clean** - Production-ready deployment made simple! 🚀
