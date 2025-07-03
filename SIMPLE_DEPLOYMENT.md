# KataCore Simple Deployment Guide v2

This guide covers the enhanced simplified deployment approach for KataCore with **automatic password generation**, **Git autopush functionality**, **automated Nginx setup**, and **secure container deployment**.

## 🚀 Quick Start

### Option 1: Complete First-time Setup (Recommended)
```bash
# Complete server setup with Nginx and SSL
sudo ./deploy-simple.sh --first-time

# With git autopush
sudo ./deploy-simple.sh --first-time --autopush
```

### Option 2: Container Deployment Only
```bash
# Make script executable
chmod +x deploy-simple.sh

# Simple deployment with auto-generated passwords
./deploy-simple.sh

# Deployment with git autopush
./deploy-simple.sh --autopush

# Force regenerate all passwords
./deploy-simple.sh --force-regen
```

### Option 3: Nginx Setup Only
```bash
# Setup Nginx with SSL (requires root)
sudo ./deploy-simple.sh --setup-nginx
```

## Overview

**What runs in Docker:**
- ✅ API (NestJS) - Port 3001
- ✅ Site (Next.js) - Port 3000

**What runs on cloud server (116.118.85.41):**
- 🌐 Nginx (reverse proxy, SSL termination)
- 🗄️ PostgreSQL database
- 🚀 Redis cache
- 📦 MinIO object storage

## 🆕 New Features in v2

### 🌐 **Automated Nginx Setup**
- **Complete server configuration** with single command
- **SSL certificate** automatic setup with Let's Encrypt
- **Firewall configuration** for security
- **Health monitoring** endpoints
- **Domain-based routing** with rate limiting

### 🔐 **Auto-Password Generation**
The deployment script automatically generates **cryptographically secure passwords** for all services:

- **PostgreSQL**: 24-character secure password
- **Redis**: 20-character secure password  
- **MinIO**: 20-character secure password
- **pgAdmin**: 16-character secure password
- **JWT Secret**: 64-character base64 encoded secret
- **Grafana**: 16-character secure password

**Security Features:**
- Uses OpenSSL for cryptographically secure random generation
- Fallback to `/dev/urandom` for better entropy
- Preserves existing passwords unless `--force-regen` is used
- Validates all environment variables before deployment

### 📤 **Git Autopush**
Automatic git operations after successful deployment:
- Detects if repository is initialized
- Checks for git user configuration
- Adds all changes to staging
- Creates timestamped commit messages
- Pushes to remote repository if configured

### 🎛️ **Advanced Options**
- `--first-time`: Complete first-time server setup
- `--setup-nginx`: Setup Nginx configuration and SSL
- `--autopush`: Enable automatic git commits and push
- `--force-regen`: Force regenerate all passwords and secrets
- `--verbose`: Enable detailed logging output
- `--dry-run`: Preview changes without execution
- `--help`: Show detailed help information

### 🛡️ **Enhanced Security**
- Environment variable validation
- Docker availability checks
- Container health monitoring
- Service connectivity tests
- Secure password generation using OpenSSL
- SSL certificate automation
- Firewall configuration
- Rate limiting and DDoS protection

## Prerequisites

1. **Cloud Server Setup (116.118.85.41):**
   - Docker and Docker Compose installed
   - Nginx installed and configured
   - PostgreSQL running
   - Redis running
   - MinIO running

2. **Environment Setup:**
   - Copy `.env.example` to `.env` (done automatically by script)
   - Secure passwords auto-generated on first run
   - External service URLs configured

3. **Git Configuration (optional for autopush):**
   - Git user configured: `git config --global user.name "Your Name"`
   - Git email configured: `git config --global user.email "your.email@example.com"`
   - Remote repository added: `git remote add origin <repository-url>`

## 📋 Deployment Steps

### 1. Quick Deployment (Recommended)
```bash
# Make deployment script executable
chmod +x deploy-simple.sh

# Simple deployment with auto-password generation
./deploy-simple.sh

# Deployment with git autopush
./deploy-simple.sh --autopush

# Force regenerate all passwords
./deploy-simple.sh --force-regen

# Dry run to preview changes
./deploy-simple.sh --dry-run --verbose
```

### 2. Manual Environment Setup (if needed)
```bash
# Copy environment template (done automatically)
cp .env.example .env

# Edit the environment file manually (optional)
nano .env

# The script will auto-generate secure values for:
# - __SECURE_POSTGRES_PASSWORD__ → 24-char password
# - __SECURE_REDIS_PASSWORD__ → 20-char password
# - __SECURE_JWT_SECRET__ → 64-char base64 secret
# - __SECURE_MINIO_PASSWORD__ → 20-char password
# - __SECURE_PGADMIN_PASSWORD__ → 16-char password
# - __SECURE_GRAFANA_PASSWORD__ → 16-char password
```

### 3. Advanced Deployment Options
```bash
# Full deployment with all features
./deploy-simple.sh --autopush --verbose

# Force regenerate passwords and push to git
./deploy-simple.sh --force-regen --autopush

# Preview what would happen without executing
./deploy-simple.sh --dry-run --verbose
```

### 4. Git Autopush Features
```bash
# Automatic git operations (when --autopush is used):
# 1. Detects if repository is initialized
# 2. Checks for git user configuration
# 3. Adds all changes to staging
# 4. Creates timestamped commit message
# 5. Pushes to remote origin (if configured)

# Manual git operations:
git add .
git commit -m "🚀 KataCore deployment update - $(date '+%Y-%m-%d %H:%M:%S')"
git push origin main
```

### 5. Configure Nginx (on host server)
Create an Nginx configuration file to proxy requests to the Docker containers:

```nginx
server {
    listen 80;
    server_name your-domain.com;

    # API proxy
    location /api/ {
        proxy_pass http://localhost:3001/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }

    # Site proxy
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
}
```

## Management Commands

### Enhanced Deployment Script
```bash
# Show help and all options
./deploy-simple.sh --help

# Simple deployment
./deploy-simple.sh

# Deployment with git autopush
./deploy-simple.sh --autopush

# Force regenerate all passwords and secrets
./deploy-simple.sh --force-regen

# Verbose output for debugging
./deploy-simple.sh --verbose

# Dry run to preview changes
./deploy-simple.sh --dry-run

# Combined options
./deploy-simple.sh --autopush --verbose --force-regen
```

### Password Management
```bash
# Passwords are auto-generated with these lengths:
# - PostgreSQL: 24 characters (alphanumeric + special chars)
# - Redis: 20 characters (alphanumeric + special chars)
# - MinIO: 20 characters (alphanumeric + special chars)
# - pgAdmin: 16 characters (alphanumeric + special chars)
# - JWT Secret: 64 characters (base64 encoded)
# - Grafana: 16 characters (alphanumeric + special chars)

# Force regenerate all passwords
./deploy-simple.sh --force-regen

# Check current environment (passwords will be generated)
cat .env | grep -E "(PASSWORD|SECRET|ACCESS_KEY)"

# Password generation algorithm:
# 1. Uses OpenSSL for cryptographically secure random generation
# 2. Falls back to /dev/urandom for better entropy
# 3. Character set includes: a-z, A-Z, 0-9, and special characters
# 4. Preserves existing passwords unless --force-regen is used
```

### Security Best Practices
```bash
# The deployment script follows these security practices:
# ✅ Cryptographically secure password generation
# ✅ Strong character sets with mixed case and special characters
# ✅ Appropriate password lengths for each service
# ✅ Base64 encoding for JWT secrets
# ✅ Automatic placeholder replacement
# ✅ Validation of environment variables
# ✅ No hardcoded secrets in the codebase

# After deployment, consider:
# - Changing default service ports for additional security
# - Setting up firewall rules
# - Enabling SSL/TLS for all services
# - Regular password rotation
# - Monitoring and logging
```

### Git Autopush
```bash
# Check git status
git status

# Manual git operations
git add .
git commit -m "deployment update"
git push

# Automatic with deployment
./deploy-simple.sh --autopush
```

### Container Operations
```bash
# Start services
docker-compose -f docker-compose.prod.yml up -d

# Stop services
docker-compose -f docker-compose.prod.yml down

# Restart services
docker-compose -f docker-compose.prod.yml restart

# View logs (all services)
docker-compose -f docker-compose.prod.yml logs -f

# View logs (specific service)
docker-compose -f docker-compose.prod.yml logs -f api
docker-compose -f docker-compose.prod.yml logs -f site

# Check container status
docker-compose -f docker-compose.prod.yml ps

# Rebuild containers
docker-compose -f docker-compose.prod.yml build
```

### Health Checks and Validation
```bash
# The deployment script includes automatic:
# - Environment variable validation
# - Docker availability check
# - Container health checks
# - Service connectivity tests

# Manual health checks
curl http://localhost:3001/health  # API health
curl http://localhost:3000         # Site health

# Check container health status
docker inspect katacore-api-prod --format='{{.State.Health.Status}}'
docker inspect katacore-site-prod --format='{{.State.Health.Status}}'
```

## Service URLs

- **API**: http://116.118.85.41:3001
- **Site**: http://116.118.85.41:3000
- **Through Nginx**: http://your-domain.com

## Troubleshooting

### 1. Password Generation Issues
```bash
# Check if OpenSSL is available
which openssl

# If OpenSSL is not available, install it
sudo apt-get update && sudo apt-get install openssl

# Manually generate a password for testing
openssl rand -base64 32 | tr -d "=+/" | cut -c1-24
```

### 2. Check Container Status
```bash
docker ps
docker-compose -f docker-compose.prod.yml ps
```

### 3. Check Container Logs
```bash
docker-compose -f docker-compose.prod.yml logs api
docker-compose -f docker-compose.prod.yml logs site
```

### 4. Test API Health
```bash
curl http://localhost:3001/health
```

### 5. Test Site
```bash
curl http://localhost:3000
```

### 6. Check Environment Variables
```bash
docker-compose -f docker-compose.prod.yml config
```

### 7. Git Autopush Issues
```bash
# Check git configuration
git config --list

# Check git status
git status

# Check if remote is configured
git remote -v

# Set up git user if needed
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### 8. Common Issues and Solutions

#### Environment Variables Not Set
```bash
# Check for remaining placeholders
grep -n "__SECURE_" .env

# Force regenerate passwords
./deploy-simple.sh --force-regen
```

#### Docker Permission Issues
```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Log out and log back in, or run:
newgrp docker
```

#### Port Already in Use
```bash
# Check what's using the port
sudo lsof -i :3001
sudo lsof -i :3000

# Stop conflicting services
sudo systemctl stop <service-name>
```

#### Database Connection Issues
```bash
# Check if PostgreSQL is running on host
sudo systemctl status postgresql

# Check if Redis is running on host
sudo systemctl status redis

# Check if MinIO is running on host
sudo systemctl status minio
```

## Benefits of This Approach

1. **Simplified Container Management**: Only application containers in Docker
2. **Better Performance**: Database and cache on host for optimal performance
3. **Easier Nginx Management**: Direct access to Nginx configuration on host
4. **Resource Efficiency**: Shared resources between host services
5. **Easier SSL Management**: SSL certificates managed directly on host Nginx

## Notes

- Make sure external services (PostgreSQL, Redis, MinIO) are accessible from Docker containers
- Update firewall rules to allow Docker containers to access host services
- Consider using Docker networks for better security if needed
- Monitor resource usage and adjust container limits as needed
