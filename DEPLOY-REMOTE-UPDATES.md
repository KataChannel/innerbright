# 🚀 Deploy Remote Script Updates

## Overview
The `deploy-remote.sh` script has been updated with improved Docker Compose handling and better deployment features.

## Key Improvements

### 1. Enhanced Docker Compose Support
- **Docker Compose File Selection**: Automatic detection and validation of available compose files
- **Enhanced Validation**: Comprehensive syntax checking and service validation
- **Build Context Verification**: Checks for required directories (api, site) and Dockerfiles
- **Service Health Monitoring**: Added detailed health checks for all services

### 2. Improved Docker Compose Function
```bash
run_docker_compose() {
    # Added features:
    - Parallel building with --parallel flag
    - Better service startup monitoring
    - Service health validation
    - Container logs checking
    - Improved error handling
}
```

### 3. Enhanced Nginx Configuration
- **Comprehensive Proxy Setup**: Added configurations for all services
  - Main app (port 3000)
  - API (port 3001) 
  - MinIO Console (port 9001)
  - pgAdmin (port 5050)
- **Security Headers**: Added security headers and optimizations
- **WebSocket Support**: Added upgrade headers for real-time features
- **Health Check Endpoint**: Added `/health` endpoint

### 4. Service Health Monitoring
- **Individual Service Checks**: Tests each service individually
- **Database Connection Testing**: PostgreSQL and Redis connectivity
- **Resource Usage Monitoring**: Docker container stats
- **Comprehensive Status Report**: Detailed health summary

### 5. Better Error Handling
- **Syntax Validation**: Fixed heredoc syntax issues
- **Prerequisite Checks**: Enhanced validation of requirements
- **Build Context Validation**: Ensures all required files exist
- **SSH Connection Testing**: Better connection validation

## Usage Examples

### Basic Full Deployment
```bash
./deploy-remote.sh 116.118.85.41 innerbright.vn
```

### Simple Deployment (No SSL)
```bash
./deploy-remote.sh --simple 116.118.85.41
```

### Custom Docker Compose File
```bash
./deploy-remote.sh --compose docker-compose.startkitv1-clean\ copy.yml 116.118.85.41 innerbright.vn
```

### With Custom SSH Settings
```bash
./deploy-remote.sh --user ubuntu --key ~/.ssh/my-key.pem 116.118.85.41 innerbright.vn
```

## New Functions Added

1. **`select_docker_compose_file()`** - Intelligent compose file selection
2. **`validate_docker_compose()`** - Enhanced validation
3. **`check_service_health()`** - Comprehensive health monitoring

## Services Deployed

After deployment, the following services will be available:

### Full Deployment (with SSL)
- 🌐 Main Site: `https://yourdomain.com`
- 🚀 API: `https://yourdomain.com/api`
- 📦 MinIO: `https://yourdomain.com:9000`
- 🗄️ pgAdmin: `https://yourdomain.com/pgadmin`

### Simple Deployment
- 🌐 Main Site: `http://SERVER_IP:3000`
- 🚀 API: `http://SERVER_IP:3001`
- 📦 MinIO: `http://SERVER_IP:9000`
- 🗄️ pgAdmin: `http://SERVER_IP:5050`

## Features

✅ **Auto Environment Generation** - Secure password generation  
✅ **Docker Compose Validation** - Syntax and service checks  
✅ **Service Health Monitoring** - Comprehensive health checks  
✅ **Nginx + SSL Support** - Full HTTPS configuration  
✅ **Build Context Validation** - Ensures all files exist  
✅ **Resource Monitoring** - Container stats and performance  
✅ **Error Recovery** - Better error handling and reporting  

## Next Steps

1. **Test Deployment**: Use with your actual server
2. **Monitor Services**: Check health status after deployment
3. **Review Logs**: Use management commands to monitor
4. **Backup**: Set up regular database backups

## Management Commands

```bash
# Check logs
ssh -i ~/.ssh/id_rsa root@SERVER_IP 'cd /opt/katacore && docker-compose logs'

# Restart services
ssh -i ~/.ssh/id_rsa root@SERVER_IP 'cd /opt/katacore && docker-compose restart'

# Check status
ssh -i ~/.ssh/id_rsa root@SERVER_IP 'cd /opt/katacore && docker-compose ps'
```
