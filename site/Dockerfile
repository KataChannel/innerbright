# 🚀 Site-Only Dockerfile with Bun Optimization
FROM oven/bun:1-alpine AS base

# Install dependencies only when needed
FROM base AS deps
WORKDIR /app

# Copy only the site package files (not root workspace package.json)
COPY package.json bun.lockb* ./

# Copy prisma directory only if it exists
COPY prisma* ./prisma/ 2>/dev/null || true

# Install dependencies without workspace configuration
RUN --mount=type=cache,target=/root/.bun/install/cache \
    bun install --frozen-lockfile

# Generate Prisma client only if schema exists
RUN --mount=type=cache,target=/root/.bun/install/cache \
    if [ -f "./prisma/schema.prisma" ]; then \
        echo "Generating Prisma client..." && bun prisma generate; \
    else \
        echo "No Prisma schema found, skipping generation"; \
    fi

# Rebuild the source code only when needed
FROM base AS builder
WORKDIR /app

# Copy dependencies and source
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Set environment for site-only build
ENV BUILD_SITE_ONLY=true
ENV NEXT_TELEMETRY_DISABLED=1
ENV NODE_ENV=production

# Build with Bun optimization
RUN bun run build:bun

# Production image, copy all the files and run next
FROM base AS runner
WORKDIR /app

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

# Create nextjs user
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# Copy standalone build
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/public ./public

# Set permissions
RUN chown -R nextjs:nodejs /app
USER nextjs

EXPOSE 3000
ENV PORT=3000

# Start the application
CMD ["bun", "server.js"]
