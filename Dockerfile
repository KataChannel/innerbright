# ============================================================================
# OPTIMIZED FOR LOW-SPEC SERVER (1 vCPU, 2GB RAM)
# Pre-built files are uploaded, NO BUILD on server
# ============================================================================

FROM oven/bun:1-slim AS runner
WORKDIR /app

ENV NODE_ENV=production
ENV PORT=3000
ENV HOSTNAME="0.0.0.0"
ENV TURBOPACK=1

# Memory optimization for low-spec server (2GB RAM)
ENV NODE_OPTIONS="--max-old-space-size=1024"

# Create non-root user (minimal overhead)
RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nextjs

# Copy PRE-BUILT files from local machine (uploaded via rsync)
# These files are already built locally, NOT on server
COPY --chown=nextjs:nodejs public ./public
COPY --chown=nextjs:nodejs .next/standalone ./
COPY --chown=nextjs:nodejs .next/static ./.next/static

# Create symlinks for Turbopack runtime files
RUN cd /app/node_modules/next/dist/compiled/next-server && \
    ln -sf app-page-turbo.runtime.prod.js app-page.runtime.prod.js && \
    ln -sf app-route-turbo.runtime.prod.js app-route.runtime.prod.js && \
    ln -sf pages-turbo.runtime.prod.js pages.runtime.prod.js

# Ensure proper permissions and ownership
RUN chown -R nextjs:nodejs /app && \
    chmod -R 755 /app

# Switch to non-root user
USER nextjs

# Expose port
EXPOSE 3000

# Start the application
CMD ["bun", "server.js"]
