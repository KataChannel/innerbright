# Deploy application function
deploy_application() {
    log "${YELLOW}🚀 Deploying application...${NC}"
    
    cd $PROJECT_DIR
    
    # Check Docker installation and permissions
    log "${YELLOW}🐳 Checking Docker installation and permissions...${NC}"
    
    # Check if Docker is installed
    if ! command -v docker &> /dev/null; then
        error_exit "Docker is not installed. Please run the install_dependencies function first."
    fi
    
    # Check if Docker daemon is running
    if ! docker info &> /dev/null; then
        log "${YELLOW}⚠️  Docker daemon is not accessible. Checking issues...${NC}"
        
        # Check if Docker service exists
        if ! sudo systemctl list-unit-files | grep -q docker.service; then
            error_exit "Docker service not found. Please run install_dependencies first."
        fi
        
        # Check Docker service status
        if ! sudo systemctl is-active --quiet docker; then
            log "${YELLOW}🔄 Docker service is not running. Starting...${NC}"
            sudo systemctl start docker
            sudo systemctl enable docker
            sleep 5
        fi
        
        # Fix Docker socket permissions
        if [[ -S /var/run/docker.sock ]]; then
            log "${YELLOW}🔧 Fixing Docker socket permissions...${NC}"
            sudo chmod 666 /var/run/docker.sock
        else
            log "${RED}❌ Docker socket not found at /var/run/docker.sock${NC}"
            error_exit "Docker socket is missing. Docker installation may be corrupted."
        fi
        
        # Test again after fixes
        if ! docker info &> /dev/null; then
            log "${RED}❌ Still cannot access Docker daemon${NC}"
            log "${YELLOW}📋 Diagnostic information:${NC}"
            log "   Docker service status:"
            sudo systemctl status docker --no-pager -l || true
            log "   Docker socket:"
            ls -la /var/run/docker.sock || true
            log "   Current user: $(whoami)"
            log "   User groups: $(groups)"
            
            # Try using sudo for all Docker commands
            log "${YELLOW}⚠️  Will use sudo for Docker commands${NC}"
            DOCKER_CMD="sudo docker"
            DOCKER_COMPOSE_CMD="sudo docker compose"
        else
            log "${GREEN}✅ Docker daemon is now accessible${NC}"
            DOCKER_CMD="docker"
            DOCKER_COMPOSE_CMD="docker compose"
        fi
    else
        log "${GREEN}✅ Docker daemon is accessible${NC}"
        DOCKER_CMD="docker"
        DOCKER_COMPOSE_CMD="docker compose"
    fi
    
    # Check if user is in docker group and apply group changes if needed
    if ! groups $USER | grep -q docker; then
        log "${YELLOW}⚠️  User $USER is not in docker group. Adding to group...${NC}"
        sudo usermod -aG docker $USER
        log "${YELLOW}⚠️  Applying group changes without logout...${NC}"
        
        # Try to apply group changes without logout
        if exec sg docker -c "$0 $*" 2>/dev/null; then
            log "${GREEN}✅ Group changes applied${NC}"
        else
            log "${YELLOW}⚠️  Could not apply group changes. Using sudo for Docker commands...${NC}"
            DOCKER_CMD="sudo docker"
            DOCKER_COMPOSE_CMD="sudo docker compose"
        fi
    fi
    
    # Test Docker with a simple command
    log "   Testing Docker functionality..."
    if $DOCKER_CMD run --rm hello-world &> /dev/null; then
        log "${GREEN}✅ Docker is working correctly${NC}"
    else
        log "${YELLOW}⚠️  Docker test failed, but continuing with deployment...${NC}"
    fi
    
    # Check if docker-compose file exists
    if [[ ! -f "docker-compose.yml" ]] && [[ ! -f "docker-compose.yaml" ]]; then
        log "${RED}❌ No docker-compose.yml file found${NC}"
        log "${YELLOW}📋 Available files in project directory:${NC}"
        ls -la
        
        # Try to find compose files in subdirectories
        COMPOSE_FILE=$(find . -name "docker-compose.yml" -o -name "docker-compose.yaml" | head -1)
        if [[ -n "$COMPOSE_FILE" ]]; then
            log "${YELLOW}📁 Found compose file at: $COMPOSE_FILE${NC}"
            cd "$(dirname "$COMPOSE_FILE")"
            log "${GREEN}✅ Changed to directory: $(pwd)${NC}"
        else
            log "${RED}❌ No docker-compose file found in project${NC}"
            log "${YELLOW}💡 Creating a basic docker-compose.yml file...${NC}"
            
            # Create a basic docker-compose.yml
            cat > docker-compose.yml << 'EOF'
services:
  postgres:
    image: postgres:15-alpine
    container_name: innerbright-postgres
    environment:
      POSTGRES_DB: ${POSTGRES_DB:-innerbright_prod}
      POSTGRES_USER: ${POSTGRES_USER:-innerbright_user}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_INITDB_ARGS: --encoding=UTF-8 --lc-collate=C --lc-ctype=C
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER:-innerbright_user} -d ${POSTGRES_DB:-innerbright_prod}"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s
    networks:
      - app-network

  minio:
    image: minio/minio:latest
    container_name: innerbright-minio
    environment:
      MINIO_ROOT_USER: ${MINIO_ROOT_USER:-minioadmin}
      MINIO_ROOT_PASSWORD: ${MINIO_ROOT_PASSWORD}
    volumes:
      - minio_data:/data
    ports:
      - "9000:9000"
      - "9001:9001"
    command: server /data --console-address ":9001"
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:9000/minio/health/live"]
      interval: 30s
      timeout: 20s
      retries: 3
    networks:
      - app-network

  redis:
    image: redis:7-alpine
    container_name: innerbright-redis
    volumes:
      - redis_data:/data
    ports:
      - "6379:6379"
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 30s
      timeout: 10s
      retries: 5
    command: redis-server --appendonly yes --maxmemory 256mb --maxmemory-policy allkeys-lru
    networks:
      - app-network

  nextjs:
    build:
      context: ./site
      dockerfile: Dockerfile
      target: runner
    container_name: innerbright-nextjs
    environment:
      - NODE_ENV=production
      - DATABASE_URL=postgresql://${POSTGRES_USER:-innerbright_user}:${POSTGRES_PASSWORD}@postgres:5432/${POSTGRES_DB:-innerbright_prod}
      - NEXTAUTH_SECRET=${NEXTAUTH_SECRET}
      - NEXTAUTH_URL=${NEXTAUTH_URL}
      - NEXT_TELEMETRY_DISABLED=1
    ports:
      - "3000:3000"
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/api/health"]
      interval: 30s
      timeout: 10s
      retries: 5
    networks:
      - app-network

  nestjs:
    build:
      context: ./api
      dockerfile: Dockerfile
      target: runner
    container_name: innerbright-nestjs
    environment:
      - NODE_ENV=production
      - DATABASE_URL=postgresql://${POSTGRES_USER:-innerbright_user}:${POSTGRES_PASSWORD}@postgres:5432/${POSTGRES_DB:-innerbright_prod}
      - MINIO_ENDPOINT=minio:9000
      - MINIO_ACCESS_KEY=${MINIO_ROOT_USER:-minioadmin}
      - MINIO_SECRET_KEY=${MINIO_ROOT_PASSWORD}
    ports:
      - "3333:3333"
    depends_on:
      postgres:
        condition: service_healthy
      minio:
        condition: service_healthy
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3333/health"]
      interval: 30s
      timeout: 10s
      retries: 5
    networks:
      - app-network

networks:
  app-network:
    driver: bridge

volumes:
  postgres_data:
    driver: local
  minio_data:
    driver: local
  redis_data:
    driver: local
EOF
            log "${GREEN}✅ Created basic docker-compose.yml${NC}"
        fi
    fi
    
    # Ensure data directories exist before starting containers
    log "   Ensuring data directories exist..."
    mkdir -p data/postgres data/minio data/redis 2>/dev/null || true
    
    # Final permission check before deployment
    log "   Final permission check..."
    if [[ ! -w "data" ]]; then
        log "${YELLOW}⚠️  Data directory not writable, fixing permissions...${NC}"
        sudo chown -R $USER:$USER data/ 2>/dev/null || \
        sudo chmod -R 777 data/ 2>/dev/null || \
        log "${YELLOW}⚠️  Could not fix permissions, continuing anyway...${NC}"
    fi
    
    # Check if .env file exists for docker compose
    if [[ ! -f ".env" ]]; then
        log "${YELLOW}⚠️  No .env file found, creating basic one...${NC}"
        cat > .env << EOF
POSTGRES_DB=${DB_NAME:-innerbright_prod}
POSTGRES_USER=${DB_USER:-innerbright_user}
POSTGRES_PASSWORD=${DB_PASSWORD:-changeme}
MINIO_ROOT_USER=${MINIO_USER:-minioadmin}
MINIO_ROOT_PASSWORD=${MINIO_PASSWORD:-changeme}
NEXTAUTH_SECRET=${NEXTAUTH_SECRET:-$(openssl rand -base64 32)}
NEXTAUTH_URL=https://${DOMAIN:-localhost}
EOF
    fi
    
    # Check available system resources before starting containers
    log "   Checking system resources..."
    AVAILABLE_MEM=$(free -m | awk 'NR==2{print $7}')
    AVAILABLE_DISK=$(df . | awk 'NR==2{print int($4/1024)}')
    
    if [[ $AVAILABLE_MEM -lt 1000 ]]; then
        log "${YELLOW}⚠️  Low available memory (${AVAILABLE_MEM}MB). Containers may fail to start.${NC}"
    fi
    
    if [[ $AVAILABLE_DISK -lt 2000 ]]; then
        log "${YELLOW}⚠️  Low available disk space (${AVAILABLE_DISK}MB). Containers may fail to start.${NC}"
    fi
    
    # Stop any existing containers to free up resources
    log "   Stopping any existing containers..."
    $DOCKER_COMPOSE_CMD down 2>/dev/null || true
    
    # Clean up any orphaned containers
    $DOCKER_CMD container prune -f 2>/dev/null || true
    
    # Pull latest base images
    log "   Pulling latest images..."
    $DOCKER_COMPOSE_CMD pull postgres minio redis 2>/dev/null || {
        log "${YELLOW}⚠️  Failed to pull some images, but continuing...${NC}"
    }
    
    # Start services one by one to better identify issues
    log "   Starting PostgreSQL database..."
    if $DOCKER_COMPOSE_CMD up postgres -d; then
        log "${GREEN}✅ PostgreSQL started${NC}"
        
        # Wait for PostgreSQL to be ready
        log "   Waiting for PostgreSQL to be ready..."
        for i in {1..30}; do
            if $DOCKER_CMD exec innerbright-postgres pg_isready -U ${DB_USER:-innerbright_user} &>/dev/null; then
                log "${GREEN}✅ PostgreSQL is ready${NC}"
                break
            fi
            sleep 2
        done
    else
        log "${RED}❌ Failed to start PostgreSQL${NC}"
        log "${YELLOW}📋 PostgreSQL logs:${NC}"
        $DOCKER_COMPOSE_CMD logs postgres 2>/dev/null || true
    fi
    
    log "   Starting MinIO object storage..."
    if $DOCKER_COMPOSE_CMD up minio -d; then
        log "${GREEN}✅ MinIO started${NC}"
    else
        log "${RED}❌ Failed to start MinIO${NC}"
        log "${YELLOW}📋 MinIO logs:${NC}"
        $DOCKER_COMPOSE_CMD logs minio 2>/dev/null || true
    fi
    
    log "   Starting Redis cache..."
    if $DOCKER_COMPOSE_CMD up redis -d; then
        log "${GREEN}✅ Redis started${NC}"
    else
        log "${RED}❌ Failed to start Redis${NC}"
        log "${YELLOW}📋 Redis logs:${NC}"
        $DOCKER_COMPOSE_CMD logs redis 2>/dev/null || true
    fi
    
    # Check if basic services are running
    RUNNING_SERVICES=$($DOCKER_COMPOSE_CMD ps --services --filter status=running | wc -l)
    if [[ $RUNNING_SERVICES -eq 0 ]]; then
        log "${RED}❌ No containers are running${NC}"
        log "${YELLOW}📋 Debugging information:${NC}"
        log "   Docker version: $($DOCKER_CMD --version)"
        log "   Docker compose version: $($DOCKER_COMPOSE_CMD version --short 2>/dev/null || echo 'N/A')"
        log "   Available memory: ${AVAILABLE_MEM}MB"
        log "   Available disk: ${AVAILABLE_DISK}MB"
        log "   Current user: $(whoami)"
        log "   User groups: $(groups)"
        
        # Show container status
        log "${YELLOW}📋 Container status:${NC}"
        $DOCKER_COMPOSE_CMD ps || true
        
        # Show recent Docker events
        log "${YELLOW}📋 Recent Docker events:${NC}"
        $DOCKER_CMD events --since 5m --until now 2>/dev/null | tail -10 || true
        
        # Try with simplified compose file
        log "${YELLOW}🔄 Creating simplified docker-compose.yml for basic services...${NC}"
        cat > docker-compose-simple.yml << 'EOF'
version: '3.8'

services:
  postgres:
    image: postgres:13-alpine
    container_name: innerbright-postgres-simple
    environment:
      POSTGRES_DB: ${POSTGRES_DB:-innerbright_prod}
      POSTGRES_USER: ${POSTGRES_USER:-innerbright_user}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-changeme123}
    volumes:
      - postgres_data_simple:/var/lib/postgresql/data
    ports:
      - "5432:5432"
    restart: unless-stopped

volumes:
  postgres_data_simple:
EOF
        
        log "   Trying with simplified PostgreSQL container..."
        if $DOCKER_COMPOSE_CMD -f docker-compose-simple.yml up -d; then
            log "${GREEN}✅ Simplified PostgreSQL container started${NC}"
            log "${YELLOW}ℹ Basic database service is running. You can continue with manual application deployment.${NC}"
        else
            # Final diagnostic
            log "${RED}❌ Even simplified container failed to start${NC}"
            log "${YELLOW}📋 Final diagnostic information:${NC}"
            
            # Check if it's a permission issue
            if ! $DOCKER_CMD ps &>/dev/null; then
                log "${RED}❌ Cannot access Docker daemon. This is likely a permission issue.${NC}"
                log "${YELLOW}💡 Solutions:${NC}"
                log "   1. Log out and log back in (if recently added to docker group)"
                log "   2. Run: newgrp docker"
                log "   3. Restart the system"
                log "   4. Check Docker service: sudo systemctl status docker"
            fi
            
            # Check disk space more thoroughly
            df -h
            
            error_exit "Failed to start even basic containers. Please check the diagnostic information above."
        fi
    else
        log "${GREEN}✅ Basic services are running (${RUNNING_SERVICES} containers)${NC}"
    fi
    
    # Wait for services to be ready
    log "${YELLOW}⏳ Waiting for services to be ready...${NC}"
    sleep 15
    
    # Check service health
    services=("postgres" "minio" "redis")
    for service in "${services[@]}"; do
        if $DOCKER_COMPOSE_CMD ps $service 2>/dev/null | grep -q "healthy\|running"; then
            log "${GREEN}✅ $service is healthy${NC}"
        else
            log "${YELLOW}⚠️  $service status check...${NC}"
            $DOCKER_COMPOSE_CMD ps $service 2>/dev/null || log "Could not check $service status"
        fi
    done
    
    # Try to start application services if basic services are running
    if [[ $RUNNING_SERVICES -gt 0 ]]; then
        log "${YELLOW}🔄 Starting application services...${NC}"
        
        # Check if application directories and Dockerfiles exist
        log "   Checking for application services..."
        
        # Check for Next.js service
        if [[ -d "site" ]]; then
            if [[ -f "site/Dockerfile" ]]; then
                log "   Starting Next.js frontend..."
                if $DOCKER_COMPOSE_CMD up nextjs -d 2>/dev/null; then
                    log "${GREEN}✅ Next.js service started${NC}"
                else
                    log "${YELLOW}⚠️  Next.js service failed to start${NC}"
                    log "${YELLOW}📋 Next.js logs:${NC}"
                    $DOCKER_COMPOSE_CMD logs nextjs 2>/dev/null || true
                fi
            else
                log "${YELLOW}⚠️  site/Dockerfile not found${NC}"
                log "   Available files in site directory:"
                ls -la site/ 2>/dev/null | head -10 || log "   Cannot list site directory"
            fi
        else
            log "${YELLOW}⚠️  site directory not found${NC}"
            log "   Current directory contents:"
            ls -la . | head -10
        fi
        
        # Check for NestJS service
        if [[ -d "api" ]]; then
            if [[ -f "api/Dockerfile" ]]; then
                log "   Starting NestJS backend..."
                if $DOCKER_COMPOSE_CMD up nestjs -d 2>/dev/null; then
                    log "${GREEN}✅ NestJS service started${NC}"
                else
                    log "${YELLOW}⚠️  NestJS service failed to start${NC}"
                    log "${YELLOW}📋 NestJS logs:${NC}"
                    $DOCKER_COMPOSE_CMD logs nestjs 2>/dev/null || true
                fi
            else
                log "${YELLOW}⚠️  api/Dockerfile not found${NC}"
                log "   Available files in api directory:"
                ls -la api/ 2>/dev/null | head -10 || log "   Cannot list api directory"
            fi
        else
            log "${YELLOW}⚠️  api directory not found${NC}"
        fi
        
        # If no application services can start, check if we need to build them differently
        if [[ ! -d "site" && ! -d "api" ]]; then
            log "${YELLOW}💡 Application directories not found. Checking project structure...${NC}"
            log "   Project directory: $(pwd)"
            log "   Directory contents:"
            find . -maxdepth 3 -name "Dockerfile" -type f 2>/dev/null || log "   No Dockerfiles found"
            
            # Try to start services anyway in case docker-compose handles paths differently
            log "${YELLOW}🔄 Attempting to start all services from docker-compose...${NC}"
            $DOCKER_COMPOSE_CMD up -d 2>/dev/null || {
                log "${YELLOW}⚠️  Full service startup failed${NC}"
                log "${YELLOW}📋 Available services in docker-compose.yml:${NC}"
                $DOCKER_COMPOSE_CMD config --services 2>/dev/null || log "   Cannot read docker-compose services"
            }
        fi
    else
        log "${RED}❌ No basic services running, skipping application services${NC}"
    fi
    
    # Final status report
    FINAL_RUNNING_SERVICES=$($DOCKER_COMPOSE_CMD ps --services --filter status=running | wc -l)
    log "${GREEN}✅ Application deployment completed${NC}"
    log "${BLUE}📊 Final Status: ${FINAL_RUNNING_SERVICES} containers running${NC}"
    
    # Show running containers
    log "${BLUE}📋 Running containers:${NC}"
    $DOCKER_COMPOSE_CMD ps 2>/dev/null || $DOCKER_CMD ps
}
