// 📝 Constants và Mock Data cho BlockEditor
import { Post, BlockType } from './types';

// Block Type Icons
export const BLOCK_TYPE_ICONS: Record<BlockType, string> = {
  heading: 'H',
  paragraph: 'P',
  image: 'I',
  quote: 'Q',
  list: 'L',
  code: 'C',
  video: 'V',
  spacer: 'S',
  container: '□',
  columns: 'C',
  column: '|',
  section: 'S',
  card: '□',
  tabs: 'T',
  accordion: 'A'
};

// Default Content for Block Types
export const DEFAULT_BLOCK_CONTENT: Record<BlockType, any> = {
  heading: { text: 'Tiêu đề mới', level: 2 },
  paragraph: { text: 'Nhập nội dung đoạn văn...' },
  image: { src: '', alt: '', caption: '' },
  quote: { text: 'Nhập trích dẫn...', author: '' },
  list: { type: 'ul', items: ['Mục 1', 'Mục 2'] },
  code: { language: 'javascript', code: '// Nhập code...' },
  video: { src: '', title: '' },
  spacer: { height: 'medium' },
  container: { padding: 'medium', backgroundColor: 'transparent' },
  columns: { columnCount: 2, gap: 'medium', distribution: 'equal' },
  column: { width: 'auto' },
  section: { backgroundColor: '#f8fafc', padding: 'large', borderRadius: 'medium' },
  card: { title: '', backgroundColor: '#ffffff', shadow: true, padding: 'medium' },
  tabs: { tabs: [{ id: '1', title: 'Tab 1', content: [] }], activeTab: '1' },
  accordion: { items: [{ id: '1', title: 'Accordion Item', content: [], expanded: false }] }
};

// Container Block Types
export const CONTAINER_BLOCK_TYPES: BlockType[] = [
  'container', 'columns', 'column', 'section', 'card', 'tabs', 'accordion'
];

// Block Categories for Add Menu
export const CONTENT_BLOCKS = [
  { type: 'heading' as BlockType, label: 'Tiêu đề', category: 'content' },
  { type: 'paragraph' as BlockType, label: 'Đoạn văn', category: 'content' },
  { type: 'image' as BlockType, label: 'Hình ảnh', category: 'content' },
  { type: 'quote' as BlockType, label: 'Trích dẫn', category: 'content' },
  { type: 'list' as BlockType, label: 'Danh sách', category: 'content' },
  { type: 'code' as BlockType, label: 'Code', category: 'content' },
  { type: 'video' as BlockType, label: 'Video', category: 'content' },
];

export const LAYOUT_BLOCKS = [
  { type: 'columns' as BlockType, label: 'Cột', category: 'layout' },
  { type: 'section' as BlockType, label: 'Section', category: 'layout' },
  { type: 'card' as BlockType, label: 'Card', category: 'layout' },
  { type: 'container' as BlockType, label: 'Container', category: 'layout' },
];

// Enhanced Mock Data with nested structure
export const mockPost: Post = {
  id: '1',
  title: 'Khám phá sức mạnh của NLP trong phát triển bản thân',
  slug: 'kham-pha-suc-manh-nlp-phat-trien-ban-than',
  author: 'Chloe Quý Châu',
  publishedAt: '2025-01-13',
  tags: ['NLP', 'Phát triển bản thân', 'Coaching'],
  status: 'draft',
  excerpt: 'NLP (Neuro Linguistic Programming) không chỉ là một tập hợp kỹ thuật mà là cách tiếp cận toàn diện...',
  featuredImage: 'https://placehold.co/800x400/4f46e5/ffffff?text=NLP+Featured+Image',
  content: [
    {
      id: '1',
      type: 'heading',
      content: { text: 'Giới thiệu về NLP', level: 1 },
      order: 1
    },
    {
      id: '2',
      type: 'columns',
      content: { 
        columnCount: 2,
        gap: 'medium',
        distribution: 'equal'
      },
      order: 2,
      children: [
        {
          id: '2-1',
          type: 'column',
          content: { width: '50%' },
          order: 1,
          parentId: '2',
          children: [
            {
              id: '2-1-1',
              type: 'paragraph',
              content: { 
                text: 'NLP (Neuro Linguistic Programming) là một phương pháp tâm lý học ứng dụng được phát triển vào những năm 1970.'
              },
              order: 1,
              parentId: '2-1'
            },
            {
              id: '2-1-2',
              type: 'list',
              content: { 
                type: 'ul',
                items: [
                  'Cải thiện kỹ năng giao tiếp',
                  'Quản lý cảm xúc hiệu quả',
                  'Tăng cường tự tin'
                ]
              },
              order: 2,
              parentId: '2-1'
            }
          ]
        },
        {
          id: '2-2',
          type: 'column',
          content: { width: '50%' },
          order: 2,
          parentId: '2',
          children: [
            {
              id: '2-2-1',
              type: 'image',
              content: { 
                src: 'https://placehold.co/400x250/a0c4ff/ffffff?text=NLP+Diagram',
                alt: 'Sơ đồ NLP',
                caption: 'Cách NLP tác động đến não bộ'
              },
              order: 1,
              parentId: '2-2'
            }
          ]
        }
      ]
    },
    {
      id: '3',
      type: 'section',
      content: { 
        backgroundColor: '#f8fafc',
        padding: 'large',
        borderRadius: 'medium'
      },
      order: 3,
      children: [
        {
          id: '3-1',
          type: 'heading',
          content: { text: 'Kỹ thuật NLP cơ bản', level: 2 },
          order: 1,
          parentId: '3'
        },
        {
          id: '3-2',
          type: 'card',
          content: {
            title: 'Anchoring Technique',
            backgroundColor: '#ffffff',
            shadow: true,
            padding: 'medium'
          },
          order: 2,
          parentId: '3',
          children: [
            {
              id: '3-2-1',
              type: 'code',
              content: { 
                language: 'javascript',
                code: `// Ví dụ về Anchoring Technique
const anchorTechnique = {
  step1: "Nhớ lại trạng thái tích cực",
  step2: "Tạo neo (anchor) vật lý",
  step3: "Lặp lại để củng cố",
  step4: "Kích hoạt khi cần thiết"
};`
              },
              order: 1,
              parentId: '3-2'
            }
          ]
        }
      ]
    }
  ]
};
