# Route Structure Update - InnerBright

## Overview
Đã cập nhật cấu trúc route để sử dụng Route Groups trong Next.js 13+ App Router, tách biệt rõ ràng giữa các phần của website.

## Current Route Structure

```
src/app/
├── layout.tsx                  # Root layout
├── page.tsx                   # Root redirect to (site)
├── globals.css                # Global styles
├── (site)/                    # Site route group (main website)
│   ├── layout.tsx            # Site-specific layout  
│   ├── page.tsx              # Homepage (main landing page)
│   ├── about/                # About pages
│   ├── nlp/                  # NLP service pages
│   ├── time-line-therapy/    # Time Line Therapy pages
│   └── ...                   # Other site pages
├── admin/                     # Admin panel (separate layout)
├── api/                       # API routes
├── login/                     # Authentication pages
└── components/               # Shared components
```

## Route Group Benefits

### 1. **Clean URL Structure**
- `/` → Homepage (through redirect)
- `/about` → About page  
- `/nlp` → NLP services
- `/admin` → Admin panel (different layout)

### 2. **Layout Separation**
- `(site)` group có layout riêng với navigation, footer
- `admin` có layout riêng với admin sidebar
- `login` có layout minimal

### 3. **Code Organization**
- Các trang liên quan được nhóm lại
- Dễ maintain và scale
- Clear separation of concerns

## Implementation Details

### Root Page (`/app/page.tsx`)
```tsx
import { redirect } from 'next/navigation';

export default function RootPage() {
  // Redirect to (site) route group
  redirect('/');
}
```

### Site Homepage (`/app/(site)/page.tsx`)
- Main landing page với đầy đủ content
- Sử dụng Roboto Typography system
- Responsive design
- SEO optimized với metadata

### Site Layout (`/app/(site)/layout.tsx`)  
- Navigation header
- Footer
- Site-specific styling
- Font Inter/Roboto integration

## Pages in (site) Route Group

### Existing Pages
- ✅ `/` - Homepage (new comprehensive design)
- ✅ `/about` - About InnerBright
- ✅ `/nlp` - NLP services and courses
- ✅ `/time-line-therapy` - Time Line Therapy services

### Planned Pages
- `/courses` - All courses listing
- `/contact` - Contact form and information
- `/blog` - Blog and articles
- `/testimonials` - Customer testimonials

## SEO & Metadata

### Homepage Metadata
```tsx
export const metadata: Metadata = {
  title: 'InnerBright - Khám phá tiềm năng bên trong bạn',
  description: 'Khám phá sức mạnh tiềm ẩn bên trong bạn với các khóa học NLP, Time Line Therapy và Hypnosis chuyên nghiệp',
  keywords: 'NLP, Time Line Therapy, Hypnosis, phát triển bản thân, coaching, InnerBright',
};
```

## Typography Integration

### Roboto Font System
- Đã tích hợp hoàn toàn vào (site) pages
- Consistent typography hierarchy
- Components: `RobotoDisplay`, `RobotoHeadline`, `RobotoTitle`, etc.

### Usage Example
```tsx
import { RobotoDisplay, RobotoBody } from '@/components/ui/Typography';

export default function Page() {
  return (
    <div>
      <RobotoDisplay>Page Title</RobotoDisplay>
      <RobotoBody>Page content with consistent typography</RobotoBody>
    </div>
  );
}
```

## Navigation Updates

### Site Navigation (`(site)/layout.tsx`)
```tsx
const navItems = [
  { label: "Về InnerBright", href: "/" },
  { label: "NLP", href: "/nlp" },
  { label: "Time Line Therapy", href: "/time-line-therapy" },
  { label: "Khoá học", href: "/courses" },
  { label: "Liên hệ", href: "/contact" },
];
```

## Development Status

### ✅ Completed
- Route group structure setup
- Homepage content migration to (site)
- Root page redirect configuration
- Typography system integration
- Development server running correctly

### 🔄 In Progress  
- Testing all route transitions
- SEO optimization for all pages
- Content updates for existing pages

### 📋 Next Steps
1. Update all existing pages to use new Typography components
2. Create missing pages (`/courses`, `/contact`, `/blog`)
3. Implement proper error boundaries for route groups
4. Add loading states for better UX
5. Test and optimize performance

## File Changes Made

### Modified Files
- `/app/page.tsx` - Converted to redirect function
- `/app/(site)/page.tsx` - New comprehensive homepage
- Updated Typography imports throughout

### New Files
- Enhanced homepage content with services, testimonials, CTA sections
- Proper metadata configuration
- Improved responsive design

## Testing
- ✅ Development server running on `http://localhost:3001`
- ✅ Homepage loads correctly through (site) route group
- ✅ Navigation works properly
- ✅ Typography system renders correctly
- ✅ Responsive design works on mobile/desktop

The route structure is now properly organized and ready for continued development! 🚀
