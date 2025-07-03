# 🚀 KataCore StartKit v1

> **Production-ready full-stack application with automated deployment**

[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com/chikiet/KataCore)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Bun](https://img.shields.io/badge/bun-1.0+-yellow.svg)](https://bun.sh)
[![Docker](https://img.shields.io/badge/docker-supported-blue.svg)](https://docker.com)
[![Next.js](https://img.shields.io/badge/next.js-15.3.4-black.svg)](https://nextjs.org)
[![NestJS](https://img.shields.io/badge/nestjs-11.1.3-red.svg)](https://nestjs.com)

**KataCore StartKit v1** is a modern full-stack application built with Next.js 15, React 19, NestJS 11, and Bun.js. It provides automated remote deployment with Docker, SSL support, and production-ready infrastructure out of the box.

---

## 🌟 **Features**

### **Full-Stack Application**
- 🚀 **Next.js 15** - Modern React framework with Turbopack for ultra-fast development
- ⚛️ **React 19** - Latest React with improved concurrent features
- 🎨 **Tailwind CSS 4** - Utility-first CSS framework for rapid UI development
- 🏗️ **NestJS 11** - Scalable TypeScript backend framework
- ⚡ **Bun.js Runtime** - Ultra-fast JavaScript runtime for both frontend and backend
- 🗄️ **Prisma ORM** - Type-safe database access with PostgreSQL
- 🔐 **Authentication** - JWT-based auth with bcrypt password hashing

### **Database & Infrastructure**
- 🐘 **PostgreSQL** - Robust relational database with full SQL support
- 🗃️ **Redis** - High-performance caching and session storage
- 📦 **MinIO** - S3-compatible object storage for file uploads
- 🔧 **pgAdmin** - Web-based PostgreSQL administration
- 📊 **Health Monitoring** - Built-in health checks for all services

### **Development & Deployment**
- 🎯 **Remote Deployment** - One-command deployment to any server
- 🔒 **Auto-SSL Configuration** - Let's Encrypt certificates with auto-renewal
- 🛡️ **Security-First** - Auto-generated secure passwords and secrets
- 🚀 **Two Deployment Modes** - Simple (IP-based) and Full (Domain + SSL)
- 🐳 **Docker Stack** - Complete containerized deployment
- 🧹 **Easy Cleanup** - Simple cleanup of remote deployments
- 📝 **TypeScript** - Full type safety across the stack

---

## 🏗️ **Technology Stack**

| Layer | Component | Technology | Version | Purpose |
|-------|-----------|------------|---------|---------|
| **Frontend** | Web Framework | Next.js | 15.3.4 | React-based web framework with SSR/SSG |
| | UI Library | React | 19.x | Modern UI library with concurrent features |
| | Styling | Tailwind CSS | 4.x | Utility-first CSS framework |
| | Build Tool | Turbopack | Latest | Ultra-fast bundler for development |
| **Backend** | API Framework | NestJS | 11.1.3 | Scalable TypeScript framework |
| | Runtime | Bun.js | 1.x | High-performance JavaScript runtime |
| | Database ORM | Prisma | 5.20.0 | Type-safe database client |
| | Authentication | JWT + bcrypt | Latest | Secure token-based authentication |
| **Database** | Primary DB | PostgreSQL | 15-alpine | Reliable relational database |
| | Cache/Session | Redis | 7-alpine | In-memory data structure store |
| | Object Storage | MinIO | Latest | S3-compatible file storage |
| | DB Admin | pgAdmin | Latest | Web-based PostgreSQL management |
| **Infrastructure** | Containerization | Docker | Latest | Application containerization |
| | Orchestration | Docker Compose | Latest | Multi-container deployment |
| | Reverse Proxy | Nginx | Latest | Load balancing and SSL termination |
| | SSL Certificates | Let's Encrypt | Latest | Free SSL certificate automation |

---

## 🚀 **Quick Start**

### **Prerequisites**
- **Bun.js** (v1.0+) - [Install Bun](https://bun.sh)
- **Docker** & **Docker Compose** (for deployment)
- **Node.js** (v18+) as fallback runtime
- **Git** for version control

### **1. Clone & Setup**
```bash
# Clone the repository
git clone https://github.com/chikiet/KataCore.git
cd KataCore

# Make deployment script executable
chmod +x deploy-remote.sh

# Install all dependencies (frontend + backend)
bun run install:all
```

### **2. Local Development**
```bash
# Start both frontend and backend in development mode
bun run dev

# Or start individually
bun run dev:site    # Frontend (Next.js) on http://localhost:3000
bun run dev:api     # Backend (NestJS) on http://localhost:3001
```

**Development URLs:**
- 🌐 **Frontend**: http://localhost:3000
- 🔌 **API**: http://localhost:3001
- ❤️ **Health Check**: http://localhost:3001/health

### **3. Build for Production**
```bash
# Build both applications
bun run build

# Or build individually
bun run build:site  # Build Next.js application
bun run build:api   # Build NestJS application
```
### **4. Remote Deployment** 🚀

**For deployment to remote servers:**

#### **Simple Deployment (IP-based)**
```bash
# Deploy to server with IP only (no SSL)
./deploy-remote.sh --simple 116.118.85.41 yourdomain.com
```

#### **Full Deployment (Domain + SSL)**
```bash
# Deploy to server with domain and SSL
./deploy-remote.sh 116.118.85.41 yourdomain.com
```

#### **Advanced Options**
```bash
# Custom SSH user and key
./deploy-remote.sh --user ubuntu --key ~/.ssh/my-key.pem 116.118.85.41 yourdomain.com

# Force regenerate environment variables
./deploy-remote.sh --force-regen 116.118.85.41 yourdomain.com

# Custom project name
./deploy-remote.sh --project myproject 116.118.85.41 yourdomain.com
```

#### **Cleanup Deployment**
```bash
# Remove deployment from remote server
./deploy-remote.sh --cleanup 116.118.85.41
```

**Requirements for remote deployment:**
- SSH access to remote server
- Docker & Docker Compose on remote server (auto-installed)
- Domain name (for full deployment with SSL)

---

## 🎯 **Deployment Options**

### **Development Mode** (Local)
```bash
# Start development servers
bun run dev  # Both frontend + backend
```
**Access:**
- 🌐 Frontend: http://localhost:3000
- 🔌 API: http://localhost:3001/health

### **Simple Deployment** (IP-based)
```bash
./deploy-remote.sh --simple SERVER_IP DOMAIN
```
**Features:**
- ✅ Docker containers only
- ✅ IP address access
- ✅ No SSL configuration
- ✅ Perfect for staging/testing

**Access:**
- Site: `http://SERVER_IP:3000`
- API: `http://SERVER_IP:3001`
- MinIO: `http://SERVER_IP:9000`
- pgAdmin: `http://SERVER_IP:5050`

### **Full Deployment** (Production)
```bash
./deploy-remote.sh SERVER_IP DOMAIN
```
**Features:**
- ✅ Docker containers + Nginx
- ✅ Domain with SSL certificates
- ✅ Production-ready configuration
- ✅ Security headers and optimizations

**Access:**
- Site: `https://yourdomain.com`
- API: `https://yourdomain.com/api`
- MinIO: `https://yourdomain.com/minio`
- pgAdmin: `https://yourdomain.com/pgadmin`

---

## 🏛️ **Application Architecture**

### **Project Structure**
```
KataCore/
├── 📁 api/                     # NestJS Backend API
│   ├── 📄 Dockerfile          # API container configuration
│   ├── 📄 package.json        # API dependencies
│   ├── 📄 tsconfig.json       # TypeScript configuration
│   ├── 📁 prisma/             # Database schema & migrations
│   │   └── 📄 schema.prisma   # Prisma database schema
│   └── 📁 src/                # API source code
│       ├── 📄 main.ts         # Application entry point
│       ├── 📄 app.module.ts   # Root module
│       ├── 📄 app.controller.ts # Main controller
│       └── 📄 app.service.ts  # Main service
├── 📁 site/                   # Next.js Frontend
│   ├── 📄 Dockerfile          # Frontend container configuration
│   ├── 📄 package.json        # Frontend dependencies
│   ├── 📄 next.config.ts      # Next.js configuration
│   ├── 📄 tailwind.config.ts  # Tailwind CSS configuration
│   ├── 📁 public/             # Static assets
│   └── 📁 src/                # Frontend source code
│       ├── 📁 app/            # App Router pages
│       │   ├── 📄 page.tsx    # Home page
│       │   ├── 📄 layout.tsx  # Root layout
│       │   └── 📄 globals.css # Global styles
│       └── 📁 components/     # React components
│           └── 📄 ApiTest.tsx # API integration test
├── 📄 package.json            # Root package.json (workspace)
├── 📄 docker-compose.startkitv1.yml # Full deployment stack
├── 📄 deploy-remote.sh        # Deployment automation script
├── 📄 README.md              # This file
└── 📄 LICENSE                # MIT License
```
```
KataCore/
├── 📁 api/                          # Backend (NestJS + Bun)
│   ├── 📁 src/
│   │   ├── app.controller.ts        # Main API controller
│   │   ├── app.service.ts           # Business logic service
│   │   ├── app.module.ts            # Root module
│   │   └── main.ts                  # Application entry point
│   ├── 📁 prisma/
│   │   └── schema.prisma            # Database schema
│   ├── Dockerfile                   # Docker configuration
│   └── package.json                 # Dependencies & scripts
├── 📁 site/                         # Frontend (Next.js + React)
│   ├── 📁 src/
│   │   ├── 📁 app/
│   │   │   ├── layout.tsx           # Root layout
│   │   │   ├── page.tsx             # Homepage
│   │   │   └── globals.css          # Global styles
│   │   └── 📁 components/
│   │       └── ApiTest.tsx          # API connection test
│   ├── Dockerfile                   # Docker configuration
│   └── package.json                 # Dependencies & scripts
├── deploy-remote.sh                 # Remote deployment script
├── docker-compose.startkitv1.yml   # Docker services
├── package.json                     # Workspace configuration
└── README.md                        # Documentation
```

### **API Endpoints**
- `GET /` - Welcome message
- `GET /health` - Health check endpoint
- Authentication endpoints (JWT-based)
- RESTful CRUD operations with Prisma ORM

### **Database Schema (Prisma)**
- **Users** - User management with roles and authentication
- **Posts** - Content management with publishing workflow
- **Comments** - Nested commenting system
- **Likes** - Post engagement tracking
- **Tags** - Content categorization
- **Sessions** - User session management
- **File Uploads** - Media file tracking

---

## 📋 **Available Scripts**

### **Development Scripts**
```bash
# Install dependencies for all packages
bun run install:all

# Development mode (both frontend + backend)
bun run dev
bun run dev:site    # Frontend only (Next.js)
bun run dev:api     # Backend only (NestJS)

# Build applications
bun run build       # Build both applications
bun run build:site  # Build Next.js frontend
bun run build:api   # Build NestJS backend

# Production mode
bun run start       # Start both in production mode
bun run start:site  # Start Next.js in production
bun run start:api   # Start NestJS in production

# Code quality
bun run lint        # Lint both applications
bun run lint:site   # Lint Next.js code
bun run lint:api    # Lint NestJS code

# Testing
bun run test        # Run API tests

# Cleanup
bun run clean       # Remove node_modules and build artifacts
```

### **Docker Scripts**
```bash
# Local Docker development
bun run docker:up   # Start all services with Docker Compose
bun run docker:down # Stop all Docker services
bun run docker:logs # View Docker logs

# Individual Docker builds
cd api && bun run docker:build   # Build API Docker image
cd api && bun run docker:run     # Run API in Docker
```

### **Database Scripts** (API directory)
```bash
cd api

# Prisma commands
bun run prisma:generate  # Generate Prisma client
bun run prisma:migrate   # Run database migrations
bun run prisma:deploy    # Deploy migrations (production)
bun run prisma:reset     # Reset database (development)
bun run prisma:studio    # Open Prisma Studio
bun run prisma:seed      # Seed database with sample data
```

---

## 🔧 **Environment Variables**

All environment variables are automatically generated on first deployment:

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

---

## 📁 **File Structure**

```
KataCore/
├── deploy-startkitv1-clean.sh          # Main deployment script
├── docker-compose.startkitv1-clean.yml # Docker services
├── test-startkitv1-clean.sh            # Test suite
├── README-startkitv1-clean.md          # Complete documentation
├── .env                                 # Auto-generated environment
├── api/                                 # NestJS API source
├── site/                                # Next.js site source
└── README.md                            # This file
```

---

## 🧪 **Testing**

```bash
# Run comprehensive tests
./test-startkitv1-clean.sh

# Test deployment (dry run)
./deploy-startkitv1-clean.sh deploy-simple 127.0.0.1 --dry-run --verbose
```

---

## 📚 **Documentation**

- **Complete Guide**: [README-startkitv1-clean.md](README-startkitv1-clean.md)
- **API Documentation**: Available at `/api/docs` when running
- **Deployment Help**: `./deploy-startkitv1-clean.sh --help`

---

## 🎯 **Examples**

### Development Setup
```bash
# Start development environment
bun run dev

# Run tests
bun run test
```

### Production Deployment
```bash
# Simple deployment
./deploy-startkitv1-clean.sh deploy-simple 192.168.1.100

# Full deployment with SSL
./deploy-startkitv1-clean.sh deploy-full example.com

# With additional options
./deploy-startkitv1-clean.sh deploy-full example.com --force-regen --auto-push --verbose
```

### Monitoring
```bash
# View logs
docker-compose -f docker-compose.startkitv1-clean.yml logs -f

# Check service health
./test-startkitv1-clean.sh

# Update deployment
git pull && ./deploy-startkitv1-clean.sh deploy-full yourdomain.com
```

---

## 🔒 **Security Features**

- 🔐 **Auto-generated passwords** (32+ characters)
- 🔒 **SSL/TLS certificates** via Let's Encrypt
- 🛡️ **Security headers** (HSTS, CSP, etc.)
- 🚫 **Rate limiting** for API endpoints
- 🔥 **Firewall-ready** configuration
- 📊 **Health checks** for all services

---

## 🌐 **Post-Deployment Access**

After successful deployment, access your services:

| Service | URL | Purpose | Authentication |
|---------|-----|---------|----------------|
| **Frontend** | `https://yourdomain.com` | Main web application | Public |
| **API** | `https://yourdomain.com/api` | REST API endpoints | API keys |
| **API Docs** | `https://yourdomain.com/api/docs` | Interactive documentation | Public |
| **pgAdmin** | `https://yourdomain.com/pgadmin` | Database management | HTTP auth |
| **MinIO Console** | `https://yourdomain.com/minio` | Object storage admin | HTTP auth |
| **Health Check** | `https://yourdomain.com/health` | Service status | Public |

---

## 🛠️ **Development Workflow**

### **Local Development**
```bash
# 1. Start development environment
bun run dev

# 2. Make your changes to:
#    - Frontend: site/src/
#    - Backend: api/src/
#    - Database: api/prisma/schema.prisma

# 3. Test changes
bun run test
bun run lint

# 4. Build for production
bun run build
```

### **Database Management**
```bash
# Generate Prisma client
cd api && bunx prisma generate

# Create migration
cd api && bunx prisma migrate dev --name your-migration

# Deploy to production (automatic during deployment)
cd api && bunx prisma migrate deploy
```

---

## 📊 **Monitoring & Maintenance**

### **Health Monitoring**
```bash
# View service status
docker-compose -f docker-compose.startkitv1.yml ps

# Real-time logs
docker-compose -f docker-compose.startkitv1.yml logs -f

# Check individual service logs
docker-compose -f docker-compose.startkitv1.yml logs service_name
```

### **Updates & Maintenance**
```bash
# Update application code
git pull
./deploy-remote.sh 116.118.85.41 yourdomain.com

# Clean deployment (removes old data)
./deploy-remote.sh --cleanup 116.118.85.41
./deploy-remote.sh --force-regen 116.118.85.41 yourdomain.com
```

### **Backup & Recovery**
```bash
# Manual backup
docker-compose -f docker-compose.startkitv1.yml exec postgres pg_dump -U katacore_user katacore_prod > backup.sql

# Restore backup
docker-compose -f docker-compose.startkitv1.yml exec -T postgres psql -U katacore_user -d katacore_prod < backup.sql
```

---

## 🚨 **Troubleshooting**

### **Common Issues**

1. **Port conflicts**
   ```bash
   # Check if ports are in use
   sudo netstat -tulpn | grep :3000
   
   # Stop conflicting services
   ./deploy-remote.sh --cleanup 116.118.85.41
   ```

2. **SSL certificate issues**
   ```bash
   # Check certificate status
   sudo certbot certificates
   
   # Renew certificates
   sudo certbot renew
   ```

3. **Service not starting**
   ```bash
   # Check service logs
   docker-compose -f docker-compose.startkitv1.yml logs service_name
   
   # Restart services
   docker-compose -f docker-compose.startkitv1.yml restart
   ```

### **Reset deployment**
```bash
# Clean everything and start fresh
./deploy-remote.sh --cleanup 116.118.85.41
./deploy-remote.sh --force-regen 116.118.85.41 yourdomain.com
```

---

## 🌍 **Cloud Provider Support**

KataCore StartKit v1 works with **any** cloud provider:

### **Tested Platforms**
- ✅ **AWS EC2** - All instance types
- ✅ **Google Cloud Compute** - All machine types  
- ✅ **DigitalOcean Droplets** - All sizes
- ✅ **Vultr Cloud Compute** - All plans
- ✅ **Linode** - All instances
- ✅ **Hetzner Cloud** - All server types

### **Linux Distributions**
- ✅ **Ubuntu** 20.04, 22.04, 24.04
- ✅ **Debian** 11, 12
- ✅ **CentOS** 8, 9
- ✅ **RHEL** 8, 9

---

## 🤝 **Contributing**

1. Fork the repository
2. Create feature branch: `git checkout -b feature/amazing-feature`
3. Test locally: `bun run dev` and `bun run test`
4. Commit changes: `git commit -m 'Add amazing feature'`
5. Push to branch: `git push origin feature/amazing-feature`
6. Submit pull request

---

## 📄 **License**

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 📞 **Support**

- 📖 **Documentation**: This README.md
- 🐛 **Issues**: GitHub Issues
- 💬 **Discussions**: GitHub Discussions
- 📧 **Email**: support@katacore.com

---

<div align="center">

**🚀 Ready to deploy?**

**Quick Start:** `./deploy-remote.sh --simple 116.118.85.41 yourdomain.com`

**Full Deploy:** `./deploy-remote.sh 116.118.85.41 yourdomain.com`

---

**Made with ❤️ by the KataCore Team**

*Deploy once, run anywhere!*

</div>
