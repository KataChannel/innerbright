# Innerbright - Unified Business Management System

## 🚀 Quick Start

### Development
```bash
# Start development server
./run.sh

# Seed database with complete data
cd site && npm run db:seed
```

### Production
```bash
# Deploy to production
./sh/deploy-production.sh
```

## 🏢 System Overview

### Core Features
- **👥 HR Management**: Complete employee lifecycle
- **🔐 Authentication**: Role-based access control  
- **💬 Communication**: Internal messaging system
- **🤝 Affiliate Program**: Referral tracking
- **📊 Analytics**: Business insights

### User Roles
- **Super Admin**: it@innerbright.vn / Innerbright@2024!
- **Department Managers**: Full department access
- **Employees**: Self-service portal

## 🛠️ Tech Stack

- **Frontend**: Next.js 15 + TypeScript
- **Database**: PostgreSQL + Prisma ORM
- **Authentication**: Custom JWT system
- **Styling**: Tailwind CSS

## 📁 Project Structure

```
innerbright/
├── run.sh                 # Main startup script
├── sh/                    # Shell utilities
├── site/                  # Main application
│   ├── prisma/
│   │   ├── schema.prisma  # Database schema
│   │   └── seed/          # Database seeding
│   ├── src/               # Application source
│   └── package.json       # Dependencies
└── README.md              # This file
```

## 🔧 Development Commands

```bash
# Install dependencies
cd site && npm install

# Generate Prisma client
cd site && npx prisma generate

# Run database migrations
cd site && npx prisma migrate deploy

# Seed database
cd site && npm run db:seed

# Start development server
cd site && npm run dev
```

## 🚀 Deployment

Use the provided shell scripts in `sh/` directory for automated deployment.

## 📞 Support

For technical support, contact the development team.

---

**Innerbright** - Professional Business Management Solution
