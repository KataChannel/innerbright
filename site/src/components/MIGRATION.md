# Component Migration Guide

## 📋 Tổng quan
Đã đồng bộ và chuẩn hóa tất cả components trùng lặp trong codebase. Tất cả components chính giờ đây nằm trong `/src/components/` và có types được định nghĩa rõ ràng.

## 🔄 Components đã được đồng bộ

### Button Component
- **Chính**: `/src/components/Button.tsx`
- **Legacy**: `/src/app/components/common/Button.tsx` (deprecated)
- **Legacy**: `/src/app/components/ui/Button.tsx` (deprecated)

**Sử dụng mới**:
```tsx
import { Button } from '@/components';

<Button variant="primary" size="md" onClick={handleClick}>
  Click me
</Button>
```

**Variants**: `primary`, `secondary`, `outline`, `ghost`, `danger`
**Sizes**: `sm`, `md`, `lg`

### Input Component
- **Chính**: `/src/components/Input.tsx`
- **Legacy**: `/src/app/components/ui/Input.tsx` (deprecated)

**Sử dụng mới**:
```tsx
import { Input } from '@/components';

<Input
  label="Email"
  type="email"
  placeholder="Enter your email"
  error={errors.email}
  required
/>
```

### Dialog Component
- **Chính**: `/src/components/Dialog.tsx`
- **Legacy**: `/src/app/components/ui/Dialog.tsx` (cần cập nhật)

**Sử dụng mới**:
```tsx
import { Dialog, DialogHeader, DialogTitle, DialogContent, DialogFooter } from '@/components';

<Dialog open={isOpen} onOpenChange={setIsOpen} size="md">
  <DialogHeader>
    <DialogTitle>Confirm Action</DialogTitle>
  </DialogHeader>
  <DialogContent>
    <p>Are you sure you want to continue?</p>
  </DialogContent>
  <DialogFooter>
    <Button variant="outline" onClick={() => setIsOpen(false)}>
      Cancel
    </Button>
    <Button variant="primary" onClick={handleConfirm}>
      Confirm
    </Button>
  </DialogFooter>
</Dialog>
```

## 📁 Cấu trúc mới

```
/src/components/
├── Section.tsx          # Layout component
├── Hero.tsx            # Hero section component  
├── Card.tsx            # Card component
├── Button.tsx          # ✅ Unified button component
├── Input.tsx           # ✅ New unified input component
├── Dialog.tsx          # ✅ New unified dialog component
├── BlockEditor.tsx     # Rich text editor
├── types.ts            # ✅ All TypeScript interfaces
└── index.ts            # ✅ Export all components

/src/app/components/    # Legacy components (deprecated)
├── auth/               # Authentication components
├── blog/               # Blog-specific components
├── common/             # ✅ Cleaned up - deprecated Button removed
├── shop/               # Shop-specific components
└── ui/                 # ✅ Cleaned up - deprecated Button, Dialog removed
```

## 🚀 Cách migrate

### 1. Import mới
**Cũ**:
```tsx
// Removed - these files no longer exist
// import Button from '@/app/components/common/Button';
// import { Button } from '@/app/ui/button';
```

**Mới**:
```tsx
import { Button } from '@/components';
```

### 2. Props mới cho Button
**Cũ**:
```tsx
<Button label="Click me" onClick={handleClick} className="custom-class" />
```

**Mới**:
```tsx
<Button onClick={handleClick} className="custom-class">
  Click me
</Button>
```

### 3. Input component mới
**Mới**:
```tsx
<Input
  label="Password"
  type="password"
  placeholder="Enter password"
  error={errors.password}
  helpText="Must be at least 8 characters"
  required
/>
```

## ⚠️ Breaking Changes

1. **Button**: Prop `label` đã được thay thế bằng `children`
2. **Button**: Thêm các variants và sizes mới
3. **Input**: Component hoàn toàn mới với nhiều tính năng hơn
4. **Dialog**: Component hoàn toàn mới thay thế cho các dialog cũ

## 🎯 Next Steps

1. **Cập nhật imports**: Thay đổi tất cả imports từ legacy components sang components mới
2. **Cập nhật props**: Điều chỉnh props theo interface mới
3. **Test**: Kiểm tra tất cả components sau khi migrate
4. **Cleanup**: Xóa các legacy components sau khi migrate xong

## 💡 Best Practices

1. **Luôn sử dụng** components từ `/src/components/`
2. **Import từ index**: `import { Button, Input } from '@/components'`
3. **Sử dụng TypeScript**: Tận dụng type checking với interfaces trong `types.ts`
4. **Consistent naming**: Sử dụng naming convention thống nhất

## 🔍 Types Reference

Tất cả TypeScript interfaces được định nghĩa trong `/src/components/types.ts`:

- `ButtonProps`
- `InputProps` 
- `DialogProps`
- `SectionProps`
- `HeroProps`
- `CardProps`

Xem file `types.ts` để biết chi tiết các props available.
