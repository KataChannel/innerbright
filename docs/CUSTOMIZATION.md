# 🎨 Customizing KataCore StartKit v1

This guide shows you how to customize KataCore StartKit v1 to build your own applications.

## 🏗️ Project Structure

```
KataCore/
├── site/                 # Next.js Frontend
├── api/                  # NestJS Backend  
├── docs/                 # Documentation
├── nginx/                # Web server config
├── scripts/              # Deployment scripts
└── docker-compose.*.yml  # Container orchestration
```

## 🌐 Frontend Customization (Next.js)

### 1. Update Branding

```bash
cd site/src/app
```

**Edit `layout.tsx`:**
```tsx
export const metadata: Metadata = {
  title: "Your App Name",
  description: "Your app description",
}
```

**Edit `page.tsx`:**
```tsx
export default function Home() {
  return (
    <main className="min-h-screen bg-gradient-to-b from-blue-50 to-white">
      <div className="container mx-auto px-4 py-16">
        <h1 className="text-4xl font-bold text-center mb-8">
          Welcome to Your App
        </h1>
        {/* Your content here */}
      </div>
    </main>
  )
}
```

### 2. Add New Pages

```bash
# Create new page
mkdir site/src/app/dashboard
echo 'export default function Dashboard() { return <h1>Dashboard</h1> }' > site/src/app/dashboard/page.tsx
```

### 3. Customize Styling

**Update `tailwind.config.ts`:**
```typescript
export default {
  content: [
    "./src/pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/components/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#eff6ff',
          500: '#3b82f6',
          900: '#1e3a8a',
        },
      },
    },
  },
  plugins: [],
}
```

### 4. Add Custom Components

```bash
mkdir site/src/components/ui
```

**Create `Button.tsx`:**
```tsx
interface ButtonProps {
  children: React.ReactNode
  onClick?: () => void
  variant?: 'primary' | 'secondary'
}

export function Button({ children, onClick, variant = 'primary' }: ButtonProps) {
  const baseClasses = "px-4 py-2 rounded-md font-medium transition-colors"
  const variants = {
    primary: "bg-primary-500 text-white hover:bg-primary-600",
    secondary: "bg-gray-200 text-gray-900 hover:bg-gray-300"
  }

  return (
    <button 
      className={`${baseClasses} ${variants[variant]}`}
      onClick={onClick}
    >
      {children}
    </button>
  )
}
```

## ⚙️ Backend Customization (NestJS)

### 1. Create New Modules

```bash
cd api/src
mkdir users
```

**Create `users/users.module.ts`:**
```typescript
import { Module } from '@nestjs/common';
import { UsersController } from './users.controller';
import { UsersService } from './users.service';

@Module({
  controllers: [UsersController],
  providers: [UsersService],
})
export class UsersModule {}
```

**Create `users/users.controller.ts`:**
```typescript
import { Controller, Get, Post, Body } from '@nestjs/common';
import { UsersService } from './users.service';

@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get()
  findAll() {
    return this.usersService.findAll();
  }

  @Post()
  create(@Body() createUserDto: any) {
    return this.usersService.create(createUserDto);
  }
}
```

### 2. Database Schema (Prisma)

**Edit `api/prisma/schema.prisma`:**
```prisma
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model User {
  id        Int      @id @default(autoincrement())
  email     String   @unique
  name      String?
  posts     Post[]
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}

model Post {
  id        Int      @id @default(autoincrement())
  title     String
  content   String?
  published Boolean  @default(false)
  author    User     @relation(fields: [authorId], references: [id])
  authorId  Int
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}
```

**Generate and apply migrations:**
```bash
cd api
bun run prisma:generate
bun run prisma:migrate
```

### 3. Authentication Setup

```bash
cd api
bun add @nestjs/passport passport passport-jwt @nestjs/jwt bcryptjs
bun add -d @types/passport-jwt @types/bcryptjs
```

**Create auth module:**
```typescript
// api/src/auth/auth.module.ts
import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';

@Module({
  imports: [
    JwtModule.register({
      secret: process.env.JWT_SECRET,
      signOptions: { expiresIn: '7d' },
    }),
  ],
  controllers: [AuthController],
  providers: [AuthService],
})
export class AuthModule {}
```

## 🐳 Docker Configuration

### 1. Environment Variables

**Update `.env.prod.template`:**
```bash
# Your App Configuration
APP_NAME=Your App Name
APP_URL=https://yourapp.com

# Database
POSTGRES_DB=yourapp_prod
POSTGRES_USER=yourapp_user

# Add your custom variables
SENDGRID_API_KEY=your_sendgrid_key
STRIPE_SECRET_KEY=your_stripe_key
```

### 2. Custom Docker Services

**Add to `docker-compose.prod.yml`:**
```yaml
services:
  # ... existing services ...

  # Custom service example
  worker:
    build:
      context: ./api
      dockerfile: Dockerfile
    image: yourapp/worker:${API_VERSION:-latest}
    container_name: yourapp-worker-prod
    restart: unless-stopped
    environment:
      NODE_ENV: production
      DATABASE_URL: ${DATABASE_URL}
      REDIS_URL: ${REDIS_URL}
    command: ["bun", "run", "worker"]
    networks:
      - katacore-network
    depends_on:
      - postgres
      - redis
```

## 🌐 Nginx Configuration

### 1. Custom Routes

**Edit `nginx/conf.d/katacore.conf`:**
```nginx
# Add custom API routes
location /api/webhooks/ {
    proxy_pass http://katacore_api;
    # Disable request buffering for webhooks
    proxy_request_buffering off;
    proxy_buffering off;
}

# Add static file serving
location /uploads/ {
    alias /var/www/uploads/;
    expires 1y;
    add_header Cache-Control "public, immutable";
}
```

### 2. Custom Domain Setup

```bash
# Deploy with your domain
bun run deploy:startkit YOUR_SERVER_IP --domain yourapp.com

# Or manually update the config
# Edit nginx/conf.d/katacore.conf and replace server_name
```

## 📱 Mobile App Integration

### 1. Expo/React Native Setup

```bash
# Create mobile app
npx create-expo-app@latest mobile --template tabs
cd mobile

# Install dependencies
npm install @tanstack/react-query axios
```

**Configure API client:**
```typescript
// mobile/lib/api.ts
import axios from 'axios';

const api = axios.create({
  baseURL: 'https://yourapp.com/api',
  timeout: 10000,
});

export default api;
```

## 🚀 Deployment Customization

### 1. Custom Deployment Scripts

**Create `deploy-custom.sh`:**
```bash
#!/bin/bash
# Custom deployment script

echo "🚀 Deploying with custom configurations..."

# Run pre-deployment tasks
bun run build
bun run test

# Deploy with custom settings
bun run deploy:startkit $1 \
  --domain yourapp.com \
  --ssl-email admin@yourapp.com \
  --backup-enabled \
  --monitoring-enabled

echo "✅ Custom deployment completed!"
```

### 2. Environment-specific Configs

```bash
# Create multiple environment files
cp .env.prod.template .env.staging
cp .env.prod.template .env.prod

# Create deployment configs
echo 'ENVIRONMENT=staging' > .deploy.staging.config
echo 'ENVIRONMENT=production' > .deploy.prod.config
```

## 🔧 Advanced Customization

### 1. Custom Build Pipeline

**Create `.github/workflows/deploy.yml`:**
```yaml
name: Deploy to Production
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: oven-sh/setup-bun@v1
      - run: bun install
      - run: bun run build
      - run: bun run test
      - run: bun run deploy:startkit ${{ secrets.SERVER_IP }}
```

### 2. Monitoring & Analytics

```bash
# Add monitoring services to docker-compose.prod.yml
# - Grafana
# - Prometheus  
# - Loki
# - Jaeger
```

## 📚 Next Steps

- [API Documentation](API.md)
- [Security Guide](SECURITY.md)
- [Performance Optimization](PERFORMANCE.md)
- [Monitoring Setup](MONITORING.md)

## 💡 Pro Tips

1. **Keep the StartKit structure** - makes updates easier
2. **Use environment variables** for all configuration
3. **Test locally first** before deploying
4. **Backup your customizations** in version control
5. **Document your changes** for team members
