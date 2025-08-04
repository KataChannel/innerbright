# 🚀 Enhanced Web Builder cho Time-line Therapy, NLP & About Pages

## Tổng quan

Hệ thống Web Builder được nâng cấp đặc biệt để tạo các trang dynamic chuyên nghiệp cho:
- **Time-line Therapy®**: Trang dịch vụ trị liệu timeline
- **NLP**: Trang dịch vụ Neuro Linguistic Programming  
- **About**: Trang giới thiệu cá nhân và chuyên môn

## 🎯 Tính năng chính

### Specialized Block Types

#### Time-line Therapy® Blocks
- **`therapy-timeline`**: Quy trình Time-line Therapy® với các giai đoạn chi tiết
- **`therapy-process`**: Visualization các bước trong quá trình trị liệu
- **`success-stories`**: Câu chuyện thành công từ khách hàng
- **`certification-showcase`**: Trưng bày chứng chỉ và bằng cấp

#### NLP Blocks  
- **`nlp-benefits`**: Lợi ích NLP được phân loại theo lĩnh vực
- **`nlp-techniques`**: Kỹ thuật NLP được sắp xếp theo độ khó
- **`coaching-programs`**: Các chương trình đào tạo và coaching
- **`success-stories`**: Case studies với before/after

#### About Page Blocks
- **`professional-journey`**: Timeline hành trình chuyên môn  
- **`certification-showcase`**: Showcase chứng chỉ và thành tựu
- **`success-stories`**: Testimonials và câu chuyện thành công

### Enhanced Features

- ✅ **Drag & Drop Interface**: Giao diện kéo thả trực quan
- ✅ **Real-time Preview**: Xem trước thời gian thực
- ✅ **Responsive Design**: Tự động responsive trên mọi thiết bị
- ✅ **SEO Optimization**: Tối ưu SEO tích hợp
- ✅ **Template Library**: Thư viện template phong phú
- ✅ **Export/Import**: Xuất/nhập trang dễ dàng
- ✅ **Context-aware Blocks**: Blocks thông minh theo ngữ cảnh
- ✅ **Advanced Editing**: Chỉnh sửa inline và modal

## 📁 Cấu trúc thư mục

```
site/src/components/WebBuilder/
├── types.ts                           # TypeScript definitions
├── utils.ts                          # Utility functions  
├── templates.ts                      # Page templates
├── hooks/
│   └── useWebBuilder.ts              # Main hook logic
├── components/
│   ├── EnhancedBlockEditor.tsx       # Enhanced block editor
│   ├── SpecializedBlocks.tsx         # Specialized blocks
│   ├── EnhancedBlockContentRenderer.tsx # Enhanced renderer
│   ├── PageManager.tsx               # Page management
│   ├── BlockLibrary.tsx              # Block library
│   └── PagePreview.tsx               # Preview component
└── index.tsx                         # Main WebBuilder component
```

## 🚀 Cách sử dụng

### 1. Truy cập Admin Panel

```
/admin/web-builder
```

### 2. Chọn loại trang

Chọn một trong 3 loại trang:
- **Time-line Therapy®** (⏰)
- **NLP** (🧠)  
- **About** (👋)

### 3. Tạo trang mới

1. Click "Tạo trang mới"
2. Sử dụng Enhanced Block Editor
3. Chọn blocks từ sidebar
4. Tùy chỉnh nội dung inline
5. Preview và lưu

### 4. Quản lý trang

- Xem danh sách trang đã tạo
- Edit/Delete/Duplicate pages
- Publish/Unpublish
- Export/Import JSON

## 🎨 Specialized Blocks Usage

### Therapy Timeline Block

```tsx
// Sử dụng trong Time-line Therapy pages
<TherapyTimelineBlock
  content={{
    title: "Quy Trình Time-line Therapy®",
    description: "Hành trình chữa lành cảm xúc",
    items: [
      {
        id: "1",
        phase: "Giai đoạn 1", 
        title: "Đánh giá và xác định vấn đề",
        description: "Tìm hiểu những cảm xúc tiêu cực...",
        duration: "1-2 buổi",
        techniques: ["Phỏng vấn sâu", "Timeline mapping"],
        outcomes: ["Xác định vấn đề cốt lõi"]
      }
    ]
  }}
  isEditMode={true}
  onUpdate={updateContent}
/>
```

### NLP Benefits Block

```tsx
// Sử dụng trong NLP pages
<NLPBenefitsBlock
  content={{
    title: "Lợi Ích Của NLP",
    description: "Khám phá những thay đổi tích cực",
    benefits: [
      {
        id: "1",
        category: "Cá nhân",
        title: "Tăng cường tự tin",
        description: "Xây dựng niềm tin...",
        icon: "💪",
        techniques: ["Anchoring", "State management"],
        examples: ["Vượt qua nỗi sợ nói trước đám đông"]
      }
    ]
  }}
  isEditMode={true}
  onUpdate={updateContent}
/>
```

### Professional Journey Block

```tsx
// Sử dụng trong About pages  
<ProfessionalJourneyBlock
  content={{
    title: "Hành Trình Chuyên Môn",
    description: "Những cột mốc quan trọng",
    milestones: [
      {
        id: "1",
        year: "2010",
        title: "Bắt đầu hành trình",
        description: "Khởi đầu con đường nghiên cứu NLP",
        category: "Học tập",
        achievements: ["Hoàn thành NLP Practitioner"],
        image: "https://example.com/image.jpg"
      }
    ]
  }}
  isEditMode={true}
  onUpdate={updateContent}
/>
```

## 🔧 Technical Details

### TypeScript Support

Tất cả components được viết với TypeScript strict mode:

```typescript
// Specialized content types
interface TherapyTimelineContent {
  title: string;
  description: string;
  items: Array<{
    id: string;
    phase: string;
    title: string;
    description: string;
    duration: string;
    techniques: string[];
    outcomes: string[];
  }>;
}
```

### Responsive Design

Blocks tự động responsive với breakpoints:
- Mobile: `max-width: 768px`
- Tablet: `769px - 1024px`  
- Desktop: `min-width: 1025px`

### SEO Optimization

Mỗi page có settings SEO:
- Meta title/description
- Open Graph tags
- Twitter Card
- Structured data

## 📱 Page Templates

### Time-line Therapy Template

```javascript
{
  id: 'timeline-therapy-landing',
  name: 'Time-line Therapy Landing',
  description: 'Trang landing cho dịch vụ Time-line Therapy',
  pageType: 'time-line-therapy',
  blocks: [
    { type: 'hero', ... },
    { type: 'therapy-timeline', ... },
    { type: 'testimonials', ... },
    { type: 'contact-form', ... }
  ]
}
```

### NLP Template

```javascript
{
  id: 'nlp-landing',
  name: 'NLP Landing Page', 
  description: 'Trang landing chuyên nghiệp cho dịch vụ NLP',
  pageType: 'nlp',
  blocks: [
    { type: 'hero', ... },
    { type: 'nlp-benefits', ... },
    { type: 'coaching-programs', ... },
    { type: 'success-stories', ... }
  ]
}
```

## 🎯 Best Practices

### Content Strategy

1. **Time-line Therapy Pages**:
   - Bắt đầu với Hero giải thích về phương pháp
   - Sử dụng Therapy Timeline để mô tả quy trình
   - Thêm Success Stories để tăng uy tín
   - Kết thúc với Contact Form

2. **NLP Pages**:
   - Hero với value proposition rõ ràng
   - NLP Benefits theo từng lĩnh vực cụ thể
   - Coaching Programs với pricing
   - Social proof với testimonials

3. **About Pages**:
   - Hero cá nhân với ảnh chất lượng cao
   - Professional Journey timeline
   - Certification Showcase
   - Contact information

### Performance

- Sử dụng lazy loading cho images
- Optimize bundle size với dynamic imports
- Cache page data trong localStorage
- Minify CSS và JavaScript

## 🐛 Troubleshooting

### Common Issues

1. **Block không render**:
   - Kiểm tra type trong PageBlockType
   - Đảm bảo content structure đúng
   - Check console for errors

2. **Styling issues**:
   - Verify Tailwind classes
   - Check responsive breakpoints
   - Inspect CSS conflicts

3. **Save/Load problems**:
   - Clear localStorage
   - Check JSON structure
   - Validate required fields

## 🔄 Development Workflow

1. **Thêm block type mới**:
   ```typescript
   // 1. Thêm vào PageBlockType union
   export type PageBlockType = 
     | 'existing-types'
     | 'new-block-type';
   
   // 2. Thêm content interface
   export interface NewBlockContent {
     title: string;
     // other fields...
   }
   
   // 3. Thêm default content
   case 'new-block-type':
     return { title: 'Default title' };
   
   // 4. Thêm icon
   'new-block-type': '🆕'
   
   // 5. Tạo component
   export const NewBlockComponent: React.FC = ({ ... }) => {
     return <div>New Block</div>;
   }
   ```

2. **Test workflow**:
   - Unit tests cho utility functions
   - Integration tests cho components
   - E2E tests cho user workflows

## 📞 Support

Nếu gặp vấn đề hoặc cần hỗ trợ:
- Tạo issue trên GitHub
- Check documentation trong code
- Review existing templates và examples

---

**🎉 Happy Building! Tạo những trang web tuyệt vời cho Time-line Therapy®, NLP và About pages!**
