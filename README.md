# 🚀 innerbright - Advanced Full-Stack Development Platform

<div align="center">

![innerbright Logo](https://img.shields.io/badge/innerbright-Production%20Ready-blue?style=for-the-badge&logo=docker)

**Enterprise-grade Full-Stack Platform with Smart Deployment**

[![Next.js](https://img.shields.io/badge/Next.js-14+-black?style=flat-square&logo=next.js)](https://nextjs.org/)
[![NestJS](https://img.shields.io/badge/NestJS-10+-red?style=flat-square&logo=nestjs)](https://nestjs.com/)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.0+-blue?style=flat-square&logo=typescript)](https://www.typescriptlang.org/)
[![Docker](https://img.shields.io/badge/Docker-Ready-blue?style=flat-square&logo=docker)](https://www.docker.com/)
[![Bun](https://img.shields.io/badge/Bun-1.0+-orange?style=flat-square&logo=bun)](https://bun.sh/)

[🚀 Quick Start](#-quick-start) • [📖 Documentation](#-documentation) • [🎯 Demo](#-demo) • [💻 Development](#-development) • [🚢 Deployment](#-deployment)

</div>

---

## ✨ Tính năng nổi bật

### 🏗️ **Architecture & Technology**
- **Next.js 14+** - Modern React framework với App Router
- **NestJS** - Scalable Node.js backend framework
- **TypeScript** - Type-safe development
- **PostgreSQL** - Robust relational database
- **Redis** - High-performance caching
- **MinIO** - S3-compatible object storage
- **Docker** - Containerized deployment

### 🛠️ **Smart Deployment System**
- **🧠 Intelligent Service Management** - Chỉ restart các service có vấn đề
- **🔒 Project-Scoped Operations** - Cô lập hoàn toàn, không ảnh hưởng server khác
- **⚡ Zero-Downtime Updates** - Healthy services tiếp tục chạy
- **🔄 Git Integration** - Tự động commit và deploy
- **📋 Health Monitoring** - Real-time service status checking

### 🎯 **Business Features**
- **👥 HRM System** - Comprehensive human resource management
- **🔐 Authentication & Authorization** - JWT-based security
- **📊 Analytics Dashboard** - Real-time business insights
- **📱 Responsive Design** - Mobile-first approach
- **🌐 Multi-language Support** - i18n ready

---

## 🚀 Quick Start

### Prerequisites
- **Bun.js** v1.0+ ([Install Guide](https://bun.sh/docs/installation))
- **Docker** & **Docker Compose** 
- **Git** for version control
- **Linux/macOS** (Windows with WSL2)

### 1. 📥 Clone & Setup
```bash
# Clone repository
git clone https://github.com/chikiet/innerbright.git
cd innerbright

# Install dependencies
bun run install:all

# Setup environment
cp .env.example .env.prod
# Edit .env.prod with your configuration
```

### 2. 🏃 Local Development
```bash
# Start development mode
bun run dev

# Or start specific services
bun run dev:api    # Backend only
bun run dev:site   # Frontend only
```

### 3. 🚀 Production Deployment
```bash
# Make deployment script executable
chmod +x sh/3pushauto.sh

# Run smart deployment
./sh/3pushauto.sh
```

---

## 🧠 Smart Deployment Features

### 🎯 **Deployment Options**

| Option | Description | Use Case |
|--------|-------------|----------|
| **Smart Deploy (Site & API)** | Updates frontend & backend only | Code updates, bug fixes |
| **Smart Deploy ALL** | Updates all services intelligently | Major updates, new features |
| **Deploy Only** | Skips git operations | Testing existing code |
| **Fresh Deploy** | Clean deployment with new env | Environment changes |
| **Selective Deploy** | Choose specific services | Targeted updates |

### 🔧 **Smart Features**
```bash
# Health Check System
✅ PostgreSQL: pg_isready validation
✅ Redis: PING response check  
✅ API/Site: Error log analysis
✅ MinIO: Health endpoint verification

# Intelligent Restart Logic
🧠 Only restart failed/unhealthy services
🟢 Keep healthy services running
⚡ Zero-downtime for stable services
```

---

## 💻 Development

### 📁 **Project Structure**
```
innerbright/
├── 📂 api/                    # NestJS Backend
│   ├── src/
│   │   ├── auth/             # Authentication module
│   │   ├── hrm/              # HR Management module
│   │   ├── common/           # Shared utilities
│   │   └── main.ts           # Application entry
│   ├── Dockerfile
│   └── package.json
├── 📂 site/                   # Next.js Frontend
│   ├── src/
│   │   ├── app/              # App Router pages
│   │   ├── components/       # Reusable components
│   │   ├── lib/              # Utilities & configs
│   │   └── styles/           # Global styles
│   ├── Dockerfile
│   └── package.json
├── 📂 sh/                     # Deployment Scripts
│   ├── 3pushauto.sh          # Smart deployment tool
│   └── 2envauto.sh           # Environment setup
├── 📂 docs/                   # Documentation
└── docker-compose.yml        # Service orchestration
```

### 🛠️ **Available Scripts**
```bash
# Development
bun run dev              # Start all services
bun run dev:api          # Backend only
bun run dev:site         # Frontend only

# Building
bun run build            # Build all
bun run build:api        # Build backend
bun run build:site       # Build frontend

# Testing
bun run test             # Run all tests
bun run test:api         # Backend tests
bun run test:site        # Frontend tests

# Deployment
./sh/3pushauto.sh        # Smart deployment
./sh/2envauto.sh         # Environment setup
```

---

## 🚢 Deployment Guide

### 🌐 **Server Requirements**
- **OS**: Ubuntu 20.04+ / CentOS 8+
- **RAM**: 4GB minimum, 8GB recommended
- **Storage**: 50GB+ SSD
- **Docker**: 24.0+
- **Docker Compose**: 2.0+

### 🔧 **Smart Deployment Workflow**

#### Step 1: Initial Setup
```bash
# Clone project on server
git clone https://github.com/chikiet/innerbright.git
cd innerbright

# Run environment setup
./sh/2envauto.sh
```

#### Step 2: Smart Deployment
```bash
# Run smart deployment tool
./sh/3pushauto.sh

# Choose deployment option:
# 1. Smart Deploy (Site & API) - Most common
# 2. Smart Deploy ALL - Full update
# 3. Deploy only - Skip git operations
# 4. Project cleanup - Fix issues
# 5. Check status - Monitor health
# 6. Fresh deploy - Clean environment
# 7. Selective deploy - Custom services
```

#### Step 3: Verification
```bash
# Check service health
docker ps --filter name="innerbright-"

# View logs
docker logs innerbright-api
docker logs innerbright-site

# Monitor resources
docker stats --filter name="innerbright-"
```

### 🔒 **Security Features**
- **Project-Scoped Operations** - Zero impact on other server services
- **Environment Isolation** - Separated configurations
- **Health Monitoring** - Continuous service validation
- **Rollback Support** - Environment backup & restore

---

## 📖 Documentation

### 📚 **Core Guides**
| Document | Description |
|----------|-------------|
| [🚀 Getting Started](docs/GETTING-STARTED.md) | Complete setup guide |
| [🏗️ Architecture](docs/guides/ARCHITECTURE.md) | System design & patterns |
| [💻 Development](docs/guides/DEVELOPMENT.md) | Local development setup |
| [🚢 Deployment](DEPLOYMENT-README.md) | Production deployment |

### 📋 **API References**
| API | Description |
|-----|-------------|
| [🔐 Auth API](docs/api/AUTH-API.md) | Authentication endpoints |
| [👥 HRM API](docs/api/HRM-API.md) | HR management endpoints |
| [⚙️ System API](docs/api/SYSTEM-API.md) | System operations |

### 🛠️ **Advanced Topics**
| Topic | Description |
|-------|-------------|
| [🧹 Troubleshooting](docs/troubleshooting/TROUBLESHOOTING.md) | Common issues & solutions |
| [🔧 Configuration](docs/guides/CONFIGURATION.md) | Advanced configurations |
| [📊 Monitoring](docs/guides/MONITORING.md) | Performance monitoring |

---

## 🎯 Live Demo

### 🌐 **Demo Environments**
- **Production**: `https://innerbright.example.com`
- **Staging**: `https://staging.innerbright.example.com`
- **API Docs**: `https://api.innerbright.example.com/docs`

### 📋 **Test Credentials**
```
Admin User:
Email: admin@innerbright.com
Password: admin123

Demo User:
Email: demo@innerbright.com  
Password: demo123
```

---

## 🔧 Management Commands

### 📊 **Monitoring Commands**
```bash
# Service status
docker ps --filter name="innerbright-"

# Service logs
docker logs innerbright-api --tail 100
docker logs innerbright-site --tail 100

# Resource usage
docker stats --filter name="innerbright-"

# Health checks
curl -f http://localhost:3000/health
curl -f http://localhost:8080/api/health
```

### 🛠️ **Maintenance Commands**
```bash
# Backup database
docker exec innerbright-postgres pg_dump -U postgres innerbright > backup.sql

# Restore database  
cat backup.sql | docker exec -i innerbright-postgres psql -U postgres innerbright

# Update SSL certificates
./sh/update-ssl.sh

# System cleanup
./sh/3pushauto.sh # Choose option 4 (Project cleanup)
```

---

## 🔐 Security

### 🛡️ **Security Features**
- **JWT Authentication** with refresh tokens
- **Role-based Access Control** (RBAC)
- **SQL Injection Protection** via TypeORM
- **XSS Protection** with CSP headers
- **Rate Limiting** on API endpoints
- **Environment Isolation** in deployment

### 🔒 **Best Practices**
- Regular security updates via smart deployment
- Encrypted data transmission (HTTPS/TLS)
- Secure session management
- Input validation & sanitization
- Audit logging for compliance

---

## 🤝 Contributing

### 🔧 **Development Setup**
```bash
# Fork and clone
git clone https://github.com/yourusername/innerbright.git
cd innerbright

# Install dependencies
bun install

# Create feature branch
git checkout -b feature/amazing-feature

# Start development
bun run dev
```

### 📝 **Contribution Guidelines**
- **Code Style**: Follow TypeScript best practices
- **Testing**: Add tests for new features
- **Documentation**: Update docs for new features  
- **Commits**: Use conventional commit messages
- **Reviews**: All PRs require review

### 🧪 **Testing**
```bash
# Run all tests
bun run test

# Run with coverage
bun run test:cov

# E2E testing
bun run test:e2e

# Lint code
bun run lint
```

---

## 📞 Support & Community

### 💬 **Get Help**
- **Issues**: [GitHub Issues](https://github.com/chikiet/innerbright/issues)
- **Discussions**: [GitHub Discussions](https://github.com/chikiet/innerbright/discussions)
- **Email**: support@innerbright.com
- **Discord**: [innerbright Community](https://discord.gg/innerbright)

### 📚 **Resources**
- **Documentation**: [docs.innerbright.com](https://docs.innerbright.com)
- **API Reference**: [api.innerbright.com](https://api.innerbright.com)
- **Blog**: [blog.innerbright.com](https://blog.innerbright.com)
- **Changelog**: [CHANGELOG.md](CHANGELOG.md)

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- **Next.js Team** - For the amazing React framework
- **NestJS Team** - For the powerful backend framework  
- **Docker Team** - For containerization technology
- **Bun Team** - For the fast JavaScript runtime
- **Open Source Community** - For endless inspiration

---

<div align="center">

**Made with ❤️ by the innerbright Team**

[![GitHub stars](https://img.shields.io/github/stars/chikiet/innerbright?style=social)](https://github.com/chikiet/innerbright/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/chikiet/innerbright?style=social)](https://github.com/chikiet/innerbright/network/members)
[![GitHub watchers](https://img.shields.io/github/watchers/chikiet/innerbright?style=social)](https://github.com/chikiet/innerbright/watchers)

[⬆ Back to top](#-innerbright---advanced-full-stack-development-platform)

</div>