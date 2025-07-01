# Quick Deployment Guide

## 🚀 One-Command Deployment

Deploy KataCore to any cloud server with a single command:

```bash
bun run deploy:universal --host YOUR_SERVER_IP
```

## 📋 Deployment Options

| Command | Description |
|---------|-------------|
| `bun run deploy:universal --host IP` | Full deployment to server |
| `bun run deploy:universal:clean --host IP` | Clean deployment (removes old containers) |
| `bun run deploy:universal --host IP --domain DOMAIN` | Deploy with SSL certificate |

## 🔧 Server Requirements

- Ubuntu 18+ or CentOS 7+
- SSH access (root or sudo user)
- Internet connection

## 📝 Environment Setup

1. Copy `.env.prod.example` to `.env.prod`
2. Update passwords and domains in `.env.prod`
3. Run deployment command

## 🌐 Post-Deployment

After successful deployment:
- Frontend: `https://yourdomain.com` or `http://server-ip`
- Backend API: `https://yourdomain.com/api` or `http://server-ip:3001`
- Admin Panel: `https://admin.yourdomain.com` or `http://server-ip:8080`

## 🆘 Quick Troubleshooting

**SSH Connection Failed:**
```bash
ssh root@YOUR_SERVER_IP  # Test connection first
```

**Port Issues:**
```bash
bun run deploy:universal:clean --host YOUR_SERVER_IP  # Clean deployment
```

**SSL Issues:**
```bash
# Ensure domain DNS points to server IP before deployment
bun run deploy:universal --host YOUR_SERVER_IP --domain yourdomain.com
```
