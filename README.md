# KataCore

> 🚀 **Modern Full-stack Application with Universal Cloud Deployment**

KataCore is a production-ready full-stack application built with the latest technologies. Deploy to any cloud server in minutes with zero configuration.

## ✨ Features

- 🌐 **Universal Cloud Deployment** - Deploy to ANY server with one command
- 🔧 **Zero-configuration Setup** - Automatic server setup and security
- ⚡ **Ultra-fast Development** - Powered by Bun.js and Next.js 15
- 🛡️ **Production Ready** - Docker, SSL, monitoring included
- 🔐 **Secure by Default** - Auto-generated passwords, firewall, SSL

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
bun run deploy:universal       # Deploy to any cloud server
bun run deploy:universal:clean # Clean deploy (removes old containers)
bun run deploy:setup-only      # Setup server only
bun run deploy:deploy-only     # Deploy only (skip setup)
```

### Git Automation
```bash
bun run git:push        # Auto commit and push
bun run git:save        # Quick save with timestamp
bun run git:build-push  # Build then push
```

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
