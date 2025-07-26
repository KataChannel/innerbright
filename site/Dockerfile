FROM oven/bun:1-alpine AS base

# Install only essential packages
RUN apk add --no-cache libc6-compat dumb-init

# Dependencies stage with better caching
FROM base AS deps
WORKDIR /app

# Copy only package files first for better layer caching
COPY package.json bun.lockb* ./

# Install dependencies including devDependencies for build stage
RUN --mount=type=cache,target=/root/.bun \
    bun install --frozen-lockfile

# Copy prisma schema after dependencies
COPY prisma ./prisma

# Generate Prisma client with explicit binary path and cache
RUN --mount=type=cache,target=/root/.bun \
    --mount=type=cache,target=/app/node_modules/.cache \
    bun add prisma @prisma/client && \
    bunx prisma generate

# Build stage
FROM base AS builder
WORKDIR /app

# Copy node_modules from deps
COPY --from=deps /app/node_modules ./node_modules
# Copy prisma generated files from deps stage
COPY --from=deps /app/prisma ./prisma
COPY . .

# Build arguments for Next.js fullstack
ARG NEXT_PUBLIC_APP_URL=http://localhost:3000
ARG DATABASE_URL
ARG JWT_SECRET

# Build with optimizations
ENV NEXT_TELEMETRY_DISABLED=1
ENV NODE_ENV=production
ENV DOCKER_BUILD=true
ENV SKIP_ENV_VALIDATION=true
ENV NEXT_PUBLIC_APP_URL=${NEXT_PUBLIC_APP_URL}
ENV DATABASE_URL=${DATABASE_URL}
ENV JWT_SECRET=${JWT_SECRET}

# Build with standalone output and optimize
RUN --mount=type=cache,target=/app/.next/cache \
    NODE_OPTIONS="--max-old-space-size=4096" \
    SKIP_ENV_VALIDATION=true \
    bun run build:optimized && \
    rm -rf node_modules/@next/swc-* && \
    rm -rf node_modules/.cache

# Production stage - Use distroless for smaller size and better security
FROM gcr.io/distroless/nodejs20-debian12:nonroot AS production
WORKDIR /app

# Copy only necessary files
COPY --from=builder --chown=nonroot:nonroot /app/.next/standalone ./
COPY --from=builder --chown=nonroot:nonroot /app/.next/static ./.next/static
COPY --from=builder --chown=nonroot:nonroot /app/public ./public

# Copy Prisma runtime files only
COPY --from=deps --chown=nonroot:nonroot /app/node_modules/.prisma/client ./node_modules/.prisma/client
COPY --from=builder --chown=nonroot:nonroot /app/prisma ./prisma

# Environment variables
ENV NODE_ENV=production
ENV PORT=3000
ENV NEXT_TELEMETRY_DISABLED=1
ENV HOSTNAME="0.0.0.0"

EXPOSE 3000

# Use distroless default user (nonroot)
USER nonroot

CMD ["server.js"]
