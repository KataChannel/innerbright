# 🚀 KataCore StartKit v1

> **Production-ready full-stack application with universal cloud deployment**

[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com/yourusername/katacore-startkit)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Bun](https://img.shields.io/badge/bun-1.0+-yellow.svg)](https://bun.sh)
[![Docker](https://img.shields.io/badge/docker-supported-blue.svg)](https://docker.com)

KataCore StartKit v1 is a complete, production-ready full-stack application that can be deployed to any cloud server in minutes with **zero configuration**. Built with modern technologies and optimized for performance, security, and scalability.

## 🌟 What's New in StartKit v1

- 🎯 **Interactive Setup Wizard** - `./quick-start.sh` for guided setup
- 🚀 **Enhanced StartKit Deployer** - Improved `startkit-deployer.sh` with advanced options
- 🔧 **Smart Environment Management** - Automatic secure password generation
- ⚡ **Optimized Performance** - Docker layer caching and smart rebuild strategies
- 🛡️ **Enhanced Security** - UFW firewall, Fail2ban, and SSL automation
- 📊 **Better Monitoring** - Health checks, logging, and admin interfaces

## ✨ Features

- 🌐 **Universal Cloud Deployment** - Deploy to ANY server with one command
- 🎯 **Interactive Setup Wizard** - Guided setup with `./quick-start.sh`
- 🚀 **StartKit Deployer** - Advanced deployment with `./startkit-deployer.sh`
- 🔧 **Zero-configuration Setup** - Automatic server setup and security
- ⚡ **Ultra-fast Development** - Powered by Bun.js and Next.js 15
- 🛡️ **Production Ready** - Docker, SSL, monitoring included
- 🔐 **Secure by Default** - Auto-generated passwords, firewall, SSL
- 📊 **Advanced Caching** - Docker layer caching and smart rebuild strategies
- 🎯 **Environment Management** - Auto-generation and validation of environment files
- 🔍 **Multiple Deploy Modes** - Full, setup-only, config-only, and clean deployments

## 🏗️ Tech Stack

- **Frontend**: Next.js 15 + React 19 + Tailwind CSS 4
- **Backend**: NestJS 11 + TypeScript 5  
- **Runtime**: Bun.js
- **Database**: PostgreSQL + Redis + MinIO
- **Deployment**: Docker + Nginx + SSL

## 🚀 Quick Start

### Prerequisites
- **Bun.js** (v1.0.0+) - [Install here](https://bun.sh)
- **Linux server** for production deployment

### 1. Clone & Install
```bash
git clone <your-repo-url>
cd KataCore
bun run install:all
```

### 2. Interactive Setup 🎯
```bash
# Run the interactive setup wizard
./quick-start.sh

# Or use individual commands:
bun run dev                # Start development
bun run test               # Run tests
```

### 3. Development
```bash
# Start both frontend and backend
bun run dev

# Frontend: http://localhost:3000
# Backend: http://localhost:3001
# API Docs: http://localhost:3001/api/docs
```

### 4. **Deploy to Production** ⭐
```bash
# 🎯 StartKit v1 Deployer (Recommended)
./startkit-deployer.sh --host YOUR_SERVER_IP

# With custom domain + SSL
./startkit-deployer.sh --host YOUR_SERVER_IP --domain yourdomain.com

# Advanced deployment options
./startkit-deployer.sh --host YOUR_SERVER_IP --clean           # Clean deployment  
./startkit-deployer.sh --host YOUR_SERVER_IP --setup-only      # Setup only
./startkit-deployer.sh --host YOUR_SERVER_IP --config-only     # Config only
./startkit-deployer.sh --host YOUR_SERVER_IP --force-rebuild   # Force rebuild
./startkit-deployer.sh --host YOUR_SERVER_IP --dry-run         # Preview changes

# Interactive deployment via quick-start
./quick-start.sh    # Choose option 2 for guided deployment
```

### 5. **Post-Deployment Access** 🎯
After deployment, you get instant access to:
- ✅ **Frontend**: https://your-domain.com
- ✅ **API**: https://your-domain.com/api
- ✅ **API Docs**: https://your-domain.com/api/docs
- ✅ **pgAdmin**: https://your-domain.com:8080
- ✅ **MinIO Console**: https://your-domain.com:9001
- ✅ **Health Check**: https://your-domain.com/health
- ✅ **Auto SSL** with Let's Encrypt
- ✅ **Security** hardening & monitoring

### 6. **Environment Management** 🔧
```bash
# Create environment template
./startkit-deployer.sh --create-env-template
# Or: bun run env:create-template

# Show template content
bun run env:show-template

# Validate configuration
bun run env:validate
```

## 🎯 **StartKit v1 Deployment Options**

### 🚀 **Interactive Setup**
```bash
# Get started with the interactive wizard
./quick-start.sh    # Guided setup with menu options
```

### ⚡ **Direct Deployment**
```bash
# Basic deployment
./startkit-deployer.sh --host 192.168.1.100

# With custom domain + SSL
./startkit-deployer.sh --host myserver.com --domain myapp.com

# Advanced options
./startkit-deployer.sh --host 192.168.1.100 --clean --verbose
./startkit-deployer.sh --host 192.168.1.100 --setup-only --dry-run
```

### 📋 **Deployment Modes**

| Mode | Command | Description |
|------|---------|-------------|
| **Full Deploy** | `--host SERVER_IP` | Complete deployment (recommended) |
| **Clean Deploy** | `--clean` | Remove existing containers first |
| **Setup Only** | `--setup-only` | Install Docker & setup server |
| **Config Only** | `--config-only` | Update configuration files |
| **Force Rebuild** | `--force-rebuild` | Rebuild all Docker images |
| **Dry Run** | `--dry-run` | Preview what would be done |

### 🛡️ **Production Security**
- 🔐 Auto-generated secure passwords (16-24 chars)
- 🔥 UFW Firewall + Fail2ban intrusion prevention  
- 🛡️ HTTPS with Let's Encrypt SSL automation
- 🚨 Security headers (HSTS, CSP, X-Frame-Options)
- 🔒 Non-root Docker containers
- 🚫 Rate limiting on API endpoints

### 📊 **Monitoring & Administration**
Post-deployment interfaces:
- **pgAdmin**: Database management at `:8080`
- **MinIO Console**: Object storage admin at `:9001`
- **Health Checks**: Automatic service monitoring at `/health`
- **API Documentation**: Interactive docs at `/api/docs`
- **Log Aggregation**: Centralized logging with Docker

## 🌐 StartKit v1 Deployment

Deploy to **any** cloud server (AWS, DigitalOcean, Vultr, Hetzner, etc.) with zero configuration!

### Quick Deploy Commands

```bash
# 🚀 StartKit v1 Deployer (Recommended)
./startkit-deployer.sh --host 192.168.1.100

# With custom domain + SSL
./startkit-deployer.sh --host myserver.com --domain mydomain.com

# Clean installation (removes old containers)
./startkit-deployer.sh --host 192.168.1.100 --clean

# Setup server only (install Docker, security)
./startkit-deployer.sh --host 192.168.1.100 --setup-only

# Configuration update only (fastest)
./startkit-deployer.sh --host 192.168.1.100 --config-only
```

### Deployment Options

| Option | Description | Example |
|--------|-------------|---------|
| `--host` | Server IP or domain | `--host 192.168.1.100` |
| `--domain` | Custom domain for SSL | `--domain mydomain.com` |
| `--user` | SSH user (default: root) | `--user ubuntu` |
| `--port` | SSH port (default: 22) | `--port 2222` |
| `--clean` | Remove old containers | `--clean` |
| `--setup-only` | Server setup only | `--setup-only` |
| `--config-only` | Configuration only | `--config-only` |
| `--force-rebuild` | Force rebuild images | `--force-rebuild` |
| `--dry-run` | Preview changes | `--dry-run` |
| `--verbose` | Detailed logging | `--verbose` |

## 📦 Available Scripts

### Development
```bash
bun run dev              # Start both frontend and backend
bun run dev:site         # Start Next.js frontend only
bun run dev:api          # Start NestJS backend only
bun run build            # Build both applications
bun run test             # Run tests
bun run lint             # Lint code
```

### Local Testing
```bash
bun run local:dev        # Start local Docker environment
bun run local:down       # Stop local Docker environment
bun run local:test       # Quick local test deployment
bun run local:logs       # View local container logs
```

### StartKit v1 Deployment
```bash
# Direct script usage (recommended for full control)
./startkit-deployer.sh --host SERVER_IP           # Deploy with StartKit v1
./startkit-deployer.sh --host SERVER_IP --clean   # Clean deployment
./startkit-deployer.sh --host SERVER_IP --setup-only      # Server setup only
./startkit-deployer.sh --host SERVER_IP --config-only     # Configuration only

# With domain and advanced options
./startkit-deployer.sh --host SERVER_IP --domain DOMAIN
./startkit-deployer.sh --host SERVER_IP --clean --verbose
./startkit-deployer.sh --host SERVER_IP --dry-run

# Note: Package.json scripts are for basic commands without parameters
# For deployment with parameters, use the script directly
```

### Environment Management
```bash
bun run env:create-template  # Create environment template
bun run env:show-template    # Display template content
bun run env:validate         # Validate configuration
```

## 🏗️ **Tech Stack**

- **Frontend**: Next.js 15 + React 19 + Tailwind CSS 4
- **Backend**: NestJS 11 + TypeScript 5  
- **Runtime**: Bun.js
- **Database**: PostgreSQL + Redis + MinIO
- **Deployment**: Docker + Nginx + SSL

## 🌐 **Universal Cloud Deployment**

Deploy to **any** cloud server (AWS, DigitalOcean, Vultr, etc.) with zero configuration!

### StartKit v1 Commands
```bash
# Basic deployment
bun run deploy:startkit YOUR_SERVER_IP

# With custom domain + SSL
bun run deploy:startkit YOUR_SERVER_IP --domain yourdomain.com

# Clean deployment (removes old containers)
bun run deploy:startkit:clean YOUR_SERVER_IP
```

### Deployment Options
| Option | Description | Example |
|--------|-------------|---------|
| `SERVER_IP` | Server IP or domain | `192.168.1.100` |
| `--domain` | Custom domain for SSL | `--domain mydomain.com` |
| `--clean` | Remove old containers | `--clean` |
| `--setup-only` | Server setup only | `--setup-only` |

📚 **For detailed optimization features, see [OPTIMIZATION_FEATURES.md](OPTIMIZATION_FEATURES.md)**

## 🏗️ Project Structure

```
KataCore/
├── 📁 site/                      # Next.js Frontend
│   ├── src/app/                  # App Router pages
│   ├── src/components/           # React components
│   └── package.json
├── 📁 api/                       # NestJS Backend
│   ├── src/                      # Source code
│   ├── prisma/                   # Database schema
│   └── package.json
├── 📁 nginx/                     # Nginx configuration
│   ├── nginx.conf               # Main config
│   └── conf.d/                  # Virtual hosts
├── 📁 scripts/                   # Deployment scripts
│   ├── backup.sh                # Database backup
│   ├── install-docker.sh        # Docker installation
│   └── validate-env.sh          # Environment validation
├── 🐳 docker-compose.local.yml   # Local development
├── 🐳 docker-compose.prod.yml    # Production deployment
├── 🚀 startkit-deployer.sh      # Main deployment script
├── 🎯 quick-start.sh             # Interactive setup wizard
├── 📄 .env.prod.template         # Environment template
├── 📄 README.md                  # Main documentation
├── 📄 README.startkit.md         # StartKit v1 guide
└── 📄 package.json               # Root workspace
```

## 🌍 Cloud Provider Support

Works with **any** cloud provider and VPS:
- ✅ **Major Clouds**: AWS EC2, Google Cloud, Azure, DigitalOcean
- ✅ **VPS Providers**: Vultr, Linode, Hetzner, OVH
- ✅ **Linux Distros**: Ubuntu, Debian, CentOS, RHEL, Fedora
- ✅ **Architectures**: x86_64, ARM64 (Apple Silicon compatible)

## 🔐 Security Features

- ✅ **Auto-generated secure passwords** for all services (16-24 characters)
- ✅ **UFW Firewall** automatically configured with minimal ports
- ✅ **Fail2Ban** intrusion prevention system
- ✅ **SSL certificates** via Let's Encrypt with auto-renewal
- ✅ **Security headers** (HSTS, CSP, X-Frame-Options, etc.)
- ✅ **Non-root Docker containers** for enhanced security
- ✅ **Rate limiting** on API endpoints and Nginx
- ✅ **Secure environment** variable handling

## 🎯 Production Architecture

```
Internet → Nginx (80/443) → Next.js (3000) + NestJS (3001)
                     ↓
               PostgreSQL (5432) + Redis (6379) + MinIO (9000)
                     ↓
            pgAdmin (8080) + MinIO Console (9001)
```

**Ports & Services:**
- **80/443**: Nginx reverse proxy with SSL
- **3000**: Next.js frontend (internal)
- **3001**: NestJS API (internal)
- **5432**: PostgreSQL database (internal)
- **6379**: Redis cache (internal)
- **9000**: MinIO storage (internal)
- **8080**: pgAdmin interface (external)
- **9001**: MinIO console (external)

## 🚨 Troubleshooting

### Common Issues & Solutions

1. **"❌ Server host is required. Use --host SERVER_IP" Error**
   ```bash
   # ❌ Wrong: Missing --host parameter
   ./startkit-deployer.sh
   
   # ❌ Wrong: Package scripts don't accept parameters
   bun run deploy:startkit --host 192.168.1.100
   
   # ✅ Correct: Always use direct script with --host
   ./startkit-deployer.sh --host 192.168.1.100
   
   # ✅ Correct: Use interactive setup
   ./quick-start.sh
   ```

2. **SSH Connection Failed**
   ```bash
   # Check SSH access first
   ssh root@YOUR_SERVER_IP
   
   # Use different user if needed
   ./startkit-deployer.sh --host YOUR_SERVER_IP --user ubuntu
   
   # Custom SSH port
   ./startkit-deployer.sh --host YOUR_SERVER_IP --port 2222
   ```

3. **Port Already in Use**
   ```bash
   # Clean deploy removes old containers
   ./startkit-deployer.sh --host YOUR_SERVER_IP --clean
   ```

4. **SSL Certificate Issues**
   ```bash
   # Ensure domain points to server IP first
   dig yourdomain.com
   
   # Then deploy with domain
   ./startkit-deployer.sh --host YOUR_SERVER_IP --domain yourdomain.com
   ```

5. **Environment Issues**
   ```bash
   # Create environment template
   ./startkit-deployer.sh --create-env-template
   
   # Validate environment
   bun run env:validate
   ```

### Debug Options

```bash
# Preview what will be done
./startkit-deployer.sh --host YOUR_SERVER_IP --dry-run

# Verbose logging
./startkit-deployer.sh --host YOUR_SERVER_IP --verbose

# Check deployment logs
ls -la .deploy-logs/
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Make your changes
4. Test deployment: `./startkit-deployer.sh --host test-server --dry-run`
5. Commit changes: `git commit -m 'Add amazing feature'`
6. Push to branch: `git push origin feature/amazing-feature`
7. Submit a pull request

### Development Guidelines
- Follow TypeScript best practices
- Test both local and production deployments
- Update documentation for new features
- Ensure security best practices

---

<div align="center">

**🚀 Ready to deploy?**

**Interactive Setup:** `./quick-start.sh`

**Direct Deploy:** `./startkit-deployer.sh --host YOUR_SERVER_IP`

---

**Made with ❤️ by the KataCore Team**

*Deploy once, run anywhere!*

</div>
