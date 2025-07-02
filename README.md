# 🚀 KataCore StartKit v2

> **Production-ready full-stack deployment with zero configuration**

[![Version](https://img.shields.io/badge/version-2.0.0-blue.svg)](https://github.com/yourusername/katacore-startkit)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Bun](https://img.shields.io/badge/bun-1.0+-yellow.svg)](https://bun.sh)
[![Docker](https://img.shields.io/badge/docker-supported-blue.svg)](https://docker.com)

**KataCore StartKit v2** revolutionizes full-stack deployment with intelligent auto-configuration. Deploy production-ready applications with automatically generated environments, SSL certificates, and zero manual setup required.

---

## 🌟 **What's New in v2.0**

- 🎯 **One-Command Deployment** - Deploy with just `./startkit-deployer.sh --host IP --domain DOMAIN`
- 🔒 **Auto-SSL Configuration** - Let's Encrypt certificates with auto-renewal
- 🛡️ **Auto-Environment Generation** - Secure 16-64 character passwords for all services
- 🚀 **Smart Deployment Detection** - Automatically detects first-time vs updates
- ⚡ **80% Less Code** - Consolidated from 15+ scripts to 3 core files
- 🔧 **Zero Manual Setup** - Complete automation from server prep to SSL
- 📊 **Enterprise Security** - Auto-hardening with firewall, fail2ban, and monitoring

---

## 🏗️ **Technology Stack**

| Component | Technology | Version | Purpose |
|-----------|------------|---------|---------|
| **Frontend** | Next.js + React | 15.x + 19.x | Modern web application |
| **Backend** | NestJS + TypeScript | 11.x + 5.x | Scalable API server |
| **Runtime** | Bun.js | 1.x | Ultra-fast JavaScript runtime |
| **Database** | PostgreSQL | 16.x | Reliable relational database |
| **Cache** | Redis | 7.x | High-performance caching |
| **Storage** | MinIO | Latest | S3-compatible object storage |
| **Proxy** | Nginx | Latest | Reverse proxy with SSL |
| **Container** | Docker + Compose | Latest | Containerized deployment |

---

## 🚀 **Quick Start**

### Prerequisites
- **Bun.js** (v1.0.0+) - [Install here](https://bun.sh)
- **Linux server** with SSH access for production deployment

### 1. **Clone & Install**
```bash
git clone <your-repo-url>
cd KataCore
bun run install:all
```

### 2. **Development Mode**
```bash
# Start both frontend and backend
bun run dev

# Access your application:
# Frontend: http://localhost:3000
# Backend: http://localhost:3001
# API Docs: http://localhost:3001/api/docs
```

### 3. **Production Deployment** ⚡

#### **First Deployment (Auto-Setup Everything)**
```bash
# HTTP deployment
./startkit-deployer.sh --host YOUR_SERVER_IP

# HTTPS deployment with SSL (Recommended)
./startkit-deployer.sh --host YOUR_SERVER_IP --domain yourdomain.com
```

#### **Update Existing Deployment**
```bash
# Smart updates (only updates what changed)
./startkit-deployer.sh --host YOUR_SERVER_IP --update

# Clean deployment (fresh start)
./startkit-deployer.sh --host YOUR_SERVER_IP --clean
```

#### **Interactive Setup**
```bash
# Guided deployment wizard
./quick-start-v2.sh
```

---

## 🎯 **Deployment Features**

### **🔥 Auto-Configuration**
- ✅ **Environment Generation** - Secure credentials for all services
- ✅ **SSL Certificates** - Let's Encrypt with auto-renewal
- ✅ **Server Setup** - Docker, Nginx, security hardening
- ✅ **Firewall Configuration** - UFW rules with minimal ports
- ✅ **Database Migrations** - Prisma schema auto-deployment

### **🧠 Smart Detection**
- ✅ **First vs Update** - Automatically detects deployment type
- ✅ **Code Changes** - Only updates modified components
- ✅ **Environment Preservation** - Keeps existing settings during updates
- ✅ **SSL Persistence** - Maintains certificates across deployments

### **🛡️ Enterprise Security**
- ✅ **Auto-Generated Passwords** (16-64 characters)
  - PostgreSQL: 24-char password
  - Redis: 20-char password
  - MinIO: 20-char password
  - pgAdmin: 16-char password
  - JWT Secret: 64-char base64
- ✅ **SSL/TLS** - TLSv1.2 + TLSv1.3 with strong ciphers
- ✅ **Security Headers** - HSTS, CSP, X-Frame-Options, XSS protection
- ✅ **Rate Limiting** - API and general request limiting
- ✅ **Fail2ban** - Automatic intrusion prevention

---

## 🌐 **Deployment Options**

### **Basic Commands**
```bash
# Show all options
./startkit-deployer.sh --help

# Deployment modes
./startkit-deployer.sh --host SERVER_IP                    # First deployment
./startkit-deployer.sh --host SERVER_IP --domain DOMAIN   # With SSL
./startkit-deployer.sh --host SERVER_IP --update          # Update only
./startkit-deployer.sh --host SERVER_IP --clean           # Clean install

# Advanced options
./startkit-deployer.sh --host SERVER_IP --verbose         # Detailed logs
./startkit-deployer.sh --host SERVER_IP --dry-run         # Preview only
./startkit-deployer.sh --host SERVER_IP --no-ssl          # Disable SSL
```

### **Deployment Modes**

| Mode | Command | Description | Use Case |
|------|---------|-------------|----------|
| **Auto** | `--host IP` | Smart detection | First deployment or updates |
| **Update** | `--update` | Code updates only | Regular application updates |
| **Clean** | `--clean` | Fresh installation | Complete reset |
| **SSL** | `--domain` | HTTPS with certificates | Production with domain |

### **SSH Options**
```bash
# Custom SSH settings
./startkit-deployer.sh --host IP --user ubuntu --port 2222

# Different authentication
./startkit-deployer.sh --host IP --user root
```

---

## 📦 **Available Scripts**

### **Development**
```bash
bun run dev              # Start both frontend and backend
bun run dev:site         # Next.js frontend only
bun run dev:api          # NestJS backend only
bun run build            # Build both applications
bun run test             # Run test suites
bun run lint             # Code linting
```

### **Local Testing**
```bash
bun run local:dev        # Local Docker environment
bun run local:down       # Stop local environment
bun run local:test       # Test production build locally
bun run local:logs       # View container logs
```

### **Environment Management**
```bash
bun run env:create-template  # Generate environment template
bun run env:show-template    # Display template content
bun run env:validate         # Validate configuration
```

---

## 🌍 **Post-Deployment Access**

After successful deployment, access your services:

| Service | URL | Purpose | Authentication |
|---------|-----|---------|----------------|
| **Frontend** | `https://yourdomain.com` | Main web application | Public |
| **API** | `https://yourdomain.com/api` | REST API endpoints | API keys |
| **API Docs** | `https://yourdomain.com/api/docs` | Interactive documentation | Public |
| **pgAdmin** | `https://yourdomain.com/pgadmin` | Database management | HTTP auth |
| **MinIO Console** | `https://yourdomain.com/minio` | Object storage admin | HTTP auth |
| **Health Check** | `https://yourdomain.com/nginx-health` | Service status | Public |

### **Admin Panel Access**
Admin panels are protected with HTTP authentication. Credentials are automatically generated and stored in `.env.prod`.

---

## 🔧 **Configuration**

### **Auto-Generated Environment**
StartKit v2 automatically creates `.env.prod` with:
```bash
# Database & Cache
POSTGRES_PASSWORD=<24-char-secure-password>
REDIS_PASSWORD=<20-char-secure-password>

# Application Secrets  
JWT_SECRET=<64-char-base64-secret>
ENCRYPTION_KEY=<64-char-hex-key>

# Object Storage
MINIO_ROOT_PASSWORD=<20-char-secure-password>

# Admin Access
PGADMIN_PASSWORD=<16-char-secure-password>

# SSL & Security
ENABLE_SSL=true
LETSENCRYPT_EMAIL=admin@yourdomain.com
```

### **Manual Customization**
```bash
# View current environment
cat .env.prod

# Edit if needed (backup created automatically)
nano .env.prod

# Validate changes
bun run env:validate
```

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
# Check service health
curl https://yourdomain.com/nginx-health

# View service status
ssh root@yourserver "cd /opt/katacore && docker compose ps"

# Real-time logs
ssh root@yourserver "cd /opt/katacore && docker compose logs -f"
```

### **Updates & Maintenance**
```bash
# Update application code
./startkit-deployer.sh --host YOUR_SERVER --update

# Update with new dependencies
./startkit-deployer.sh --host YOUR_SERVER --force-rebuild

# Clean deployment (removes old data)
./startkit-deployer.sh --host YOUR_SERVER --clean
```

### **Backup & Recovery**
```bash
# Database backups (automated daily)
# Location: /opt/katacore/backups/

# Manual backup
ssh root@yourserver "cd /opt/katacore && docker compose exec postgres pg_dump -U katacore_user katacore_prod > backup.sql"
```

---

## 🌐 **Cloud Provider Support**

StartKit v2 works with **any** cloud provider:

### **Tested Platforms**
- ✅ **AWS EC2** - All instance types
- ✅ **Google Cloud Compute** - All machine types  
- ✅ **DigitalOcean Droplets** - All sizes
- ✅ **Vultr Cloud Compute** - All plans
- ✅ **Linode** - All instances
- ✅ **Hetzner Cloud** - All server types
- ✅ **Azure VMs** - All series

### **Linux Distributions**
- ✅ **Ubuntu** 20.04, 22.04, 24.04
- ✅ **Debian** 11, 12
- ✅ **CentOS** 8, 9
- ✅ **RHEL** 8, 9
- ✅ **Fedora** 36+

---

## 🚨 **Troubleshooting**

### **Common Issues**

1. **"Server host is required" Error**
   ```bash
   # ❌ Wrong: Missing --host parameter
   ./startkit-deployer.sh
   
   # ✅ Correct: Always provide --host
   ./startkit-deployer.sh --host YOUR_SERVER_IP
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

3. **SSL Certificate Issues**
   ```bash
   # Ensure domain points to server IP
   dig yourdomain.com
   
   # Then deploy with domain
   ./startkit-deployer.sh --host YOUR_SERVER_IP --domain yourdomain.com
   ```

4. **Port Conflicts**
   ```bash
   # Clean deployment removes old containers
   ./startkit-deployer.sh --host YOUR_SERVER_IP --clean
   ```

### **Debug Options**
```bash
# Preview deployment actions
./startkit-deployer.sh --host YOUR_SERVER_IP --dry-run

# Verbose logging
./startkit-deployer.sh --host YOUR_SERVER_IP --verbose

# Check deployment logs
ls -la .deploy-logs/
```

---

## 📈 **Performance Features**

### **Frontend Optimizations**
- ⚡ **Next.js 15** - App Router with RSC
- 🗜️ **Bundle Optimization** - Automatic code splitting
- 📱 **Progressive Web App** - Service worker support
- 🎨 **Tailwind CSS 4** - Optimized utility classes

### **Backend Optimizations**
- 🚀 **NestJS 11** - Modular architecture
- 🔄 **Connection Pooling** - Database connection management
- 📊 **Redis Caching** - High-performance caching layer
- 🔍 **Query Optimization** - Prisma ORM optimizations

### **Infrastructure Optimizations**
- 🐳 **Multi-stage Docker builds** - Smaller production images
- 🌐 **Nginx Performance** - Compression, caching, keep-alive
- 📈 **Load Balancing** - Upstream server configuration
- 🛡️ **Security Headers** - Modern security standards

---

## 🔄 **Migration from v1**

### **Automatic Migration**
```bash
# StartKit v2 automatically handles migration
./startkit-deployer.sh --host YOUR_SERVER_IP --update

# Your existing .env.prod will be backed up
# New secure environment will be generated
# SSL configuration will be preserved
```

### **Manual Migration Steps**
1. **Backup current deployment**
2. **Update to v2 commands** 
3. **Environment auto-generated**
4. **SSL auto-configured**

---

## 🤝 **Contributing**

1. Fork the repository
2. Create feature branch: `git checkout -b feature/amazing-feature`
3. Test deployment: `./startkit-deployer.sh --host test-server --dry-run`
4. Commit changes: `git commit -m 'Add amazing feature'`
5. Push to branch: `git push origin feature/amazing-feature`
6. Submit pull request

### **Development Guidelines**
- Follow TypeScript best practices
- Test both local and production deployments
- Update documentation for new features
- Ensure security best practices

---

## 📄 **License**

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 📞 **Support**

- 📖 **Documentation**: This README + inline help (`--help`)
- 🐛 **Issues**: [GitHub Issues](https://github.com/your-org/katacore-startkit/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/your-org/katacore-startkit/discussions)
- 📧 **Email**: support@katacore.com

---

<div align="center">

**🚀 Ready to deploy?**

**Quick Start:** `./quick-start-v2.sh`

**Direct Deploy:** `./startkit-deployer.sh --host YOUR_SERVER_IP --domain yourdomain.com`

---

**Made with ❤️ by the KataCore Team**

*Deploy once, run anywhere!*

</div>
