# 🔐 SSH Key Setup Guide for KataCore

Complete guide for setting up SSH keys to securely connect to cloud servers for KataCore deployment.

## 📋 Table of Contents

- [Quick Start](#quick-start)
- [SSH Key Scripts](#ssh-key-scripts)
- [Manual Setup](#manual-setup)
- [Cloud Provider Examples](#cloud-provider-examples)
- [Security Best Practices](#security-best-practices)
- [Troubleshooting](#troubleshooting)

## 🚀 Quick Start

### Option 1: Interactive Setup (Recommended for beginners)
```bash
# Run interactive SSH key setup
./quick-ssh-setup.sh

# Follow the prompts to configure your server connection
```

### Option 2: One-Command Setup
```bash
# Quick setup with server IP
./quick-ssh-setup.sh 192.168.1.100

# Setup with custom user
./quick-ssh-setup.sh myserver.com ubuntu
```

### Option 3: Integrated with Deployment
```bash
# Setup SSH keys and deploy in one command
./startkit-deployer.sh --host 192.168.1.100 --setup-ssh
```

## 📦 SSH Key Scripts

### 1. `scripts/ssh-keygen-setup.sh` - Full-Featured SSH Setup

Complete SSH key generation and deployment script with advanced options.

#### Basic Usage
```bash
# Generate and deploy SSH key
./scripts/ssh-keygen-setup.sh --setup --host 192.168.1.100

# Generate key only
./scripts/ssh-keygen-setup.sh --generate --key-name my-project

# Deploy existing key
./scripts/ssh-keygen-setup.sh --deploy --host server.com --key-name existing-key
```

#### Advanced Options
```bash
# Custom configuration
./scripts/ssh-keygen-setup.sh --setup \
  --host myserver.com \
  --user ubuntu \
  --port 2222 \
  --key-type rsa \
  --key-bits 4096 \
  --key-name production-key

# Force regenerate existing keys
./scripts/ssh-keygen-setup.sh --setup --host server.com --force

# Verbose output
./scripts/ssh-keygen-setup.sh --setup --host server.com --verbose

# Dry run (see what would be done)
./scripts/ssh-keygen-setup.sh --setup --host server.com --dry-run
```

#### Key Types Supported
- **ed25519** (Recommended): Modern, secure, fast
- **rsa**: Traditional, widely supported (2048-4096 bits)
- **ecdsa**: Elliptic curve, good performance

### 2. `quick-ssh-setup.sh` - Simplified Wrapper

User-friendly wrapper for common SSH key setup scenarios.

```bash
# Interactive mode
./quick-ssh-setup.sh

# Quick setup
./quick-ssh-setup.sh 192.168.1.100

# With custom user
./quick-ssh-setup.sh myserver.com ubuntu
```

## 🔧 Manual Setup

If you prefer to set up SSH keys manually or need to understand the process:

### 1. Generate SSH Key Pair

```bash
# Ed25519 key (recommended)
ssh-keygen -t ed25519 -f ~/.ssh/katacore-deploy -C "KataCore-Deploy-$(date +%Y%m%d)"

# RSA key (traditional)
ssh-keygen -t rsa -b 4096 -f ~/.ssh/katacore-deploy -C "KataCore-Deploy-$(date +%Y%m%d)"
```

### 2. Deploy Public Key to Server

```bash
# Using ssh-copy-id (easiest)
ssh-copy-id -i ~/.ssh/katacore-deploy.pub user@server-ip

# Manual method
cat ~/.ssh/katacore-deploy.pub | ssh user@server-ip "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
```

### 3. Update SSH Config

Add to `~/.ssh/config`:
```
Host my-katacore-server
    HostName 192.168.1.100
    User root
    Port 22
    IdentityFile ~/.ssh/katacore-deploy
    IdentitiesOnly yes
    ServerAliveInterval 60
    StrictHostKeyChecking accept-new
```

### 4. Test Connection

```bash
ssh my-katacore-server
# or
ssh -i ~/.ssh/katacore-deploy user@server-ip
```

## ☁️ Cloud Provider Examples

### AWS EC2

```bash
# Ubuntu instance
./quick-ssh-setup.sh ec2-xxx.amazonaws.com ubuntu

# Amazon Linux
./scripts/ssh-keygen-setup.sh --setup \
  --host ec2-xxx.amazonaws.com \
  --user ec2-user \
  --key-name aws-production

# With custom port
./scripts/ssh-keygen-setup.sh --setup \
  --host ec2-xxx.amazonaws.com \
  --user ubuntu \
  --port 2222
```

### DigitalOcean

```bash
# Standard droplet
./quick-ssh-setup.sh 192.168.1.100

# With verbose output
./scripts/ssh-keygen-setup.sh --setup \
  --host droplet.digitalocean.com \
  --user root \
  --verbose
```

### Google Cloud Platform

```bash
# GCE instance
./scripts/ssh-keygen-setup.sh --setup \
  --host gce-instance.googlecloud.com \
  --user gce-user \
  --key-name gcp-production
```

### Microsoft Azure

```bash
# Azure VM
./scripts/ssh-keygen-setup.sh --setup \
  --host azure-vm.cloudapp.azure.com \
  --user azureuser \
  --key-name azure-production
```

### Vultr / Linode / Other VPS

```bash
# Generic VPS
./quick-ssh-setup.sh vps.provider.com root

# With custom configuration
./scripts/ssh-keygen-setup.sh --setup \
  --host vps.provider.com \
  --user root \
  --key-type ed25519 \
  --key-name vultr-production
```

## 🔒 Security Best Practices

### 1. Use Strong Key Types
- **Recommended**: Ed25519 for new deployments
- **Compatible**: RSA 4096-bit for legacy systems
- **Avoid**: RSA keys smaller than 2048 bits

### 2. Key Management
```bash
# Set proper permissions
chmod 600 ~/.ssh/katacore-deploy
chmod 644 ~/.ssh/katacore-deploy.pub
chmod 700 ~/.ssh
chmod 600 ~/.ssh/config

# List existing keys
./scripts/ssh-keygen-setup.sh --list

# Backup keys
cp -r ~/.ssh/katacore-keys ~/.ssh/backup-$(date +%Y%m%d)
```

### 3. Server-Side Security
```bash
# Disable password authentication (after SSH key setup)
echo "PasswordAuthentication no" | sudo tee -a /etc/ssh/sshd_config
echo "PubkeyAuthentication yes" | sudo tee -a /etc/ssh/sshd_config
sudo systemctl restart sshd

# Setup fail2ban
sudo apt-get install fail2ban
```

### 4. Multiple Keys for Different Environments
```bash
# Development environment
./scripts/ssh-keygen-setup.sh --generate --key-name dev-server

# Staging environment
./scripts/ssh-keygen-setup.sh --generate --key-name staging-server

# Production environment
./scripts/ssh-keygen-setup.sh --generate --key-name production-server
```

## 🛠️ Troubleshooting

### Connection Issues

#### Problem: "Permission denied (publickey)"
```bash
# Check if key exists
ls -la ~/.ssh/katacore-keys/

# Verify key permissions
chmod 600 ~/.ssh/katacore-keys/katacore-deploy

# Test connection with verbose output
ssh -v -i ~/.ssh/katacore-keys/katacore-deploy user@server

# Regenerate and redeploy key
./scripts/ssh-keygen-setup.sh --setup --host server --force
```

#### Problem: "Host key verification failed"
```bash
# Remove old host key
ssh-keygen -R server-ip

# Or accept new host key
ssh -o StrictHostKeyChecking=accept-new user@server
```

#### Problem: "Connection timed out"
```bash
# Check if server is reachable
ping server-ip

# Try different port
./scripts/ssh-keygen-setup.sh --setup --host server --port 2222

# Check firewall settings on server
sudo ufw status
sudo ufw allow ssh
```

### Key Management Issues

#### Problem: "SSH key already exists"
```bash
# Force regenerate
./scripts/ssh-keygen-setup.sh --setup --host server --force

# Or use different key name
./scripts/ssh-keygen-setup.sh --setup --host server --key-name new-key
```

#### Problem: "ssh-copy-id failed"
```bash
# Try manual deployment
./scripts/ssh-keygen-setup.sh --deploy --host server --verbose

# Or copy key manually
cat ~/.ssh/katacore-keys/katacore-deploy.pub
# Then add to server's ~/.ssh/authorized_keys
```

### Script Issues

#### Problem: "Script not found"
```bash
# Ensure scripts are executable
chmod +x scripts/ssh-keygen-setup.sh
chmod +x quick-ssh-setup.sh

# Run from project root directory
cd /path/to/KataCore
./scripts/ssh-keygen-setup.sh --help
```

## 📚 Additional Resources

### SSH Configuration Examples

#### High-Security Configuration
```bash
# ~/.ssh/config
Host production-server
    HostName prod.mycompany.com
    User deploy
    Port 2222
    IdentityFile ~/.ssh/katacore-keys/production
    IdentitiesOnly yes
    ServerAliveInterval 30
    ServerAliveCountMax 3
    ConnectTimeout 10
    StrictHostKeyChecking yes
    UserKnownHostsFile ~/.ssh/known_hosts
    Protocol 2
```

#### Development Configuration
```bash
Host dev-server
    HostName dev.mycompany.com
    User developer
    IdentityFile ~/.ssh/katacore-keys/development
    IdentitiesOnly yes
    ServerAliveInterval 60
    StrictHostKeyChecking accept-new
    ForwardAgent no
```

### Useful Commands

```bash
# Test SSH connection
ssh -T user@server

# Copy files using SSH key
scp -i ~/.ssh/katacore-keys/katacore-deploy file.txt user@server:/path/

# Rsync with SSH key
rsync -avz -e "ssh -i ~/.ssh/katacore-keys/katacore-deploy" ./local/ user@server:/remote/

# SSH tunnel
ssh -L 8080:localhost:80 -i ~/.ssh/katacore-keys/katacore-deploy user@server

# Execute remote command
ssh -i ~/.ssh/katacore-keys/katacore-deploy user@server "docker ps"
```

### Integration with KataCore Deployment

```bash
# Full deployment with SSH setup
./startkit-deployer.sh --host server --setup-ssh --domain myapp.com

# Update deployment using existing SSH key
./startkit-deployer.sh --host server --config-only

# Clean deployment with SSH key
./startkit-deployer.sh --host server --clean --ssh-key-name production
```

---

For more help, run any script with `--help` flag or check the [main documentation](README.md).
