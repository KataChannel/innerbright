# KataCore Deployment Guide - Optimized Deployment System

## 🚀 One-Command Deployment

Deploy KataCore to any cloud server with a single command:

```bash
# First deployment (auto-creates .env.prod.example)
bun run deploy:universal --host YOUR_SERVER_IP

# Quick subsequent deployments (optimized)
bun run deploy:quick YOUR_SERVER_IP
```

## 📋 Deployment Options

### Universal Deployment Commands
| Command | Description |
|---------|-------------|
| `bun run deploy:universal --host IP` | Full deployment with auto-optimization |
| `bun run deploy:universal:clean --host IP` | Clean deployment (removes old containers) |
| `bun run deploy:universal --host IP --domain DOMAIN` | Deploy with custom domain |
| `bun run deploy:setup-only --host IP` | Server setup only (no deployment) |
| `bun run deploy:deploy-only --host IP` | Deploy only (skip server setup) |

### Quick Deployment Commands (Optimized)
| Command | Description |
|---------|-------------|
| `bun run deploy:quick IP` | Smart auto-detection deployment |
| `bun run deploy:smart IP` | Intelligent deployment with change analysis |
| `bun run deploy:config IP` | Configuration-only update |
| `bun run deploy:source IP` | Source code changes only |
| `bun run deploy:rebuild IP` | Force rebuild all images |
| `bun run deploy:full IP` | Full deployment with server setup |

### Environment Management Commands
| Command | Description |
|---------|-------------|
| `bun run env:create-template` | Auto-create .env.prod.example |
| `bun run env:show-template` | Display current template |
| `bun run env:validate` | Validate environment configuration |

### Deployment Cache Management
| Command | Description |
|---------|-------------|
| `bun run deploy:cache:info` | Show deployment cache information |
| `bun run deploy:history` | Display deployment history |
| `bun run deploy:cache:clear` | Clear deployment cache |

## 🎯 Smart Deployment Features

### Automatic Environment Generation
- **Auto .env.prod.example creation**: Automatically creates environment template on first deploy
- **Domain-specific configuration**: Replaces placeholders with actual domain values
- **Secure password generation**: Generates cryptographically secure passwords automatically

### Intelligent Change Detection
- **File-level analysis**: Detects changes in Dockerfiles, package.json, source code
- **Smart strategies**: Chooses optimal deployment strategy based on changes
- **Incremental deployments**: Only rebuilds what's actually changed

### Deployment Strategies
1. **Clean Deploy**: Complete fresh installation (first deploy or major changes)
2. **Rebuild Deploy**: Rebuilds images when dependencies change
3. **Incremental Deploy**: Smart rebuild based on file changes
4. **Source-only Deploy**: Fast deployment for source code changes
5. **Config-only Deploy**: Ultra-fast configuration updates

### Performance Optimizations
- **Docker layer caching**: Preserves intermediate build layers
- **Selective rebuilding**: Only rebuilds changed services
- **Optimized startup sequence**: Databases start first with health checks
- **Minimal cleanup**: Preserves useful caches and artifacts

## 🔧 Server Requirements

- **Operating System**: Ubuntu 18+ or CentOS 7+ (automatic detection)
- **Access**: SSH access (root or sudo user)
- **Network**: Internet connection for Docker installation
- **Resources**: Minimum 2GB RAM, 10GB disk space

## 📝 Environment Setup (Automated)

### First Deployment
```bash
# Environment template is auto-created
bun run deploy:universal --host YOUR_SERVER_IP --domain yourdomain.com

# Or create template manually first
bun run env:create-template
```

### Manual Environment Setup (Optional)
```bash
# 1. Create from template
cp .env.prod.example .env.prod

# 2. Validate configuration
bun run env:validate

# 3. Deploy
bun run deploy:quick YOUR_SERVER_IP
```

## 🚀 Deployment Workflow Examples

### First-time Deployment
```bash
# Comprehensive setup with domain
bun run deploy:universal --host 1.2.3.4 --domain myapp.com

# Simple IP-based deployment
bun run deploy:universal --host 1.2.3.4
```

### Daily Development Deployments
```bash
# Smart deployment (recommended)
bun run deploy:smart 1.2.3.4

# Quick auto-detection
bun run deploy:quick 1.2.3.4

# Configuration updates only
bun run deploy:config 1.2.3.4
```

### Maintenance Operations
```bash
# Force complete rebuild
bun run deploy:rebuild 1.2.3.4

# Clean deployment (remove all data)
bun run deploy:universal:clean --host 1.2.3.4

# Server setup only (no deploy)
bun run deploy:setup-only 1.2.3.4
```

## 📊 Monitoring Deployment

### Check Deployment Status
```bash
# View deployment information
bun run deploy:cache:info

# See deployment history
bun run deploy:history

# Validate environment
bun run env:validate
```

### Remote Management
```bash
# SSH to server
ssh root@YOUR_SERVER_IP

# Check service status
cd /opt/katacore && docker compose ps

# View logs
cd /opt/katacore && docker compose logs -f

# Restart services
cd /opt/katacore && docker compose restart
```

## 🌐 Post-Deployment Access

After successful deployment, your applications will be available at:

### With Custom Domain
- **Frontend**: `https://yourdomain.com` (production) or `http://yourdomain.com:3000` (dev)
- **Backend API**: `https://api.yourdomain.com` or `http://yourdomain.com:3001`
- **Admin Panel (PgAdmin)**: `https://admin.yourdomain.com` or `http://yourdomain.com:8080`
- **File Storage (MinIO)**: `https://storage.yourdomain.com` or `http://yourdomain.com:9001`

### With IP Address
- **Frontend**: `http://SERVER_IP:3000`
- **Backend API**: `http://SERVER_IP:3001`
- **Admin Panel**: `http://SERVER_IP:8080`
- **File Storage**: `http://SERVER_IP:9001`

### Generated Credentials
Check `/opt/katacore/.env.prod` on your server for auto-generated:
- Database passwords
- Admin panel credentials
- API keys and JWT secrets
- MinIO access keys

## 🔄 Deployment Optimization Features

### Automatic Optimizations
- ✅ **Smart change detection**: Only rebuilds what's changed
- ✅ **Docker layer caching**: Faster subsequent builds
- ✅ **Incremental file sync**: Only uploads changed files
- ✅ **Parallel service startup**: Optimized service dependencies
- ✅ **Health check integration**: Waits for services to be ready

### Performance Metrics
- **First deployment**: ~5-10 minutes (full setup)
- **Incremental deployment**: ~1-3 minutes (changed files only)
- **Config-only deployment**: ~30 seconds (configuration updates)
- **Source-only deployment**: ~2-4 minutes (code changes)

## 🆘 Troubleshooting

### Common Issues and Solutions

**SSH Connection Failed:**
```bash
# Test SSH connection
ssh root@YOUR_SERVER_IP

# Try with different user
bun run deploy:universal --host YOUR_SERVER_IP --user ubuntu
```

**Port Issues:**
```bash
# Clean deployment to reset everything
bun run deploy:universal:clean --host YOUR_SERVER_IP

# Check firewall
ssh root@YOUR_SERVER_IP "ufw status"
```

**Environment Issues:**
```bash
# Validate environment
bun run env:validate

# Recreate environment template
rm .env.prod.example && bun run env:create-template
```

**Build Failures:**
```bash
# Force complete rebuild
bun run deploy:rebuild YOUR_SERVER_IP

# Clear deployment cache
bun run deploy:cache:clear && bun run deploy:full YOUR_SERVER_IP
```

**Service Not Starting:**
```bash
# Check logs on server
ssh root@YOUR_SERVER_IP "cd /opt/katacore && docker compose logs"

# Restart specific service
ssh root@YOUR_SERVER_IP "cd /opt/katacore && docker compose restart SERVICE_NAME"
```

### Debug Commands
```bash
# Show deployment cache information
bun run deploy:cache:info

# View deployment history
bun run deploy:history

# Test environment configuration
bun run env:validate

# Manual server connection test
ssh -v root@YOUR_SERVER_IP
```

## 🎯 Best Practices

### Development Workflow
1. **Use smart deployment**: `bun run deploy:smart IP` for regular updates
2. **Validate environment**: Run `bun run env:validate` before deploying
3. **Monitor deployments**: Check `bun run deploy:history` regularly
4. **Use specific strategies**: Choose appropriate deployment type for your changes

### Production Deployment
1. **First deployment**: Use `bun run deploy:universal --host IP --domain DOMAIN`
2. **Regular updates**: Use `bun run deploy:quick IP` for routine deployments
3. **Major changes**: Use `bun run deploy:rebuild IP` when dependencies change
4. **Emergency fixes**: Use `bun run deploy:config IP` for configuration-only updates

### Security Considerations
- Generated passwords are cryptographically secure (16+ characters)
- Environment files are automatically validated for security
- File permissions are automatically set appropriately
- Firewall rules are configured during server setup
# Ensure domain DNS points to server IP before deployment
bun run deploy:universal --host YOUR_SERVER_IP --domain yourdomain.com
```
