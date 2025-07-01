# 🚀 Getting Started with KataCore StartKit v1

## Quick Overview

KataCore StartKit v1 is designed to get you from zero to production in minutes. This guide will walk you through everything you need to know.

## 📋 Prerequisites

### Required
- **Bun.js** v1.0+ ([Install here](https://bun.sh))
- **Linux Server** (Ubuntu 20.04+, Debian 11+, CentOS 8+)
- **SSH Access** to your server

### Optional (for local development)
- **Docker** & **Docker Compose** ([Install here](https://docker.com))
- **Git** for version control

## 🏁 Step 1: Clone & Setup

```bash
# Clone the repository
git clone <your-repository-url>
cd KataCore

# Install all dependencies
bun run install:all

# Verify installation
bun --version
```

## 🔧 Step 2: Local Development

```bash
# Start development environment
bun run dev

# This starts:
# - Next.js frontend on http://localhost:3000
# - NestJS backend on http://localhost:3001
# - PostgreSQL database 
# - Redis cache
# - MinIO object storage
```

### Development Commands

```bash
# Frontend only
bun run dev:site

# Backend only  
bun run dev:api

# Build for production
bun run build

# Run tests
bun run test

# Lint code
bun run lint
```

## 🚀 Step 3: Production Deployment

### Option A: StartKit Deployer (Recommended)

```bash
# Basic deployment
bun run deploy:startkit YOUR_SERVER_IP

# With custom domain
bun run deploy:startkit YOUR_SERVER_IP --domain yourdomain.com

# Clean deployment (removes existing containers)
bun run deploy:startkit:clean YOUR_SERVER_IP
```

### Option B: Universal Deployer (Legacy)

```bash
# Universal deployment
bun run deploy:universal --host YOUR_SERVER_IP --domain yourdomain.com
```

## 🔐 Step 4: Environment Configuration

### Automatic Configuration (Recommended)
The StartKit deployer automatically generates secure passwords and configurations.

### Manual Configuration
```bash
# Create environment template
bun run env:create-template

# Edit the file
nano .env.prod

# Validate configuration
bun run env:validate
```

## 🌐 Step 5: Access Your Application

After successful deployment:

| Service | URL | Description |
|---------|-----|-------------|
| **Frontend** | `https://yourdomain.com` | Main application |
| **API** | `https://yourdomain.com/api` | REST API endpoints |
| **Health Check** | `https://yourdomain.com/api/health` | API status |
| **pgAdmin** | `http://yourdomain.com:8080` | Database admin |
| **MinIO Console** | `http://yourdomain.com:9001` | Object storage admin |

## 📊 Step 6: Monitoring & Maintenance

```bash
# Check deployment status
bun run deploy:status YOUR_SERVER_IP

# View logs
ssh root@YOUR_SERVER_IP "cd /opt/katacore && docker compose logs -f"

# Restart services
ssh root@YOUR_SERVER_IP "cd /opt/katacore && docker compose restart"
```

## 🔧 Troubleshooting

### Common Issues

1. **Port 22 not accessible**
   ```bash
   # Use custom SSH port
   bun run deploy:startkit YOUR_SERVER_IP --port 2222
   ```

2. **SSL certificate issues**
   ```bash
   # Force SSL renewal
   bun run deploy:startkit YOUR_SERVER_IP --renew-ssl
   ```

3. **Container won't start**
   ```bash
   # Check logs
   ssh root@YOUR_SERVER_IP "docker logs container-name"
   ```

## 🎯 Next Steps

- [Customization Guide](CUSTOMIZATION.md)
- [API Documentation](API.md)
- [Deployment Options](DEPLOYMENT.md)
- [Security Guide](SECURITY.md)

## 💡 Pro Tips

1. **Use domain names** for production deployments
2. **Enable backup profiles** for important data
3. **Monitor resource usage** with `docker stats`
4. **Keep your StartKit updated** with `git pull origin startkitv1`

## 🆘 Support

- 📖 [Full Documentation](../README.md)
- 🐛 [Issue Tracker](https://github.com/yourusername/katacore-startkit/issues)
- 💬 [Discord Community](https://discord.gg/your-invite)
