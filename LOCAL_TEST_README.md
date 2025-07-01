# KataCore Local Testing Guide

## Quick Start

Để test KataCore trên localhost một cách nhanh chóng:

### 1. Chuẩn bị
```bash
# Đảm bảo Docker đang chạy
docker --version
docker compose --version
```

### 2. Deploy nhanh (khuyến nghị)
```bash
# Deploy đơn giản nhất
./local-test.sh

# Deploy với logs
./local-test.sh --logs

# Clean deploy (xóa data cũ)
./local-test.sh --clean
```

### 3. Deploy với nhiều options hơn
```bash
# Deploy với nhiều tùy chọn
./test-local.sh --dev --logs

# Clean deploy với rebuild
./test-local.sh --clean --rebuild --logs
```

## Access URLs

Sau khi deploy thành công, bạn có thể truy cập:

- **Frontend**: http://localhost:3000
- **API**: http://localhost:3001
- **API Health**: http://localhost:3001/health
- **PgAdmin**: http://localhost:8080
- **MinIO Console**: http://localhost:9001

## Default Credentials

- **PgAdmin**: admin@localhost.com / local_pgladmin_pass_123
- **MinIO**: katacore_minio_admin / local_minio_pass_123

## Useful Commands

```bash
# Xem logs tất cả services
docker compose -f docker-compose.test.yml logs -f

# Xem logs một service cụ thể
docker compose -f docker-compose.test.yml logs -f api
docker compose -f docker-compose.test.yml logs -f site

# Stop tất cả services
docker compose -f docker-compose.test.yml down

# Stop và xóa volumes
docker compose -f docker-compose.test.yml down -v

# Restart một service
docker compose -f docker-compose.test.yml restart api
```

## Troubleshooting

### Lỗi port đã được sử dụng
```bash
# Kiểm tra port nào đang được sử dụng
netstat -tulpn | grep :3000
netstat -tulpn | grep :3001

# Stop containers cũ
docker compose -f docker-compose.test.yml down
```

### Lỗi Docker không có quyền
```bash
# Thêm user vào group docker
sudo usermod -aG docker $USER
# Logout và login lại
```

### Services không khởi động được
```bash
# Xem logs để debug
docker compose -f docker-compose.test.yml logs
```

## Files quan trọng

- `.env.local` - Environment variables cho local testing
- `docker-compose.test.yml` - Docker compose cho testing
- `local-test.sh` - Script deploy đơn giản
- `test-local.sh` - Script deploy với nhiều options

## Development Mode

Để chạy ở chế độ development với hot reload:

```bash
./test-local.sh --dev
```

## Production-like Testing

Để test giống production environment:

```bash
./test-local.sh --prod
```
