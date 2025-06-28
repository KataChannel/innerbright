# Giai đoạn build
FROM node:18-alpine as builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Giai đoạn production
FROM node:18-alpine
WORKDIR /app
# Chỉ copy những file cần thiết cho chạy ứng dụng
COPY package*.json ./
RUN npm install --only=production
COPY --from=builder /app/dist ./dist

EXPOSE 3333
CMD ["node", "dist/main.js"]