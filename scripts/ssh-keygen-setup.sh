#!/bin/bash

# KataCore SSH Key Generation and Setup Script
# Automates SSH key generation and deployment to cloud servers
# Compatible with all major cloud providers and Linux distributions

set -euo pipefail

# Version information
readonly SCRIPT_VERSION="1.0.0"

# Color codes for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m' # No Color

# Global variables
SERVER_HOST=""
SERVER_PORT="22"
SERVER_USER="root"
SSH_KEY_NAME="katacore-deploy"
SSH_KEY_TYPE="ed25519"
SSH_KEY_BITS="4096"
FORCE_REGENERATE=false
AUTO_DEPLOY=false
BACKUP_EXISTING=true
VERBOSE=false
DRY_RUN=false

# Paths
readonly SSH_DIR="$HOME/.ssh"
readonly KEYS_DIR="$SSH_DIR/katacore-keys"
readonly CONFIG_FILE="$SSH_DIR/config"
readonly BACKUP_DIR="$SSH_DIR/backup-$(date +%Y%m%d-%H%M%S)"

# Logging functions
log() {
    echo -e "${BLUE}[$(date +'%H:%M:%S')]${NC} $1" >&2
}

info() {
    echo -e "${CYAN}ℹ️  $1${NC}" >&2
}

success() {
    echo -e "${GREEN}✅ $1${NC}" >&2
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}" >&2
}

error() {
    echo -e "${RED}❌ $1${NC}" >&2
    exit 1
}

debug() {
    if [[ "${VERBOSE}" == "true" ]]; then
        echo -e "${PURPLE}🔍 $1${NC}" >&2
    fi
}

# Enhanced banner
show_banner() {
    echo -e "${CYAN}"
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════════════════════╗
║                     🔐 KataCore SSH Key Setup & Management                  ║
║                                                                              ║
║    Secure SSH Key Generation • Automated Deployment • Multi-Server Support  ║
║    Ed25519 & RSA Support • Cloud Provider Compatible • Zero Password        ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    echo -e "  ${GREEN}Script Version:${NC} ${SCRIPT_VERSION}"
    echo ""
}

# Show help information
show_help() {
    cat << EOF
KataCore SSH Key Setup & Management Script

USAGE:
    $0 [OPTIONS] --host SERVER_IP

COMMANDS:
    --host HOST        Target server IP address or domain
    --generate         Generate new SSH key pair only
    --deploy           Deploy existing SSH key to server
    --setup            Complete setup (generate + deploy)

OPTIONS:
    --port PORT        SSH port (default: 22)
    --user USER        SSH user (default: root)
    --key-name NAME    SSH key name (default: katacore-deploy)
    --key-type TYPE    Key type: ed25519, rsa, ecdsa (default: ed25519)
    --key-bits BITS    Key bits for RSA (default: 4096)
    --force            Force regenerate existing keys
    --auto-deploy      Automatically deploy after generation
    --no-backup        Don't backup existing keys
    --verbose          Enable verbose logging
    --dry-run          Show what would be done without executing
    --help             Show this help message

KEY TYPES:
    ed25519            Modern, secure, fast (recommended)
    rsa                Traditional, widely supported
    ecdsa              Elliptic curve, good performance

EXAMPLES:
    # Generate SSH key and deploy to server
    $0 --setup --host 192.168.1.100

    # Generate Ed25519 key only
    $0 --generate --key-name myproject-key

    # Deploy existing key to server
    $0 --deploy --host myserver.com --key-name existing-key

    # Generate RSA key with custom settings
    $0 --generate --key-type rsa --key-bits 4096 --key-name rsa-key

    # Setup with custom user and port
    $0 --setup --host myserver.com --user ubuntu --port 2222

    # Multiple server deployment
    $0 --deploy --host server1.com --key-name prod-key
    $0 --deploy --host server2.com --key-name prod-key

CLOUD PROVIDER EXAMPLES:
    # AWS EC2 (Ubuntu)
    $0 --setup --host ec2-xxx.amazonaws.com --user ubuntu

    # DigitalOcean Droplet
    $0 --setup --host 192.168.1.100 --user root

    # Google Cloud VM
    $0 --setup --host gce-instance.com --user gce-user

    # Azure VM
    $0 --setup --host azure-vm.com --user azureuser

For more information, visit: https://github.com/your-org/katacore
EOF
}

# Parse command line arguments
parse_arguments() {
    local command_set=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --host)
                if [[ -z "${2:-}" ]] || [[ "${2:-}" =~ ^-- ]]; then
                    error "--host requires a value (IP address or domain)"
                fi
                SERVER_HOST="$2"
                shift 2
                ;;
            --port)
                if [[ -z "${2:-}" ]] || [[ "${2:-}" =~ ^-- ]]; then
                    error "--port requires a value (port number)"
                fi
                SERVER_PORT="$2"
                shift 2
                ;;
            --user)
                if [[ -z "${2:-}" ]] || [[ "${2:-}" =~ ^-- ]]; then
                    error "--user requires a value (username)"
                fi
                SERVER_USER="$2"
                shift 2
                ;;
            --key-name)
                if [[ -z "${2:-}" ]] || [[ "${2:-}" =~ ^-- ]]; then
                    error "--key-name requires a value (key name)"
                fi
                SSH_KEY_NAME="$2"
                shift 2
                ;;
            --key-type)
                if [[ -z "${2:-}" ]] || [[ "${2:-}" =~ ^-- ]]; then
                    error "--key-type requires a value (ed25519, rsa, ecdsa)"
                fi
                case "$2" in
                    ed25519|rsa|ecdsa)
                        SSH_KEY_TYPE="$2"
                        ;;
                    *)
                        error "Invalid key type: $2. Use ed25519, rsa, or ecdsa"
                        ;;
                esac
                shift 2
                ;;
            --key-bits)
                if [[ -z "${2:-}" ]] || [[ "${2:-}" =~ ^-- ]]; then
                    error "--key-bits requires a value (number)"
                fi
                SSH_KEY_BITS="$2"
                shift 2
                ;;
            --generate)
                GENERATE_ONLY=true
                command_set=true
                shift
                ;;
            --deploy)
                DEPLOY_ONLY=true
                command_set=true
                shift
                ;;
            --setup)
                SETUP_MODE=true
                command_set=true
                shift
                ;;
            --force)
                FORCE_REGENERATE=true
                shift
                ;;
            --auto-deploy)
                AUTO_DEPLOY=true
                shift
                ;;
            --no-backup)
                BACKUP_EXISTING=false
                shift
                ;;
            --verbose)
                VERBOSE=true
                shift
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --help)
                show_help
                exit 0
                ;;
            *)
                warning "Unknown option: $1"
                shift
                ;;
        esac
    done
    
    # Set default command if none specified
    if [[ "$command_set" == "false" ]]; then
        if [[ -n "$SERVER_HOST" ]]; then
            SETUP_MODE=true
        else
            GENERATE_ONLY=true
        fi
    fi
    
    # Validate arguments
    if [[ "${DEPLOY_ONLY:-false}" == "true" || "${SETUP_MODE:-false}" == "true" ]]; then
        if [[ -z "$SERVER_HOST" ]]; then
            error "Server host is required for deploy/setup operations. Use --host SERVER_IP"
        fi
        
        # Validate host format
        if [[ ! "$SERVER_HOST" =~ ^[a-zA-Z0-9.-]+$ ]]; then
            error "Invalid host format: $SERVER_HOST"
        fi
        
        # Validate port
        if [[ ! "$SERVER_PORT" =~ ^[0-9]+$ ]] || [[ "$SERVER_PORT" -lt 1 ]] || [[ "$SERVER_PORT" -gt 65535 ]]; then
            error "Invalid port: $SERVER_PORT"
        fi
    fi
}

# Check prerequisites
check_prerequisites() {
    log "🔍 Checking prerequisites..."
    
    # Check required tools
    local missing_tools=()
    
    for tool in ssh ssh-keygen ssh-copy-id openssl; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            missing_tools+=("$tool")
        fi
    done
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        error "Missing required tools: ${missing_tools[*]}"
    fi
    
    # Check SSH directory
    if [[ ! -d "$SSH_DIR" ]]; then
        log "Creating SSH directory: $SSH_DIR"
        mkdir -p "$SSH_DIR"
        chmod 700 "$SSH_DIR"
    fi
    
    # Create KataCore keys directory
    if [[ ! -d "$KEYS_DIR" ]]; then
        log "Creating KataCore keys directory: $KEYS_DIR"
        mkdir -p "$KEYS_DIR"
        chmod 700 "$KEYS_DIR"
    fi
    
    success "Prerequisites check passed"
}

# Backup existing SSH configuration
backup_ssh_config() {
    if [[ "$BACKUP_EXISTING" == "false" ]]; then
        debug "Skipping backup (--no-backup specified)"
        return
    fi
    
    local has_backup_items=false
    
    # Check if there's anything to backup
    if [[ -f "$CONFIG_FILE" ]] || [[ -f "$SSH_DIR/${SSH_KEY_NAME}" ]] || [[ -f "$SSH_DIR/${SSH_KEY_NAME}.pub" ]]; then
        has_backup_items=true
    fi
    
    if [[ "$has_backup_items" == "false" ]]; then
        debug "No existing SSH configuration to backup"
        return
    fi
    
    log "📦 Backing up existing SSH configuration..."
    
    mkdir -p "$BACKUP_DIR"
    
    # Backup SSH config file
    if [[ -f "$CONFIG_FILE" ]]; then
        cp "$CONFIG_FILE" "$BACKUP_DIR/"
        success "Backed up SSH config to $BACKUP_DIR/"
    fi
    
    # Backup existing keys
    if [[ -f "$SSH_DIR/${SSH_KEY_NAME}" ]]; then
        cp "$SSH_DIR/${SSH_KEY_NAME}"* "$BACKUP_DIR/" 2>/dev/null || true
        success "Backed up existing keys to $BACKUP_DIR/"
    fi
    
    success "SSH configuration backed up to $BACKUP_DIR"
}

# Generate SSH key pair
generate_ssh_key() {
    log "🔑 Generating SSH key pair..."
    
    local key_path="$KEYS_DIR/${SSH_KEY_NAME}"
    local key_comment="KataCore-Deploy-$(date +%Y%m%d)-${SERVER_HOST:-local}"
    
    # Check if key already exists
    if [[ -f "$key_path" ]] && [[ "$FORCE_REGENERATE" == "false" ]]; then
        warning "SSH key already exists: $key_path"
        info "Use --force to regenerate or choose a different --key-name"
        return 0
    fi
    
    if [[ "$DRY_RUN" == "true" ]]; then
        info "DRY RUN: Would generate $SSH_KEY_TYPE key at $key_path"
        return 0
    fi
    
    # Remove existing key if force regenerate
    if [[ "$FORCE_REGENERATE" == "true" ]] && [[ -f "$key_path" ]]; then
        warning "Removing existing key due to --force flag"
        rm -f "$key_path" "$key_path.pub"
    fi
    
    # Generate key based on type
    case "$SSH_KEY_TYPE" in
        ed25519)
            ssh-keygen -t ed25519 -f "$key_path" -C "$key_comment" -N ""
            ;;
        rsa)
            ssh-keygen -t rsa -b "$SSH_KEY_BITS" -f "$key_path" -C "$key_comment" -N ""
            ;;
        ecdsa)
            ssh-keygen -t ecdsa -b 521 -f "$key_path" -C "$key_comment" -N ""
            ;;
        *)
            error "Unsupported key type: $SSH_KEY_TYPE"
            ;;
    esac
    
    # Set proper permissions
    chmod 600 "$key_path"
    chmod 644 "$key_path.pub"
    
    success "SSH key pair generated successfully"
    info "🔑 Private key: $key_path"
    info "🗝️  Public key:  $key_path.pub"
    
    # Show key fingerprint
    local fingerprint
    fingerprint=$(ssh-keygen -lf "$key_path.pub" | awk '{print $2}')
    info "🔍 Fingerprint: $fingerprint"
    
    # Show public key content
    echo ""
    echo -e "${CYAN}📋 Public Key Content:${NC}"
    echo -e "${GREEN}$(cat "$key_path.pub")${NC}"
    echo ""
}

# Update SSH config file
update_ssh_config() {
    log "⚙️  Updating SSH configuration..."
    
    local key_path="$KEYS_DIR/${SSH_KEY_NAME}"
    
    if [[ ! -f "$key_path" ]]; then
        error "SSH key not found: $key_path"
    fi
    
    if [[ "$DRY_RUN" == "true" ]]; then
        info "DRY RUN: Would update SSH config for $SERVER_HOST"
        return 0
    fi
    
    # Create or update SSH config
    local config_entry=""
    read -r -d '' config_entry << EOF || true

# KataCore deployment configuration for $SERVER_HOST
Host katacore-${SSH_KEY_NAME}
    HostName $SERVER_HOST
    Port $SERVER_PORT
    User $SERVER_USER
    IdentityFile $key_path
    IdentitiesOnly yes
    ServerAliveInterval 60
    ServerAliveCountMax 3
    ConnectTimeout 10
    StrictHostKeyChecking accept-new

# Alias for easier access
Host ${SERVER_HOST}
    HostName $SERVER_HOST
    Port $SERVER_PORT
    User $SERVER_USER
    IdentityFile $key_path
    IdentitiesOnly yes
    ServerAliveInterval 60
    ServerAliveCountMax 3
    ConnectTimeout 10
    StrictHostKeyChecking accept-new
EOF
    
    # Check if entry already exists
    if [[ -f "$CONFIG_FILE" ]] && grep -q "Host katacore-${SSH_KEY_NAME}" "$CONFIG_FILE"; then
        warning "SSH config entry already exists for katacore-${SSH_KEY_NAME}"
        if [[ "$FORCE_REGENERATE" == "true" ]]; then
            # Remove existing entry and add new one
            sed -i "/# KataCore deployment configuration for $SERVER_HOST/,/StrictHostKeyChecking accept-new/d" "$CONFIG_FILE"
            echo "$config_entry" >> "$CONFIG_FILE"
            success "Updated existing SSH config entry"
        else
            info "Use --force to update existing configuration"
        fi
    else
        echo "$config_entry" >> "$CONFIG_FILE"
        success "Added SSH config entry"
    fi
    
    # Set proper permissions on config file
    chmod 600 "$CONFIG_FILE"
    
    info "📝 SSH config updated: $CONFIG_FILE"
    info "🔗 Connect using: ssh katacore-${SSH_KEY_NAME}"
    info "🔗 Or simply: ssh ${SERVER_HOST}"
}

# Test SSH connection with key
test_ssh_connection() {
    log "🔗 Testing SSH connection to $SERVER_HOST..."
    
    local key_path="$KEYS_DIR/${SSH_KEY_NAME}"
    
    if [[ ! -f "$key_path" ]]; then
        error "SSH key not found: $key_path"
    fi
    
    if [[ "$DRY_RUN" == "true" ]]; then
        info "DRY RUN: Would test SSH connection to $SERVER_HOST"
        return 0
    fi
    
    # Test connection with the specific key
    if ssh -o ConnectTimeout=10 -o BatchMode=yes -o StrictHostKeyChecking=accept-new \
       -i "$key_path" -p "$SERVER_PORT" "$SERVER_USER@$SERVER_HOST" exit 2>/dev/null; then
        success "SSH connection successful with generated key"
        return 0
    else
        warning "SSH connection failed with generated key"
        return 1
    fi
}

# Deploy SSH key to server
deploy_ssh_key() {
    log "🚀 Deploying SSH key to server..."
    
    local key_path="$KEYS_DIR/${SSH_KEY_NAME}"
    
    if [[ ! -f "$key_path.pub" ]]; then
        error "SSH public key not found: $key_path.pub"
    fi
    
    if [[ "$DRY_RUN" == "true" ]]; then
        info "DRY RUN: Would deploy public key to $SERVER_USER@$SERVER_HOST:$SERVER_PORT"
        info "DRY RUN: Public key content:"
        cat "$key_path.pub"
        return 0
    fi
    
    # Multiple deployment methods for reliability
    local deployment_success=false
    
    # Method 1: ssh-copy-id (most reliable)
    if command -v ssh-copy-id >/dev/null 2>&1; then
        info "📤 Attempting deployment with ssh-copy-id..."
        if ssh-copy-id -i "$key_path.pub" -p "$SERVER_PORT" "$SERVER_USER@$SERVER_HOST" 2>/dev/null; then
            success "SSH key deployed successfully with ssh-copy-id"
            deployment_success=true
        else
            warning "ssh-copy-id failed, trying alternative method..."
        fi
    fi
    
    # Method 2: Manual authorized_keys setup
    if [[ "$deployment_success" == "false" ]]; then
        info "📤 Attempting manual deployment..."
        local pub_key_content
        pub_key_content=$(cat "$key_path.pub")
        
        # Create authorized_keys entry
        if ssh -p "$SERVER_PORT" "$SERVER_USER@$SERVER_HOST" \
           "mkdir -p ~/.ssh && chmod 700 ~/.ssh && echo '$pub_key_content' >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys && sort ~/.ssh/authorized_keys | uniq > ~/.ssh/authorized_keys.tmp && mv ~/.ssh/authorized_keys.tmp ~/.ssh/authorized_keys" 2>/dev/null; then
            success "SSH key deployed successfully with manual method"
            deployment_success=true
        else
            warning "Manual deployment failed"
        fi
    fi
    
    # Method 3: Interactive guidance
    if [[ "$deployment_success" == "false" ]]; then
        warning "Automatic deployment failed. Manual setup required."
        echo ""
        echo -e "${YELLOW}📋 Manual Setup Instructions:${NC}"
        echo -e "${CYAN}1. Connect to your server:${NC}"
        echo -e "   ssh -p $SERVER_PORT $SERVER_USER@$SERVER_HOST"
        echo ""
        echo -e "${CYAN}2. Create SSH directory and set permissions:${NC}"
        echo -e "   mkdir -p ~/.ssh && chmod 700 ~/.ssh"
        echo ""
        echo -e "${CYAN}3. Add the following public key to ~/.ssh/authorized_keys:${NC}"
        echo -e "${GREEN}$(cat "$key_path.pub")${NC}"
        echo ""
        echo -e "${CYAN}4. Set proper permissions:${NC}"
        echo -e "   chmod 600 ~/.ssh/authorized_keys"
        echo ""
        echo -e "${CYAN}5. Test the connection:${NC}"
        echo -e "   ssh -i $key_path -p $SERVER_PORT $SERVER_USER@$SERVER_HOST"
        echo ""
        
        read -p "Press Enter after completing manual setup to test connection..."
    fi
    
    # Test the deployed key
    if test_ssh_connection; then
        success "SSH key deployment verified successfully"
    else
        error "SSH key deployment verification failed"
    fi
}

# Display deployment summary
show_deployment_summary() {
    echo ""
    echo -e "${GREEN}🎉 SSH Key Setup Complete!${NC}"
    echo ""
    echo -e "${CYAN}📋 Deployment Summary:${NC}"
    echo -e "  🔑 Key Name:     ${SSH_KEY_NAME}"
    echo -e "  🔐 Key Type:     ${SSH_KEY_TYPE}"
    echo -e "  📁 Key Path:     ${KEYS_DIR}/${SSH_KEY_NAME}"
    echo -e "  🖥️  Server:       ${SERVER_HOST}:${SERVER_PORT}"
    echo -e "  👤 User:         ${SERVER_USER}"
    echo ""
    echo -e "${CYAN}🚀 Quick Commands:${NC}"
    echo -e "  Connect:         ssh katacore-${SSH_KEY_NAME}"
    echo -e "  Or simply:       ssh ${SERVER_HOST}"
    echo -e "  Deploy KataCore: ./startkit-deployer.sh --host ${SERVER_HOST}"
    echo ""
    echo -e "${CYAN}📂 Files Created:${NC}"
    echo -e "  Private Key:     ${KEYS_DIR}/${SSH_KEY_NAME}"
    echo -e "  Public Key:      ${KEYS_DIR}/${SSH_KEY_NAME}.pub"
    echo -e "  SSH Config:      ${CONFIG_FILE}"
    
    if [[ "$BACKUP_EXISTING" == "true" ]] && [[ -d "$BACKUP_DIR" ]]; then
        echo -e "  Backup:          ${BACKUP_DIR}"
    fi
    echo ""
}

# List existing SSH keys
list_ssh_keys() {
    log "📋 Listing existing SSH keys..."
    
    if [[ ! -d "$KEYS_DIR" ]] || [[ -z "$(ls -A "$KEYS_DIR" 2>/dev/null)" ]]; then
        info "No KataCore SSH keys found in $KEYS_DIR"
        return
    fi
    
    echo ""
    echo -e "${CYAN}🔑 Existing KataCore SSH Keys:${NC}"
    echo ""
    
    for key_file in "$KEYS_DIR"/*; do
        if [[ -f "$key_file" ]] && [[ ! "$key_file" =~ \.pub$ ]]; then
            local key_name
            key_name=$(basename "$key_file")
            local key_type
            key_type=$(ssh-keygen -lf "$key_file" 2>/dev/null | awk '{print $NF}' | tr -d '()' || echo "unknown")
            local fingerprint
            fingerprint=$(ssh-keygen -lf "$key_file" 2>/dev/null | awk '{print $2}' || echo "unknown")
            
            echo -e "  📁 ${GREEN}$key_name${NC}"
            echo -e "     Type: $key_type"
            echo -e "     Fingerprint: $fingerprint"
            echo -e "     Path: $key_file"
            echo ""
        fi
    done
}

# Main function
main() {
    # Show help if no arguments provided
    if [[ $# -eq 0 ]]; then
        show_banner
        echo -e "${YELLOW}No arguments provided.${NC}\n"
        show_help
        exit 1
    fi
    
    show_banner
    parse_arguments "$@"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        info "🔍 DRY RUN MODE - No changes will be made"
        echo ""
    fi
    
    check_prerequisites
    
    # Handle different modes
    if [[ "${GENERATE_ONLY:-false}" == "true" ]]; then
        backup_ssh_config
        generate_ssh_key
        
        if [[ "${AUTO_DEPLOY:-false}" == "true" ]] && [[ -n "$SERVER_HOST" ]]; then
            update_ssh_config
            deploy_ssh_key
            show_deployment_summary
        else
            list_ssh_keys
        fi
        
    elif [[ "${DEPLOY_ONLY:-false}" == "true" ]]; then
        deploy_ssh_key
        update_ssh_config
        show_deployment_summary
        
    elif [[ "${SETUP_MODE:-false}" == "true" ]]; then
        backup_ssh_config
        generate_ssh_key
        update_ssh_config
        deploy_ssh_key
        show_deployment_summary
        
    else
        list_ssh_keys
    fi
    
    success "🎉 SSH key setup completed successfully!"
}

# Execute main function with all arguments
main "$@"
