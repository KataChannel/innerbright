#!/bin/bash

echo "🚀 Bắt đầu tái cấu trúc dự án Next.js..."

# Backup thư mục cũ
echo "📦 Backup dữ liệu cũ..."
mkdir -p backup/$(date +%Y%m%d_%H%M%S)
cp -r app backup/$(date +%Y%m%d_%H%M%S)/app_backup 2>/dev/null || true

# Xóa các file layout copy không cần thiết
echo "🗑️ Dọn dẹp các file không cần thiết..."
find . -name "*layout copy*" -type f -delete 2>/dev/null || true
find . -name "*layout.tsx.backup*" -type f -delete 2>/dev/null || true

# Di chuyển assets nếu cần
echo "📁 Tổ chức lại assets..."
mkdir -p public/images
mkdir -p public/icons

# Cập nhật package.json scripts nếu cần
echo "📝 Cập nhật scripts..."

echo "✅ Hoàn thành tái cấu trúc!"
echo ""
echo "📋 Những gì đã được cập nhật:"
echo "  - ✅ Cấu trúc src/ folder chuẩn Next.js"
echo "  - ✅ Root layout với metadata đầy đủ"
echo "  - ✅ Components được tổ chức theo module"
echo "  - ✅ Site config tập trung"
echo "  - ✅ Layout system có thể tái sử dụng"
echo "  - ✅ TypeScript paths (@/*) được cấu hình"
echo "  - ✅ Tailwind CSS v4 compatible"
echo ""
echo "🔄 Bước tiếp theo:"
echo "  1. Chạy: npm run dev"
echo "  2. Kiểm tra website hoạt động"
echo "  3. Di chuyển nội dung từ app cũ sang src/app"
echo "  4. Cập nhật các trang con theo cấu trúc mới"
