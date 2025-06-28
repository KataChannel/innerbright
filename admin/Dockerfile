# Build stage: cài đặt dependencies và build ứng dụng Angular
FROM node:18-alpine AS build

WORKDIR /app
# Chỉ copy package.json và package-lock.json để tận dụng cache cho việc cài đặt npm
COPY package*.json ./
RUN npm ci
# Copy phần còn lại của source code
COPY . .
RUN npm run build --prod

# Deploy stage: sử dụng Nginx để serve các file build ra từ Angular
FROM nginx:alpine

# Copy file build từ stage build sang folder mặc định của nginx
COPY --from=build /app/dist/your-angular-app /usr/share/nginx/html
# Sử dụng file cấu hình nginx tùy chỉnh nếu cần
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]