# Multi-stage optimized build for Next.js with maximum efficiency
FROM oven/bun:1-alpine AS base

# Install system dependencies for build and runtime
RUN apk add --no-cache \
    libc6-compat \
    curl \
    dumb-init \
    && rm -rf /var/cache/apk/* \
    && rm -rf /tmp/*

WORKDIR /app

# Dependencies stage - optimized caching
FROM base AS deps
COPY package.json bun.lockb* ./
RUN bun install --frozen-lockfile --no-optional --silent

# Builder stage - build application with optimizations
FROM base AS builder
WORKDIR /app

# Copy dependencies from deps stage
COPY --from=deps /app/node_modules ./node_modules

# Copy only necessary files for build (exclude unnecessary files)
COPY package.json next.config.ts tsconfig.json ./
COPY postcss.config.mjs ./
COPY src ./src
COPY public ./public

# Set build environment variables
ENV NEXT_TELEMETRY_DISABLED=1
ENV NODE_ENV=production
ENV SKIP_ENV_VALIDATION=1

# Build the application with optimizations
RUN bun run build && \
    # Remove source maps and other dev files to reduce size
    find .next -name "*.map" -delete && \
    # Remove unnecessary files
    rm -rf node_modules/.cache && \
    rm -rf .next/cache/webpack

# Production dependencies stage - minimal deps only
FROM base AS prod-deps
COPY package.json bun.lockb* ./
RUN bun install --frozen-lockfile --production --no-optional --silent && \
    # Clean up unnecessary files
    rm -rf node_modules/.cache && \
    rm -rf /root/.bun/install/cache

# Runner stage - ultra-minimal production image
FROM oven/bun:1-alpine AS runner
WORKDIR /app

# Install only essential runtime dependencies
RUN apk add --no-cache curl dumb-init && \
    rm -rf /var/cache/apk/* && \
    rm -rf /tmp/*

# Set production environment
ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1
ENV PORT=3000
ENV HOSTNAME="0.0.0.0"

# Create non-root user for security
RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nextjs --ingroup nodejs

# Create necessary directories with correct permissions
RUN mkdir -p .next && chown nextjs:nodejs .next

# Copy built application files with optimized layers
COPY --from=builder --chown=nextjs:nodejs /app/public ./public

# Copy standalone build output (Next.js optimized for standalone mode)
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

# Copy only production dependencies if needed
# COPY --from=prod-deps --chown=nextjs:nodejs /app/node_modules ./node_modules

# Switch to non-root user
USER nextjs

# Expose port
EXPOSE 3000

# Health check optimized for standalone mode
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:3000/health || curl -f http://localhost:3000/ || exit 1

# Use dumb-init for proper signal handling and bun for optimal performance
ENTRYPOINT ["dumb-init", "--"]
CMD ["bun", "server.js"]
