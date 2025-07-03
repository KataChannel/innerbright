# 🚀 KataCore StartKit v1 Clean

> **Clean, minimal, and production-ready deployment system**

[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com/katacore/startkitv1-clean)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Bun](https://img.shields.io/badge/bun-1.0+-yellow.svg)](https://bun.sh)
[![Docker](https://img.shields.io/badge/docker-supported-blue.svg)](https://docker.com)

**KataCore StartKit v1 Clean** provides a streamlined deployment system with auto-generated secure environments, SSL support, and production-ready Docker configuration. Deploy full-stack applications with minimal complexity and maximum reliability.

---

## 🌟 **Features**

- 🎯 **Simple Deployment** - Deploy with just `./deploy-startkitv1-clean.sh deploy-simple IP` or `./deploy-startkitv1-clean.sh deploy-full DOMAIN`
- 🔒 **Auto-SSL Configuration** - Let's Encrypt certificates with auto-renewal (full deployment)
- 🛡️ **Auto-Environment Generation** - Secure 16-64 character passwords for all services
- 🚀 **Two Deployment Modes** - Simple (IP-based) and Full (Domain + SSL)
- ⚡ **Clean Architecture** - Minimal codebase focused on essential functionality
- 🔧 **Docker Stack** - Complete containerized deployment with all services
- 📊 **Production Security** - Security headers, rate limiting, and hardening

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
- **Docker & Docker Compose** - For containerized deployment
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

#### **Simple Deployment (IP-based)**
```bash
# Make deployment script executable
chmod +x deploy-startkitv1-clean.sh

# Deploy with IP address
./deploy-startkitv1-clean.sh deploy-simple YOUR_SERVER_IP
```

#### **Full Deployment (Domain + SSL)**
```bash
# Deploy with domain and SSL
./deploy-startkitv1-clean.sh deploy-full yourdomain.com
```

#### **Interactive Setup**
```bash
# Guided deployment wizard
./deploy-startkitv1-clean.sh deploy-guide
```

---

## 🎯 **Deployment Modes**

### **Simple Deployment**
- ✅ Docker containers only
- ✅ IP address access
- ✅ No Nginx configuration
- ✅ Perfect for development/testing

**Access:**
- Site: `http://SERVER_IP:3000`
- API: `http://SERVER_IP:3001`
- MinIO: `http://SERVER_IP:9000`
- pgAdmin: `http://SERVER_IP:5050`

### **Full Deployment**
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

## 🧠 **Architecture**

### **Container Services**
- **API (NestJS)**: Port 3001 - Backend application
- **Site (Next.js)**: Port 3000 - Frontend application  
- **PostgreSQL**: Port 5432 - Database
- **Redis**: Port 6379 - Cache and sessions
- **MinIO**: Ports 9000/9001 - Object storage
- **pgAdmin**: Port 5050 - Database management

### **Auto-Generated Security**
- **Auto-generated passwords**: 16-32 character secure passwords
- **JWT secrets**: 64-character base64 encoded
- **SSL certificates**: Let's Encrypt with auto-renewal
- **Security headers**: XSS protection, frame options, etc.
- **Rate limiting**: Built into Nginx configuration

---

## 📋 **Available Commands**

```bash
# Deployment commands
./deploy-startkitv1-clean.sh deploy-simple IP_ADDRESS
./deploy-startkitv1-clean.sh deploy-full DOMAIN_NAME
./deploy-startkitv1-clean.sh deploy-guide

# Utility commands
./deploy-startkitv1-clean.sh generate-env
./deploy-startkitv1-clean.sh test-deployment
./deploy-startkitv1-clean.sh cleanup

# Help
./deploy-startkitv1-clean.sh --help
```

### **Command Options**
- `--force-regen`: Force regenerate passwords and secrets
- `--auto-push`: Auto commit and push changes to git
- `--verbose`: Enable detailed logging
- `--dry-run`: Show what would be done without executing

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
# Check service health
./deploy-startkitv1-clean.sh test-deployment

# View service status
docker-compose -f docker-compose.startkitv1-clean.yml ps

# Real-time logs
docker-compose -f docker-compose.startkitv1-clean.yml logs -f
```

### **Updates & Maintenance**
```bash
# Update application code
git pull
./deploy-startkitv1-clean.sh deploy-full yourdomain.com

# Clean deployment (removes old data)
./deploy-startkitv1-clean.sh cleanup
./deploy-startkitv1-clean.sh deploy-full yourdomain.com --force-regen
```

### **Backup & Recovery**
```bash
# Manual backup
docker-compose -f docker-compose.startkitv1-clean.yml exec postgres pg_dump -U katacore_user katacore_prod > backup.sql

# Restore backup
docker-compose -f docker-compose.startkitv1-clean.yml exec -T postgres psql -U katacore_user -d katacore_prod < backup.sql
```

---

## 🚨 **Troubleshooting**

### **Common Issues**

1. **Port conflicts**
   ```bash
   # Check if ports are in use
   sudo netstat -tulpn | grep :3000
   
   # Stop conflicting services
   ./deploy-startkitv1-clean.sh cleanup
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
   docker-compose -f docker-compose.startkitv1-clean.yml logs service_name
   
   # Restart services
   docker-compose -f docker-compose.startkitv1-clean.yml restart
   ```

### **Reset deployment**
```bash
# Clean everything and start fresh
./deploy-startkitv1-clean.sh cleanup
./deploy-startkitv1-clean.sh deploy-full yourdomain.com --force-regen
```

---

## 🌍 **Cloud Provider Support**

StartKit v1 Clean works with **any** cloud provider:

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
3. Test deployment: `./deploy-startkitv1-clean.sh deploy-simple test-ip --dry-run`
4. Commit changes: `git commit -m 'Add amazing feature'`
5. Push to branch: `git push origin feature/amazing-feature`
6. Submit pull request

---

## 📄 **License**

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 📞 **Support**

- 📖 **Documentation**: [README-startkitv1-clean.md](README-startkitv1-clean.md)
- 🐛 **Issues**: GitHub Issues
- 💬 **Discussions**: GitHub Discussions
- 📧 **Email**: support@katacore.com

---

<div align="center">

**🚀 Ready to deploy?**

**Quick Start:** `./deploy-startkitv1-clean.sh deploy-guide`

**Direct Deploy:** `./deploy-startkitv1-clean.sh deploy-full yourdomain.com`

---

**Made with ❤️ by the KataCore Team**

*Deploy once, run anywhere!*

</div>
