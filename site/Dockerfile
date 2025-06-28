# Sử dụng Node.js image chính thức
FROM node:22-alpine

# Thiết lập thư mục làm việc
WORKDIR /app

# Sao chép package.json và package-lock.json
COPY package*.json ./

# Cài đặt dependencies
RUN npm install

# Sao chép toàn bộ mã nguồn
COPY . .

# Build ứng dụng Next.js
RUN npm run build

# Expose port 3000
EXPOSE 3000

# Chạy ứng dụng
CMD ["npm", "start"]