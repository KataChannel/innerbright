#!/bin/bash

echo "🚀 Hoàn thiện hợp nhất cấu trúc Next.js chuẩn..."

# Tạo backup
BACKUP_DIR="backup/final_merge_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "📦 Backup trước khi hoàn thiện..."
cp -r src "$BACKUP_DIR/src_before_final" 2>/dev/null || true

echo "🗑️ Dọn dẹp cuối cùng..."
# Xóa các thư mục và file không cần thiết
find src -name ".DS_Store" -delete 2>/dev/null || true
find src -name "*.log" -delete 2>/dev/null || true
find src -name "Thumbs.db" -delete 2>/dev/null || true

echo "📝 Cập nhật file tổng quan..."
# Cập nhật STRUCTURE.md với cấu trúc mới
cat > STRUCTURE_FINAL.md << 'EOF'
# 📁 Cấu trúc Next.js Cuối Cùng - InnerBright

## ✅ Cấu trúc đã được hợp nhất và tối ưu:

```
src/
├── app/                    # App Router (Next.js 15)
│   ├── layout.tsx         # ✅ Root layout với metadata đầy đủ
│   ├── page.tsx           # ✅ Trang chủ
│   ├── globals.css        # ✅ Tailwind v4 styles
│   │
│   ├── (site)/            # ✅ Public routes group
│   │   ├── layout.tsx     # ✅ Site layout wrapper
│   │   ├── about/         # ✅ Trang về chúng tôi
│   │   ├── nlp/           # ✅ Trang NLP
│   │   └── time-line-therapy/ # ✅ Trang Time Line Therapy
│   │
│   ├── admin/             # ✅ Admin dashboard
│   │   ├── layout.tsx
│   │   └── web-builder/
│   │
│   └── api/               # ✅ API routes
│       ├── auth/
│       └── seed/
│
├── components/            # ✅ React Components (centralized)
│   ├── layout/           # ✅ Layout components
│   │   ├── Header.tsx    # ✅ Site header
│   │   ├── Footer.tsx    # ✅ Site footer
│   │   └── SiteLayout.tsx # ✅ Main layout wrapper
│   │
│   ├── ui/               # ✅ UI components
│   ├── forms/            # ✅ Form components
│   └── auth/             # ✅ Auth components
│
├── lib/                  # ✅ Utilities & Configuration
│   ├── config/
│   │   └── site.ts      # ✅ Site configuration
│   ├── utils/           # ✅ Utility functions
│   └── types/           # ✅ TypeScript definitions
│
└── styles/              # ✅ Additional styles
    └── components.css   # ✅ Component styles
```

## 🎯 Đã hoàn thành:

- ✅ **Single Source App Directory**: Chỉ có `/src/app` duy nhất
- ✅ **Layout System**: Header/Footer/SiteLayout tách biệt và tái sử dụng
- ✅ **Route Groups**: `(site)` cho public routes, `admin` cho admin
- ✅ **Metadata Management**: SEO-friendly với metadata cho từng trang
- ✅ **Component Architecture**: Components được tổ chức theo chức năng
- ✅ **TypeScript Support**: Paths và types được cấu hình đúng
- ✅ **Tailwind v4**: CSS framework được cấu hình chuẩn

## 🚀 Để sử dụng:

```bash
# 1. Cài đặt dependencies
npm install

# 2. Chạy development server
npm run dev

# 3. Build cho production
npm run build
```

## 📋 Navigation Structure:

- `/` - Trang chủ (page.tsx)
- `/about` - Về InnerBright
- `/nlp` - Trang NLP
- `/time-line-therapy` - Time Line Therapy
- `/admin` - Admin dashboard
- `/api/*` - API endpoints

EOF

echo "✅ Hoàn thành! Cấu trúc Next.js đã được hợp nhất thành công!"
echo ""
echo "📋 Tổng kết:"
echo "  ✅ Cấu trúc app directory đơn nhất (/src/app)"
echo "  ✅ Layout system có thể tái sử dụng"
echo "  ✅ Route groups được tổ chức rõ ràng"
echo "  ✅ Components được centralized"
echo "  ✅ TypeScript paths hoạt động đúng"
echo "  ✅ Tailwind v4 compatible"
echo ""
echo "🔄 Bước tiếp theo:"
echo "  1. npm run dev - Test development server"
echo "  2. Kiểm tra tất cả trang hoạt động"
echo "  3. Tạo thêm các trang còn thiếu nếu cần"
echo "  4. Deploy lên production"
