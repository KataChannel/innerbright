FROM oven/bun:1-alpine AS base

# Install security updates and necessary packages
RUN apk update && apk upgrade && \
    apk add --no-cache libc6-compat curl wget dumb-init && \
    rm -rf /var/cache/apk/*

# Dependencies stage  
FROM base AS deps
WORKDIR /app

# Copy package files (we're in the site directory context)
COPY package.json bun.lockb* ./

# Install dependencies with better error handling
RUN bun install --frozen-lockfile || \
    { echo "Frozen lockfile failed, installing without cache..."; \
      rm -rf node_modules bun.lockb; \
      bun install --no-cache; }

# Build stage
FROM deps AS builder
WORKDIR /app

# Copy source code
COPY . .

# Set build environment
ENV NEXT_TELEMETRY_DISABLED=1
ENV NODE_ENV=production
ENV DOCKER_BUILD=true

# Add runtime environment variables for build
ARG NEXT_PUBLIC_API_URL=http://localhost:3001
ARG NEXT_PUBLIC_APP_URL=http://localhost:3000
ARG NEXT_PUBLIC_MINIO_ENDPOINT=http://localhost:9000
ENV NEXT_PUBLIC_API_URL=${NEXT_PUBLIC_API_URL}
ENV NEXT_PUBLIC_APP_URL=${NEXT_PUBLIC_APP_URL}
ENV NEXT_PUBLIC_MINIO_ENDPOINT=${NEXT_PUBLIC_MINIO_ENDPOINT}

# Provide a fallback DATABASE_URL for build-time Prisma operations
ENV DATABASE_URL="file:./dev.db"

# Generate Prisma client if schema exists
RUN if [ -f "src/prisma/schema.prisma" ]; then \
        echo "Generating Prisma client from src/prisma/schema.prisma..." && \
        bunx prisma generate --schema=src/prisma/schema.prisma; \
    elif [ -f "prisma/schema.prisma" ]; then \
        echo "Generating Prisma client from prisma/schema.prisma..." && \
        bunx prisma generate; \
    else \
        echo "No Prisma schema found, skipping client generation"; \
    fi

# Build the application
RUN bun run build 2>&1 | tee /tmp/build.log || \
    { echo "Build failed. Error log:"; \
      cat /tmp/build.log; \
      exit 1; }

# Validate build output
RUN if [ ! -d ".next" ]; then \
        echo "Error: .next directory not found"; \
        exit 1; \
    fi && \
    if [ ! -d ".next/static" ] && [ ! -d ".next/server" ] && [ ! -f ".next/package.json" ]; then \
        echo "Error: No expected Next.js output found"; \
        exit 1; \
    fi

# Production stage - Minimal image
FROM base AS production
WORKDIR /app

# Create non-root user
RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nextjs --ingroup nodejs

# Set environment variables
ENV NODE_ENV=production
ENV PORT=3000
ENV NEXT_TELEMETRY_DISABLED=1
ENV HOSTNAME="0.0.0.0"

# Create necessary directories first
RUN mkdir -p public .next/cache logs node_modules src && \
    chown -R nextjs:nodejs . && \
    chmod 755 public .next logs

# Copy public files if they exist
RUN if [ -d "/app/public" ]; then echo "Public directory exists"; else mkdir -p public; fi
COPY --from=builder --chown=nextjs:nodejs /app/public/ ./public/

# For Next.js standalone mode, copy the standalone output
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone/ ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static/ ./.next/static/

# Copy Prisma client and schema if they exist
RUN if [ -d "/app/node_modules/.prisma" ]; then \
        echo "Prisma client directory found, will copy..."; \
    else \
        echo "No Prisma client directory found"; \
    fi
COPY --from=builder --chown=nextjs:nodejs /app/node_modules/.prisma/ ./node_modules/.prisma/
COPY --from=builder --chown=nextjs:nodejs /app/node_modules/@prisma/ ./node_modules/@prisma/
COPY --from=builder --chown=nextjs:nodejs /app/src/prisma/ ./src/prisma/

# Set proper permissions
RUN chown -R nextjs:nodejs /app && \
    chmod -R 755 /app

USER nextjs

EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=45s --retries=5 \
  CMD curl -f http://localhost:3000/api/health || curl -f http://localhost:3000/ || exit 1

# Use dumb-init for proper signal handling
ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "server.js"]
