# InnerBright Training & Coaching Website

Website huấn luyện và coaching NLP với thiết kế responsive và tối ưu hiệu suất.

## Tính năng

- ✅ Thiết kế responsive với 8 sections chính
- ✅ Carousel tương tác (Hero, Five Foundations, Trainer)
- ✅ Tối ưu hiệu suất với Next.js 16 + Turbopack
- ✅ UI components với shadcn/ui và Tailwind CSS v4
- ✅ Docker deployment với standalone mode
- ✅ Progressive Web App (PWA) ready

## Development

### Prerequisites
- Node.js 18+ hoặc Bun 1.0+
- Docker (cho deployment)

### Local Development

```bash
# Install dependencies
bun install

# Run development server
bun dev

# Build for production
bun run build

# Start production server
bun start
```

Open [http://localhost:3000](http://localhost:3000) để xem website.

### Build Commands

```bash
# Development build với hot reload
bun dev

# Production build
bun run build

# Preview production build
bun start

# Lint code
bun run lint
```

## Deployment

### Docker Deployment (Recommended)

Website sử dụng Docker để deploy lên server production tại `116.118.48.208:14000`.

#### 1. Main Deployment Script

```bash
# Deploy toàn bộ project
./scripts/95copy.sh

# Deploy với build mới
./scripts/95copy.sh --build

# Chỉ restart services
./scripts/95copy.sh --restart
```

#### 2. Debug Deployment Issues

```bash
# Chạy diagnostic tool
./scripts/debug-deploy.sh

# Test specific components
./scripts/debug-deploy.sh ssh      # Test SSH connection
./scripts/debug-deploy.sh docker   # Test Docker on server
./scripts/debug-deploy.sh network  # Test network connectivity
./scripts/debug-deploy.sh all      # Run all tests
```

#### 3. Manual Deployment Steps

Nếu cần deploy manual:

```bash
# 1. Build project
bun run build

# 2. Create symlink (required)
ln -s . frontend

# 3. Deploy files
rsync -avz --timeout=600 \
  --exclude 'node_modules' \
  --exclude '.git' \
  --exclude '.next/cache' \
  ./ root@116.118.48.208:/root/innerbright/

# 4. Build and restart on server
ssh root@116.118.48.208 "cd /root/innerbright && docker compose up -d --build"
```

### Production URLs

- **Main Website**: http://116.118.48.208:14000
- **PgAdmin**: http://116.118.48.208:14002
- **PostgreSQL**: 116.118.48.208:14003
- **Redis**: 116.118.48.208:14004

## Project Structure

```
blognextjsfullstack/
├── app/                    # Next.js App Router
│   ├── globals.css        # Global styles
│   ├── layout.tsx         # Root layout
│   ├── page.tsx          # Homepage (8 sections)
│   └── nlp-certification/ # NLP certification page
├── components/            # React components
│   ├── ui/               # shadcn/ui components
│   ├── Header.tsx        # Website header
│   ├── HeroCarousel.tsx  # Main hero carousel
│   ├── FiveFoundationsCarousel.tsx
│   ├── TrainerCarousel.tsx
│   └── Footer.tsx        # Website footer
├── public/               # Static assets
├── scripts/              # Deployment scripts
│   ├── 95copy.sh         # Main deployment script
│   └── debug-deploy.sh   # Debug tool
├── docker-compose.yml    # Docker services config
├── Dockerfile           # Application container
└── package.json         # Dependencies
```

## Tech Stack

- **Frontend**: Next.js 16.0.1, React 19
- **Styling**: Tailwind CSS v4, shadcn/ui
- **Build Tool**: Turbopack (Next.js built-in)
- **Package Manager**: Bun 1.0+
- **Deployment**: Docker + Docker Compose
- **Database**: PostgreSQL (ready for future features)
- **Cache**: Redis (ready for future features)

## Troubleshooting

### Common Issues

1. **Build errors:**
   ```bash
   # Clean and rebuild
   rm -rf .next node_modules
   bun install
   bun run build
   ```

2. **Docker deployment hanging:**
   ```bash
   # Use debug tool
   ./scripts/debug-deploy.sh docker
   
   # Or check server manually
   ssh root@116.118.48.208 "docker system prune -f"
   ```

3. **SSH connection issues:**
   ```bash
   # Test connectivity
   ./scripts/debug-deploy.sh ssh
   
   # Add SSH key
   ssh-add ~/.ssh/id_rsa
   ```

4. **Port 14000 not accessible:**
   ```bash
   # Check if service is running
   ./scripts/debug-deploy.sh status
   
   # Restart services
   ./scripts/95copy.sh --restart
   ```

### Performance Optimization

- Build size: ~14MB (1377 standalone files + 14 static files)
- Docker image: ~200MB với multi-stage build
- Deploy time: ~1-2 minutes với optimized rsync
- Startup time: ~10-15 seconds

## Development Notes

- Sử dụng Bun làm package manager cho tốc độ build nhanh hơn
- Dockerfile sử dụng multi-stage build để tối ưu image size
- Deployment script có timeout controls để tránh hanging
- Components được thiết kế responsive mobile-first

## Support

Nếu gặp vấn đề deployment, chạy debug tool trước:

```bash
./scripts/debug-deploy.sh
```

Tool sẽ test tất cả components và đưa ra suggestions để fix issues.
