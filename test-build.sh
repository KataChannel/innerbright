#!/bin/bash

echo "Testing KataCore Projects..."

# Test API build
echo "Building API..."
cd /chikiet/kataoffical/KataCore/api
bun run build

if [ $? -eq 0 ]; then
    echo "✅ API build successful"
else
    echo "❌ API build failed"
    exit 1
fi

# Test Frontend build
echo "Building Frontend..."
cd /chikiet/kataoffical/KataCore/site
bun run build

if [ $? -eq 0 ]; then
    echo "✅ Frontend build successful"
else
    echo "❌ Frontend build failed"
    exit 1
fi

echo "🎉 Both projects built successfully!"
