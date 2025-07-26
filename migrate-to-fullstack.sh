#!/bin/bash

# =============================================================================
# INNERBRIGHT FULLSTACK MIGRATION SCRIPT
# Migrate from NestJS + Next.js to Next.js Fullstack
# =============================================================================

set -e

echo "🚀 Starting Innerbright Fullstack Migration..."
echo "=================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in the right directory
if [ ! -f "package.json" ] || [ ! -d "site" ]; then
    print_error "Please run this script from the project root directory"
    exit 1
fi

# Backup important files before migration
print_status "Creating backup of current state..."
BACKUP_DIR="migration_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Backup API folder if exists
if [ -d "api" ]; then
    print_status "Backing up API folder..."
    cp -r api "$BACKUP_DIR/"
fi

# Backup shared folder if exists
if [ -d "shared" ]; then
    print_status "Backing up shared folder..."
    cp -r shared "$BACKUP_DIR/"
fi

# Backup current package.json
cp package.json "$BACKUP_DIR/"

# Backup docker-compose files
cp docker-compose*.yml "$BACKUP_DIR/" 2>/dev/null || true

print_success "Backup created in $BACKUP_DIR"

# Stop any running containers
print_status "Stopping running containers..."
docker-compose down 2>/dev/null || true

# Remove API folder
if [ -d "api" ]; then
    print_status "Removing API folder..."
    rm -rf api
    print_success "API folder removed"
else
    print_warning "API folder not found"
fi

# Remove shared folder
if [ -d "shared" ]; then
    print_status "Removing shared folder..."
    rm -rf shared
    print_success "Shared folder removed"
else
    print_warning "Shared folder not found"
fi

# Update package.json workspaces
print_status "Updating package.json workspaces..."
if grep -q '"api"' package.json; then
    # Remove "api" from workspaces array
    sed -i.bak 's/    "api",//g' package.json
    sed -i.bak 's/"api",//g' package.json
    rm -f package.json.bak
    print_success "Removed API from workspaces"
fi

if grep -q '"shared"' package.json; then
    # Remove "shared" from workspaces array
    sed -i.bak 's/    "shared",//g' package.json
    sed -i.bak 's/"shared",//g' package.json
    rm -f package.json.bak
    print_success "Removed shared from workspaces"
fi

# Clean up old scripts that reference api/shared
print_status "Cleaning up package.json scripts..."
# Remove API-related scripts
sed -i.bak '/dev:api/d' package.json
sed -i.bak '/build:api/d' package.json
sed -i.bak '/start:api/d' package.json
sed -i.bak '/lint:api/d' package.json
sed -i.bak '/test:api/d' package.json
rm -f package.json.bak

# Update Docker files
print_status "Updating Docker configuration..."
if [ -f "docker-compose.yml" ]; then
    mv docker-compose.yml docker-compose.old.yml
    print_warning "Moved old docker-compose.yml to docker-compose.old.yml"
fi

# Use the new fullstack docker-compose
if [ -f "docker-compose.fullstack.yml" ]; then
    cp docker-compose.fullstack.yml docker-compose.yml
    print_success "Updated docker-compose.yml for fullstack"
fi

# Clean dependencies
print_status "Cleaning dependencies..."
rm -rf node_modules
rm -f package-lock.json
rm -f bun.lockb

# Install dependencies
print_status "Installing dependencies..."
cd site
rm -rf node_modules
rm -f bun.lockb
bun install
cd ..

bun install

# Generate Prisma client
print_status "Generating Prisma client..."
cd site
bun run db:generate
cd ..

print_success "Migration completed successfully!"
echo ""
print_status "Summary of changes:"
echo "  ✅ Removed API folder (NestJS backend)"
echo "  ✅ Removed shared folder"
echo "  ✅ Updated package.json workspaces"
echo "  ✅ Updated Docker configuration"
echo "  ✅ Installed dependencies"
echo "  ✅ Generated Prisma client"
echo ""
print_status "Backup location: $BACKUP_DIR"
echo ""
print_warning "Next steps:"
echo "  1. Review the new fullstack configuration"
echo "  2. Update environment variables (.env)"
echo "  3. Test the application: bun run dev"
echo "  4. Deploy with: docker-compose up -d"
echo ""
print_success "🎉 Innerbright is now a Next.js Fullstack application!"
