# 🚀 KataCore StartKit v1 - Clean Deployment Guide

## Overview

KataCore StartKit v1 is a **clean, minimal, and production-ready** deployment system that provides:

- ✅ **Auto-generate secure passwords** on first deployment
- ✅ **Docker deployment** for all services (API, Site, PostgreSQL, Redis, MinIO, pgAdmin)  
- ✅ **Nginx reverse proxy** with SSL support
- ✅ **Dynamic IP/Domain** configuration
- ✅ **Two deployment modes**: Simple (IP-based) and Full (Domain with SSL)
- ✅ **Git integration** with auto-commit and push

## Quick Start

### Prerequisites

1. **Server Requirements:**
   - Ubuntu/Debian server with Docker and Docker Compose installed
   - Nginx installed (for full deployment)
   - Domain pointing to server IP (for full deployment)

2. **Local Requirements:**
   - Git configured
   - SSH access to server

### Deployment Commands

```bash
# Make deployment script executable
chmod +x deploy-startkitv1.sh

# Option 1: Simple deployment with IP
./deploy-startkitv1.sh deploy --ip 116.118.85.41

# Option 2: Full deployment with domain + SSL
sudo ./deploy-startkitv1.sh full-deploy --domain innerbright.vn

# With additional options
./deploy-startkitv1.sh deploy --ip 116.118.85.41 --autopush --force-regen --verbose
```

## Deployment Modes

### 1. Simple Deployment (`deploy`)
- Deploys Docker containers only
- Uses IP address for access
- No Nginx/SSL configuration
- Perfect for development or internal servers

**Command:**
```bash
./deploy-startkitv1.sh deploy --ip <SERVER_IP>
```

**Access URLs:**
- Site: `http://SERVER_IP:3000`
- API: `http://SERVER_IP:3001`
- pgAdmin: `http://SERVER_IP:5050`

### 2. Full Deployment (`full-deploy`)
- Complete production setup
- Nginx reverse proxy with SSL
- Domain-based access
- Production security headers

**Command:**
```bash
sudo ./deploy-startkitv1.sh full-deploy --domain <DOMAIN>
```

**Access URLs:**
- Site: `https://DOMAIN`
- API: `https://DOMAIN/api`
- pgAdmin: `https://DOMAIN/pgadmin`
- MinIO: `https://DOMAIN/minio`

## Command Options

| Option | Description |
|--------|-------------|
| `--ip <IP>` | Server IP address (required for `deploy`) |
| `--domain <DOMAIN>` | Domain name (required for `full-deploy`) |
| `--force-regen` | Force regenerate all passwords |
| `--autopush` | Auto commit and push to git |
| `--verbose` | Enable detailed logging |
| `--dry-run` | Preview changes without execution |
| `--help` | Show help information |

## Architecture

### Container Services
- **API (NestJS)**: Port 3001 - Backend application
- **Site (Next.js)**: Port 3000 - Frontend application  
- **PostgreSQL**: Port 5432 - Database
- **Redis**: Port 6379 - Cache and sessions
- **MinIO**: Ports 9000/9001 - Object storage
- **pgAdmin**: Port 5050 - Database management

### Security Features
- **Auto-generated passwords**: 16-24 character secure passwords
- **JWT secrets**: 64-character base64 encoded
- **SSL certificates**: Let's Encrypt or self-signed fallback
- **Security headers**: XSS protection, frame options, etc.
- **Rate limiting**: Built into Nginx configuration

## Environment Management

### First Deployment
- Automatically generates `.env` from `.env.startkitv1` template
- Creates secure passwords for all services
- Configures environment for specified IP/domain

### Subsequent Deployments
- Preserves existing passwords unless `--force-regen` is used
- Updates only code changes
- Maintains environment consistency

### Password Configuration
- **PostgreSQL**: 24 characters
- **Redis**: 20 characters  
- **MinIO**: 20 characters
- **pgAdmin**: 16 characters
- **JWT Secret**: 64 characters (base64)

## Examples

### Development Setup
```bash
# Quick development deployment
./deploy-startkitv1.sh deploy --ip 192.168.1.100 --verbose
```

### Production Setup
```bash
# Complete production deployment
sudo ./deploy-startkitv1.sh full-deploy --domain myapp.com --autopush
```

### Update Deployment
```bash
# Update existing deployment with new passwords
./deploy-startkitv1.sh deploy --ip 116.118.85.41 --force-regen --autopush
```

### Dry Run Testing
```bash
# Test what would happen without making changes
./deploy-startkitv1.sh deploy --ip 116.118.85.41 --dry-run --verbose
```

## Management Commands

### Container Management
```bash
# View logs
docker-compose -f docker-compose.startkitv1.yml logs -f

# Restart services
docker-compose -f docker-compose.startkitv1.yml restart

# Stop all services
docker-compose -f docker-compose.startkitv1.yml down

# Check status
docker-compose -f docker-compose.startkitv1.yml ps
```

### Health Monitoring
```bash
# Check API health
curl http://localhost:3001/health

# Check Site health  
curl http://localhost:3000

# Check all container status
docker ps
```

### Nginx Management (Full Deployment)
```bash
# Test configuration
sudo nginx -t

# Reload configuration
sudo systemctl reload nginx

# Check status
sudo systemctl status nginx

# View logs
sudo tail -f /var/log/nginx/error.log
```

## Troubleshooting

### Common Issues

1. **Permission denied for Nginx setup**
   ```bash
   # Use sudo for full deployment
   sudo ./deploy-startkitv1.sh full-deploy --domain yourdomain.com
   ```

2. **Docker not found**
   ```bash
   # Install Docker
   curl -fsSL https://get.docker.com -o get-docker.sh
   sudo sh get-docker.sh
   ```

3. **SSL certificate issues**
   ```bash
   # Check if domain points to server
   dig yourdomain.com
   
   # Check firewall
   sudo ufw allow 80
   sudo ufw allow 443
   ```

4. **Service not starting**
   ```bash
   # Check logs
   docker-compose -f docker-compose.startkitv1.yml logs [service-name]
   
   # Check environment
   cat .env | grep -E "(PASSWORD|SECRET)"
   ```

### Reset Deployment
```bash
# Stop all services
docker-compose -f docker-compose.startkitv1.yml down

# Remove volumes (WARNING: This deletes all data)
docker volume rm $(docker volume ls -q | grep katacore)

# Fresh deployment
./deploy-startkitv1.sh deploy --ip YOUR_IP --force-regen
```

## File Structure

```
KataCore/
├── deploy-startkitv1.sh           # Main deployment script
├── .env.startkitv1                # Environment template
├── docker-compose.startkitv1.yml  # Production Docker config
├── .env                           # Generated environment (auto-created)
├── api/                           # NestJS backend
├── site/                          # Next.js frontend  
└── README-startkitv1.md          # This guide
```

## Benefits

✅ **Minimal Configuration**: Single script handles everything  
✅ **Secure by Default**: Auto-generated passwords and SSL  
✅ **Production Ready**: Optimized for real-world deployment  
✅ **Flexible**: Supports both IP and domain-based deployment  
✅ **Maintainable**: Clean code structure and clear documentation  
✅ **Git Integrated**: Automatic version control integration  

---

**KataCore StartKit v1** - Ready for production deployment! 🚀
