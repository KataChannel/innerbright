# KataCore

KataCore is a full-stack application built with the latest technologies and powered by Bun.js for optimal performance.

## 🚀 Tech Stack

### Frontend (site/)
- **Next.js 15.3.4** - The latest version with Turbopack for ultra-fast development
- **React 19** - The latest React with improved performance and features
- **Tailwind CSS 4** - Latest version for modern styling
- **TypeScript 5** - For type safety and better developer experience

### Backend (api/)
- **NestJS 11** - Latest version of the progressive Node.js framework
- **Bun.js** - Ultra-fast JavaScript runtime and package manager
- **TypeScript 5** - For type-safe backend development

## 🏗️ Project Structure

```
KataCore/
├── site/          # Next.js frontend application
├── api/           # NestJS backend API
├── package.json   # Root workspace configuration
└── README.md      # This file
```

## 🚦 Quick Start

### Prerequisites
- Bun.js (v1.0.0 or higher)

### Installation
```bash
# Install all dependencies
bun run install:all

# Or install individually
bun install          # Root dependencies
cd site && bun install   # Frontend dependencies  
cd api && bun install    # Backend dependencies
```

### Development
```bash
# Start both frontend and backend in development mode
bun run dev

# Or start individually
bun run dev:site      # Start Next.js frontend (http://localhost:3000)
bun run dev:api       # Start NestJS backend (http://localhost:3001)
```

### Building for Production
```bash
# Build both applications
bun run build

# Or build individually
bun run build:site   # Build Next.js application
bun run build:api    # Build NestJS application
```

### Production Start
```bash
# Start both applications in production mode
bun run start
```

## 📦 Available Scripts

| Script | Description |
|--------|-------------|
| `bun run dev` | Start both frontend and backend in development mode |
| `bun run dev:site` | Start only the Next.js frontend |
| `bun run dev:api` | Start only the NestJS backend |
| `bun run build` | Build both applications for production |
| `bun run start` | Start both applications in production mode |
| `bun run test` | Run backend tests |
| `bun run lint` | Lint both applications |
| `bun run clean` | Clean all node_modules and build artifacts |
| `bun run git:push` | Auto commit and push changes to git |
| `bun run git:save` | Quick save with timestamp |
| `bun run git:build-push` | Build first, then commit and push |
| `bun run git:watch` | Auto-commit every 10 minutes |
| `bun run compose:check` | Check if docker-compose.prod.yml exists |
| `bun run compose:create` | Create docker-compose.prod.yml from template |
| `bun run compose:ensure` | Ensure docker-compose.prod.yml exists (create if missing) |
| `bun run compose:validate` | Validate docker-compose.prod.yml syntax |
| `bun run compose:git-add` | Add docker-compose.prod.yml to git |
| `bun run compose:status` | Show docker-compose.prod.yml status |
| `bun run docker:install` | Auto-install Docker and Docker Compose |
| `bun run docker:check` | Check Docker installation status |
| `bun run docker:status` | Show detailed Docker system status |
| `bun run docker:manage` | Launch Docker management interface |
| `bun run docker:cleanup` | Clean up unused Docker resources |
| `bun run docker:fix` | Fix Docker permissions for current user |
| `bun run deploy:local` | Deploy locally with auto Docker installation |
| `bun run deploy:remote` | Deploy to remote server with auto setup |
| `bun run deploy:test-remote` | Test remote server before deployment |
| `bun run git:push` | Auto commit and push changes to git |
| `bun run git:save` | Quick save with timestamp |
| `bun run git:build-push` | Build first, then commit and push |
| `bun run git:watch` | Auto-commit every 10 minutes |

## 🚀 Universal Cloud Deployer v2.0

KataCore features a **Universal Cloud Deployer** that can deploy to **any** cloud server with zero configuration!

### ✨ New Features

- **🌐 Universal Deployment** - Deploy to ANY server with one command
- **🔧 Automatic Server Setup** - Installs Docker, configures firewall, sets up dependencies
- **🔐 Secure by Default** - Generates random secure passwords for all services
- **📦 Smart Docker Handling** - Handles both regular and snap-installed Docker Compose
- **🌐 SSL Ready** - Automatic SSL certificate setup with Let's Encrypt
- **🧹 Clean Deployment** - Option to remove old containers and start fresh
- **⚡ Flexible Modes** - Setup-only, deploy-only, or full deployment
- **🎨 Beautiful CLI** - Colored output with progress indicators

### 🚀 Quick Start

```bash
# Deploy to any server (recommended)
bun run deploy:universal --host 192.168.1.100

# Deploy with custom domain and SSL
bun run deploy:universal --host myserver.com --domain mydomain.com

# Clean installation (removes old containers)
bun run deploy:universal:clean --host 192.168.1.100
```

### 📋 Universal Deployer Options

```bash
# Full deployment with auto-setup
bun run deploy:universal --host SERVER_IP

# Setup server only (no deployment)
bun run deploy:setup-only --host SERVER_IP

# Deploy only (skip server setup)
bun run deploy:deploy-only --host SERVER_IP

# Clean deployment (removes old containers)
bun run deploy:universal:clean --host SERVER_IP
```

### 🏠 Legacy Local Deployment

```bash
# Deploy locally with auto Docker installation
bun run deploy:local
```

### 🔧 Manual Docker Management

```bash
# Install Docker manually
./scripts/install-docker.sh install

# Check Docker status
./scripts/install-docker.sh check

# Test Docker installation
./scripts/test-docker-install.sh

# Test remote deployment setup
SERVER_HOST=your-server-ip ./scripts/test-remote-deploy.sh
```

## 🚨 Troubleshooting

For detailed deployment documentation, see [DEPLOYMENT.md](DEPLOYMENT.md)

Common issues:
- **SSH connection problems**: Verify server connectivity and SSH access
- **Docker not found**: Universal deployer auto-installs Docker
- **Permission denied**: Use `--user ubuntu` for non-root servers
- **Port conflicts**: Use `--clean` flag to remove old containers

## 🌐 API Endpoints

- **Base URL**: `http://localhost:3001`
- **Health Check**: `GET /health`
- **Hello**: `GET /`

## 🎯 Features

### Frontend Features
- ⚡ **Turbopack** - Ultra-fast development server
- 🎨 **Tailwind CSS 4** - Latest utility-first CSS framework
- 📱 **Responsive Design** - Mobile-first approach
- 🔄 **Hot Reload** - Instant updates during development
- 🏗️ **App Router** - Next.js 13+ App Directory structure

### Backend Features  
- 🚀 **High Performance** - Powered by Bun.js runtime
- 🛡️ **Type Safety** - Full TypeScript support
- 🔄 **Auto Restart** - Development mode with watch
- 🌐 **CORS Enabled** - Ready for frontend integration
- 📊 **Health Monitoring** - Built-in health check endpoint

## 🔧 Development Notes

- The API runs on port **3001** by default
- The frontend runs on port **3000** by default  
- CORS is pre-configured to allow communication between frontend and backend
- Both projects use the latest versions of their respective frameworks
- Bun.js is used as the package manager and runtime for optimal performance

## 📄 License

This project is private and proprietary.# Test change
