# 🚀 Innerbright Fullstack Migration Guide

## Overview
This guide will help you migrate from the current NestJS + Next.js architecture to a unified Next.js Fullstack application with Prisma ORM.

## What's Changing

### Before (Multi-Service)
```
innerbright/
├── api/          # NestJS Backend
├── shared/       # Shared code
└── site/         # Next.js Frontend
```

### After (Fullstack)
```
innerbright/
└── site/         # Next.js Fullstack with API Routes
    ├── src/app/api/  # Backend API endpoints
    ├── prisma/       # Database schema & migrations
    └── components/   # Frontend components
```

## Migration Steps

### 1. Automated Migration
```bash
# Run the migration script
./migrate-to-fullstack.sh
```

### 2. Manual Configuration

#### Update Environment Variables
```bash
# Copy the new environment template
cp .env.fullstack.example .env

# Edit with your values
nano .env
```

#### Key Environment Variables
```env
DATABASE_URL="postgresql://postgres:postgres123@localhost:5432/innerbright"
JWT_SECRET="your-jwt-secret"
NEXTAUTH_SECRET="your-nextauth-secret"
REDIS_URL="redis://:redis123@localhost:6379"
```

### 3. Database Setup
```bash
# Start database services
docker-compose up -d postgres redis minio

# Generate Prisma client
cd site && bun run db:generate

# Run migrations
bun run db:migrate

# Seed database
bun run db:seed:master
```

### 4. Development
```bash
# Start development server
bun run dev

# Or with database generation
bun run dev:full
```

## New Features

### API Routes (Replaces NestJS)
- `/api/auth/login` - User authentication
- `/api/auth/register` - User registration  
- `/api/users` - User management
- `/api/departments` - Department management
- `/api/employees` - Employee management
- `/api/health` - Health check

### Built-in Authentication
- JWT tokens
- NextAuth.js integration
- Role-based access control
- Password hashing with bcryptjs

### Unified Database Access
- Single Prisma schema
- Shared database client
- Consistent data models
- Type-safe operations

## Development Workflow

### Old Workflow
```bash
# Start multiple services
bun run dev:api    # NestJS on :3001
bun run dev:site   # Next.js on :3000
```

### New Workflow
```bash
# Start single fullstack app
bun run dev        # Next.js fullstack on :3000
```

## Deployment

### Docker Deployment
```bash
# Use the new fullstack docker-compose
docker-compose -f docker-compose.fullstack.yml up -d

# Or use the default (now points to fullstack)
docker-compose up -d
```

### Production Build
```bash
# Build the fullstack application
bun run build

# Start production server
bun run start
```

## Benefits

### ✅ Simplified Architecture
- Single codebase
- Unified development
- Easier deployment
- Better type safety

### ✅ Improved Performance  
- No API network calls
- Server components
- Optimized builds
- Better caching

### ✅ Developer Experience
- Single development server
- Shared types
- Unified tooling
- Faster hot reload

### ✅ Reduced Complexity
- No API/frontend sync issues
- Single deployment
- Unified monitoring
- Simpler debugging

## Migration Checklist

- [ ] Run migration script: `./migrate-to-fullstack.sh`
- [ ] Update environment variables
- [ ] Configure database connection
- [ ] Test API endpoints
- [ ] Verify authentication flows
- [ ] Update deployment scripts
- [ ] Test production build
- [ ] Update documentation
- [ ] Train team on new architecture

## Rollback Plan

If you need to rollback:

1. **Restore from backup**
   ```bash
   # Backups are in migration_backup_YYYYMMDD_HHMMSS/
   cp -r migration_backup_*/api .
   cp -r migration_backup_*/shared .
   cp migration_backup_*/package.json .
   ```

2. **Reinstall dependencies**
   ```bash
   bun install
   cd api && bun install
   cd ../shared && bun install
   ```

3. **Restart services**
   ```bash
   docker-compose -f docker-compose.old.yml up -d
   ```

## Support

If you encounter issues during migration:

1. Check the backup folder for original files
2. Review the migration logs
3. Verify environment variables
4. Test database connectivity
5. Check API endpoints manually

## Next Steps

After successful migration:

1. Update CI/CD pipelines
2. Update monitoring/logging
3. Train team on new architecture  
4. Update documentation
5. Plan for additional features

---

**Happy coding with Next.js Fullstack! 🚀**
