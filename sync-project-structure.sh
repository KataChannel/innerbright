#!/bin/bash

# 🚀 InnerBright Project Structure Cleanup & Synchronization Script
# Mục đích: Hợp nhất các thư mục app, src/app thành 1 cấu trúc Next.js chuẩn

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Functions
log() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
}

header() {
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${PURPLE}🏗️  $1${NC}"
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Backup function
create_backup() {
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_dir="backup/cleanup_$timestamp"
    
    log "Tạo backup trước khi dọn dẹp..."
    mkdir -p "$backup_dir"
    
    # Backup existing directories
    if [ -d "app" ]; then
        cp -r app "$backup_dir/app_original" 2>/dev/null || true
        success "Backup app/ directory"
    fi
    
    if [ -d "src" ]; then
        cp -r src "$backup_dir/src_original" 2>/dev/null || true
        success "Backup src/ directory"
    fi
    
    if [ -d "components" ]; then
        cp -r components "$backup_dir/components_original" 2>/dev/null || true
        success "Backup components/ directory"
    fi
    
    success "Backup hoàn tất tại: $backup_dir"
}

# Clean duplicate files
clean_duplicates() {
    header "DỌING DẸP CÁC FILE TRÙNG LẶP"
    
    # Remove copy files
    log "Xóa các file copy không cần thiết..."
    find . -name "*copy*.tsx" -type f -delete 2>/dev/null || true
    find . -name "*copy*.ts" -type f -delete 2>/dev/null || true
    find . -name "layout copy*.tsx" -type f -delete 2>/dev/null || true
    
    success "Đã xóa các file copy"
}

# Merge app directories
merge_app_directories() {
    header "HỢP NHẤT CÁC THƯ MỤC APP"
    
    # Create new clean src structure
    log "Tạo cấu trúc src/ mới..."
    mkdir -p src/app
    mkdir -p src/components
    mkdir -p src/lib
    mkdir -p src/styles
    
    # Merge app/ content to src/app/
    if [ -d "app" ]; then
        log "Di chuyển nội dung từ app/ sang src/app/..."
        
        # Copy important files, avoiding duplicates
        for item in app/*; do
            if [ -e "$item" ]; then
                basename_item=$(basename "$item")
                
                # Skip if already exists in src/app
                if [ ! -e "src/app/$basename_item" ]; then
                    cp -r "$item" "src/app/" 2>/dev/null || true
                    log "Đã sao chép: $basename_item"
                else
                    warning "Bỏ qua (đã tồn tại): $basename_item"
                fi
            fi
        done
    fi
    
    # Merge components
    if [ -d "components" ]; then
        log "Di chuyển components..."
        for item in components/*; do
            if [ -e "$item" ]; then
                basename_item=$(basename "$item")
                if [ ! -e "src/components/$basename_item" ]; then
                    cp -r "$item" "src/components/" 2>/dev/null || true
                    log "Đã sao chép component: $basename_item"
                fi
            fi
        done
    fi
    
    success "Hoàn tất hợp nhất app directories"
}

# Fix import paths
fix_import_paths() {
    header "SỬA LỖI IMPORT PATHS"
    
    log "Cập nhật import paths trong src/..."
    
    # Fix imports in TypeScript/JavaScript files
    find src -name "*.tsx" -o -name "*.ts" -o -name "*.jsx" -o -name "*.js" | while read file; do
        if [ -f "$file" ]; then
            # Fix paths
            sed -i 's|@/app/|@/|g' "$file" 2>/dev/null || true
            sed -i 's|from "@/app/lib/|from "@/lib/|g' "$file" 2>/dev/null || true
            sed -i 's|from "@/app/components/|from "@/components/|g' "$file" 2>/dev/null || true
            sed -i 's|from "@/app/styles/|from "@/styles/|g' "$file" 2>/dev/null || true
        fi
    done
    
    success "Đã cập nhật import paths"
}

# Create proper layout structure
create_layout_structure() {
    header "TẠO CẤU TRÚC LAYOUT CHUẨN"
    
    # Ensure root layout exists and is correct
    if [ ! -f "src/app/layout.tsx" ]; then
        log "Tạo root layout..."
        cat > src/app/layout.tsx << 'EOF'
import type { Metadata } from 'next';
import { Inter } from 'next/font/google';
import './globals.css';

// Components
import { MaintenanceGuard } from '@/components/auth/MaintenanceGuard';

// Config
import { siteConfig } from '@/lib/config/site';

const inter = Inter({ subsets: ['latin', 'vietnamese'] });

export const metadata: Metadata = {
  title: {
    default: siteConfig.title,
    template: `%s | ${siteConfig.title}`,
  },
  description: siteConfig.description,
  keywords: siteConfig.keywords,
  authors: [{ name: siteConfig.author }],
  creator: siteConfig.author,
  metadataBase: new URL(siteConfig.url),
  openGraph: {
    type: 'website',
    locale: 'vi_VN',
    url: siteConfig.url,
    title: siteConfig.title,
    description: siteConfig.description,
    siteName: siteConfig.title,
  },
  twitter: {
    card: 'summary_large_image',
    title: siteConfig.title,
    description: siteConfig.description,
  },
  robots: {
    index: true,
    follow: true,
    googleBot: {
      index: true,
      follow: true,
      'max-video-preview': -1,
      'max-image-preview': 'large',
      'max-snippet': -1,
    },
  },
  manifest: '/manifest.json',
  themeColor: '#000000',
  appleWebApp: {
    capable: true,
    statusBarStyle: 'default',
    title: siteConfig.title,
  },
  icons: {
    apple: '/icon-192x192.png',
    icon: '/favicon.ico',
  },
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="vi" className="scroll-smooth">
      <body className={`${inter.className} antialiased`}>
        <MaintenanceGuard>
          <div id="root">{children}</div>
        </MaintenanceGuard>
      </body>
    </html>
  );
}
EOF
        success "Đã tạo root layout"
    fi
    
    # Create home page
    if [ ! -f "src/app/page.tsx" ]; then
        log "Tạo trang chủ..."
        cat > src/app/page.tsx << 'EOF'
import { SiteLayout } from '@/components/layout/SiteLayout';
import { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'Trang chủ',
  description: 'InnerBright Training & Coaching - Khai phóng tiềm năng và phát huy tối đa nội lực',
};

export default function HomePage() {
  return (
    <SiteLayout>
      <div className="container mx-auto px-4 py-16">
        {/* Hero Section */}
        <section className="text-center mb-16">
          <h1 className="text-4xl md:text-6xl font-bold text-gray-900 mb-6">
            Khai Phóng <span className="text-blue-600">Tiềm Năng</span> Của Bạn
          </h1>
          <p className="text-xl text-gray-600 mb-8 max-w-3xl mx-auto">
            InnerBright Training & Coaching đồng hành cùng bạn trên hành trình 
            phát triển bản thân thông qua NLP và Time Line Therapy
          </p>
          <div className="space-x-4">
            <button className="bg-blue-600 hover:bg-blue-700 text-white px-8 py-3 rounded-lg font-semibold transition-colors">
              Khám phá khóa học
            </button>
            <button className="border border-blue-600 text-blue-600 hover:bg-blue-50 px-8 py-3 rounded-lg font-semibold transition-colors">
              Liên hệ tư vấn
            </button>
          </div>
        </section>
      </div>
    </SiteLayout>
  );
}
EOF
        success "Đã tạo trang chủ"
    fi
}

# Remove old directories
cleanup_old_directories() {
    header "DỌN DẸP CÁC THƯ MỤC CŨ"
    
    log "Xóa các thư mục không cần thiết..."
    
    # Remove old app directory (keep backup)
    if [ -d "app" ] && [ -d "src/app" ]; then
        warning "Xóa thư mục app/ cũ (đã backup)..."
        rm -rf app 2>/dev/null || true
    fi
    
    # Remove old components directory (keep backup)
    if [ -d "components" ] && [ -d "src/components" ]; then
        warning "Xóa thư mục components/ cũ (đã backup)..."
        rm -rf components 2>/dev/null || true
    fi
    
    # Remove site directory if exists (this seems to be a separate project)
    if [ -d "site" ]; then
        warning "Phát hiện thư mục 'site/' - có vẻ là dự án riêng biệt"
        echo -e "${CYAN}Bạn có muốn xóa thư mục 'site/'? (y/N): ${NC}"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            mv site "backup/cleanup_$(date +%Y%m%d_%H%M%S)/site_moved" 2>/dev/null || true
            success "Đã di chuyển thư mục site/ vào backup"
        else
            warning "Giữ nguyên thư mục site/"
        fi
    fi
    
    success "Hoàn tất dọn dẹp"
}

# Validate final structure
validate_structure() {
    header "KIỂM TRA CẤU TRÚC CUỐI CÙNG"
    
    log "Kiểm tra cấu trúc dự án..."
    
    local valid=true
    
    # Check essential files
    if [ ! -f "src/app/layout.tsx" ]; then
        error "Thiếu src/app/layout.tsx"
        valid=false
    fi
    
    if [ ! -f "src/app/page.tsx" ]; then
        error "Thiếu src/app/page.tsx"
        valid=false
    fi
    
    if [ ! -f "src/app/globals.css" ]; then
        warning "Thiếu src/app/globals.css"
    fi
    
    if [ ! -f "tsconfig.json" ]; then
        error "Thiếu tsconfig.json"
        valid=false
    fi
    
    if [ ! -f "package.json" ]; then
        error "Thiếu package.json"
        valid=false
    fi
    
    if [ "$valid" = true ]; then
        success "Cấu trúc dự án hợp lệ!"
    else
        error "Cấu trúc dự án có vấn đề, vui lòng kiểm tra lại"
        return 1
    fi
}

# Update tsconfig paths
update_tsconfig() {
    header "CẬP NHẬT TSCONFIG.JSON"
    
    if [ -f "tsconfig.json" ]; then
        log "Cập nhật paths trong tsconfig.json..."
        
        # Backup tsconfig
        cp tsconfig.json tsconfig.json.backup
        
        # Update paths to point to src
        sed -i 's|"@/\*": \["./\*"\]|"@/*": ["./src/*"]|g' tsconfig.json 2>/dev/null || true
        
        success "Đã cập nhật tsconfig.json"
    else
        warning "Không tìm thấy tsconfig.json"
    fi
}

# Display final structure
show_final_structure() {
    header "CẤU TRÚC DỰ ÁN CUỐI CÙNG"
    
    echo -e "${CYAN}📁 Cấu trúc Next.js chuẩn:${NC}"
    echo ""
    echo "src/"
    echo "├── app/                    # App Router (Next.js 13+)"
    echo "│   ├── layout.tsx          # Root layout"
    echo "│   ├── page.tsx            # Home page" 
    echo "│   ├── globals.css         # Global styles"
    echo "│   ├── loading.tsx         # Loading UI"
    echo "│   ├── error.tsx           # Error UI"
    echo "│   ├── not-found.tsx       # 404 page"
    echo "│   │"
    echo "│   ├── about/              # About page"
    echo "│   ├── nlp/                # NLP page"
    echo "│   ├── courses/            # Courses page"
    echo "│   ├── admin/              # Admin dashboard"
    echo "│   └── api/                # API routes"
    echo "│"
    echo "├── components/             # React Components"
    echo "│   ├── layout/             # Layout components"
    echo "│   ├── ui/                 # UI components"
    echo "│   ├── forms/              # Form components"
    echo "│   └── auth/               # Auth components"
    echo "│"
    echo "├── lib/                    # Utilities & Configs"
    echo "│   ├── config/             # Configuration files"
    echo "│   ├── utils/              # Utility functions"
    echo "│   ├── hooks/              # Custom hooks"
    echo "│   └── types/              # TypeScript types"
    echo "│"
    echo "└── styles/                 # Additional styles"
    echo ""
    echo "public/                     # Static assets"
    echo "package.json                # Dependencies"
    echo "tsconfig.json               # TypeScript config"
    echo "next.config.ts              # Next.js config"
    echo ""
}

# Main execution
main() {
    header "INNERBRIGHT PROJECT CLEANUP & SYNC"
    
    echo -e "${CYAN}Tự động hợp nhất và đồng bộ cấu trúc dự án Next.js${NC}"
    echo -e "${YELLOW}⚠️  Script này sẽ thực hiện thay đổi lớn. Backup sẽ được tạo tự động.${NC}"
    echo ""
    echo -e "${CYAN}Bạn có muốn tiếp tục? (y/N): ${NC}"
    read -r confirm
    
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        warning "Hủy bỏ thao tác"
        exit 0
    fi
    
    # Execute steps
    create_backup
    clean_duplicates
    merge_app_directories
    fix_import_paths
    create_layout_structure
    update_tsconfig
    cleanup_old_directories
    validate_structure
    show_final_structure
    
    header "HOÀN THÀNH"
    
    success "Đã hợp nhất và đồng bộ cấu trúc dự án thành công!"
    echo ""
    echo -e "${CYAN}🎯 Bước tiếp theo:${NC}"
    echo "  1. Chạy: npm install"
    echo "  2. Kiểm tra: npm run dev"
    echo "  3. Kiểm tra các trang hoạt động"
    echo "  4. Cập nhật các import paths nếu cần"
    echo ""
    echo -e "${GREEN}🎉 Cấu trúc dự án Next.js đã được chuẩn hóa!${NC}"
}

# Run main function
main "$@"
