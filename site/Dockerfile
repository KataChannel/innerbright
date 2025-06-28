# Stage 1: Build
FROM node:22-bullseye-slim AS builder
WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm ci

# Copy source files and build the application
COPY . .
RUN npm run build

# Stage 2: Production
FROM node:22-bullseye-slim
WORKDIR /app

# Copy only the required files from the build stage
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public

EXPOSE 3000
CMD ["npm", "start"]