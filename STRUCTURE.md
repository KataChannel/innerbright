# 📁 Cấu trúc dự án InnerBright - Chuẩn Next.js 15

## 🏗️ Cấu trúc thư mục được tái tổ chức:

```
src/
├── app/                           # App Router (Next.js 15)
│   ├── layout.tsx                 # Root Layout với metadata đầy đủ
│   ├── page.tsx                   # Trang chủ
│   ├── globals.css                # Global styles (Tailwind v4)
│   ├── loading.tsx                # Loading UI
│   ├── error.tsx                  # Error UI
│   ├── not-found.tsx              # 404 Page
│   │
│   ├── about/                     # Trang về chúng tôi
│   │   ├── page.tsx
│   │   └── layout.tsx (optional)
│   │
│   ├── nlp/                       # Trang NLP
│   │   ├── page.tsx
│   │   └── [slug]/
│   │       └── page.tsx
│   │
│   ├── courses/                   # Trang khóa học
│   │   ├── page.tsx
│   │   └── [courseId]/
│   │       └── page.tsx
│   │
│   ├── admin/                     # Admin Dashboard
│   │   ├── layout.tsx
│   │   ├── page.tsx
│   │   └── [...slug]/
│   │       └── page.tsx
│   │
│   └── api/                       # API Routes
│       ├── auth/
│       ├── courses/
│       └── contact/
│
├── components/                    # React Components
│   ├── index.ts                   # Barrel exports
│   │
│   ├── layout/                    # Layout components
│   │   ├── Header.tsx
│   │   ├── Footer.tsx
│   │   ├── SiteLayout.tsx
│   │   └── AdminLayout.tsx
│   │
│   ├── ui/                        # UI Components
│   │   ├── Button.tsx
│   │   ├── Card.tsx
│   │   ├── Modal.tsx
│   │   └── index.ts
│   │
│   ├── forms/                     # Form components
│   │   ├── ContactForm.tsx
│   │   ├── LoginForm.tsx
│   │   └── index.ts
│   │
│   ├── course/                    # Course specific components
│   │   ├── CourseCard.tsx
│   │   ├── CourseList.tsx
│   │   └── index.ts
│   │
│   └── auth/                      # Auth components
│       ├── MaintenanceGuard.tsx
│       ├── LoginForm.tsx
│       └── index.ts
│
├── lib/                          # Utilities & Configurations
│   ├── config/
│   │   ├── site.ts               # Site configuration
│   │   ├── database.ts           # DB config
│   │   └── auth.ts               # Auth config
│   │
│   ├── utils/                    # Utility functions
│   │   ├── cn.ts                 # Tailwind class names
│   │   ├── formatters.ts         # Data formatters
│   │   └── validators.ts         # Validation schemas
│   │
│   ├── hooks/                    # Custom React hooks
│   │   ├── useLocalStorage.ts
│   │   ├── useApi.ts
│   │   └── index.ts
│   │
│   └── types/                    # TypeScript definitions
│       ├── auth.ts
│       ├── course.ts
│       └── index.ts
│
└── styles/                       # Additional styles
    ├── components.css            # Component-specific styles
    └── print.css                 # Print styles

public/                           # Static assets
├── images/
│   ├── logo.png
│   ├── og-image.jpg
│   └── team/
├── icons/
│   ├── favicon.ico
│   └── apple-touch-icon.png
├── manifest.json
└── robots.txt
```

## 🚀 Lợi ích của cấu trúc mới:

### ✅ **Chuẩn Next.js 15:**
- Sử dụng App Router thay vì Pages Router
- Metadata API cho SEO tốt hơn
- Layout system có thể tái sử dụng
- TypeScript first với strict mode

### ✅ **Maintainable & Scalable:**
- Components được tổ chức theo chức năng
- Barrel exports để import dễ dàng
- Separation of concerns rõ ràng
- Type safety với TypeScript

### ✅ **Performance Optimized:**
- Code splitting tự động
- Lazy loading components
- Optimized bundle với Next.js 15
- CSS-in-JS với Tailwind v4

### ✅ **Developer Experience:**
- Hot reloading nhanh hơn
- Better error handling
- Consistent file naming
- Clear folder structure

## 🔧 Quy tắc đặt tên file:

```bash
# Components: PascalCase
Header.tsx
CourseCard.tsx
MaintenanceGuard.tsx

# Pages: lowercase with dashes
about/page.tsx
nlp-training/page.tsx
time-line-therapy/page.tsx

# Utils & Hooks: camelCase
useLocalStorage.ts
formatDate.ts
validateEmail.ts

# Config files: lowercase
site.ts
database.ts
auth.ts
```

## 📦 Import patterns:

```typescript
// ✅ Good - Barrel imports
import { Header, Footer, SiteLayout } from '@/components';
import { Button, Card } from '@/components/ui';
import { siteConfig } from '@/lib/config/site';

// ❌ Avoid - Direct file imports
import Header from '@/components/layout/Header';
import Button from '@/components/ui/Button';
```

## 🎯 Migration Checklist:

- [x] ✅ Root layout với metadata
- [x] ✅ Components structure
- [x] ✅ Site configuration
- [x] ✅ TypeScript paths
- [x] ✅ Tailwind v4 setup
- [ ] 🔄 Migrate existing pages
- [ ] 🔄 Update API routes
- [ ] 🔄 Move assets to public
- [ ] 🔄 Update navigation links
- [ ] 🔄 Test all functionality

## 🚀 Để bắt đầu:

```bash
# 1. Chạy script tái cấu trúc
./restructure.sh

# 2. Install dependencies
npm install

# 3. Start development server
npm run dev

# 4. Build for production
npm run build
```
