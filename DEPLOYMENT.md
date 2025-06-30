# KataCore Deployment Guide

## 🚀 Universal Cloud Deployer v2.0

The KataCore Universal Deployer is a comprehensive deployment solution that can deploy your application to **any** cloud server with automated setup and configuration.

## ✨ Features

- **🔧 Automatic Server Setup**: Installs Docker, configures firewall, sets up dependencies
- **🔐 Secure by Default**: Generates random secure passwords for all services
- **📦 Smart Docker Handling**: Detects and handles both regular and snap-installed Docker Compose
- **🌐 SSL Ready**: Automatic SSL certificate setup with Let's Encrypt (when domain provided)
- **🧹 Clean Deployment**: Option to remove old containers and start fresh
- **⚡ Flexible Modes**: Setup-only, deploy-only, or full deployment
- **🎨 Beautiful CLI**: Colored output with progress indicators
- **🔄 Error Recovery**: Comprehensive error handling and recovery mechanisms

## 🏃‍♂️ Quick Start

### Basic Deployment (IP Address)
```bash
bun run deploy:universal --host 192.168.1.100
```

### Domain-based Deployment (with SSL)
```bash
bun run deploy:universal --host myserver.com --domain mydomain.com
```

### Clean Installation
```bash
bun run deploy:universal:clean --host 192.168.1.100
```

## 📋 Available Commands

### Universal Deployer (Recommended)
```bash
# Full deployment with auto-setup
bun run deploy:universal --host SERVER_IP

# Clean deployment (removes old containers)
bun run deploy:universal:clean --host SERVER_IP

# Setup server only (no deployment)
bun run deploy:setup-only --host SERVER_IP

# Deploy only (skip server setup)
bun run deploy:deploy-only --host SERVER_IP
```

### Legacy Scripts (Still Available)
```bash
# Legacy cloud deployment
bun run deploy:local
bun run deploy:remote

# Docker management
bun run docker:prod
bun run docker:prod:down
bun run docker:prod:build
```

## 🔧 Configuration Options

### Required Parameters
- `--host IP/DOMAIN`: Server host (required)

### Optional Parameters
- `--user USER`: SSH user (default: root)
- `--port PORT`: SSH port (default: 22)
- `--path PATH`: Deploy path (default: /opt/katacore)
- `--domain DOMAIN`: Domain for SSL (default: server IP)
- `--clean`: Clean install (remove old containers)
- `--setup-only`: Only setup server, don't deploy
- `--deploy-only`: Only deploy, skip server setup

## 📚 Examples

### 1. Basic VPS Deployment
```bash
bun run deploy:universal --host 1.2.3.4
```

### 2. Ubuntu Server with Custom User
```bash
bun run deploy:universal --host myserver.com --user ubuntu
```

### 3. Custom Port and Path
```bash
bun run deploy:universal --host 192.168.1.100 --port 2222 --path /home/deploy/katacore
```

### 4. Production Domain with SSL
```bash
bun run deploy:universal --host myserver.com --domain katacore.example.com
```

### 5. Clean Reinstall
```bash
bun run deploy:universal --host 1.2.3.4 --clean
```

## 🛠 What the Deployer Does

### 🔧 Server Setup Phase
1. **System Update**: Updates package manager and system packages
2. **Docker Installation**: Installs Docker and Docker Compose
3. **Firewall Configuration**: Opens necessary ports (80, 443, 22)
4. **User Permissions**: Adds user to docker group
5. **Directory Setup**: Creates deployment directory with proper permissions

### 📦 Deployment Phase
1. **Code Transfer**: Syncs project files to server
2. **Environment Setup**: Creates `.env.prod` with secure random passwords
3. **Docker Compose**: Generates production docker-compose.yml
4. **Build & Deploy**: Builds and starts all services
5. **Health Check**: Verifies all services are running correctly

### 🔐 Security Features
- Random secure passwords for all databases and services
- Firewall configuration with minimal open ports
- SSL certificate generation (when domain provided)
- Non-root user support with proper Docker permissions

## 🐳 Docker Services

The deployment includes these services:

- **🌐 Nginx**: Reverse proxy and web server
- **🖥 Site**: Next.js frontend application
- **🔧 API**: NestJS backend application
- **🗄 PostgreSQL**: Database server
- **📨 Redis**: Cache and session store
- **💾 Backup**: Automated backup service

## 📊 Monitoring & Management

### Check Service Status
```bash
bun run monitor:status
```

### View Logs
```bash
bun run logs          # All services
bun run logs:api      # API only
bun run logs:site     # Site only
bun run logs:nginx    # Nginx only
```

### Create Backup
```bash
bun run backup
```

## 🔧 Troubleshooting

### Common Issues

#### 1. Docker Compose Command Not Found
The deployer automatically detects and fixes snap-installed Docker Compose issues.

#### 2. Permission Denied
```bash
# Fix Docker permissions
bun run docker:fix
```

#### 3. Port Already in Use
```bash
# Stop existing services
bun run docker:prod:down
# Clean deployment
bun run deploy:universal:clean --host YOUR_SERVER
```

#### 4. SSL Certificate Issues
Ensure your domain points to the server IP and ports 80/443 are accessible.

### Manual Debugging

#### Connect to Server
```bash
ssh root@YOUR_SERVER_IP
```

#### Check Docker Status
```bash
docker ps
docker compose -f /opt/katacore/docker-compose.prod.yml logs
```

#### Check Service Health
```bash
curl http://localhost
curl http://localhost/api/health
```

## 🎯 Migration from Old Scripts

If you were using the old deployment scripts, the universal deployer is backward compatible:

```bash
# Old way
./scripts/deploy-cloud.sh --remote

# New way (recommended)
bun run deploy:universal --host YOUR_SERVER
```

## 🆘 Support

If you encounter issues:

1. Check the deployment logs during execution
2. Verify server connectivity: `ssh user@server`
3. Check Docker status on server: `docker ps`
4. Review service logs: `bun run logs`

For additional help, check the server setup logs and Docker service status.

---

**✨ The Universal Deployer makes cloud deployment simple, secure, and reliable!**
