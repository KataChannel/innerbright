# 🚀 Innerbright - Next.js Fullstack Enterprise Platform

<div align="center">

![Innerbright Logo](https://img.shields.io/badge/Innerbright-Next.js%20Fullstack-blue?style=for-the-badge&logo=nextjs)

**Modern Next.js 15 Fullstack Platform with Prisma ORM**

[![Next.js](https://img.shields.io/badge/Next.js-15+-black?style=flat-square&logo=next.js)](https://nextjs.org/)
[![React](https://img.shields.io/badge/React-19+-blue?style=flat-square&logo=react)](https://reactjs.org/)
[![Prisma](https://img.shields.io/badge/Prisma-6+-green?style=flat-square&logo=prisma)](https://www.prisma.io/)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.0+-blue?style=flat-square&logo=typescript)](https://www.typescriptlang.org/)
[![Docker](https://img.shields.io/badge/Docker-Ready-blue?style=flat-square&logo=docker)](https://www.docker.com/)
[![Bun](https://img.shields.io/badge/Bun-1.0+-orange?style=flat-square&logo=bun)](https://bun.sh/)

[🚀 Quick Start](#-quick-start) • [📖 API Documentation](#-api-documentation) • [🎯 Features](#-features) • [💻 Development](#-development) • [🚢 Deployment](#-deployment)

</div>

---

## 🌟 Features

### 🏗️ **Next.js Fullstack Architecture**
- **🚀 Next.js 15** - App Router with Server Components and Server Actions
- **⚛️ React 19** - Latest React with concurrent features
- **🎨 Tailwind CSS 4** - Utility-first CSS framework
- **⚡ Bun.js Runtime** - Ultra-fast JavaScript runtime
- **🗄️ Prisma ORM** - Type-safe database client with PostgreSQL
- **🔐 NextAuth.js** - Complete authentication solution
- **📱 API Routes** - Built-in backend API endpoints

### 🛠️ **Infrastructure & Deployment**
- **🐳 Docker Support** - Multi-stage builds with distroless images
- **🔄 Auto Deployment** - Automated deployment scripts
- **🌐 Nginx Reverse Proxy** - Load balancing and SSL termination
- **🔒 SSL Certificates** - Automated Let's Encrypt integration
- **☁️ Cloud Ready** - Multi-cloud provider support
- **📊 Health Monitoring** - Built-in health checks

### 💾 **Database & Storage**
- **🗄️ PostgreSQL** - Primary relational database
- **⚡ Redis** - Caching and session storage
- **📦 MinIO** - S3-compatible object storage
- **🔄 Prisma Migrations** - Database schema management
- **🌱 Database Seeding** - Sample data generation

### 🚀 **Business Features**
- **👥 User Management** - Complete user CRUD operations
- **🏢 Department Management** - Organizational structure
- **👷 Employee Management** - HR system integration
- **🔐 Role-Based Access Control** - Permission management
- **📊 Dashboard** - Real-time analytics
- **📱 Responsive Design** - Mobile-first approach

---

## 🚀 Quick Start

### Prerequisites
- **Bun.js** (Latest)
- **Docker & Docker Compose**
- **Git**

### 1. Clone & Setup
```bash
git clone https://github.com/yourusername/innerbright.git
cd innerbright

# Copy environment variables
cp .env.fullstack.example .env

# Install dependencies
bun run install:all
```

### 2. Database Setup
```bash
# Start database services
docker-compose -f docker-compose.fullstack.yml up -d postgres redis minio

# Generate Prisma client and run migrations
bun run db:generate
bun run db:migrate
bun run db:seed:master
```

### 3. Development
```bash
# Start development server
bun run dev

# Or start full environment
bun run dev:full
```

**Development URLs:**
- 🌐 **Frontend**: http://localhost:3000
- 🔌 **API**: http://localhost:3000/api
- ❤️ **Health Check**: http://localhost:3000/api/health
- 🗄️ **Prisma Studio**: http://localhost:5555

### 4. Production Build
```bash
# Build application
bun run build

# Start production server
bun run start

# Or deploy with Docker
docker-compose -f docker-compose.fullstack.yml up -d
```

---

## 📖 API Documentation

### Authentication Endpoints

#### POST `/api/auth/login`
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

#### POST `/api/auth/register`
```json
{
  "email": "newuser@example.com",
  "password": "password123",
  "displayName": "New User",
  "username": "newuser"
}
```

### User Management

#### GET `/api/users`
Get all users with role and department information.

#### POST `/api/users`
Create a new user.

### Department Management

#### GET `/api/departments`
Get all departments with manager and employee count.

#### POST `/api/departments`
Create a new department.

### Employee Management

#### GET `/api/employees`
Get all employees with user, department, and position details.

#### POST `/api/employees`
Create a new employee record.

---

## 🏗️ Project Structure

```
innerbright/
├── 📁 site/                   # Next.js Application
│   ├── 📁 src/
│   │   ├── 📁 app/            # App Router
│   │   │   ├── 📁 api/        # API Routes
│   │   │   │   ├── auth/      # Authentication endpoints
│   │   │   │   ├── users/     # User management
│   │   │   │   ├── departments/ # Department management
│   │   │   │   └── employees/ # Employee management
│   │   │   ├── 📁 (site)/     # Main application pages
│   │   │   └── 📄 layout.tsx  # Root layout
│   │   ├── 📁 components/     # React components
│   │   ├── 📁 lib/           # Utility functions
│   │   └── 📁 prisma/        # Database
│   │       ├── 📄 schema.prisma # Database schema
│   │       ├── 📁 migrations/ # Migration files
│   │       └── 📁 seed/      # Seed scripts
│   ├── 📄 package.json       # Dependencies
│   ├── 📄 Dockerfile         # Container config
│   └── 📄 next.config.ts     # Next.js config
├── 📄 docker-compose.fullstack.yml # Full stack deployment
├── 📄 .env.fullstack.example # Environment template
└── 📄 package.json           # Root package.json
```

---

## 💻 Development

### Available Scripts

```bash
# Development
bun run dev              # Start development server
bun run dev:full         # Start with database generation
bun run dev:debug        # Debug mode
bun run dev:reset        # Reset database and start

# Building
bun run build            # Build for production
bun run build:check      # Build with type checking
bun run build:analyze    # Analyze bundle size

# Database
bun run db:generate      # Generate Prisma client
bun run db:migrate       # Run migrations
bun run db:seed          # Seed database
bun run db:studio        # Open Prisma Studio
bun run db:reset         # Reset database

# Testing & Quality
bun run test             # Run tests
bun run lint             # Lint code
bun run type-check       # Type checking
bun run format           # Format code

# Docker
bun run docker:up        # Start services
bun run docker:down      # Stop services
bun run docker:build     # Build images
bun run docker:logs      # View logs
```

### Environment Variables

Copy `.env.fullstack.example` to `.env` and configure:

```env
# Database
DATABASE_URL="postgresql://postgres:postgres123@localhost:5432/innerbright"

# Authentication
JWT_SECRET="your-jwt-secret"
NEXTAUTH_SECRET="your-nextauth-secret"
NEXTAUTH_URL="http://localhost:3000"

# Redis
REDIS_URL="redis://:redis123@localhost:6379"

# MinIO
MINIO_ENDPOINT="localhost:9000"
MINIO_ROOT_USER="minioadmin"
MINIO_ROOT_PASSWORD="minioadmin123"
```

---

## 🚢 Deployment

### Docker Deployment

```bash
# Build and start all services
docker-compose -f docker-compose.fullstack.yml up -d

# View logs
docker-compose -f docker-compose.fullstack.yml logs -f

# Stop services
docker-compose -f docker-compose.fullstack.yml down
```

### Production Deployment

1. **Prepare Environment**
   ```bash
   cp .env.fullstack.example .env.prod
   # Edit .env.prod with production values
   ```

2. **Deploy to Cloud**
   ```bash
   # Using deployment script
   ./scripts/deploy-production.sh
   
   # Or manual deployment
   docker-compose -f docker-compose.fullstack.yml --env-file .env.prod up -d
   ```

3. **SSL Setup**
   ```bash
   # Automated with Let's Encrypt
   ./sh/nginx.sh
   ```

---

## 🔧 Configuration

### Database Schema

The application uses Prisma with PostgreSQL. Key models include:

- **User** - Authentication and user profiles
- **Role** - Role-based access control
- **Department** - Organizational structure
- **Employee** - HR management
- **Position** - Job positions and levels

### Authentication

JWT-based authentication with:
- Email/password login
- Password hashing with bcryptjs
- Token-based API access
- Role-based permissions

### File Storage

MinIO S3-compatible storage for:
- User avatars
- Document uploads
- File attachments
- Backup storage

---

## 🛠️ Troubleshooting

### Common Issues

1. **Database Connection**
   ```bash
   # Check database status
   docker-compose -f docker-compose.fullstack.yml ps postgres
   
   # Reset database
   bun run db:reset
   ```

2. **Prisma Issues**
   ```bash
   # Regenerate client
   bun run db:generate
   
   # Reset and reseed
   bun run db:migrate:reset
   ```

3. **Port Conflicts**
   ```bash
   # Check port usage
   lsof -i :3000
   
   # Kill process
   kill -9 <PID>
   ```

### Performance Optimization

- Enable Redis caching
- Use CDN for static assets
- Optimize Prisma queries
- Enable gzip compression
- Use Docker multi-stage builds

---

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 📞 Support

- 📧 **Email**: support@innerbright.com
- 💬 **Discord**: [Join our community](https://discord.gg/innerbright)
- 📖 **Docs**: [documentation.innerbright.com](https://documentation.innerbright.com)
- 🐛 **Issues**: [GitHub Issues](https://github.com/yourusername/innerbright/issues)

---

<div align="center">

**Made with ❤️ by the Innerbright Team**

[![Star this repo](https://img.shields.io/github/stars/yourusername/innerbright?style=social)](https://github.com/yourusername/innerbright)

</div>
