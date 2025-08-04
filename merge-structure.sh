#!/bin/bash

echo "🔄 Bắt đầu hợp nhất và đồng bộ cấu trúc Next.js..."

# Tạo backup với timestamp
BACKUP_DIR="backup/merge_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "📦 Backup cấu trúc hiện tại..."
cp -r src "$BACKUP_DIR/src_backup" 2>/dev/null || true

echo "🗑️ Dọn dẹp các file trùng lặp..."
# Xóa các layout copy không cần thiết
find src/app -name "*layout copy*" -type f -delete 2>/dev/null || true
find src/app -name "*layout.tsx.backup*" -type f -delete 2>/dev/null || true
find src/app -name "*page copy*" -type f -delete 2>/dev/null || true

echo "🔧 Tối ưu cấu trúc components..."
# Đảm bảo components có cấu trúc đúng
mkdir -p src/components/{layout,ui,forms,auth}
mkdir -p src/app/{(site),admin,api}

echo "📝 Cập nhật imports..."
# Sẽ được thực hiện trong script tiếp theo

echo "✅ Hoàn thành merge cơ bản!"

echo "📋 Cấu trúc sau khi merge:"
echo "src/"
echo "├── app/                    # App Router (Next.js 15)"
echo "│   ├── layout.tsx         # Root layout"
echo "│   ├── page.tsx           # Homepage"
echo "│   ├── globals.css        # Global styles"
echo "│   ├── (site)/            # Public routes"
echo "│   ├── admin/             # Admin routes"
echo "│   └── api/               # API routes"
echo "├── components/            # React components"
echo "│   ├── layout/            # Layout components"
echo "│   ├── ui/                # UI components"
echo "│   └── forms/             # Form components"
echo "├── lib/                   # Utilities & config"
echo "└── styles/                # Additional styles"
echo ""
echo "🔄 Bước tiếp theo: Chạy 'npm run dev' để kiểm tra"
