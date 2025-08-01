FROM oven/bun:1-alpine AS base

# Install essential packages for Alpine + musl compatibility
RUN apk add --no-cache \
    libc6-compat \
    dumb-init \
    ca-certificates \
    tzdata

# Production stage - chỉ copy file đã build
FROM base AS runner
WORKDIR /app

# Create app user for security
RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nextjs

# Copy pre-built application from local build
# Giả định rằng bạn đã chạy `bun run build` ở local trước khi build Docker
COPY --chown=nextjs:nodejs .next/standalone ./
COPY --chown=nextjs:nodejs .next/static ./.next/static
COPY --chown=nextjs:nodejs public ./public

# Copy essential runtime files
COPY --chown=nextjs:nodejs package.json ./

# Copy Prisma client đã generate (nếu có)
COPY --chown=nextjs:nodejs node_modules/.prisma ./node_modules/.prisma
COPY --chown=nextjs:nodejs node_modules/@prisma ./node_modules/@prisma

# Environment variables
ENV NODE_ENV=production
ENV PORT=3000
ENV NEXT_TELEMETRY_DISABLED=1
ENV HOSTNAME="0.0.0.0"

# Expose port
EXPOSE 3000

# Switch to non-root user
USER nextjs

# Use dumb-init for proper signal handling and Bun for execution
ENTRYPOINT ["dumb-init", "--"]
CMD ["bun", "run", "server.js"]
