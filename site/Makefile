# Makefile for Innerbright Site - Optimized for PWA builds
.PHONY: help build-local build-docker deploy clean status logs test dev

# Default target
help:
	@echo "Available targets:"
	@echo "  build-local  - Build Next.js application locally (PWA optimized)"
	@echo "  build-docker - Build Docker image with CPU optimization"
	@echo "  deploy       - Deploy to production server"
	@echo "  full         - Complete build and deploy process"
	@echo "  clean        - Clean up build artifacts"
	@echo "  status       - Show deployment status"
	@echo "  logs         - Show container logs"
	@echo "  test         - Test build locally"
	@echo "  dev          - Start development server"

# Build locally with PWA optimization
build-local:
	@echo "🔨 Building locally with PWA optimization..."
	@./build-deploy-optimized.sh build

# Build Docker image with CPU optimization
build-docker:
	@echo "🐳 Building Docker image with PWA optimization..."
	@./docker-build-optimized.sh

# Full deployment process
deploy:
	@echo "🚀 Starting full deployment..."
	@./build-deploy-optimized.sh full

# Deploy only (assume image exists)
deploy-only:
	@echo "📤 Deploying existing image..."
	@./build-deploy-optimized.sh deploy

# Clean up artifacts
clean:
	@echo "🧹 Cleaning up..."
	@./build-deploy-optimized.sh clean
	@rm -rf .next node_modules/.cache
	@docker system prune -f

# Show deployment status
status:
	@echo "📊 Deployment Status:"
	@ssh -i ~/.ssh/id_rsa root@116.118.85.41 'docker ps | grep innerbright-site || echo "Container not running"'

# Show container logs
logs:
	@echo "📋 Container Logs:"
	@ssh -i ~/.ssh/id_rsa root@116.118.85.41 'docker logs --tail=50 innerbright-site || echo "Container not found"'

# Test build locally
test:
	@echo "🧪 Testing build..."
	@./test-build.sh

# Development server
dev:
	@echo "🔥 Starting development server..."
	@if command -v bun > /dev/null 2>&1; then \
		bun run dev; \
	else \
		npm run dev; \
	fi

# Quick build without Docker (for testing)
build-quick:
	@echo "⚡ Quick build for testing..."
	@export DISABLE_PWA_BUILD=true && \
	if command -v bun > /dev/null 2>&1; then \
		NODE_OPTIONS="--max-old-space-size=2048" bun run build; \
	else \
		NODE_OPTIONS="--max-old-space-size=2048" npm run build; \
	fi

# Install dependencies
install:
	@echo "📦 Installing dependencies..."
	@if command -v bun > /dev/null 2>&1; then \
		bun install; \
	else \
		npm install; \
	fi

# Update dependencies
update:
	@echo "🔄 Updating dependencies..."
	@if command -v bun > /dev/null 2>&1; then \
		bun update; \
	else \
		npm update; \
	fi
