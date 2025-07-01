#!/bin/bash

# KataCore Quick Deploy - Optimized for frequent deployments
# Usage: ./quick-deploy.sh [SERVER_HOST] [options]

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log() { echo -e "${BLUE}[$(date +'%H:%M:%S')]${NC} $1"; }
success() { echo -e "${GREEN}✅ $1${NC}"; }
info() { echo -e "${CYAN}ℹ️  $1${NC}"; }

# Default values
SERVER_HOST=""
DEPLOY_TYPE="fast"

# Parse arguments
if [[ $# -gt 0 ]]; then
    SERVER_HOST="$1"
    shift
fi

while [[ $# -gt 0 ]]; do
    case $1 in
        --config-only)
            DEPLOY_TYPE="config"
            shift
            ;;
        --force-rebuild)
            DEPLOY_TYPE="rebuild"
            shift
            ;;
        --full)
            DEPLOY_TYPE="full"
            shift
            ;;
        --source-only)
            DEPLOY_TYPE="source"
            shift
            ;;
        --smart)
            DEPLOY_TYPE="smart"
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

if [[ -z "$SERVER_HOST" ]]; then
    echo "Usage: $0 SERVER_HOST [--config-only|--force-rebuild|--full|--source-only|--smart]"
    echo ""
    echo "Deploy types:"
    echo "  (default)      Fast deploy - auto-detect changes"
    echo "  --config-only  Only update configuration (skip file upload)"
    echo "  --force-rebuild Force rebuild all Docker images"
    echo "  --full         Full deployment with server setup"
    echo "  --source-only  Deploy source code changes only"
    echo "  --smart        Intelligent deployment (recommended)"
    exit 1
fi

log "🚀 Quick Deploy to $SERVER_HOST"
info "📋 Deploy type: $DEPLOY_TYPE"

case "$DEPLOY_TYPE" in
    "config")
        log "⚙️  Configuration-only deployment..."
        ./universal-deployer.sh --host "$SERVER_HOST" --skip-upload --deploy-only
        ;;
    "rebuild")
        log "🔨 Force rebuild deployment..."
        ./universal-deployer.sh --host "$SERVER_HOST" --force-rebuild --deploy-only
        ;;
    "full")
        log "🔧 Full deployment with setup..."
        ./universal-deployer.sh --host "$SERVER_HOST"
        ;;
    "source")
        log "📝 Source-only deployment..."
        ./universal-deployer.sh --host "$SERVER_HOST" --deploy-only --source-only
        ;;
    "smart")
        log "🧠 Smart deployment (auto-analyzing changes)..."
        ./universal-deployer.sh --host "$SERVER_HOST" --deploy-only --smart
        ;;
    "fast"|*)
        log "⚡ Fast incremental deployment..."
        ./universal-deployer.sh --host "$SERVER_HOST" --deploy-only
        ;;
esac

success "🎉 Quick deploy completed!"
