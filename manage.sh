#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
BACKUP_DIR="./backups"
DATE=$(date +%Y%m%d_%H%M%S)
POSTGRES_CONTAINER="innerbright-postgres-1"

echo -e "${BLUE}🔧 Innerbright Management Script${NC}"

# Create backup directory
mkdir -p $BACKUP_DIR

case $1 in
    "backup")
        echo -e "${YELLOW}📦 Creating database backup...${NC}"
        docker-compose exec -T postgres pg_dump -U postgres innerbright > "$BACKUP_DIR/backup_$DATE.sql"
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅ Backup created: $BACKUP_DIR/backup_$DATE.sql${NC}"
        else
            echo -e "${RED}❌ Backup failed${NC}"
            exit 1
        fi
        ;;
        
    "restore")
        if [ -z "$2" ]; then
            echo -e "${RED}❌ Please specify backup file: ./manage.sh restore backup_file.sql${NC}"
            exit 1
        fi
        
        echo -e "${YELLOW}🔄 Restoring database from $2...${NC}"
        docker-compose exec -T postgres psql -U postgres innerbright < "$2"
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅ Database restored successfully${NC}"
        else
            echo -e "${RED}❌ Restore failed${NC}"
            exit 1
        fi
        ;;
        
    "logs")
        SERVICE=${2:-""}
        if [ -z "$SERVICE" ]; then
            echo -e "${YELLOW}📋 Showing logs for all services...${NC}"
            docker-compose logs -f --tail=100
        else
            echo -e "${YELLOW}📋 Showing logs for $SERVICE...${NC}"
            docker-compose logs -f --tail=100 $SERVICE
        fi
        ;;
        
    "status")
        echo -e "${YELLOW}📊 Service Status:${NC}"
        docker-compose ps
        
        echo -e "\n${YELLOW}💾 Resource Usage:${NC}"
        docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}"
        
        echo -e "\n${YELLOW}💽 Disk Usage:${NC}"
        docker system df
        ;;
        
    "health")
        echo -e "${YELLOW}🏥 Health Checks:${NC}"
        
        # Check Next.js
        if curl -f -s http://localhost:3000/api/health > /dev/null; then
            echo -e "${GREEN}✅ Next.js Frontend: Healthy${NC}"
        else
            echo -e "${RED}❌ Next.js Frontend: Unhealthy${NC}"
        fi
        
        # Check NestJS
        if curl -f -s http://localhost:3333/health > /dev/null; then
            echo -e "${GREEN}✅ NestJS API: Healthy${NC}"
        else
            echo -e "${RED}❌ NestJS API: Unhealthy${NC}"
        fi
        
        # Check PostgreSQL
        if docker-compose exec postgres pg_isready -U postgres > /dev/null 2>&1; then
            echo -e "${GREEN}✅ PostgreSQL: Healthy${NC}"
        else
            echo -e "${RED}❌ PostgreSQL: Unhealthy${NC}"
        fi
        
        # Check MinIO
        if curl -f -s http://localhost:9000/minio/health/live > /dev/null; then
            echo -e "${GREEN}✅ MinIO: Healthy${NC}"
        else
            echo -e "${RED}❌ MinIO: Unhealthy${NC}"
        fi
        ;;
        
    "clean")
        echo -e "${YELLOW}🧹 Cleaning up Docker resources...${NC}"
        docker system prune -f
        docker volume prune -f
        echo -e "${GREEN}✅ Cleanup completed${NC}"
        ;;
        
    "update")
        echo -e "${YELLOW}🔄 Updating services...${NC}"
        docker-compose pull
        docker-compose up -d --remove-orphans
        echo -e "${GREEN}✅ Services updated${NC}"
        ;;
        
    "shell")
        SERVICE=${2:-"nextjs"}
        echo -e "${YELLOW}🐚 Opening shell in $SERVICE container...${NC}"
        docker-compose exec $SERVICE sh
        ;;
        
    "db")
        echo -e "${YELLOW}🗄️  Opening PostgreSQL shell...${NC}"
        docker-compose exec postgres psql -U postgres innerbright
        ;;
        
    *)
        echo -e "${BLUE}Usage: ./manage.sh [command] [options]${NC}"
        echo -e ""
        echo -e "${GREEN}Available commands:${NC}"
        echo -e "  ${YELLOW}backup${NC}           - Create database backup"
        echo -e "  ${YELLOW}restore <file>${NC}   - Restore database from backup"
        echo -e "  ${YELLOW}logs [service]${NC}   - Show logs (all services or specific)"
        echo -e "  ${YELLOW}status${NC}           - Show service status and resource usage"
        echo -e "  ${YELLOW}health${NC}           - Check health of all services"
        echo -e "  ${YELLOW}clean${NC}            - Clean up Docker resources"
        echo -e "  ${YELLOW}update${NC}           - Update all services"
        echo -e "  ${YELLOW}shell [service]${NC}  - Open shell in container (default: nextjs)"
        echo -e "  ${YELLOW}db${NC}               - Open PostgreSQL shell"
        echo -e ""
        echo -e "${GREEN}Examples:${NC}"
        echo -e "  ./manage.sh backup"
        echo -e "  ./manage.sh restore backups/backup_20240101_120000.sql"
        echo -e "  ./manage.sh logs nextjs"
        echo -e "  ./manage.sh shell nestjs"
        ;;
esac
