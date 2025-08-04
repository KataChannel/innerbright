# Multi-stage optimized build for Next.js
FROM oven/bun:1-alpine AS base

# Install system dependencies
RUN apk add --no-cache libc6-compat curl && \
    rm -rf /var/cache/apk/*

WORKDIR /app

# Dependencies stage - cache layer for package.json changes
FROM base AS deps
COPY package.json bun.lockb* ./
RUN bun install --frozen-lockfile --production=false

# Builder stage - build application
FROM base AS builder
WORKDIR /app

# Copy dependencies from deps stage
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Set build environment variables
ENV NEXT_TELEMETRY_DISABLED=1
ENV NODE_ENV=production

# Build the application
RUN bun run build

# Production dependencies stage - only production deps
FROM base AS prod-deps
COPY package.json bun.lockb* ./
RUN bun install --frozen-lockfile --production=true

# Runner stage - minimal production image
FROM oven/bun:1-alpine AS runner
WORKDIR /app

# Install only essential runtime dependencies
RUN apk add --no-cache curl dumb-init && \
    rm -rf /var/cache/apk/*

# Set production environment
ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1
ENV PORT=3000
ENV HOSTNAME="0.0.0.0"

# Create non-root user for security
RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nextjs

# Copy built application files
COPY --from=builder --chown=nextjs:nodejs /app/public ./public

# Copy standalone build output
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

# Switch to non-root user
USER nextjs

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD curl -f http://localhost:3000/ || exit 1

# Use dumb-init for proper signal handling
ENTRYPOINT ["dumb-init", "--"]
CMD ["bun", "server.js"]
