# 🚀 KataCore StartKit v1

> **Production-ready full-stack application with universal cloud deployment**

KataCore StartKit v1 is a complete, production-ready full-stack application that can be deployed to any cloud server in minutes with zero configuration. Built with the latest technologies and optimized for performance, security, and scalability.

## ✨ Key Features

- 🌐 **Universal Cloud Deployment** - Deploy to ANY Linux server with one command
- 🚀 **Zero Configuration** - Automatic server setup, SSL certificates, and security hardening
- ⚡ **Ultra-fast Performance** - Optimized Docker containers with health checks and caching
- 🛡️ **Production Security** - Auto-generated passwords, firewall, rate limiting, and HTTPS
- 🔧 **Modern Tech Stack** - Next.js 15, NestJS 11, PostgreSQL, Redis, MinIO, Nginx
- 📊 **Monitoring Ready** - Built-in health checks, logging, and admin panels
- 🎯 **Developer Friendly** - Hot reload, TypeScript, ESLint, and comprehensive tooling

## 🏗️ Technology Stack

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

## 🚀 Quick Start

### Prerequisites

- **Bun.js** (v1.0.0+) - [Install here](https://bun.sh)
- **Docker** (for local development) - [Install here](https://docker.com)
- **Linux server** (for production deployment)

### 1. Clone & Install

```bash
git clone <your-repo-url>
cd KataCore
bun run install:all
```

### 2. Local Development

```bash
# Start development environment
bun run dev

# Available at:
# Frontend: http://localhost:3000
# Backend:  http://localhost:3001
# Docs:     http://localhost:3001/api/docs
```

### 3. Deploy to Production 🎯

```bash
# Deploy to any cloud server
bun run startkit:deploy --host YOUR_SERVER_IP

# With custom domain + SSL
bun run startkit:deploy --host YOUR_SERVER_IP --domain yourdomain.com

# Clean deployment (removes existing data)
bun run startkit:deploy --host YOUR_SERVER_IP --clean
```

## 🌐 Deployment Options

### Quick Deploy Commands

```bash
# 🚀 Full deployment (recommended for first time)
bun run startkit:deploy --host 192.168.1.100

# 🏗️ Setup server only (install Docker, create directories)
bun run startkit:deploy --host 192.168.1.100 --setup-only

# ⚡ Configuration update only (fastest)
bun run startkit:deploy --host 192.168.1.100 --config-only

# 🔄 Force rebuild all containers
bun run startkit:deploy --host 192.168.1.100 --force-rebuild

# 🧪 Dry run (see what would be done)
bun run startkit:deploy --host 192.168.1.100 --dry-run
```

### Deployment with Custom Domain

```bash
# Deploy with SSL certificate
bun run startkit:deploy --host myserver.com --domain myapp.com

# The script will automatically:
# ✅ Setup Let's Encrypt SSL certificates
# ✅ Configure Nginx with HTTPS
# ✅ Setup automatic certificate renewal
# ✅ Configure firewall rules
```

## 🔧 Environment Configuration

### Automatic Environment Generation

KataCore StartKit v1 automatically generates secure environment configurations:

```bash
# Generate new environment file
bun run env:generate

# Validate environment configuration
bun run env:validate
```

### Manual Environment Setup

If you need to customize environment variables:

```bash
# Copy template and edit
cp .env.prod.template .env.prod
nano .env.prod
```

## 📊 Service URLs

After deployment, access your services at:

| Service | URL | Purpose |
|---------|-----|---------|
| **Frontend** | `https://yourdomain.com/` | Main web application |
| **API** | `https://yourdomain.com/api/` | REST API endpoints |
| **Health** | `https://yourdomain.com/health` | Health check endpoint |
| **Admin** | `https://yourdomain.com:8080/` | Database admin (pgAdmin) |
| **Storage** | `https://yourdomain.com:9001/` | Object storage admin (MinIO) |

## 🔒 Security Features

### Automatic Security Hardening

- 🔐 **Auto-generated passwords** - Secure 16-24 character passwords
- 🛡️ **Firewall configuration** - UFW rules for required ports only
- 🔒 **SSL certificates** - Automatic Let's Encrypt certificates
- 🚫 **Rate limiting** - API and general request rate limiting
- 📊 **Security headers** - HSTS, CSP, X-Frame-Options, etc.
- 🔍 **Fail2ban** - Automatic intrusion prevention

### Security Best Practices

```bash
# View deployment security info
bun run cache:info

# Check service status
bun run status

# View application logs
bun run logs:app
```

## 🛠️ Development Workflow

### Local Development

```bash
# Start development servers
bun run dev

# Run tests
bun run test

# Lint code
bun run lint

# Build for production
bun run build
```

### Local Testing

```bash
# Test production build locally
bun run local:test

# Test with clean environment
bun run local:test --clean

# View local logs
bun run local:test --logs
```

## 📈 Performance Optimizations

### Docker Optimizations

- 🐳 **Multi-stage builds** - Smaller production images
- 🔄 **Health checks** - Automatic service recovery
- 📊 **Resource limits** - Memory and CPU constraints
- 🗄️ **Volume optimization** - Persistent data storage
- 🌐 **Network optimization** - Isolated container networks

### Nginx Optimizations

- ⚡ **Caching** - Static asset caching with proper headers
- 🗜️ **Compression** - Gzip and Brotli compression
- 🔄 **Load balancing** - Upstream load balancing
- 📈 **Connection pooling** - Keepalive connections
- 🛡️ **Security headers** - Modern security standards

## 🔍 Monitoring & Logging

### Built-in Monitoring

```bash
# Check service health
curl https://yourdomain.com/health

# View service status
bun run status

# View real-time logs
bun run logs:deploy
bun run logs:app
```

### Log Files

- 📁 **Deployment logs**: `.deploy-logs/`
- 📁 **Application logs**: Docker container logs
- 📁 **Nginx logs**: `/var/log/nginx/`
- 📁 **System logs**: `/var/log/`

## 🔄 Maintenance & Updates

### Update Deployment

```bash
# Update configuration only
bun run startkit:deploy --host YOUR_SERVER --config-only

# Update with new code
bun run startkit:deploy --host YOUR_SERVER

# Full rebuild
bun run startkit:deploy --host YOUR_SERVER --force-rebuild
```

### Backup & Recovery

```bash
# Database backup (automated daily)
# Backups stored in: /opt/katacore/backups/

# Manual backup
ssh root@yourserver "cd /opt/katacore && ./scripts/backup.sh"
```

## 📚 Documentation

### Project Structure

```
KataCore/
├── 📁 api/                    # NestJS backend
├── 📁 site/                   # Next.js frontend
├── 📁 nginx/                  # Nginx configuration
├── 📁 scripts/                # Deployment scripts
├── 🐳 docker-compose.prod.yml # Production containers
├── 🚀 startkit-deployer.sh   # Main deployment script
├── 📄 .env.prod.template      # Environment template
└── 📄 README.md              # This file
```

### API Documentation

After deployment, visit:
- **Swagger UI**: `https://yourdomain.com/api/docs`
- **OpenAPI JSON**: `https://yourdomain.com/api/docs-json`

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

### Common Issues

1. **SSH Connection Failed**
   ```bash
   # Check SSH key authentication
   ssh-copy-id root@yourserver
   ```

2. **Domain Not Resolving**
   ```bash
   # Ensure DNS A record points to your server IP
   dig yourdomain.com
   ```

3. **SSL Certificate Issues**
   ```bash
   # Check Let's Encrypt rate limits
   # Ensure domain points to server before SSL setup
   ```

### Getting Help

- 📖 **Documentation**: Check the `/docs` folder
- 🐛 **Issues**: [GitHub Issues](https://github.com/your-org/katacore-startkit/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/your-org/katacore-startkit/discussions)

---

**Made with ❤️ by the KataCore Team**

*Deploy once, run anywhere!*
