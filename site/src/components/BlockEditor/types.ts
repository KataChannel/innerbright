// 📝 Types cho BlockEditor
export interface BlockData {
  id: string;
  type: BlockType;
  content: any;
  order: number;
  parentId?: string; // For nested blocks
  children?: BlockData[]; // For container blocks
}

export type BlockType = 
  | 'heading' 
  | 'paragraph' 
  | 'image' 
  | 'quote' 
  | 'list' 
  | 'code' 
  | 'video'
  | 'spacer'
  | 'container'
  | 'columns'
  | 'column'
  | 'section'
  | 'card'
  | 'tabs'
  | 'accordion';

export interface Post {
  id: string;
  title: string;
  slug: string;
  content: BlockData[];
  author: string;
  publishedAt: string;
  tags: string[];
  status: 'draft' | 'published';
  excerpt: string;
  featuredImage?: string;
}

// Drag & Drop Types
export interface DragState {
  isDragging: boolean;
  draggedBlockId: string | null;
  dropTargetId: string | null;
  dropPosition: 'before' | 'after' | 'inside' | null;
  dragOverlay: boolean;
}

// Component Props Types
export interface BlockEditorProps {
  initialPost?: Post;
  onSave?: (post: Post) => void;
  onPreview?: (post: Post) => void;
}

export interface DraggableBlockRendererProps {
  block: BlockData;
  isActive: boolean;
  isExpanded: boolean;
  isDragging: boolean;
  isDropTarget: boolean;
  dropPosition: 'before' | 'after' | 'inside' | null;
  onActivate: () => void;
  onUpdate: (content: any) => void;
  onDelete: () => void;
  onMove: (id: string, direction: 'up' | 'down' | 'left' | 'right', targetParentId?: string) => void;
  onClone: () => void;
  onAddAfter: (type: BlockType, parentId?: string) => void;
  onToggleExpanded: () => void;
  onDragStart: (e: React.DragEvent) => void;
  onDragEnd: () => void;
  onDragOver: (e: React.DragEvent, targetId: string, position: 'before' | 'after' | 'inside') => void;
  onDragLeave: (e: React.DragEvent) => void;
  onDrop: (e: React.DragEvent, targetId: string, position: 'before' | 'after' | 'inside') => void;
  level: number;
}

export interface BlockContentProps {
  block: BlockData;
  onUpdate: (content: any) => void;
}

export interface AddBlockToolbarProps {
  onAdd: (type: BlockType) => void;
}

export interface AddBlockMenuProps {
  onAdd: (type: BlockType) => void;
  showContainers?: boolean;
}

export interface PostPreviewProps {
  post: Post;
  onEditMode: () => void;
}
