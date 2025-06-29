#!/bin/bash

# Auto Server Login Script
# Quickly connect to production server

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Default server configuration
DEFAULT_SERVER_IP="116.118.85.41"
DEFAULT_USER="deploy"
DEFAULT_PORT="22"
DEFAULT_KEY_PATH=""

# Configuration file
CONFIG_FILE="$HOME/.innerbright-server-config"

# Function to save config
save_config() {
    cat > "$CONFIG_FILE" << EOF
SERVER_IP="$SERVER_IP"
SERVER_USER="$SERVER_USER"
SERVER_PORT="$SERVER_PORT"
KEY_PATH="$KEY_PATH"
EOF
    chmod 600 "$CONFIG_FILE"
}

# Function to load config
load_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        source "$CONFIG_FILE"
    fi
}

# Function to setup server config
setup_config() {
    echo -e "${CYAN}🔧 Server Configuration Setup${NC}\n"
    
    read -p "Enter server IP [$DEFAULT_SERVER_IP]: " SERVER_IP
    SERVER_IP=${SERVER_IP:-$DEFAULT_SERVER_IP}
    
    read -p "Enter username [$DEFAULT_USER]: " SERVER_USER
    SERVER_USER=${SERVER_USER:-$DEFAULT_USER}
    
    read -p "Enter SSH port [$DEFAULT_PORT]: " SERVER_PORT
    SERVER_PORT=${SERVER_PORT:-$DEFAULT_PORT}
    
    read -p "Enter SSH key path (optional): " KEY_PATH
    
    # Save configuration
    save_config
    
    echo -e "\n${GREEN}✅ Configuration saved to $CONFIG_FILE${NC}"
}

# Function to connect to server
connect_server() {
    echo -e "${BLUE}🚀 Connecting to server...${NC}"
    echo -e "${CYAN}Server: $SERVER_USER@$SERVER_IP:$SERVER_PORT${NC}\n"
    
    # Build SSH command
    SSH_CMD="ssh"
    
    # Add key if specified
    if [[ -n "$KEY_PATH" && -f "$KEY_PATH" ]]; then
        SSH_CMD="$SSH_CMD -i $KEY_PATH"
    fi
    
    # Add port if not default
    if [[ "$SERVER_PORT" != "22" ]]; then
        SSH_CMD="$SSH_CMD -p $SERVER_PORT"
    fi
    
    # Add user@host
    SSH_CMD="$SSH_CMD $SERVER_USER@$SERVER_IP"
    
    # Execute SSH command
    echo -e "${YELLOW}Executing: $SSH_CMD${NC}"
    exec $SSH_CMD
}

# Function to deploy and connect
deploy_and_connect() {
    echo -e "${BLUE}🚀 Auto Deploy & Connect${NC}\n"
    
    # Check if we have git changes
    if git diff-index --quiet HEAD -- 2>/dev/null; then
        echo -e "${GREEN}✅ No local changes to deploy${NC}"
    else
        echo -e "${YELLOW}📝 Found local changes, deploying...${NC}"
        ./git-deploy.sh "$1"
    fi
    
    echo -e "\n${CYAN}🔗 Connecting to server...${NC}"
    
    # Connect to server with automatic commands
    SSH_CMD="ssh"
    
    if [[ -n "$KEY_PATH" && -f "$KEY_PATH" ]]; then
        SSH_CMD="$SSH_CMD -i $KEY_PATH"
    fi
    
    if [[ "$SERVER_PORT" != "22" ]]; then
        SSH_CMD="$SSH_CMD -p $SERVER_PORT"
    fi
    
    # Auto-execute commands on server
    SSH_CMD="$SSH_CMD -t $SERVER_USER@$SERVER_IP 'cd /opt/innerbright && bash -l'"
    
    echo -e "${YELLOW}Executing: $SSH_CMD${NC}"
    exec $SSH_CMD
}

# Function to show help
show_help() {
    echo -e "${BLUE}🔧 Innerbright Server Connection Tool${NC}\n"
    echo -e "${CYAN}Usage:${NC}"
    echo -e "  $0                    - Connect to server"
    echo -e "  $0 setup              - Setup server configuration"
    echo -e "  $0 deploy             - Deploy changes and connect"
    echo -e "  $0 deploy \"message\"    - Deploy with custom message and connect"
    echo -e "  $0 config             - Show current configuration"
    echo -e "  $0 help               - Show this help"
    echo
    echo -e "${CYAN}Examples:${NC}"
    echo -e "  $0                              # Quick connect"
    echo -e "  $0 deploy                       # Deploy and connect"
    echo -e "  $0 deploy \"fix login bug\"       # Deploy with message and connect"
    echo -e "  $0 setup                        # Configure server details"
}

# Function to show config
show_config() {
    load_config
    echo -e "${CYAN}📋 Current Server Configuration:${NC}\n"
    echo -e "  Server IP: ${GREEN}${SERVER_IP:-Not set}${NC}"
    echo -e "  Username: ${GREEN}${SERVER_USER:-Not set}${NC}"
    echo -e "  Port: ${GREEN}${SERVER_PORT:-Not set}${NC}"
    echo -e "  SSH Key: ${GREEN}${KEY_PATH:-Not set}${NC}"
    echo -e "  Config file: ${BLUE}$CONFIG_FILE${NC}"
}

# Main logic
main() {
    # Load existing configuration
    load_config
    
    # Parse command line arguments
    case "$1" in
        "setup")
            setup_config
            ;;
        "config")
            show_config
            ;;
        "deploy")
            # Check if config exists
            if [[ -z "$SERVER_IP" ]]; then
                echo -e "${YELLOW}⚠️  No server configuration found${NC}"
                setup_config
                load_config
            fi
            deploy_and_connect "$2"
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        "")
            # Default: just connect
            if [[ -z "$SERVER_IP" ]]; then
                echo -e "${YELLOW}⚠️  No server configuration found${NC}"
                setup_config
                load_config
            fi
            connect_server
            ;;
        *)
            echo -e "${RED}❌ Unknown command: $1${NC}"
            show_help
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
