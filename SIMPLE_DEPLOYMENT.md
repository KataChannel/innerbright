# KataCore Simple Deployment Guide

This guide covers the simplified deployment approach for KataCore that only runs the API (NestJS) and Site (Next.js) containers on Docker, while external services (PostgreSQL, Redis, MinIO) and Nginx are managed separately on the cloud server.

## Overview

**What runs in Docker:**
- ✅ API (NestJS) - Port 3001
- ✅ Site (Next.js) - Port 3000

**What runs on cloud server (116.118.85.41):**
- 🌐 Nginx (reverse proxy, SSL termination)
- 🗄️ PostgreSQL database
- 🚀 Redis cache
- 📦 MinIO object storage

## Prerequisites

1. **Cloud Server Setup (116.118.85.41):**
   - Docker and Docker Compose installed
   - Nginx installed and configured
   - PostgreSQL running
   - Redis running
   - MinIO running

2. **Required Environment Variables:**
   - Copy `.env.example` to `.env`
   - Update all the values with your actual configuration

## Deployment Steps

### 1. Prepare Environment
```bash
# Copy environment template
cp .env.example .env

# Edit the environment file
nano .env
```

### 2. Deploy Containers
```bash
# Make deployment script executable
chmod +x deploy-simple.sh

# Run deployment
./deploy-simple.sh
```

### 3. Configure Nginx (on host server)
Create an Nginx configuration file to proxy requests to the Docker containers:

```nginx
server {
    listen 80;
    server_name your-domain.com;

    # API proxy
    location /api/ {
        proxy_pass http://localhost:3001/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }

    # Site proxy
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
```

## Management Commands

### Start Services
```bash
docker-compose -f docker-compose.prod.yml up -d
```

### Stop Services
```bash
docker-compose -f docker-compose.prod.yml down
```

### View Logs
```bash
# All services
docker-compose -f docker-compose.prod.yml logs -f

# API only
docker-compose -f docker-compose.prod.yml logs -f api

# Site only
docker-compose -f docker-compose.prod.yml logs -f site
```

### Check Status
```bash
docker-compose -f docker-compose.prod.yml ps
```

### Rebuild and Deploy
```bash
# Rebuild specific service
docker-compose -f docker-compose.prod.yml build api
docker-compose -f docker-compose.prod.yml build site

# Restart services
docker-compose -f docker-compose.prod.yml up -d
```

## Service URLs

- **API**: http://116.118.85.41:3001
- **Site**: http://116.118.85.41:3000
- **Through Nginx**: http://your-domain.com

## Troubleshooting

### 1. Check Container Status
```bash
docker ps
docker-compose -f docker-compose.prod.yml ps
```

### 2. Check Container Logs
```bash
docker-compose -f docker-compose.prod.yml logs api
docker-compose -f docker-compose.prod.yml logs site
```

### 3. Test API Health
```bash
curl http://localhost:3001/health
```

### 4. Test Site
```bash
curl http://localhost:3000
```

### 5. Check Environment Variables
```bash
docker-compose -f docker-compose.prod.yml config
```

## Benefits of This Approach

1. **Simplified Container Management**: Only application containers in Docker
2. **Better Performance**: Database and cache on host for optimal performance
3. **Easier Nginx Management**: Direct access to Nginx configuration on host
4. **Resource Efficiency**: Shared resources between host services
5. **Easier SSL Management**: SSL certificates managed directly on host Nginx

## Notes

- Make sure external services (PostgreSQL, Redis, MinIO) are accessible from Docker containers
- Update firewall rules to allow Docker containers to access host services
- Consider using Docker networks for better security if needed
- Monitor resource usage and adjust container limits as needed
