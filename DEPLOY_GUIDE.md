# Complete Deployment Guide - deploy.sh

## Overview
File `deploy.sh` là script deployment hoàn chỉnh, gộp chung tất cả các bước từ build local đến deploy lên server trong một lần chạy.

## Features

### 🏗️ **Local Build**
- Tự động clean builds cũ
- Install dependencies nếu cần (bun hoặc npm)
- Build Next.js application với optimization
- Detect standalone build hoặc regular build
- Hiển thị kích thước build

### 📦 **Package Creation**
- Tạo deployment archive với tất cả files cần thiết
- Include: .next/, package.json, Dockerfile, docker-compose, public/, prisma/
- Optimize package size

### 🚀 **Server Deployment**  
- Test connection đến server trước khi deploy
- Stop containers cũ và clean artifacts
- Upload package lên server
- Extract và setup environment
- Auto-select đúng Dockerfile (prebuilt vs regular)
- Build và start Docker containers
- Health check application
- Show resource usage và logs

## Usage

### Quick Deploy
```bash
./deploy.sh
```

### Step by Step Process
1. **Local Build**: Builds Next.js app locally
2. **Package**: Creates deployment archive
3. **Upload**: Sends package to server
4. **Deploy**: Extracts and runs on server
5. **Verify**: Checks if app is running correctly

## Prerequisites

### Local Environment
- Node.js/Bun installed
- SSH access to server configured
- Project dependencies in package.json

### Server Environment  
- Docker và Docker Compose installed
- SSH key access configured
- Project directory exists at `/root/innerbright`

## Configuration

### Server Details
- **IP**: 116.118.48.208
- **User**: root
- **Project Path**: /root/innerbright
- **Port**: 3000

### Docker Files Used
- `Dockerfile.prebuilt` - For standalone builds
- `Dockerfile.prebuilt-regular` - For regular builds  
- `docker-compose.prebuilt.yml` - Container orchestration

## Build Types

### Standalone Build (Preferred)
- Next.js creates `.next/standalone` directory
- Self-contained with all dependencies
- Faster startup and smaller container size
- Uses `Dockerfile.prebuilt`

### Regular Build (Fallback)
- Standard Next.js build in `.next/`
- Requires node_modules in container
- Uses `Dockerfile.prebuilt-regular`

## Output

### Success Indicators
```
✅ Local build completed!
✅ Server connection successful  
✅ Application is responding on port 3000
🎉 Complete Deployment Finished Successfully!
```

### Available URLs
- http://116.118.48.208:3000
- http://innerbright.vn (if DNS configured)

## Troubleshooting

### Common Issues

#### Build Failures
```bash
# Check Node.js version
node --version

# Clean and reinstall dependencies  
rm -rf node_modules
bun install
```

#### Connection Issues
```bash
# Test SSH connection
ssh root@116.118.48.208 exit

# Check server status
ping 116.118.48.208
```

#### Docker Issues on Server
```bash
# SSH to server and check
ssh root@116.118.48.208
cd /root/innerbright
docker-compose -f docker-compose.prebuilt.yml logs
```

### Manual Commands

#### Check Logs
```bash
ssh root@116.118.48.208 'cd /root/innerbright && docker-compose -f docker-compose.prebuilt.yml logs'
```

#### Restart Application
```bash
ssh root@116.118.48.208 'cd /root/innerbright && docker-compose -f docker-compose.prebuilt.yml restart'
```

#### Check Container Status
```bash
ssh root@116.118.48.208 'cd /root/innerbright && docker-compose -f docker-compose.prebuilt.yml ps'
```

## File Structure After Deployment

### Server Directory (`/root/innerbright/`)
```
├── .next/                          # Built application
├── package.json                    # Dependencies info
├── next.config.ts                  # Next.js config
├── public/                         # Static assets
├── prisma/                         # Database schema
├── Dockerfile.prebuilt*            # Docker configurations
├── docker-compose.prebuilt.yml     # Container setup
└── deploy-package.tar.gz           # Cleanup after deploy
```

## Performance Optimization

### Local Build Optimization
- Uses Bun if available (faster than npm)
- Cleans cache before build
- Standalone build when possible

### Server Optimization  
- No-cache Docker build to ensure fresh deployment
- Health checks with retry logic
- Resource monitoring included

## Security Considerations

### SSH Configuration
- Uses SSH key authentication
- Connection timeout for failed connections
- Batch mode to avoid interactive prompts

### Server Security
- Runs containers as non-root when possible
- Environment isolation with Docker
- Clean up temporary files after deployment

## Monitoring

### Health Checks
- HTTP response check on port 3000
- Container status verification
- Resource usage monitoring
- Application startup verification

### Logs Access
```bash
# Real-time logs
ssh root@116.118.48.208 'cd /root/innerbright && docker-compose -f docker-compose.prebuilt.yml logs -f'

# Last 100 lines
ssh root@116.118.48.208 'cd /root/innerbright && docker-compose -f docker-compose.prebuilt.yml logs --tail=100'
```

## Comparison with Previous Scripts

### Old Method
- `build-local.sh` → Manual build
- `deploy-prebuilt-simple.sh` → Deploy pre-built files
- Two separate steps, possibility for errors

### New Method ✅
- `deploy.sh` → Complete pipeline in one command
- Integrated error handling
- Better user experience
- Comprehensive status reporting

## Next Steps

After successful deployment:

1. **Configure DNS**: Point innerbright.vn to 116.118.48.208
2. **Setup SSL**: Configure HTTPS with Let's Encrypt
3. **Monitoring**: Setup application monitoring
4. **Backups**: Configure database and file backups
5. **CI/CD**: Integrate with GitHub Actions for automated deployment

## Example Run

```bash
$ ./deploy.sh
🚀 Complete Deployment for Innerbright
Target: AMD CS 2 Server (1 vCPU, 2GB RAM)
================================================
🏗️ Step 1: Building application locally...
🧹 Cleaning previous builds...
🔨 Building Next.js application...
✅ Standalone build created successfully!
📊 Build size:
45M     .next/standalone
12M     .next/static
✅ Local build completed!
🏗️ Step 2: Preparing deployment package...
📦 Creating deployment archive...
✅ Archive created: deploy-package.tar.gz
🚀 Step 3: Deploying to server...
🔌 Testing server connection...
✅ Server connection successful
🔧 Preparing server environment...
📤 Uploading deployment package...
🚀 Extracting and deploying on server...
✅ Application is responding on port 3000
🎉 Complete Deployment Finished Successfully!
```

The deployment is now streamlined into a single command! 🚀
