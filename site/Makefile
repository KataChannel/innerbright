# 🚀 Innerbright Site-Only Build & Deploy Makefile

.PHONY: help build deploy clean logs status restart dev

# Configuration
PROJECT_NAME := innerbright-site
DOCKER_IMAGE := $(PROJECT_NAME):latest
SERVER_IP := 116.118.85.41
CONTAINER_NAME := innerbright-site-only

# Colors for output
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
NC := \033[0m

help: ## Show this help message
	@echo -e "$(BLUE)🚀 Innerbright Site-Only Build & Deploy Commands$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "$(GREEN)%-15s$(NC) %s\n", $$1, $$2}'

dev: ## Start development server with Bun
	@echo -e "$(BLUE)🔥 Starting development server...$(NC)"
	BUILD_SITE_ONLY=true bun run dev:bun

build-local: ## Build application locally
	@echo -e "$(BLUE)🔨 Building application locally...$(NC)"
	@if [ ! -d "node_modules" ]; then \
		echo -e "$(YELLOW)📦 Installing dependencies...$(NC)"; \
		if command -v bun >/dev/null 2>&1; then \
			bun install; \
		else \
			npm install; \
		fi; \
	fi
	@export BUILD_SITE_ONLY=true && \
	export NEXT_TELEMETRY_DISABLED=1 && \
	export NODE_ENV=production && \
	if command -v bun >/dev/null 2>&1; then \
		echo -e "$(BLUE)Using Bun for build...$(NC)" && \
		bun run build:site-only; \
	else \
		echo -e "$(BLUE)Using npm for build...$(NC)" && \
		npm run build:site-only; \
	fi
	@if [ ! -d ".next/standalone" ]; then \
		echo -e "$(YELLOW)❌ Standalone build failed - check next.config.ts$(NC)"; \
		exit 1; \
	fi
	@if [ ! -d ".next/static" ]; then \
		echo -e "$(YELLOW)⚠️  Creating static directory...$(NC)"; \
		mkdir -p .next/static; \
	fi
	@echo -e "$(GREEN)✅ Local build completed$(NC)"

build-docker: build-local ## Build Docker image locally
	@echo -e "$(BLUE)🐳 Building Docker image...$(NC)"
	DOCKER_BUILDKIT=1 docker build --no-cache -t $(DOCKER_IMAGE) .
	@echo -e "$(GREEN)✅ Docker image built: $(DOCKER_IMAGE)$(NC)"

build: build-docker ## Build everything (local + Docker)

deploy: build-docker ## Deploy to production server
	@echo -e "$(BLUE)🚀 Deploying to server...$(NC)"
	./build-deploy-optimized.sh deploy

deploy-compose: ## Deploy using Docker Compose
	@echo -e "$(BLUE)🐳 Deploying with Docker Compose...$(NC)"
	docker-compose -f docker-compose.site-only.yml up -d --build

clean: ## Clean build artifacts and Docker images
	@echo -e "$(YELLOW)🧹 Cleaning build artifacts...$(NC)"
	rm -rf .next dist build
	docker rmi $(DOCKER_IMAGE) 2>/dev/null || true
	docker system prune -f

logs: ## Show container logs from server
	@echo -e "$(BLUE)📋 Showing container logs...$(NC)"
	./build-deploy-optimized.sh logs

status: ## Check container status on server
	@echo -e "$(BLUE)📊 Checking container status...$(NC)"
	./build-deploy-optimized.sh status

restart: ## Restart container on server
	@echo -e "$(BLUE)🔄 Restarting container...$(NC)"
	./build-deploy-optimized.sh restart

test-build: ## Test build locally without Docker
	@echo -e "$(BLUE)🧪 Testing local build...$(NC)"
	BUILD_SITE_ONLY=true NEXT_TELEMETRY_DISABLED=1 bun run build:site-only
	@echo -e "$(GREEN)✅ Local build successful$(NC)"

test-docker: build-docker ## Test Docker image locally
	@echo -e "$(BLUE)🧪 Testing Docker image locally...$(NC)"
	docker run --rm -p 3001:3000 --name test-$(CONTAINER_NAME) $(DOCKER_IMAGE) &
	sleep 10
	curl -f http://localhost:3001 && echo -e "$(GREEN)✅ Docker test successful$(NC)" || echo -e "$(RED)❌ Docker test failed$(NC)"
	docker stop test-$(CONTAINER_NAME) || true

size: ## Show Docker image size
	@echo -e "$(BLUE)📦 Docker image size:$(NC)"
	docker images $(DOCKER_IMAGE) --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"

push: ## Push image to registry (if configured)
	@echo -e "$(BLUE)📤 Pushing to registry...$(NC)"
	docker push $(DOCKER_IMAGE)

benchmark: ## Run performance benchmark
	@echo -e "$(BLUE)⚡ Running performance benchmark...$(NC)"
	@echo "Build time test:"
	time make build-local
	@echo ""
	@echo "Docker size:"
	make size

full-deploy: clean build deploy ## Full clean build and deploy
	@echo -e "$(GREEN)🎉 Full deployment completed!$(NC)"

# Development workflow
dev-workflow: ## Complete development workflow
	make clean
	make test-build
	make test-docker
	@echo -e "$(GREEN)✅ Development workflow completed$(NC)"

# Production workflow  
prod-workflow: ## Complete production workflow
	make clean
	make build
	make deploy
	make status
	@echo -e "$(GREEN)🎉 Production deployment completed!$(NC)"
