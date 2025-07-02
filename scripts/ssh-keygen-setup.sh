#!/bin/bash

# KataCore StartKit v2 - SSH Key Generation and Setup
# Automated SSH key generation, deployment, and connection management

set -euo pipefail

# Version information
readonly SCRIPT_VERSION="2.0.0"
readonly SSH_KEY_TYPE="ed25519"
readonly SSH_KEY_BITS="4096"

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
KEY_NAME=""
KEY_COMMENT=""
FORCE_REGENERATE=false
VERBOSE=false
DRY_RUN=false
COPY_TO_SERVER=true

# SSH directories
readonly SSH_DIR="$HOME/.ssh"
readonly KATACORE_SSH_DIR="$SSH_DIR/katacore"

# Logging functions
log() {
    echo -e "${GREEN}[$(date +'%H:%M:%S')]${NC} $1"
}

info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}" >&2
    exit 1
}

debug() {
    if [[ "$VERBOSE" == "true" ]]; then
        echo -e "${PURPLE}🐛 $1${NC}"
    fi
}

# Enhanced banner
show_banner() {
    echo -e "${BLUE}"
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════════════════════╗
║                🔐 KataCore StartKit v2 - SSH Key Manager                    ║
║                                                                              ║
║    Auto-generate • Deploy • Manage SSH connections for deployment           ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# Show help information
show_help() {
    cat << EOF
KataCore StartKit v2 - SSH Key Generation and Setup

DESCRIPTION:
    Generate SSH keys and set up secure connections for KataCore deployment.
    Supports both password-based and key-based authentication setup.

USAGE:
    $0 --host SERVER_IP [OPTIONS]

REQUIRED:
    --host HOST        Target server IP address or domain

OPTIONS:
    --user USER        SSH username (default: root)
    --port PORT        SSH port (default: 22)
    --name NAME        SSH key name (default: katacore-{timestamp})
    --comment TEXT     SSH key comment (default: KataCore-{hostname})
    --force           Force regenerate existing keys
    --no-copy         Don't copy key to server (generate only)
    --verbose         Enable verbose output
    --dry-run         Show what would be done without executing
    --help            Show this help message

KEY TYPES:
    • ed25519 (default) - Modern, secure, fast
    • rsa (4096-bit)    - Compatible with older systems

EXAMPLES:
    # Generate and deploy SSH key for root user
    $0 --host 192.168.1.100

    # Generate key for ubuntu user on custom port
    $0 --host 192.168.1.100 --user ubuntu --port 2222

    # Generate key with custom name and comment
    $0 --host 192.168.1.100 --name my-server --comment "Production Server"

    # Generate only (don't copy to server)
    $0 --host 192.168.1.100 --no-copy

    # Force regenerate existing key
    $0 --host 192.168.1.100 --force

FEATURES:
    ✅ Auto-generates secure SSH key pairs
    ✅ Deploys public key to server
    ✅ Creates SSH config entries
    ✅ Tests connection automatically
    ✅ Integrates with KataCore deployment
    ✅ Supports multiple key management

SECURITY:
    • Uses Ed25519 encryption by default
    • 4096-bit RSA fallback for compatibility
    • Secure file permissions (600/700)
    • Unique keys per server/project
    • Comment tagging for identification

For more information, visit: https://github.com/your-org/katacore
EOF
}

# Parse command line arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --host)
                if [[ -z "${2:-}" ]] || [[ "${2:-}" =~ ^-- ]]; then
                    error "--host requires a value (IP address or domain)"
                fi
                SERVER_HOST="$2"
                shift 2
                ;;
            --user)
                if [[ -z "${2:-}" ]] || [[ "${2:-}" =~ ^-- ]]; then
                    error "--user requires a value (username)"
                fi
                SERVER_USER="$2"
                shift 2
                ;;
            --port)
                if [[ -z "${2:-}" ]] || [[ "${2:-}" =~ ^-- ]]; then
                    error "--port requires a value (port number)"
                fi
                SERVER_PORT="$2"
                shift 2
                ;;
            --name)
                if [[ -z "${2:-}" ]] || [[ "${2:-}" =~ ^-- ]]; then
                    error "--name requires a value (key name)"
                fi
                KEY_NAME="$2"
                shift 2
                ;;
            --comment)
                if [[ -z "${2:-}" ]] || [[ "${2:-}" =~ ^-- ]]; then
                    error "--comment requires a value (comment text)"
                fi
                KEY_COMMENT="$2"
                shift 2
                ;;
            --force)
                FORCE_REGENERATE=true
                shift
                ;;
            --no-copy)
                COPY_TO_SERVER=false
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

    # Validate required arguments
    if [[ -z "$SERVER_HOST" ]]; then
        error "Server host is required. Use --host SERVER_IP or --help for usage information"
    fi
    
    # Validate host format (basic check)
    if [[ ! "$SERVER_HOST" =~ ^[a-zA-Z0-9.-]+$ ]]; then
        error "Invalid host format: $SERVER_HOST. Please provide a valid IP address or domain name"
    fi
    
    # Set defaults if not provided
    if [[ -z "$KEY_NAME" ]]; then
        KEY_NAME="katacore-$(echo "$SERVER_HOST" | tr '.' '-')-$(date +%Y%m%d)"
    fi
    
    if [[ -z "$KEY_COMMENT" ]]; then
        KEY_COMMENT="KataCore-v2-${SERVER_HOST}-$(hostname)"
    fi
}

# Check if SSH client is available
check_ssh_client() {
    log "🔍 Checking SSH client availability..."
    
    local missing_tools=()
    
    for tool in ssh ssh-keygen ssh-copy-id; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            missing_tools+=("$tool")
        fi
    done
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        error "Missing required SSH tools: ${missing_tools[*]}. Please install openssh-client package."
    fi
    
    success "SSH client tools available"
}

# Setup SSH directories
setup_ssh_directories() {
    log "📁 Setting up SSH directories..."
    
    # Create main SSH directory
    if [[ ! -d "$SSH_DIR" ]]; then
        debug "Creating SSH directory: $SSH_DIR"
        if [[ "$DRY_RUN" == "false" ]]; then
            mkdir -p "$SSH_DIR"
            chmod 700 "$SSH_DIR"
        fi
    fi
    
    # Create KataCore SSH subdirectory
    if [[ ! -d "$KATACORE_SSH_DIR" ]]; then
        debug "Creating KataCore SSH directory: $KATACORE_SSH_DIR"
        if [[ "$DRY_RUN" == "false" ]]; then
            mkdir -p "$KATACORE_SSH_DIR"
            chmod 700 "$KATACORE_SSH_DIR"
        fi
    fi
    
    success "SSH directories configured"
}

# Generate SSH key pair
generate_ssh_key() {
    log "🔑 Generating SSH key pair..."
    
    local private_key="$KATACORE_SSH_DIR/$KEY_NAME"
    local public_key="${private_key}.pub"
    
    # Check if key already exists
    if [[ -f "$private_key" ]] && [[ "$FORCE_REGENERATE" == "false" ]]; then
        warning "SSH key already exists: $private_key"
        info "Use --force to regenerate or --name to use different name"
        return 0
    fi
    
    if [[ "$DRY_RUN" == "true" ]]; then
        info "DRY RUN: Would generate SSH key: $private_key"
        return 0
    fi
    
    # Remove existing keys if force regenerate
    if [[ "$FORCE_REGENERATE" == "true" ]]; then
        debug "Force regenerate enabled, removing existing keys"
        rm -f "$private_key" "$public_key" 2>/dev/null || true
    fi
    
    # Generate the key pair
    info "Generating $SSH_KEY_TYPE SSH key pair..."
    
    if [[ "$SSH_KEY_TYPE" == "ed25519" ]]; then
        ssh-keygen -t ed25519 \
                   -f "$private_key" \
                   -C "$KEY_COMMENT" \
                   -N "" \
                   -q
    else
        ssh-keygen -t rsa \
                   -b "$SSH_KEY_BITS" \
                   -f "$private_key" \
                   -C "$KEY_COMMENT" \
                   -N "" \
                   -q
    fi
    
    # Set secure permissions
    chmod 600 "$private_key"
    chmod 644 "$public_key"
    
    success "SSH key pair generated successfully"
    info "🔐 Private key: $private_key"
    info "🗝️  Public key: $public_key"
    
    # Show key fingerprint
    local fingerprint=$(ssh-keygen -lf "$public_key" 2>/dev/null | awk '{print $2}')
    info "🔍 Key fingerprint: $fingerprint"
}

# Test server connectivity
test_server_connectivity() {
    log "🌐 Testing server connectivity..."
    
    debug "Testing connection to $SERVER_USER@$SERVER_HOST:$SERVER_PORT"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        info "DRY RUN: Would test connection to $SERVER_USER@$SERVER_HOST:$SERVER_PORT"
        return 0
    fi
    
    # Test basic connectivity
    if ! nc -z -w5 "$SERVER_HOST" "$SERVER_PORT" 2>/dev/null; then
        error "Cannot connect to $SERVER_HOST:$SERVER_PORT. Please check server address and port."
    fi
    
    success "Server is reachable on port $SERVER_PORT"
}

# Copy SSH key to server
copy_key_to_server() {
    if [[ "$COPY_TO_SERVER" == "false" ]]; then
        info "Key copying disabled, skipping server deployment"
        return 0
    fi
    
    log "📤 Copying SSH public key to server..."
    
    local private_key="$KATACORE_SSH_DIR/$KEY_NAME"
    local public_key="${private_key}.pub"
    
    if [[ ! -f "$public_key" ]]; then
        error "Public key not found: $public_key"
    fi
    
    if [[ "$DRY_RUN" == "true" ]]; then
        info "DRY RUN: Would copy key to $SERVER_USER@$SERVER_HOST:$SERVER_PORT"
        return 0
    fi
    
    debug "Copying public key to server authorized_keys"
    
    # Try to copy key using ssh-copy-id (recommended method)
    if command -v ssh-copy-id >/dev/null 2>&1; then
        if ssh-copy-id -i "$public_key" \
                       -p "$SERVER_PORT" \
                       "$SERVER_USER@$SERVER_HOST" 2>/dev/null; then
            success "SSH public key copied successfully using ssh-copy-id"
            return 0
        else
            warning "ssh-copy-id failed, trying manual method..."
        fi
    fi
    
    # Manual method as fallback
    debug "Using manual key copy method"
    
    local public_key_content=$(cat "$public_key")
    
    ssh -p "$SERVER_PORT" "$SERVER_USER@$SERVER_HOST" bash << EOF
# Create .ssh directory if it doesn't exist
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Add public key to authorized_keys
echo "$public_key_content" >> ~/.ssh/authorized_keys

# Remove duplicates and set permissions
sort ~/.ssh/authorized_keys | uniq > ~/.ssh/authorized_keys.tmp
mv ~/.ssh/authorized_keys.tmp ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

echo "SSH key added successfully"
EOF
    
    success "SSH public key deployed manually"
}

# Create SSH config entry
create_ssh_config() {
    log "⚙️ Creating SSH config entry..."
    
    local ssh_config="$SSH_DIR/config"
    local private_key="$KATACORE_SSH_DIR/$KEY_NAME"
    
    # Create config entry
    local config_entry="
# KataCore StartKit v2 - Auto-generated SSH config
# Generated on $(date -Iseconds)
Host katacore-$KEY_NAME
    HostName $SERVER_HOST
    User $SERVER_USER
    Port $SERVER_PORT
    IdentityFile $private_key
    IdentitiesOnly yes
    StrictHostKeyChecking accept-new
    ServerAliveInterval 60
    ServerAliveCountMax 3
    
# Alias for easier access
Host $SERVER_HOST
    User $SERVER_USER
    Port $SERVER_PORT
    IdentityFile $private_key
    IdentitiesOnly yes
    StrictHostKeyChecking accept-new
"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        info "DRY RUN: Would add SSH config entry"
        echo "$config_entry"
        return 0
    fi
    
    # Backup existing config
    if [[ -f "$ssh_config" ]]; then
        cp "$ssh_config" "${ssh_config}.backup-$(date +%Y%m%d-%H%M%S)"
        debug "Backed up existing SSH config"
    fi
    
    # Add new config entry
    echo "$config_entry" >> "$ssh_config"
    chmod 600 "$ssh_config"
    
    success "SSH config entry created"
    info "📝 Config file: $ssh_config"
    info "🔗 Connection alias: katacore-$KEY_NAME"
}

# Test SSH key authentication
test_ssh_connection() {
    log "🧪 Testing SSH key authentication..."
    
    local private_key="$KATACORE_SSH_DIR/$KEY_NAME"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        info "DRY RUN: Would test SSH connection"
        return 0
    fi
    
    debug "Testing SSH connection with key authentication"
    
    # Test connection
    if ssh -i "$private_key" \
           -p "$SERVER_PORT" \
           -o ConnectTimeout=10 \
           -o BatchMode=yes \
           -o StrictHostKeyChecking=accept-new \
           "$SERVER_USER@$SERVER_HOST" \
           "echo 'SSH key authentication successful'" 2>/dev/null; then
        success "SSH key authentication working correctly"
        return 0
    else
        warning "SSH key authentication test failed"
        info "You may need to:"
        echo "  1. Ensure password authentication is enabled temporarily"
        echo "  2. Check server SSH configuration"
        echo "  3. Verify user permissions on server"
        return 1
    fi
}

# Show connection information
show_connection_info() {
    echo ""
    success "🎉 SSH key setup completed successfully!"
    echo ""
    
    local private_key="$KATACORE_SSH_DIR/$KEY_NAME"
    local public_key="${private_key}.pub"
    
    echo -e "🔐 ${BLUE}SSH Key Information:${NC}"
    echo -e "   📁 Private Key: ${CYAN}$private_key${NC}"
    echo -e "   🗝️  Public Key: ${CYAN}$public_key${NC}"
    echo -e "   🏷️  Comment: ${CYAN}$KEY_COMMENT${NC}"
    echo ""
    
    echo -e "🌐 ${BLUE}Connection Information:${NC}"
    echo -e "   🖥️  Server: ${CYAN}$SERVER_USER@$SERVER_HOST:$SERVER_PORT${NC}"
    echo -e "   🔗 SSH Alias: ${CYAN}katacore-$KEY_NAME${NC}"
    echo ""
    
    echo -e "🚀 ${BLUE}Usage Examples:${NC}"
    echo -e "   # Connect using alias"
    echo -e "   ${CYAN}ssh katacore-$KEY_NAME${NC}"
    echo ""
    echo -e "   # Connect using direct command"
    echo -e "   ${CYAN}ssh -i $private_key $SERVER_USER@$SERVER_HOST${NC}"
    echo ""
    echo -e "   # Use with KataCore deployment"
    echo -e "   ${CYAN}./startkit-deployer.sh --host $SERVER_HOST --user $SERVER_USER --port $SERVER_PORT${NC}"
    echo ""
    
    echo -e "📝 ${BLUE}Next Steps:${NC}"
    echo -e "   1. Test connection: ${CYAN}ssh katacore-$KEY_NAME${NC}"
    echo -e "   2. Deploy KataCore: ${CYAN}./startkit-deployer.sh --host $SERVER_HOST${NC}"
    echo -e "   3. (Optional) Disable password auth on server for security"
    echo ""
}

# Main execution function
main() {
    show_banner
    
    # Parse arguments
    parse_arguments "$@"
    
    # Show configuration
    if [[ "$VERBOSE" == "true" ]]; then
        echo -e "${BLUE}Configuration:${NC}"
        echo -e "  Server: $SERVER_USER@$SERVER_HOST:$SERVER_PORT"
        echo -e "  Key Name: $KEY_NAME"
        echo -e "  Key Comment: $KEY_COMMENT"
        echo -e "  Force Regenerate: $FORCE_REGENERATE"
        echo -e "  Copy to Server: $COPY_TO_SERVER"
        echo -e "  Dry Run: $DRY_RUN"
        echo ""
    fi
    
    # Execute setup steps
    check_ssh_client
    setup_ssh_directories
    test_server_connectivity
    generate_ssh_key
    
    if [[ "$COPY_TO_SERVER" == "true" ]]; then
        copy_key_to_server
        test_ssh_connection
    fi
    
    create_ssh_config
    show_connection_info
    
    if [[ "$DRY_RUN" == "true" ]]; then
        echo ""
        warning "This was a dry run. No actual changes were made."
        info "Remove --dry-run flag to execute the setup."
    fi
}

# Run main function with all arguments
main "$@"