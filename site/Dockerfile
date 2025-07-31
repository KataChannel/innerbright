# 🚀 Site-Only Dockerfile - Optimized for Pre-built Applications
FROM node:18-alpine AS base

# Install system dependencies
RUN apk add --no-cache libc6-compat ca-certificates curl tzdata
WORKDIR /app

# Production stage - Copy pre-built files
FROM base AS runner

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

# Create nextjs user for security
RUN addgroup --system --gid 1001 nodejs \
    && adduser --system --uid 1001 nextjs

# Create necessary directories
RUN mkdir -p .next/static

# Copy ONLY the built application from local build
# These files must exist from local build process
COPY --chown=nextjs:nodejs .next/standalone ./
COPY --chown=nextjs:nodejs .next/static ./.next/static
COPY --chown=nextjs:nodejs public ./public

# Verify critical files exist
RUN test -f server.js || (echo "❌ server.js not found in standalone build" && exit 1)

USER nextjs

EXPOSE 3000
ENV PORT=3000
ENV HOSTNAME="0.0.0.0"

# Health check with better error handling
HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
    CMD curl -f http://localhost:3000/ || exit 1

CMD ["node", "server.js"]