# 🚀 Site-Only Deployment Guide

## ✅ Fixed Issues & Solutions

### 1. Dockerfile Context Problem
**Problem**: `COPY site/package.json` failed when building from site directory
**Solution**: Updated Dockerfile to work with proper build context

### 2. Prisma Dependencies 
**Problem**: Docker build failed looking for non-existent Prisma directory
**Solution**: Removed Prisma dependencies from site-only build

### 3. Build Command Compatibility
**Problem**: Bun runtime had compatibility issues with Next.js standalone
**Solution**: Use regular Node.js for production, Bun for development

## 🐳 Docker Deployment Options

### Option 1: Quick Docker Build (Recommended)
```bash
# From site directory
cd /chikiet/Innerbright/innerbright/site

# Build and run
./docker-build-site.sh

# Or with custom settings
./docker-build-site.sh v1.0.0 8080
```

### Option 2: Production Deployment
```bash
# From site directory
cd /chikiet/Innerbright/innerbright/site

# Deploy with Docker Compose (recommended)
./deploy-site-production.sh compose

# Deploy directly with Docker
./deploy-site-production.sh direct

# Deploy specific version
./deploy-site-production.sh compose v1.0.0 3000
```

### Option 3: Docker Compose Site-Only
```bash
# From root directory
cd /chikiet/Innerbright/innerbright

# Use site-only compose file
docker-compose -f docker-compose.site-only.yml up -d --build

# Or with environment
SITE_PORT=8080 docker-compose -f docker-compose.site-only.yml up -d --build
```

## 🔧 Environment Variables

### Required for Site-Only Build
```bash
BUILD_SITE_ONLY=true
NODE_ENV=production
NEXT_TELEMETRY_DISABLED=1
```

### Optional Configuration
```bash
SITE_PORT=3000              # Host port binding
DOMAIN=localhost            # Domain for Traefik
SITE_VERSION=latest         # Docker image version
```

## 📁 Available Dockerfiles

1. **`Dockerfile`** - Standard site-only build
2. **`Dockerfile.production`** - Node.js based production build
3. **`Dockerfile.site-only`** - Optimized Bun-based build

## 🚀 Build Commands

### Local Development
```bash
# Bun development server (site-only)
bun run dev:bun

# Standard development server
bun run dev
```

### Production Builds
```bash
# Site-only build (fastest)
bun run build:site-only

# Bun optimized build
bun run build:bun

# Check build output
ls -la .next/standalone/
```

## 🔍 Troubleshooting

### Build Context Issues
```bash
# Ensure you're in the right directory
pwd
# Should be: /chikiet/Innerbright/innerbright/site

# Check Dockerfile exists
ls -la Dockerfile*
```

### Container Issues
```bash
# Check container logs
docker logs innerbright-site-only

# Check container status
docker ps --filter name=innerbright-site

# Restart container
docker restart innerbright-site-only
```

### Network Issues
```bash
# Test local connection
curl http://localhost:3000

# Check port binding
netstat -tlnp | grep 3000
```

## 📊 Performance Metrics

- **Build Time**: ~16s (with site-only optimization)
- **Image Size**: ~200MB (Alpine-based)
- **Memory Usage**: ~100MB runtime
- **Startup Time**: ~5-10 seconds

## 🎯 Production Checklist

- [ ] Build succeeds with `BUILD_SITE_ONLY=true`
- [ ] Standalone output generated in `.next/standalone/`
- [ ] Docker image builds without errors
- [ ] Container starts and responds to health checks
- [ ] Site accessible on configured port
- [ ] Logs show no critical errors

## 🚨 Common Errors & Solutions

### Error: "Workspace not found 'site'"
**Solution**: Build from site directory, not root

### Error: "prisma directory not found"
**Solution**: Use updated Dockerfile without Prisma dependencies

### Error: "Html should not be imported outside pages/_document"
**Solution**: Fixed in `global-error.tsx` - no longer uses `<html>` tag

### Error: "Permission denied"
**Solution**: Make scripts executable with `chmod +x script-name.sh`

## 🎉 Success Indicators

When deployment is successful, you should see:
- ✅ Docker build completes without errors
- ✅ Container starts and shows "healthy" status
- ✅ Site responds at http://localhost:3000
- ✅ No critical errors in container logs
- ✅ PWA features work correctly
