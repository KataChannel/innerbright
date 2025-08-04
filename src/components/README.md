# 📚 Hướng dẫn sử dụng Components

Hệ thống components được thiết kế để tái sử dụng và duy trì tính nhất quán trong toàn bộ ứng dụng.

## 🚀 Import Components

```tsx
// Import từng component
import Section from '@/components/Section';
import Hero from '@/components/Hero';
import Card from '@/components/Card';

// Hoặc import tất cả
import { Section, Hero, Card } from '@/components';
```

## 📦 Section Component

### Mô tả
Component wrapper chung cho các phần của trang, cung cấp styling nhất quán.

### Props

| Prop | Type | Default | Mô tả |
|------|------|---------|-------|
| `children` | `ReactNode` | - | Nội dung bên trong section |
| `className` | `string` | `''` | CSS classes tùy chỉnh |
| `backgroundColor` | `'white' \| 'gray' \| 'dark' \| 'transparent'` | `'white'` | Màu nền |
| `padding` | `'none' \| 'small' \| 'medium' \| 'large'` | `'large'` | Khoảng cách padding |
| `margin` | `'none' \| 'small' \| 'medium' \| 'large'` | `'medium'` | Khoảng cách margin bottom |
| `shadow` | `boolean` | `true` | Hiển thị shadow |
| `rounded` | `boolean` | `true` | Bo góc |
| `id` | `string` | - | ID cho section |

### Ví dụ sử dụng

```tsx
// Section cơ bản
<Section>
  <h2>Tiêu đề</h2>
  <p>Nội dung...</p>
</Section>

// Section với background tối
<Section backgroundColor="dark" className="text-white">
  <h2>Tiêu đề trắng</h2>
</Section>

// Section không padding và shadow
<Section padding="none" shadow={false}>
  <img src="/banner.jpg" alt="Banner" />
</Section>

// Section với ID để anchor link
<Section id="about-us" backgroundColor="gray">
  <h2>Về chúng tôi</h2>
</Section>
```

### Background Colors
- `white`: Nền trắng (default)
- `gray`: Nền xám nhạt (`bg-gray-100`)
- `dark`: Nền tối (`bg-[#1A2A44]`)
- `transparent`: Trong suốt

### Padding Sizes
- `none`: Không padding
- `small`: `p-4` (16px)
- `medium`: `p-6` (24px)
- `large`: `p-8` (32px)

### Margin Sizes
- `none`: Không margin
- `small`: `mb-4` (16px)
- `medium`: `mb-6` (24px)
- `large`: `mb-8` (32px)

## 🎨 Hero Component

### Mô tả
Component cho hero sections với background image và overlay.

### Props

| Prop | Type | Default | Mô tả |
|------|------|---------|-------|
| `title` | `ReactNode` | - | Tiêu đề chính (có thể là JSX) |
| `subtitle` | `ReactNode` | - | Tiêu đề phụ |
| `description` | `string` | - | Mô tả |
| `imageSrc` | `string` | - | URL của background image |
| `imageAlt` | `string` | - | Alt text cho image |
| `gradientOverlay` | `boolean` | `true` | Hiển thị gradient overlay |
| `height` | `'small' \| 'medium' \| 'large'` | `'large'` | Chiều cao |
| `textPosition` | `'left' \| 'center' \| 'right'` | `'left'` | Vị trí text |
| `textColor` | `'white' \| 'black'` | `'white'` | Màu text |
| `className` | `string` | `''` | CSS classes tùy chỉnh |

### Ví dụ sử dụng

```tsx
// Hero đơn giản
<Hero
  title="Chào mừng đến với InnerBright"
  description="Khai phóng tiềm năng nội tại của bạn"
  imageSrc="/hero-bg.jpg"
  imageAlt="Hero background"
/>

// Hero với JSX title phức tạp
<Hero
  title={
    <>
      <span>CÂU CHUYỆN</span>{' '}
      <span className="text-blue-400">Về InnerBright</span>
    </>
  }
  subtitle="Training & Coaching"
  description="Được thành lập từ năm 2020"
  imageSrc="/about-hero.jpg"
  imageAlt="About us"
  height="medium"
/>

// Hero căn giữa
<Hero
  title="Liên hệ với chúng tôi"
  description="Hãy bắt đầu hành trình của bạn ngay hôm nay"
  imageSrc="/contact-bg.jpg"
  imageAlt="Contact"
  textPosition="center"
  height="small"
/>

// Hero không overlay
<Hero
  title="Gallery"
  imageSrc="/gallery-bg.jpg"
  imageAlt="Gallery"
  gradientOverlay={false}
  textColor="black"
/>
```

### Height Sizes
- `small`: `h-48 lg:h-56` (~192px/224px)
- `medium`: `h-64 lg:h-72` (~256px/288px)
- `large`: `h-80 lg:h-96` (~320px/384px)

## 🃏 Card Component

### Mô tả
Component card linh hoạt cho hiển thị nội dung với hoặc không có hình ảnh.

### Props

| Prop | Type | Default | Mô tả |
|------|------|---------|-------|
| `title` | `ReactNode` | - | Tiêu đề card |
| `content` | `ReactNode` | - | Nội dung card |
| `imageSrc` | `string` | - | URL hình ảnh |
| `imageAlt` | `string` | - | Alt text cho hình ảnh |
| `imagePosition` | `'top' \| 'left' \| 'right' \| 'background'` | `'top'` | Vị trí hình ảnh |
| `overlay` | `boolean` | `false` | Overlay cho background image |
| `gradientOverlay` | `boolean` | `true` | Gradient overlay |
| `className` | `string` | `''` | CSS classes tùy chỉnh |

### Ví dụ sử dụng

```tsx
// Card với image ở trên
<Card
  title="Sứ mệnh"
  content="Tạo dựng cuộc sống thịnh vượng hơn cho người Việt Nam"
  imageSrc="/mission.jpg"
  imageAlt="Mission"
/>

// Card với background image
<Card
  title="Tầm nhìn"
  content="Trang bị tư duy phát triển bản thân đúng đắn"
  imageSrc="/vision-bg.jpg"
  imageAlt="Vision"
  imagePosition="background"
  overlay={true}
  className="text-white"
/>

// Card layout ngang
<Card
  title="Về chúng tôi"
  content={
    <div>
      <p>Đoạn mô tả dài...</p>
      <ul>
        <li>Điểm 1</li>
        <li>Điểm 2</li>
      </ul>
    </div>
  }
  imageSrc="/team.jpg"
  imageAlt="Team"
  imagePosition="left"
/>

// Card không có hình ảnh
<Card
  title="Thông tin liên hệ"
  content={
    <div>
      <p>Email: info@innerbright.vn</p>
      <p>Phone: +84 123 456 789</p>
    </div>
  }
/>
```

## 🎯 Best Practices

### 1. Consistency (Tính nhất quán)
```tsx
// ✅ Tốt - sử dụng design system
<Section backgroundColor="white" padding="large">
  <h2 className="text-3xl font-bold text-blue-700 mb-8">Tiêu đề</h2>
</Section>

// ❌ Tránh - hardcode styles
<section className="bg-white p-8 mb-8 rounded-xl shadow-lg">
  <h2 style={{fontSize: '24px', color: '#1e40af'}}>Tiêu đề</h2>
</section>
```

### 2. Responsive Design
```tsx
// ✅ Tốt - responsive height
<Hero
  title="Mobile-friendly Hero"
  imageSrc="/hero.jpg"
  imageAlt="Hero"
  height="medium" // Tự động responsive
/>

// ✅ Tốt - responsive text trong content
<Card
  title="Responsive Card"
  content={
    <p className="text-sm md:text-base lg:text-lg">
      Text tự động resize theo màn hình
    </p>
  }
/>
```

### 3. Accessibility
```tsx
// ✅ Tốt - có alt text và semantic HTML
<Hero
  title="Accessible Hero"
  imageSrc="/hero.jpg"
  imageAlt="Detailed description of the hero image"
/>

<Section id="main-content">
  <h2>Tiêu đề có thể link được</h2>
</Section>
```

### 4. Performance
```tsx
// ✅ Tốt - lazy loading images
<Card
  imageSrc="/large-image.jpg"
  imageAlt="Description"
  className="lazy-load"
/>

// ✅ Tốt - optimize image sizes
<Hero
  imageSrc="/hero-optimized.webp" // Sử dụng WebP
  imageAlt="Optimized hero image"
/>
```

## 🔧 Customization

### Extending Components
```tsx
// Tạo variant mới
const PrimarySection = ({ children, ...props }) => (
  <Section 
    backgroundColor="white" 
    padding="large"
    className="border-l-4 border-blue-600"
    {...props}
  >
    {children}
  </Section>
);

// Sử dụng
<PrimarySection>
  <h2>Section có border trái</h2>
</PrimarySection>
```

### Theme Integration
```tsx
// Kết hợp với Tailwind theme
<Section className="bg-gradient-to-r from-purple-400 to-pink-400">
  <Hero
    title="Gradient Background"
    textColor="white"
    gradientOverlay={false}
  />
</Section>
```

## 🐛 Troubleshooting

### Common Issues

1. **Image không hiển thị**
   ```tsx
   // Kiểm tra đường dẫn image
   <Hero imageSrc="/images/hero.jpg" /> // ✅ Đường dẫn từ public/
   ```

2. **Text không đọc được trên background**
   ```tsx
   // Sử dụng overlay
   <Hero gradientOverlay={true} textColor="white" />
   ```

3. **Layout bị vỡ trên mobile**
   ```tsx
   // Sử dụng responsive classes
   <Section className="px-4 md:px-8">
   ```

## 📱 Responsive Breakpoints

Components tự động responsive với Tailwind breakpoints:
- `sm`: 640px
- `md`: 768px  
- `lg`: 1024px
- `xl`: 1280px
- `2xl`: 1536px

## 🎨 Color Palette

Sử dụng color palette của InnerBright:
- Primary Blue: `text-blue-700`, `bg-blue-600`
- Dark: `bg-[#1A2A44]`
- Gray: `bg-gray-100`, `text-gray-700`
- White: `bg-white`, `text-white`

---

*Cập nhật lần cuối: 13/07/2025*
