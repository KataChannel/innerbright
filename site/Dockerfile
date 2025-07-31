# 🚀 Site-Only Dockerfile with Root Context
FROM oven/bun:1-alpine AS base

# Install dependencies only when needed
FROM base AS deps
WORKDIR /app

# Copy site package files
COPY site/package.json site/bun.lockb* ./

# Copy shared prisma if it exists
COPY prisma ./prisma/ 2>/dev/null || echo "No root prisma directory"

# Install dependencies
RUN --mount=type=cache,target=/root/.bun/install/cache \
    bun install --frozen-lockfile

# Generate Prisma client if schema exists
RUN if [ -f "./prisma/schema.prisma" ]; then \
        echo "Generating Prisma client..." && bun prisma generate; \
    else \
        echo "No Prisma schema found"; \
    fi

# Build stage
FROM base AS builder
WORKDIR /app

# Copy dependencies
COPY --from=deps /app/node_modules ./node_modules
COPY --from=deps /app/prisma ./prisma/ 2>/dev/null || true

# Copy site source
COPY site/ .

# Build environment
ENV BUILD_SITE_ONLY=true
ENV NEXT_TELEMETRY_DISABLED=1
ENV NODE_ENV=production

# Build with Bun
RUN bun run build:bun

# Production stage
FROM base AS runner
WORKDIR /app

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

# Create user
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# Copy build artifacts
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/public ./public

# Set permissions
RUN chown -R nextjs:nodejs /app
USER nextjs

EXPOSE 3000
ENV PORT=3000
ENV HOSTNAME="0.0.0.0"

CMD ["bun", "server.js"]