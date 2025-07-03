#!/bin/bash

# KataCore Server Deployment Quick Start
# Updated for nginx on cloud server + Docker services architecture

set -e

echo "🚀 KataCore Server Deployment - Quick Start"
echo "============================================"
echo ""

# Check if .env file exists
if [ ! -f .env ]; then
    echo "❌ .env file not found!"
    echo "Please create .env file with required environment variables."
    echo "See DEPLOYMENT_GUIDE_SERVER.md for details."
    exit 1
fi

# Load environment variables
source .env

echo "📋 Configuration Summary:"
echo "Server IP: 116.118.85.41"
echo "Domain: innerbright.vn"
echo "API URL: ${NEXT_PUBLIC_API_URL:-https://innerbright.vn/api}"
echo ""

# Step 1: Deploy nginx to server
echo "🔧 Step 1: Deploying nginx to cloud server..."
./scripts/deploy-nginx-server.sh

echo ""

# Step 2: Build and start Docker services
echo "🐳 Step 2: Building and starting Docker services..."
docker-compose -f docker-compose.prod.yml down
docker-compose -f docker-compose.prod.yml pull
docker-compose -f docker-compose.prod.yml build --no-cache
docker-compose -f docker-compose.prod.yml up -d

echo ""

# Step 3: Wait for services to be healthy
echo "⏳ Step 3: Waiting for services to be healthy..."
echo "Checking API health..."
timeout=60
counter=0
while [ $counter -lt $timeout ]; do
    if curl -s http://localhost:3001/health >/dev/null 2>&1; then
        echo "✅ API is healthy"
        break
    fi
    sleep 2
    counter=$((counter + 2))
    echo -n "."
done

echo ""
echo "Checking Site health..."
counter=0
while [ $counter -lt $timeout ]; do
    if curl -s http://localhost:3000 >/dev/null 2>&1; then
        echo "✅ Site is healthy"
        break
    fi
    sleep 2
    counter=$((counter + 2))
    echo -n "."
done

echo ""

# Step 4: Show service status
echo "📊 Step 4: Service Status"
echo "========================"
docker-compose -f docker-compose.prod.yml ps

echo ""

# Step 5: Test deployment
echo "🧪 Step 5: Testing deployment..."
echo ""

echo "Testing local services:"
echo -n "API (localhost:3001): "
if curl -s http://localhost:3001/health >/dev/null 2>&1; then
    echo "✅ OK"
else
    echo "❌ FAILED"
fi

echo -n "Site (localhost:3000): "
if curl -s http://localhost:3000 >/dev/null 2>&1; then
    echo "✅ OK"
else
    echo "❌ FAILED"
fi

echo -n "pgAdmin (localhost:5050): "
if curl -s http://localhost:5050/misc/ping >/dev/null 2>&1; then
    echo "✅ OK"
else
    echo "❌ FAILED"
fi

echo -n "MinIO (localhost:9000): "
if curl -s http://localhost:9000/minio/health/live >/dev/null 2>&1; then
    echo "✅ OK"
else
    echo "❌ FAILED"
fi

echo ""
echo "Testing public access (through nginx):"
echo -n "Main site: "
if curl -s -k https://innerbright.vn >/dev/null 2>&1; then
    echo "✅ OK"
else
    echo "❌ FAILED (check DNS and SSL)"
fi

echo -n "API health: "
if curl -s -k https://innerbright.vn/api/health >/dev/null 2>&1; then
    echo "✅ OK"
else
    echo "❌ FAILED"
fi

echo -n "Nginx health: "
if curl -s -k https://innerbright.vn/nginx-health >/dev/null 2>&1; then
    echo "✅ OK"
else
    echo "❌ FAILED"
fi

echo ""
echo "🎉 Deployment Complete!"
echo "======================"
echo ""
echo "📱 Access Points:"
echo "- Main Site: https://innerbright.vn"
echo "- API: https://innerbright.vn/api/"
echo "- API Health: https://innerbright.vn/api/health"
echo "- Nginx Health: https://innerbright.vn/nginx-health"
echo ""
echo "🔐 Admin Panels (Password Protected):"
echo "- MinIO Console: https://innerbright.vn/minio/"
echo "- pgAdmin: https://innerbright.vn/pgadmin/"
echo ""
echo "🔧 Next Steps:"
echo "1. Set up SSL certificate: ssh root@116.118.85.41 'certbot --nginx -d innerbright.vn -d www.innerbright.vn'"
echo "2. Set admin passwords: ssh root@116.118.85.41 'htpasswd /etc/nginx/.htpasswd admin'"
echo "3. Test all functionality thoroughly"
echo ""
echo "📚 For more details, see: DEPLOYMENT_GUIDE_SERVER.md"
echo ""

# Show logs if there are any errors
if ! docker-compose -f docker-compose.prod.yml ps | grep -q "Up"; then
    echo "⚠️  Some services may have issues. Showing recent logs:"
    docker-compose -f docker-compose.prod.yml logs --tail=20
fi
