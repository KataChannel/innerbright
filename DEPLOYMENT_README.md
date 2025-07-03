# KataCore Simple Deployment System

🚀 **Complete containerized deployment solution for KataCore with automatic password generation and Git autopush functionality.**

## ✨ Features

- **🔐 Automatic Password Generation**: Cryptographically secure passwords for all services
- **📤 Git Autopush**: Automatic git commits and push after successful deployments
- **🐳 Container Management**: Simplified Docker container deployment
- **🛡️ Security First**: No hardcoded secrets, all passwords auto-generated
- **📊 Health Monitoring**: Built-in health checks for all services
- **🎛️ Advanced Options**: Dry run, verbose output, force regeneration

## 🚀 Quick Start

### 1. Make Scripts Executable
```bash
chmod +x deploy-simple.sh
chmod +x test-deployment.sh
```

### 2. Test Your Environment
```bash
# Run comprehensive tests
./test-deployment.sh

# Test deployment without actually deploying
./deploy-simple.sh --dry-run --verbose
```

### 3. Deploy with Auto-Generated Passwords
```bash
# Simple deployment
./deploy-simple.sh

# Deployment with git autopush
./deploy-simple.sh --autopush

# Force regenerate all passwords
./deploy-simple.sh --force-regen
```

## 🔐 Security Features

### Auto-Generated Passwords
- **PostgreSQL**: 24-character secure password
- **Redis**: 20-character secure password
- **MinIO**: 20-character secure password
- **pgAdmin**: 16-character secure password
- **JWT Secret**: 64-character base64 encoded
- **Grafana**: 16-character secure password

### Security Best Practices
- Uses OpenSSL for cryptographically secure random generation
- Fallback to `/dev/urandom` for better entropy
- Strong character sets with mixed case and special characters
- No hardcoded secrets in codebase
- Automatic placeholder replacement

## 📂 Architecture

### What Runs in Docker
- ✅ **API (NestJS)** - Port 3001
- ✅ **Site (Next.js)** - Port 3000

### What Runs on Host Server (116.118.85.41)
- 🌐 **Nginx** (reverse proxy, SSL termination)
- 🗄️ **PostgreSQL** database
- 🚀 **Redis** cache
- 📦 **MinIO** object storage

## 🎛️ Command Reference

### Deployment Options
```bash
# Basic deployment
./deploy-simple.sh

# Show help
./deploy-simple.sh --help

# Dry run (preview changes)
./deploy-simple.sh --dry-run

# Verbose output
./deploy-simple.sh --verbose

# Force regenerate passwords
./deploy-simple.sh --force-regen

# Enable git autopush
./deploy-simple.sh --autopush

# Combined options
./deploy-simple.sh --autopush --verbose --force-regen
```

### Container Management
```bash
# Start containers
docker-compose -f docker-compose.prod.yml up -d

# Stop containers
docker-compose -f docker-compose.prod.yml down

# View logs
docker-compose -f docker-compose.prod.yml logs -f

# Check container status
docker-compose -f docker-compose.prod.yml ps

# Restart containers
docker-compose -f docker-compose.prod.yml restart
```

### Testing
```bash
# Run comprehensive tests
./test-deployment.sh

# Check API health
curl http://localhost:3001/health

# Check site health
curl http://localhost:3000
```

## 🔧 Configuration

### Environment Variables
The system automatically generates a `.env` file from `.env.example` and replaces all placeholders with secure values:

```env
# Auto-generated secure passwords
POSTGRES_PASSWORD=<24-char-password>
REDIS_PASSWORD=<20-char-password>
MINIO_ROOT_PASSWORD=<20-char-password>
PGADMIN_PASSWORD=<16-char-password>
JWT_SECRET=<64-char-base64-secret>
GRAFANA_ADMIN_PASSWORD=<16-char-password>
```

### Git Configuration (for autopush)
```bash
# Set up git user
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Add remote repository
git remote add origin <your-repository-url>
```

## 🌐 Nginx Configuration

Create `/etc/nginx/sites-available/katacore`:

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

## 🚨 Troubleshooting

### Common Issues

#### Password Generation Issues
```bash
# Check OpenSSL availability
which openssl

# Install OpenSSL if missing
sudo apt-get update && sudo apt-get install openssl

# Manually test password generation
openssl rand -base64 32 | tr -d "=+/" | cut -c1-24
```

#### Docker Issues
```bash
# Check Docker status
docker --version
docker-compose --version

# Fix Docker permissions
sudo usermod -aG docker $USER
newgrp docker
```

#### Port Conflicts
```bash
# Check what's using ports
sudo lsof -i :3001
sudo lsof -i :3000

# Stop conflicting services
sudo systemctl stop <service-name>
```

### Service URLs
- **API**: http://116.118.85.41:3001
- **Site**: http://116.118.85.41:3000
- **Through Nginx**: http://your-domain.com

## 📚 Documentation

- **[SIMPLE_DEPLOYMENT.md](./SIMPLE_DEPLOYMENT.md)** - Comprehensive deployment guide
- **[docker-compose.prod.yml](./docker-compose.prod.yml)** - Production container configuration
- **[.env.example](./.env.example)** - Environment variable template

## 🔄 Workflow

1. **Test Environment**: `./test-deployment.sh`
2. **Preview Changes**: `./deploy-simple.sh --dry-run`
3. **Deploy**: `./deploy-simple.sh --autopush`
4. **Monitor**: `docker-compose -f docker-compose.prod.yml logs -f`

## 🎯 Benefits

- **Simplified Management**: Only essential containers in Docker
- **Enhanced Security**: Auto-generated passwords, no hardcoded secrets
- **Better Performance**: External services on host for optimal performance
- **Easy Maintenance**: Direct access to services and configuration
- **Automated Workflows**: Git autopush, health checks, validation

## 📦 What's Included

- **deploy-simple.sh** - Main deployment script
- **test-deployment.sh** - Comprehensive test suite
- **docker-compose.prod.yml** - Production container configuration
- **.env.example** - Environment template
- **SIMPLE_DEPLOYMENT.md** - Detailed deployment guide

---

**Made with ❤️ for KataCore** - Simple, secure, and scalable deployment solution.
