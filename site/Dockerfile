# 🚀 Site-Only Dockerfile Production Ready
FROM oven/bun:1-alpine AS base

# Install system dependencies
WORKDIR /app
RUN apk add --no-cache libc6-compat ca-certificates

# Dependencies stage
FROM base AS deps

# Copy package files (building from site directory context)
COPY package.json bun.lockb* ./

# Install dependencies
RUN --mount=type=cache,target=/root/.bun/install/cache \
    bun install --frozen-lockfile

# Build stage
FROM base AS builder
WORKDIR /app

# Copy dependencies
COPY --from=deps /app/node_modules ./node_modules

# Copy all source files
COPY . .

# Build environment
ENV BUILD_SITE_ONLY=true
ENV NEXT_TELEMETRY_DISABLED=1
ENV NODE_ENV=production

# Build with site-only optimization
RUN bun run build:site-only

# Production stage
FROM base AS runner
WORKDIR /app

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

# Create user for security
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# Copy build artifacts with proper ownership
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static
COPY --from=builder --chown=nextjs:nodejs /app/public ./public

# Switch to non-root user
USER nextjs

EXPOSE 3000
ENV PORT=3000
ENV HOSTNAME="0.0.0.0"

# Use Node.js for better compatibility with standalone mode
CMD ["node", "server.js"]