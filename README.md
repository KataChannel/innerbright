# 🚀 KataCore StartKit v1

> **Production-ready full-stack application with universal cloud deployment**

[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com/yourusername/katacore-startkit)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Bun](https://img.shields.io/badge/bun-1.0+-yellow.svg)](https://bun.sh)
[![Docker](https://img.shields.io/badge/docker-supported-blue.svg)](https://docker.com)

KataCore StartKit v1 is a complete, production-ready full-stack application that can be deployed to any cloud server in minutes with **zero configuration**. Built with modern technologies and optimized for performance, security, and scalability.

## ✨ Features

- 🌐 **Universal Cloud Deployment** - Deploy to ANY server with one command
- 🚀 **Smart Deployment Optimization** - Intelligent change detection and incremental deployments
- 🔧 **Zero-configuration Setup** - Automatic server setup and security
- ⚡ **Ultra-fast Development** - Powered by Bun.js and Next.js 15
- 🛡️ **Production Ready** - Docker, SSL, monitoring included
- 🔐 **Secure by Default** - Auto-generated passwords, firewall, SSL
- 📊 **Advanced Caching** - Docker layer caching and smart rebuild strategies
- 🎯 **Environment Management** - Auto-generation and validation of environment files

## 🏗️ Tech Stack

- **Frontend**: Next.js 15 + React 19 + Tailwind CSS 4
- **Backend**: NestJS 11 + TypeScript 5  
- **Runtime**: Bun.js
- **Database**: PostgreSQL + Redis + MinIO
- **Deployment**: Docker + Nginx + SSL

## 🚀 Quick Start

### Prerequisites
- **Bun.js** (v1.0.0+) - [Install here](https://bun.sh)

### 1. Clone & Install
```bash
git clone <your-repo-url>
cd KataCore
bun run install:all
```

### 2. Development
```bash
# Start both frontend and backend
bun run dev

# Frontend: http://localhost:3000
# Backend: http://localhost:3001
```

### 3. **Deploy to Cloud (StartKit v1)** ⭐
```bash
# Deploy to any server with one command!
bun run deploy:startkit YOUR_SERVER_IP

# With custom domain + SSL
bun run deploy:startkit YOUR_SERVER_IP --domain yourdomain.com

# StartKit deployment options
bun run deploy:startkit:clean YOUR_SERVER_IP    # Clean deployment
bun run deploy:startkit:setup YOUR_SERVER_IP    # Setup only  
bun run deploy:startkit:config YOUR_SERVER_IP   # Config only

# Legacy universal deployer (still supported)
bun run deploy:universal --host YOUR_SERVER_IP
```

### 4. **StartKit Features** 🎯
After deployment, you get:
- ✅ **Frontend**: https://your-domain.com
- ✅ **API**: https://your-domain.com/api
- ✅ **pgAdmin**: http://your-domain.com:8080
- ✅ **MinIO Console**: http://your-domain.com:9001
- ✅ **Auto SSL** with Let's Encrypt
- ✅ **Security** hardening & monitoring

### 5. **Environment Management** 🔧
```bash
# Auto-create environment template
bun run env:create-template

# Validate configuration
bun run env:validate

# View deployment history
bun run deploy:history
```

## 🎯 **StartKit v1 Highlights**

### ⚡ **Ultra-Fast Setup**
```bash
# Get started in 30 seconds
git clone <your-repo>
cd KataCore
./quick-start.sh    # Interactive setup wizard
```

### 🛡️ **Production Security**
- 🔐 Auto-generated secure passwords (16-24 chars)
- 🔥 UFW Firewall + Fail2ban protection  
- 🛡️ HTTPS with Let's Encrypt SSL
- 🚨 Security headers (HSTS, CSP, etc.)
- 🔒 Non-root Docker containers

### 📊 **Monitoring & Admin**
Post-deployment access:
- **pgAdmin**: Database management interface
- **MinIO Console**: Object storage administration
- **Health Checks**: Auto-recovery monitoring
- **Log Aggregation**: Centralized application logs

## 🌐 Universal Cloud Deployment

Deploy to **any** cloud server (AWS, DigitalOcean, Vultr, etc.) with zero configuration!

### Quick Deploy Commands

```bash
# Full deployment (recommended)
bun run deploy:universal --host 192.168.1.100

# Clean installation (removes old containers)
bun run deploy:universal:clean --host 192.168.1.100

# With custom domain + SSL
bun run deploy:universal --host myserver.com --domain mydomain.com
```

### Deploy Options

| Option | Description | Example |
|--------|-------------|---------|
| `--host` | Server IP or domain | `--host 192.168.1.100` |
| `--domain` | Custom domain for SSL | `--domain mydomain.com` |
| `--user` | SSH user (default: root) | `--user ubuntu` |
| `--clean` | Remove old containers | `--clean` |

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
bun run local:up         # Start local Docker environment
bun run local:down       # Stop local Docker environment
bun run local:test       # Quick local test deployment
bun run local:logs       # View local container logs
```

### Production Deployment
```bash
# StartKit v1 Deployer (Recommended)
bun run deploy:startkit SERVER_IP           # Deploy with StartKit v1
bun run deploy:startkit:clean SERVER_IP     # Clean deployment
bun run deploy:startkit:setup SERVER_IP     # Server setup only
bun run deploy:startkit:config SERVER_IP    # Configuration only

# Universal Deployer (Legacy)
bun run deploy:universal --host SERVER_IP   # Universal deployment
bun run deploy:universal:clean --host SERVER_IP  # Clean universal deployment
```

### Environment Management
```bash
bun run env:create-template  # Create environment template
bun run env:show-template    # Display template
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
├── site/                      # Next.js Frontend
│   ├── src/app/              # App Router pages
│   ├── src/components/       # React components
│   └── package.json
├── api/                       # NestJS Backend
│   ├── src/                  # Source code
│   ├── prisma/               # Database schema
│   └── package.json
├── docker-compose.yml         # Development setup
├── docker-compose.prod.yml    # Production setup
├── universal-deployer.sh      # Universal deployer
├── scripts/                   # Deployment scripts
├── nginx/                     # Nginx configuration
└── package.json              # Root workspace
```

## 🌍 Cloud Provider Support

Works with **any** cloud provider:
- ✅ DigitalOcean, AWS EC2, Vultr, Linode
- ✅ Hetzner, Google Cloud, Azure
- ✅ Any VPS running Ubuntu/CentOS

## 🔐 Security Features

- ✅ Auto-generated secure passwords for all services
- ✅ Firewall automatically configured
- ✅ SSL certificates via Let's Encrypt
- ✅ Non-root user support
- ✅ Secure environment variable handling

## 🎯 Production Architecture

```
Internet → Nginx (80/443) → Next.js (3000) + NestJS (3001)
                     ↓
               PostgreSQL (5432) + Redis (6379) + MinIO (9000)
```

## 🚨 Troubleshooting

### SSH Connection Failed
```bash
# Check SSH access first
ssh root@YOUR_SERVER_IP

# Use different user if needed
bun run deploy:universal --host YOUR_SERVER_IP --user ubuntu
```

### Port Already in Use
```bash
# Clean deploy removes old containers
bun run deploy:universal:clean --host YOUR_SERVER_IP
```

### SSL Certificate Issues
```bash
# Ensure domain points to server
bun run deploy:universal --host YOUR_SERVER_IP --domain yourdomain.com
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test deployment
5. Submit a pull request

---

<div align="center">

**🚀 Ready to deploy? Run `bun run deploy:universal --host YOUR_SERVER_IP`**

</div>
