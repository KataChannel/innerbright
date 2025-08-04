# Build stage
FROM oven/bun:1-alpine AS builder
WORKDIR /app

# Copy package files
COPY package.json bun.lockb* ./

# Install dependencies
RUN bun install --frozen-lockfile

# Copy source code
COPY . .

# Build application
RUN bun run build

# Production stage
FROM oven/bun:1-alpine AS runner
WORKDIR /app

# Set environment to production
ENV NODE_ENV production

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nextjs -u 1001

# Copy only necessary files
COPY --from=builder --chown=nextjs:nodejs /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

# Change to non-root user
USER nextjs

# Expose port
EXPOSE 3000

# Start application
ENV PORT 3000
ENV HOSTNAME "0.0.0.0"
CMD ["bun", "server.js"]
