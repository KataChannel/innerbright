# 🏗️ innerbright Architecture Overview

## System Architecture

innerbright follows a modern microservices architecture with clear separation of concerns:

```
┌─────────────────────────────────────────────────────────────────────┐
│                              Frontend                                  │
│  ┌─────────────────────────────────────────────────────────────────┐  │
│  │                     Next.js 15 (React 19)                      │  │
│  │  ┌─────────────────────────────────────────────────────────────┐ │  │
│  │  │  App Router  │  Components  │  Hooks  │  Utils  │  Styles  │ │  │
│  │  └─────────────────────────────────────────────────────────────┘ │  │
│  └─────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
                                    │
                                HTTP/REST API
                                    │
┌─────────────────────────────────────────────────────────────────────┐
│                              Backend                                   │
│  ┌─────────────────────────────────────────────────────────────────┐  │
│  │                     NestJS 11 (Node.js)                        │  │
│  │  ┌─────────────────────────────────────────────────────────────┐ │  │
│  │  │ Controllers │ Services │ Guards │ Modules │ Decorators │ DTOs│ │  │
│  │  └─────────────────────────────────────────────────────────────┘ │  │
│  └─────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
                                    │
                           Database Connections
                                    │
┌─────────────────────────────────────────────────────────────────────┐
│                            Data Layer                                  │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────────┐  │
│  │   PostgreSQL    │  │      Redis      │  │       MinIO         │  │
│  │   (Primary DB)  │  │    (Caching)    │  │  (File Storage)     │  │
│  └─────────────────┘  └─────────────────┘  └─────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
```

## Technology Stack

### Frontend (site/)
- **Framework**: Next.js 15 with App Router
- **UI Library**: React 19 with Server Components
- **Styling**: Tailwind CSS 4.0 + Material-UI 7.0
- **Language**: TypeScript 5.7
- **Runtime**: Bun.js for ultra-fast development
- **State Management**: React Context + Custom Hooks
- **Forms**: React Hook Form with Zod validation

### Backend (api/)
- **Framework**: NestJS 11 with Modular Architecture
- **Database ORM**: Prisma Client with PostgreSQL
- **Authentication**: JWT with bcrypt password hashing
- **API Documentation**: Swagger/OpenAPI 3.0
- **Language**: TypeScript 5.7
- **Runtime**: Bun.js for performance
- **Validation**: Class Validator + Class Transformer

### Infrastructure
- **Database**: PostgreSQL 15 (Primary data storage)
- **Cache**: Redis 7 (Session storage and caching)
- **File Storage**: MinIO (S3-compatible object storage)
- **Containerization**: Docker + Docker Compose
- **Reverse Proxy**: Nginx with SSL termination
- **SSL Certificates**: Let's Encrypt with automatic renewal

## Project Structure

```
innerbright/
├── 📁 site/                      # Frontend Application
│   ├── src/app/                   # Next.js App Router pages
│   │   ├── (auth)/               # Authentication routes
│   │   ├── dashboard/            # Dashboard pages
│   │   ├── employees/            # Employee management
│   │   ├── departments/          # Department management
│   │   └── layout.tsx            # Root layout component
│   ├── src/components/           # Reusable React components
│   │   ├── ui/                   # Basic UI components
│   │   ├── forms/                # Form components
│   │   ├── layouts/              # Layout components
│   │   └── features/             # Feature-specific components
│   ├── src/lib/                  # Utilities and configurations
│   │   ├── auth.ts               # Authentication logic
│   │   ├── api.ts                # API client
│   │   ├── utils.ts              # Helper functions
│   │   └── validations.ts        # Form validations
│   └── prisma/                   # Database client (frontend)
│
├── 📁 api/                       # Backend Application
│   ├── src/                      # NestJS source code
│   │   ├── auth/                 # Authentication module
│   │   ├── employees/            # Employee management module
│   │   ├── departments/          # Department management module
│   │   ├── users/                # User management module
│   │   ├── common/               # Shared utilities
│   │   │   ├── guards/           # Authentication guards
│   │   │   ├── decorators/       # Custom decorators
│   │   │   ├── filters/          # Exception filters
│   │   │   └── interceptors/     # Response interceptors
│   │   ├── app.module.ts         # Root application module
│   │   └── main.ts               # Application entry point
│   ├── prisma/                   # Database schema and migrations
│   │   ├── schema.prisma         # Database schema
│   │   ├── migrations/           # Database migrations
│   │   └── seed.ts               # Database seeding
│   └── dist/                     # Built output
│
├── 📁 deployment/                # Deployment System
│   ├── scripts/                  # Deployment automation scripts
│   │   ├── deploy-production.sh  # Professional deployment
│   │   ├── deploy-wizard.sh      # Interactive deployment wizard
│   │   ├── quick-deploy-enhanced.sh # Quick deployment
│   │   └── auto-ssh-deploy.sh    # SSH automation
│   ├── configs/                  # Server configurations
│   │   ├── nginx/                # Nginx configurations
│   │   ├── ssl/                  # SSL configurations
│   │   └── docker/               # Docker configurations
│   └── templates/                # Configuration templates
│
├── 📁 configs/                   # Project Configurations
│   ├── docker/                   # Docker Compose files
│   │   ├── docker-compose.yml    # Standard configuration
│   │   ├── docker-compose.dev.yml # Development configuration
│   │   └── docker-compose.prod.yml # Production configuration
│   ├── environments/             # Environment configurations
│   │   ├── dev.conf              # Development environment
│   │   ├── staging.conf          # Staging environment
│   │   └── prod.conf             # Production environment
│   └── nginx/                    # Nginx configurations
│
├── 📁 scripts/                   # Development Scripts
│   ├── setup/                    # Initial setup scripts
│   │   ├── generate-security.sh  # Security key generation
│   │   └── ssh-keygen-setup.sh   # SSH key setup
│   ├── deployment/               # Deployment helpers
│   │   └── deploy.sh             # Master deployment script
│   ├── maintenance/              # Maintenance scripts
│   │   └── autopush.sh           # Git automation
│   └── testing/                  # Testing scripts
│       └── test-deployment.sh    # Deployment testing
│
└── 📁 docs/                      # Documentation
    ├── guides/                   # User guides
    │   ├── QUICK-START.md        # Quick start guide
    │   ├── DEVELOPMENT.md        # Development guide
    │   ├── DEPLOYMENT-GUIDE.md   # Deployment guide
    │   └── ARCHITECTURE.md       # This file
    ├── api/                      # API documentation
    │   ├── HRM-API.md            # HRM API reference
    │   ├── AUTH-API.md           # Authentication API
    │   └── SYSTEM-API.md         # System API
    └── examples/                 # Code examples
        ├── api-usage/            # API usage examples
        ├── components/           # Component examples
        └── deployment/           # Deployment examples
```

## Data Flow

### Authentication Flow
```
1. User submits login credentials
2. Frontend sends POST to /auth/login
3. Backend validates credentials against database
4. Backend generates JWT token
5. Frontend stores token in secure cookie
6. Subsequent requests include JWT in Authorization header
7. Backend validates JWT on protected routes
```

### Employee Management Flow
```
1. User accesses employee management page
2. Frontend fetches employees from /employees endpoint
3. Backend queries PostgreSQL via Prisma ORM
4. Data is returned with proper pagination
5. Frontend displays data in table/grid format
6. User actions (CRUD) trigger API calls
7. Backend validates permissions and updates database
8. Frontend updates UI with new data
```

### File Upload Flow
```
1. User selects file for upload
2. Frontend uploads to MinIO via signed URL
3. Backend generates pre-signed upload URL
4. File is stored in MinIO object storage
5. File metadata is saved in PostgreSQL
6. Frontend receives success confirmation
```

## Security Architecture

### Authentication & Authorization
- **JWT Tokens**: Stateless authentication with refresh tokens
- **Role-Based Access Control**: Admin, Manager, Employee roles
- **Password Security**: bcrypt hashing with salt rounds
- **Session Management**: Secure HTTP-only cookies

### Data Security
- **SQL Injection Protection**: Prisma ORM parameterized queries
- **XSS Protection**: React's built-in XSS protection
- **CSRF Protection**: SameSite cookies and CSRF tokens
- **Data Validation**: Input validation on both client and server

### Infrastructure Security
- **HTTPS Encryption**: Let's Encrypt SSL certificates
- **Network Security**: Docker networks with isolated services
- **Database Security**: Encrypted connections and access controls
- **Backup Security**: Encrypted backup storage

## Performance Optimizations

### Frontend Performance
- **Server-Side Rendering**: Next.js SSR for fast initial loads
- **Code Splitting**: Automatic code splitting by route
- **Image Optimization**: Next.js built-in image optimization
- **Caching**: Browser caching and CDN integration

### Backend Performance
- **Database Indexing**: Optimized database indexes
- **Connection Pooling**: PostgreSQL connection pooling
- **Caching Layer**: Redis for frequently accessed data
- **Response Compression**: Gzip compression for API responses

### Infrastructure Performance
- **Container Optimization**: Multi-stage Docker builds
- **Resource Management**: CPU and memory limits
- **Load Balancing**: Nginx load balancing for high availability
- **Monitoring**: Performance monitoring and alerting

## Scalability Considerations

### Horizontal Scaling
- **Stateless Design**: JWT-based authentication for multi-instance deployment
- **Database Scaling**: Read replicas and connection pooling
- **File Storage**: S3-compatible object storage
- **Container Orchestration**: Docker Swarm or Kubernetes ready

### Vertical Scaling
- **Resource Allocation**: Configurable CPU and memory limits
- **Database Optimization**: Query optimization and indexing
- **Caching Strategy**: Multi-layer caching implementation
- **Performance Monitoring**: Real-time performance metrics

## Development Workflow

### Local Development
1. **Environment Setup**: Bun.js runtime with hot reloading
2. **Database Development**: Local PostgreSQL with Prisma migrations
3. **API Development**: NestJS with Swagger documentation
4. **Frontend Development**: Next.js with Turbopack

### Testing Strategy
1. **Unit Testing**: Jest for backend, React Testing Library for frontend
2. **Integration Testing**: API endpoint testing with supertest
3. **E2E Testing**: Playwright for end-to-end testing
4. **Performance Testing**: Load testing with k6

### Deployment Pipeline
1. **Development**: Local development with hot reloading
2. **Staging**: Automated deployment to staging environment
3. **Production**: Manual approval for production deployment
4. **Monitoring**: Real-time monitoring and alerting

## Monitoring & Observability

### Application Monitoring
- **Health Checks**: Endpoint health monitoring
- **Performance Metrics**: Response time and throughput
- **Error Tracking**: Error logging and alerting
- **User Analytics**: User behavior tracking

### Infrastructure Monitoring
- **System Metrics**: CPU, memory, disk usage
- **Container Monitoring**: Docker container health
- **Database Monitoring**: Query performance and connections
- **Network Monitoring**: Traffic and latency monitoring

### Logging Strategy
- **Structured Logging**: JSON-formatted logs
- **Log Aggregation**: Centralized log collection
- **Log Retention**: Configurable retention policies
- **Alert Integration**: Integration with alerting systems

This architecture ensures scalability, maintainability, and security while providing excellent developer experience and performance.
