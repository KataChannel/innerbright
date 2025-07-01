#!/bin/bash

# Test environment generation
set -euo pipefail

# Generate secure passwords
generate_password() {
    local length=${1:-16}
    openssl rand -base64 $((length * 3 / 4)) | tr -d "=+/" | cut -c1-${length}
}

# Generate JWT secret
generate_jwt_secret() {
    openssl rand -base64 64 | tr -d "\n"
}

echo "Generating test environment..."

# Generate secure passwords
postgres_pass=$(generate_password 24)
redis_pass=$(generate_password 20)
jwt_secret=$(generate_jwt_secret)
minio_pass=$(generate_password 20)
pgadmin_pass=$(generate_password 16)
grafana_pass=$(generate_password 16)

echo "Generated passwords:"
echo "POSTGRES_PASSWORD: $postgres_pass"
echo "REDIS_PASSWORD: $redis_pass"
echo "JWT_SECRET: $jwt_secret"
echo "MINIO_PASSWORD: $minio_pass"
echo "PGADMIN_PASSWORD: $pgladmin_pass"

# Create environment file from template
if [[ -f ".env.prod.template" ]]; then
    cp .env.prod.template .env.prod
    
    # Replace the actual values from the template with new secure passwords
    sed -i "s/puwIRuLehf8jDeb98oFUUjzz/$postgres_pass/g" .env.prod
    sed -i "s/YbyKUZUKS0Md8JJf0ABR/$redis_pass/g" .env.prod  
    sed -i "s/5Bjbnwyj5h23PSrd/$jwt_secret/g" .env.prod
    
    # Update domain if needed
    sed -i "s/innerbright.vn/116.118.85.41/g" .env.prod
    sed -i "s/admin@innerbright.vn/admin@116.118.85.41/g" .env.prod
    
    echo "✅ Environment file generated successfully"
    echo "First few lines of .env.prod:"
    head -15 .env.prod
else
    echo "❌ Template file not found"
    exit 1
fi
