#!/bin/bash

# Simple deployment script for KataCore (API + Site only)
# For use on cloud server 116.118.85.41
# This script only builds and deploys the API and Site containers

set -e

echo "🚀 Starting KataCore Simple Deployment..."

# Check if .env file exists
if [ ! -f .env ]; then
    echo "❌ Error: .env file not found!"
    echo "Please create a .env file with the required environment variables:"
    echo "  DATABASE_URL=your_database_url"
    echo "  REDIS_URL=your_redis_url"
    echo "  MINIO_ENDPOINT=your_minio_endpoint"
    echo "  MINIO_PORT=your_minio_port"
    echo "  MINIO_ACCESS_KEY=your_minio_access_key"
    echo "  MINIO_SECRET_KEY=your_minio_secret_key"
    echo "  JWT_SECRET=your_jwt_secret"
    echo "  NEXT_PUBLIC_API_URL=your_api_url"
    echo "  CORS_ORIGIN=your_cors_origin"
    exit 1
fi

# Load environment variables
source .env

echo "📦 Building containers..."

# Build API container
echo "🔨 Building API container..."
docker-compose -f docker-compose.prod.yml build api

# Build Site container
echo "🔨 Building Site container..."
docker-compose -f docker-compose.prod.yml build site

echo "🔄 Stopping existing containers..."
docker-compose -f docker-compose.prod.yml down

echo "🚀 Starting containers..."
docker-compose -f docker-compose.prod.yml up -d

echo "⏳ Waiting for services to be ready..."
sleep 10

# Check if API is running
echo "🔍 Checking API health..."
if curl -f http://localhost:3001/health > /dev/null 2>&1; then
    echo "✅ API is running on port 3001"
else
    echo "⚠️  API health check failed, but container might still be starting..."
fi

# Check if Site is running
echo "🔍 Checking Site health..."
if curl -f http://localhost:3000 > /dev/null 2>&1; then
    echo "✅ Site is running on port 3000"
else
    echo "⚠️  Site health check failed, but container might still be starting..."
fi

echo "📊 Container status:"
docker-compose -f docker-compose.prod.yml ps

echo ""
echo "🎉 Deployment completed!"
echo ""
echo "📋 Services Information:"
echo "  🔗 API: http://116.118.85.41:3001"
echo "  🌐 Site: http://116.118.85.41:3000"
echo ""
echo "💡 Tips:"
echo "  - Make sure Nginx is configured on the host to proxy to these ports"
echo "  - Check logs with: docker-compose -f docker-compose.prod.yml logs -f"
echo "  - Stop services with: docker-compose -f docker-compose.prod.yml down"
echo ""
