# Project Structure

## 📁 Root Directory
```
KataCore/
├── 📄 README.md                  # Main documentation
├── 📄 DEPLOYMENT_GUIDE.md        # Quick deployment guide
├── 📄 package.json              # Root workspace configuration
├── 🔧 universal-deployer.sh     # Universal deployment script
├── ⚡ quick-deploy.sh            # Optimized quick deployment
├── 🐳 docker-compose.yml        # Development environment
├── 🏭 docker-compose.prod.yml   # Production environment
├── 📄 .env.prod.example         # Production environment template
└── 📄 .deploy.config.example    # Deployment configuration template
```

## 🌐 Frontend (site/)
```
site/
├── 📄 package.json              # Next.js dependencies
├── 📄 next.config.ts            # Next.js configuration
├── 📄 tailwind.config.ts        # Tailwind CSS configuration
├── 📄 tsconfig.json             # TypeScript configuration
├── 🐳 Dockerfile                # Frontend container
├── 📁 public/                   # Static assets
└── 📁 src/
    ├── 📁 app/                  # Next.js App Router
    │   ├── 📄 layout.tsx        # Root layout
    │   ├── 📄 page.tsx          # Home page
    │   └── 📄 globals.css       # Global styles
    └── 📁 components/           # React components
        └── 📄 ApiTest.tsx       # API testing component
```

## ⚙️ Backend (api/)
```
api/
├── 📄 package.json              # NestJS dependencies
├── 📄 tsconfig.json             # TypeScript configuration
├── 📄 nest-cli.json             # NestJS CLI configuration
├── 🐳 Dockerfile                # Backend container
├── 📁 prisma/                   # Database schema
│   └── 📄 schema.prisma         # Prisma schema
└── 📁 src/
    ├── 📄 main.ts               # Application entry point
    ├── 📄 app.module.ts         # Root module
    ├── 📄 app.controller.ts     # Main controller
    └── 📄 app.service.ts        # Main service
```

## 🌐 Infrastructure
```
nginx/                           # Nginx configuration
├── 📄 nginx.conf                # Main Nginx config
└── 📁 conf.d/
    ├── 📄 katacore.conf         # Development config
    └── 📄 katacore.prod.conf    # Production config

scripts/                         # Deployment scripts
├── 📄 auto-push.sh              # Auto git commit/push
├── 📄 quick-save.sh             # Quick save with timestamp
├── 📄 backup.sh                 # Database backup
└── 📄 install-docker.sh         # Docker installation

backups/                         # Database backups (created at runtime)
ssl/                            # SSL certificates (created at runtime)
```

## 🔧 Key Configuration Files

- **Root package.json**: Workspace configuration and main scripts
- **docker-compose.yml**: Development environment with hot reload
- **docker-compose.prod.yml**: Production environment with optimizations
- **.env.prod.example**: Template for production environment variables
- **universal-deployer.sh**: Main deployment script for any cloud server
- **quick-deploy.sh**: Optimized script for frequent deployments
- **.deploy.config.example**: Deployment configuration template

## 🚀 Development Workflow

1. **Development**: `bun run dev` - starts both frontend and backend
2. **Building**: `bun run build` - builds both applications
3. **Testing**: `bun run test` - runs API tests
4. **First Deployment**: `bun run deploy:universal --host SERVER_IP`
5. **Quick Deployment**: `bun run deploy:quick SERVER_IP`

## 🔄 Optimized Deployment Features

### 🎯 Smart Deployment Strategies
- **First Deploy**: Automatically generates `.env.prod` from `.env.prod.example`
- **Incremental Deploy**: Only uploads changed files and rebuilds when necessary
- **Config Deploy**: Updates configuration without file uploads
- **Force Rebuild**: Rebuilds all images when needed

### ⚡ Quick Deployment Commands
```bash
# Fast incremental deployment (recommended for frequent updates)
bun run deploy:quick SERVER_IP

# Configuration-only deployment (fastest)
bun run deploy:config SERVER_IP

# Force rebuild all images
bun run deploy:rebuild SERVER_IP

# Full deployment with server setup
bun run deploy:full SERVER_IP
```

### 🎚️ Deployment Optimization Features
- **Auto Environment Generation**: Secure passwords auto-generated from template
- **File Change Detection**: Only uploads files that have changed
- **Smart Docker Caching**: Preserves build cache between deployments
- **Incremental Builds**: Only rebuilds services with changes
- **Optimized Cleanup**: Removes only unused resources, preserves caches
- **Health Checks**: Verifies database readiness before starting apps

## 📦 Dependencies Management

- **Bun Workspaces**: Manages dependencies across frontend and backend
- **Shared Scripts**: Common operations available from root
- **Independent Builds**: Each service can be built independently
- **Optimized Builds**: Smart caching reduces build times
