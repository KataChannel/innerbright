# Stage 1: Run SSR with Bun.js
FROM oven/bun:1 AS runtime

WORKDIR /app

# Copy build from local into Docker image
COPY ./dist/admin /app/dist/admin
# COPY ./node_modules /app/node_modules
# COPY ./package.json /app/package.json

# Run SSR application with Bun
EXPOSE 4200
CMD ["bun", "dist/admin/server/server.mjs"]
