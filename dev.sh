#!/bin/bash
# Development build script with hot reload

set -e

echo "🔧 Starting development environment..."

# Create .env if not exists
if [ ! -f .env ]; then
    echo "📝 Creating .env from example..."
    cp .env.example .env
    echo "⚠️  Please update .env with your actual values!"
fi

# Start development with hot reload
echo "🚀 Starting services in development mode..."
docker-compose up --build -d postgres redis minio

echo "⏳ Waiting for services to be ready..."
sleep 15

# Start Next.js in development mode (outside container for hot reload)
echo "🔥 Starting Next.js with hot reload..."
bun run dev
