# InnerBright - Next.js with Bun.js Runtime

InnerBright Training & Coaching tự hào là thành viên chính thức và uy tín của Hiệp hội NLP Hoa Kỳ (ABNLP) trong suốt 5 năm liên tiếp.

## 🚀 Tech Stack

- **Runtime**: Bun.js (High-performance JavaScript runtime)
- **Framework**: Next.js 15 with App Router
- **Database**: PostgreSQL with Prisma ORM
- **Styling**: Tailwind CSS
- **Authentication**: NextAuth.js
- **Deployment**: Docker with optimized multi-stage builds

## 🛠️ Prerequisites

- [Bun.js](https://bun.sh/) >= 1.0.0
- PostgreSQL database
- Docker (for deployment)

## 📦 Installation & Setup

### Quick Start with Migration Script
```bash
# Run the migration script to set up everything
./migrate-to-bun.sh
```

### Manual Setup
```bash
# Install Bun.js
curl -fsSL https://bun.sh/install | bash

# Install dependencies
bun install

# Set up environment variables
cp .env.example .env.local
# Edit .env.local with your database connection and other configs

# Generate Prisma client
bun run prisma:generate

# Run database migrations
bun run prisma:migrate

# Start development server
bun run dev
```

## 🏃‍♂️ Development Commands

```bash
# Development
bun run dev              # Start development server
bun run build            # Build for production
bun run start            # Start production server

# Database
bun run prisma:generate  # Generate Prisma client
bun run prisma:migrate   # Run database migrations
bun run prisma:studio    # Open Prisma Studio

# Docker
./docker-build.sh        # Build and run Docker container
```

## 🐳 Docker Deployment

The project includes optimized Docker configuration using Bun.js runtime:

```bash
# Build and run with Docker
./docker-build.sh

# Manual Docker commands
docker build -t innerbright-nextjs-bun:latest .
docker run -p 3000:3000 innerbright-nextjs-bun:latest
```

## 📁 Project Structure

```
├── app/                    # Next.js App Router
│   ├── (site)/            # Public site routes
│   ├── admin/             # Admin dashboard
│   ├── api/               # API routes
│   ├── components/        # Reusable components
│   └── lib/               # Utilities and configurations
├── prisma/                # Database schema and migrations
├── public/                # Static assets
├── bunfig.toml           # Bun configuration
├── migrate-to-bun.sh     # Migration script
└── docker-build.sh       # Docker build script
```

## ⚡ Performance Benefits of Bun.js

- **3-5x faster** package installation
- **2-3x faster** development server startup
- **10-20% faster** build times
- **15-30% lower** memory usage

## 🔧 Configuration

### Environment Variables
Create `.env.local` with:
```env
DATABASE_URL="postgresql://..."
NEXTAUTH_SECRET="your-secret-key"
NEXTAUTH_URL="http://localhost:3000"
```

### Bun Configuration
Configuration is managed in `bunfig.toml` for:
- Package installation settings
- Trusted dependencies
- Environment variables

## 📖 Migration from Node.js

If you're migrating from Node.js, check [BUN_MIGRATION.md](./BUN_MIGRATION.md) for detailed instructions.

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is private and proprietary to InnerBright Training & Coaching.
