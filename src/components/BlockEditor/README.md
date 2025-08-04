# BlockEditor - Rich Text Editor Component

## Tổng quan

BlockEditor là một rich text editor hiện đại được xây dựng với React, hỗ trợ:
- Block-based interface với drag & drop
- Nested blocks và column layouts
- Container blocks (sections, cards, columns)
- Content blocks (headings, paragraphs, images, lists, code, etc.)
- Real-time preview
- Tối ưu hóa performance với hooks tách biệt

## Cấu trúc thư mục

```
BlockEditor/
├── index.tsx                    # Main component
├── types.ts                     # TypeScript types
├── constants.ts                 # Constants và mock data
├── utils.ts                     # Utility functions
├── exports.ts                   # Central export file
├── hooks/
│   ├── useBlockEditor.ts        # Block management logic
│   └── useDragAndDrop.ts        # Drag & drop logic
└── components/
    ├── BlockContent.tsx         # Block content renderers
    ├── AddBlock.tsx             # Add block toolbar và menu
    ├── DraggableBlockRenderer.tsx # Block renderer với drag & drop
    └── PostPreview.tsx          # Preview mode component
```

## Cách sử dụng

### Import cơ bản

```tsx
import BlockEditor from '@/components/BlockEditor';

// Hoặc import với named exports
import { BlockEditor, BlockType, Post } from '@/components/BlockEditor';
```

### Sử dụng component

```tsx
function MyPage() {
  const handleSave = (post: Post) => {
    console.log('Saving post:', post);
    // Logic lưu post
  };

  const handlePreview = (post: Post) => {
    console.log('Previewing post:', post);
    // Logic preview
  };

  return (
    <BlockEditor
      initialPost={myPost}
      onSave={handleSave}
      onPreview={handlePreview}
    />
  );
}
```

### Tùy chỉnh block types

```tsx
import { BlockType, getDefaultContent } from '@/components/BlockEditor';

// Thêm block type mới vào constants.ts
export const CUSTOM_BLOCKS = [
  { type: 'custom' as BlockType, label: 'Custom Block', category: 'content' }
];

// Thêm default content cho block type mới
export const CUSTOM_DEFAULT_CONTENT = {
  custom: { text: 'Custom content...' }
};
```

## API Reference

### Props của BlockEditor

| Prop | Type | Default | Mô tả |
|------|------|---------|--------|
| `initialPost` | `Post` | `mockPost` | Post ban đầu để edit |
| `onSave` | `(post: Post) => void` | - | Callback khi save |
| `onPreview` | `(post: Post) => void` | - | Callback khi preview |

### Các Block Types có sẵn

#### Content Blocks
- `heading` - Tiêu đề (H1, H2, H3)
- `paragraph` - Đoạn văn
- `image` - Hình ảnh với caption
- `quote` - Trích dẫn
- `list` - Danh sách (có/không đánh số)
- `code` - Code block với syntax highlighting
- `video` - Video embed

#### Layout Blocks
- `columns` - Layout cột (1-4 cột)
- `section` - Section với background và padding
- `card` - Card container với shadow
- `container` - Container block cơ bản

### Hooks có sẵn

#### useBlockEditor
Quản lý state và logic của editor:

```tsx
const {
  post,
  setPost,
  activeBlockId,
  setActiveBlockId,
  expandedBlocks,
  setExpandedBlocks,
  addBlock,
  updateBlock,
  deleteBlock,
  moveBlock,
  cloneBlock,
  toggleExpanded
} = useBlockEditor(initialPost);
```

#### useDragAndDrop
Quản lý logic drag & drop:

```tsx
const {
  dragState,
  handleDragStart,
  handleDragEnd,
  handleDragOver,
  handleDragLeave,
  handleDrop
} = useDragAndDrop(post, setPost, setExpandedBlocks);
```

## Tùy chỉnh và mở rộng

### Thêm Block Type mới

1. **Thêm type vào `types.ts`:**
```tsx
export type BlockType = 
  | 'heading' 
  | 'paragraph'
  // ... existing types
  | 'my-custom-block';
```

2. **Thêm default content vào `constants.ts`:**
```tsx
export const DEFAULT_BLOCK_CONTENT: Record<BlockType, any> = {
  // ... existing content
  'my-custom-block': { title: '', description: '' }
};
```

3. **Thêm renderer vào `BlockContent.tsx`:**
```tsx
case 'my-custom-block':
  return (
    <div>
      <input
        value={block.content.title}
        onChange={(e) => onUpdate({ ...block.content, title: e.target.value })}
        placeholder="Tiêu đề..."
      />
      {/* Thêm UI cho block */}
    </div>
  );
```

4. **Thêm preview vào `PostPreview.tsx`:**
```tsx
case 'my-custom-block':
  return (
    <div className="my-custom-block">
      <h4>{block.content.title}</h4>
      <p>{block.content.description}</p>
    </div>
  );
```

### Tùy chỉnh styling

Tất cả styling sử dụng Tailwind CSS. Bạn có thể:
- Override class names trong components
- Thêm custom CSS cho các block types mới
- Sử dụng CSS variables cho theme customization

### Performance Optimization

- Components đã được tối ưu với `useCallback` và `useMemo`
- State management được tách biệt vào hooks
- Drag & drop được optimize để tránh re-render không cần thiết

## Lưu ý phát triển

1. **TypeScript**: Tất cả components đều có strict typing
2. **Modularity**: Logic được tách biệt rõ ràng giữa các file
3. **Extensibility**: Dễ dàng thêm block types và features mới
4. **Testing**: Có thể test từng phần riêng biệt
5. **Performance**: Optimized cho large documents với nhiều blocks

## Troubleshooting

### Lỗi import
- Đảm bảo đường dẫn import đúng
- Check file `exports.ts` có export đầy đủ

### Drag & drop không hoạt động
- Check browser support cho HTML5 drag & drop
- Đảm bảo `draggable` attribute được set

### Performance issues
- Sử dụng React DevTools để check re-renders
- Consider virtualization cho documents lớn
