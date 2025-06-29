# Innerbright - Production Deployment with Bun

Innerbright is a modern web application built with Next.js, NestJS, and powered by **Bun** for faster development and deployment.

## 🚀 Quick Start with Bun

### Prerequisites
- **Bun** (latest version)
- **Docker** and **Docker Compose**
- **Git**

### Installation

1. **Install Bun** (if not already installed):
```bash
curl -fsSL https://bun.sh/install | bash
source ~/.bashrc
```

2. **Clone the repository**:
```bash
git clone https://github.com/chikiet/innerbright.git
cd innerbright
```

3. **Development Environment**:
```bash
# Start both API and Site in development mode
./bun-dev-full.sh

# Or start individually:
# API only
cd api && ./bun-dev.sh

# Site only  
cd site && ./start-dev.sh
```

## 🐳 Production Deployment

### Option 1: Quick Deploy (Recommended)
```bash
# Deploy with auto-commit message
./quick-deploy.sh

# Deploy with custom message
./quick-deploy.sh "feature: add new functionality"
```

### Option 2: Full Deploy Pipeline
```bash
# Complete deployment pipeline
./full-deploy.sh "production deployment"
```

### Option 3: One-Click Deploy
```bash
# Complete setup from scratch
./one-click-deploy.sh
```

## 🏗️ Architecture

### Tech Stack
- **Frontend**: Next.js 15 with Bun
- **Backend**: NestJS with Bun  
- **Database**: PostgreSQL 15
- **Object Storage**: MinIO
- **Caching**: Redis (optional)
- **Reverse Proxy**: Nginx
- **Container**: Docker & Docker Compose

### Services
- **Next.js Frontend**: Port 3000
- **NestJS API**: Port 3333
- **PostgreSQL Database**: Port 5432
- **MinIO Storage**: Port 9000
- **Nginx Proxy**: Port 80/443

## 📁 Project Structure

```
┌── api/                    # NestJS API with Bun
│   ├── src/               # Source code
│   ├── package.json       # Bun dependencies
│   ├── bun.lockb         # Bun lockfile
│   ├── bunfig.toml       # Bun configuration
│   ├── bun-dev.sh        # Development script
│   └── bun-prod.sh       # Production script
├── site/                  # Next.js Frontend with Bun
│   ├── app/              # Next.js 15 app directory
│   ├── prisma/           # Database schema
│   ├── package.json      # Bun dependencies
│   ├── bun.lockb        # Bun lockfile
│   └── start-dev.sh     # Development script
├── nginx/                # Nginx configuration
├── docker-compose.yml    # Production services
└── deployment scripts   # Various deployment options
```

## 🛠️ Development Commands

### API (NestJS with Bun)
```bash
cd api
bun install              # Install dependencies
bun run build           # Build application
bun run start:dev       # Development mode
bun run start:prod      # Production mode
bun run test            # Run tests
bun run lint            # Run linter
```

### Site (Next.js with Bun)
```bash
cd site
bun install              # Install dependencies
bun run build           # Build application
bun run dev             # Development mode
bun run start           # Production mode
bun run prisma:generate # Generate Prisma client
bun run prisma:migrate  # Run migrations
```

## 🚀 Deployment Options

### 1. Quick Deploy
- **Use case**: Quick updates and hotfixes
- **Command**: `./quick-deploy.sh "message"`
- **Process**: Local commit → Push → Server pull → Docker rebuild

### 2. Full Deploy
- **Use case**: Major deployments with full pipeline
- **Command**: `./full-deploy.sh "message"`
- **Process**: Git operations → Server connection → Health checks

### 3. Production Deploy
- **Use case**: Clean production deployment
- **Command**: `./deploy-production.sh`
- **Process**: Environment setup → Docker compose → Health verification

## 🔍 Monitoring & Maintenance

### Health Checks
```bash
# Check service health
curl http://localhost:3000/api/health  # Frontend
curl http://localhost:3333/health      # Backend

# View container status
docker compose ps

# View logs
docker compose logs -f [service_name]
```

### Database Management
```bash
# Access database
docker compose exec postgres psql -U postgres -d innerbright

# Run migrations
cd site && bun run prisma:migrate

# View data in Prisma Studio
cd site && bun run prisma:studio
```

## 🐛 Troubleshooting

### Common Issues

1. **Bun not found**:
```bash
export PATH="$HOME/.bun/bin:$PATH"
source ~/.bashrc
```

2. **Port conflicts**:
```bash
# Check what's using the port
lsof -i :3000
lsof -i :3333

# Stop Docker containers
docker compose down
```

3. **Database connection issues**:
```bash
# Reset database
docker compose down -v
docker compose up -d postgres
```

4. **Permission issues**:
```bash
# Fix Docker permissions
sudo chown -R $USER:$USER .
sudo usermod -aG docker $USER
```

## 🔧 Configuration

### Environment Variables
Create `.env` file in project root:
```env
# Database
POSTGRES_DB=innerbright
POSTGRES_USER=postgres
POSTGRES_PASSWORD=your_password

# Next.js
NEXTAUTH_SECRET=your_secret_32_chars_minimum
NEXTAUTH_URL=https://your-domain.com

# MinIO
MINIO_ACCESS_KEY=minioadmin
MINIO_SECRET_KEY=minioadmin

# API
JWT_SECRET=your_jwt_secret
```

## 📚 Additional Resources

- [Next.js Documentation](https://nextjs.org/docs)
- [NestJS Documentation](https://docs.nestjs.com)
- [Bun Documentation](https://bun.sh/docs)
- [Prisma Documentation](https://www.prisma.io/docs)
- [Docker Compose Documentation](https://docs.docker.com/compose)

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes with Bun (`./git-deploy.sh "add amazing feature"`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License.

---
Built with ❤️ using **Bun**, **Next.js**, and **NestJS**
