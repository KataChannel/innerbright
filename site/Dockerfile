# Stage 1: Build
FROM node:18-alpine AS builder
WORKDIR /app

# Cài đặt dependencies
COPY package*.json ./
RUN npm ci

# Copy toàn bộ source và build ứng dụng
COPY . .
RUN npm run build

# Stage 2: Production
FROM node:18-alpine
WORKDIR /app

# Chỉ copy những file cần thiết từ stage build
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/build ./build

EXPOSE 3000
CMD ["npm", "start"]