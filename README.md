# KataCore

> 🚀 **Modern Full-stack Application with Universal Cloud Deployment**

KataCore is a production-ready full-stack application built with the latest technologies. Deploy to any cloud server in minutes with zero configuration.

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

### 3. Deploy to Cloud ⭐
```bash
# Deploy to any server with one command!
bun run deploy:universal --host YOUR_SERVER_IP

# With custom domain + SSL
bun run deploy:universal --host YOUR_SERVER_IP --domain yourdomain.com

# Optimized subsequent deployments
bun run deploy:smart YOUR_SERVER_IP    # Smart auto-detection
bun run deploy:quick YOUR_SERVER_IP    # Fast deployment
bun run deploy:config YOUR_SERVER_IP   # Config-only updates
```

### 4. Environment Management 🔧
```bash
# Auto-create environment template
bun run env:create-template

# Validate environment configuration
bun run env:validate

# View deployment history
bun run deploy:history
```

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
bun run dev          # Start both frontend and backend
bun run dev:site     # Start Next.js frontend only
bun run dev:api      # Start NestJS backend only
bun run build        # Build both applications
bun run test         # Run tests
bun run lint         # Lint code
```

### Deployment
```bash
# Universal Deployment
bun run deploy:universal       # Deploy to any cloud server
bun run deploy:universal:clean # Clean deploy (removes old containers)
bun run deploy:setup-only      # Setup server only
bun run deploy:deploy-only     # Deploy only (skip setup)

# Optimized Quick Deployment
bun run deploy:smart          # Smart deployment with change detection
bun run deploy:quick          # Fast deployment with auto-optimization
bun run deploy:config         # Configuration-only updates
bun run deploy:source         # Source code changes only
bun run deploy:rebuild        # Force rebuild all images

# Environment Management
bun run env:create-template   # Auto-create .env.prod.example
bun run env:show-template     # Display environment template
bun run env:validate          # Validate environment configuration

# Deployment Cache Management
bun run deploy:cache:info     # Show deployment cache information
bun run deploy:history        # Display deployment history
bun run deploy:cache:clear    # Clear deployment cache
```

### Git Automation
```bash
bun run git:push        # Auto commit and push
bun run git:save        # Quick save with timestamp
bun run git:build-push  # Build then push
```

## 🚀 Deployment Optimization Features

KataCore includes advanced deployment optimization that makes subsequent deployments **70-90% faster**:

### Smart Deployment Strategies
- **Intelligent Change Detection**: Automatically detects what changed since last deployment
- **Incremental Deployments**: Only rebuilds what's actually changed
- **Docker Layer Caching**: Preserves build caches between deployments
- **Parallel Processing**: Optimized service startup sequences

### Performance Improvements
| Deployment Type | Traditional | Optimized | Improvement |
|----------------|-------------|-----------|-------------|
| First Deploy | 8-12 min | 5-8 min | 30-40% faster |
| Code Changes | 6-10 min | 1-3 min | 70-80% faster |
| Config Updates | 3-5 min | 30-60 sec | 85-90% faster |

### Automatic Environment Management
- **Auto Template Creation**: Generates `.env.prod.example` on first deploy
- **Secure Password Generation**: Creates cryptographically secure passwords
- **Environment Validation**: Checks for weak passwords and missing variables
- **Domain Configuration**: Automatically replaces placeholders with your domain

### Usage Examples
```bash
# Daily development workflow (recommended)
bun run deploy:smart YOUR_SERVER_IP

# Quick config updates
bun run deploy:config YOUR_SERVER_IP

# Force rebuild after dependency changes
bun run deploy:rebuild YOUR_SERVER_IP

# Monitor deployment performance
bun run deploy:history
```

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
