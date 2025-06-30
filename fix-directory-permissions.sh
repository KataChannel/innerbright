#!/bin/bash

# Fix Directory Permissions for PWA Build
# Khắc phục lỗi "CouldntReadCurrentDirectory"

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔧 Directory Permissions Fix${NC}"
echo -e "${BLUE}=============================${NC}"

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR"

echo -e "\n${YELLOW}📂 Checking directory permissions...${NC}"

# Check current directory permissions
ls -la . | head -5

echo -e "\n${YELLOW}🔍 Diagnosing directory access issues...${NC}"

# Check if we can read current directory
if pwd > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Can read current directory${NC}"
else
    echo -e "${RED}❌ Cannot read current directory${NC}"
fi

# Check site directory
SITE_DIR="$SCRIPT_DIR/site"
if [ -d "$SITE_DIR" ]; then
    echo -e "${GREEN}✅ Site directory exists${NC}"
    
    # Check site directory permissions
    echo -e "${YELLOW}Site directory permissions:${NC}"
    ls -la "$SITE_DIR" | head -5
    
    # Try to access site directory
    if cd "$SITE_DIR" 2>/dev/null; then
        echo -e "${GREEN}✅ Can access site directory${NC}"
        if pwd > /dev/null 2>&1; then
            echo -e "${GREEN}✅ Can read site directory${NC}"
        else
            echo -e "${RED}❌ Cannot read site directory${NC}"
        fi
        cd "$SCRIPT_DIR"
    else
        echo -e "${RED}❌ Cannot access site directory${NC}"
    fi
else
    echo -e "${RED}❌ Site directory not found${NC}"
    exit 1
fi

# Fix permissions if needed
echo -e "\n${YELLOW}🔧 Fixing permissions...${NC}"

# Fix current directory permissions
chmod +rx . 2>/dev/null || echo -e "${YELLOW}⚠️  Cannot change current directory permissions${NC}"

# Fix parent directory permissions
chmod +rx .. 2>/dev/null || echo -e "${YELLOW}⚠️  Cannot change parent directory permissions${NC}"

# Fix site directory permissions
chmod +rx "$SITE_DIR" 2>/dev/null || echo -e "${YELLOW}⚠️  Cannot change site directory permissions${NC}"

# Fix site subdirectories
if [ -d "$SITE_DIR" ]; then
    find "$SITE_DIR" -type d -exec chmod +rx {} \; 2>/dev/null || echo -e "${YELLOW}⚠️  Cannot fix all subdirectory permissions${NC}"
    
    # Fix important files
    chmod +r "$SITE_DIR/package.json" 2>/dev/null || true
    chmod +r "$SITE_DIR/next.config.ts" 2>/dev/null || true
    chmod +r "$SITE_DIR/tsconfig.json" 2>/dev/null || true
fi

echo -e "\n${YELLOW}🧪 Testing directory access after fixes...${NC}"

# Test current directory access
if pwd > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Current directory access fixed${NC}"
else
    echo -e "${RED}❌ Current directory access still broken${NC}"
fi

# Test site directory access
if cd "$SITE_DIR" 2>/dev/null && pwd > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Site directory access fixed${NC}"
    cd "$SCRIPT_DIR"
else
    echo -e "${RED}❌ Site directory access still broken${NC}"
fi

# Alternative solution: copy to temp directory
echo -e "\n${YELLOW}🔄 Setting up alternative build method...${NC}"

TEMP_BUILD_SCRIPT="$SCRIPT_DIR/temp-build.sh"
cat > "$TEMP_BUILD_SCRIPT" << 'EOF'
#!/bin/bash

# Temporary build script for permission issues
set -e

echo "🔧 Alternative build method using temp directory"

# Create temp directory
TEMP_DIR="/tmp/innerbright-build-$(date +%s)"
echo "Creating temp directory: $TEMP_DIR"

# Copy source to temp
echo "Copying source files..."
cp -r . "$TEMP_DIR"
cd "$TEMP_DIR"

echo "Current directory: $(pwd)"
echo "Directory contents:"
ls -la

# Try to build
echo "Starting build..."
if command -v bun >/dev/null 2>&1; then
    echo "Using Bun for build..."
    bun install
    bun run build
elif command -v npm >/dev/null 2>&1; then
    echo "Using npm for build..."
    npm install
    npm run build
else
    echo "No build tool available"
    exit 1
fi

# Copy back results
echo "Copying build results back..."
if [ -d ".next" ]; then
    cp -r .next "$1/"
    echo "✅ Build files copied back"
fi

if [ -f "public/sw.js" ]; then
    cp public/sw.js "$1/public/"
    echo "✅ Service worker copied back"
fi

if ls public/workbox-*.js 1> /dev/null 2>&1; then
    cp public/workbox-*.js "$1/public/"
    echo "✅ Workbox files copied back"
fi

# Cleanup
cd /
rm -rf "$TEMP_DIR"
echo "✅ Temp directory cleaned up"
EOF

chmod +x "$TEMP_BUILD_SCRIPT"

echo -e "${GREEN}✅ Alternative build script created: temp-build.sh${NC}"

# Test bun access
echo -e "\n${YELLOW}🧪 Testing Bun access...${NC}"
if command -v bun >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Bun is available${NC}"
    echo -e "${YELLOW}Bun version: $(bun --version)${NC}"
    
    # Test bun in current directory
    if cd "$SITE_DIR" 2>/dev/null; then
        if bun --version > /dev/null 2>&1; then
            echo -e "${GREEN}✅ Bun works in site directory${NC}"
        else
            echo -e "${RED}❌ Bun fails in site directory${NC}"
        fi
        cd "$SCRIPT_DIR"
    fi
else
    echo -e "${RED}❌ Bun not available${NC}"
fi

# Create a wrapper script for the original fix script
echo -e "\n${YELLOW}🔧 Creating wrapper script...${NC}"

WRAPPER_SCRIPT="$SCRIPT_DIR/fix-pwa-safe.sh"
cat > "$WRAPPER_SCRIPT" << 'EOF'
#!/bin/bash

# Safe PWA Fix Script Wrapper
# Handles directory permission issues

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔧 Safe PWA Deployment Fix${NC}"
echo -e "${BLUE}===========================${NC}"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# First, try to fix permissions
echo -e "${YELLOW}Step 1: Fixing permissions...${NC}"
"$SCRIPT_DIR/fix-directory-permissions.sh"

# Then try the original script
echo -e "\n${YELLOW}Step 2: Running PWA fix...${NC}"
if "$SCRIPT_DIR/fix-pwa-deployment.sh"; then
    echo -e "${GREEN}✅ PWA fix completed successfully${NC}"
else
    echo -e "${YELLOW}⚠️  Original script failed, trying alternative method...${NC}"
    
    # Use temp build method
    cd "$SCRIPT_DIR/site"
    if "$SCRIPT_DIR/temp-build.sh" "$SCRIPT_DIR/site"; then
        echo -e "${GREEN}✅ Alternative build method successful${NC}"
    else
        echo -e "${RED}❌ All build methods failed${NC}"
        exit 1
    fi
fi

echo -e "\n${GREEN}🎉 PWA deployment fix completed!${NC}"
EOF

chmod +x "$WRAPPER_SCRIPT"

echo -e "${GREEN}✅ Safe wrapper script created: fix-pwa-safe.sh${NC}"

echo -e "\n${BLUE}📋 Usage Instructions:${NC}"
echo -e "${GREEN}1. Try the safe wrapper first:${NC}"
echo -e "   ${YELLOW}./fix-pwa-safe.sh${NC}"
echo -e "${GREEN}2. If still failing, use temp build directly:${NC}"
echo -e "   ${YELLOW}cd site && ../temp-build.sh \$(pwd)${NC}"
echo -e "${GREEN}3. Manual alternative:${NC}"
echo -e "   ${YELLOW}cp -r site /tmp/build && cd /tmp/build && bun run build && cp -r .next /original/site/${NC}"

echo -e "\n${GREEN}✅ Directory permissions fix completed!${NC}"
