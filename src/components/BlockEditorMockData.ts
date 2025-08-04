// 📊 Mock Data cho Block Editor
import { Post, BlockData } from './BlockEditor';

export const mockPosts: Post[] = [
  {
    id: '1',
    title: 'Khám phá sức mạnh của NLP trong phát triển bản thân',
    slug: 'kham-pha-suc-manh-nlp-phat-trien-ban-than',
    author: 'Chloe Quý Châu',
    publishedAt: '2025-01-13',
    tags: ['NLP', 'Phát triển bản thân', 'Coaching'],
    status: 'published',
    excerpt: 'NLP (Neuro Linguistic Programming) không chỉ là một tập hợp kỹ thuật mà là cách tiếp cận toàn diện để hiểu và thay đổi bản thân.',
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
        type: 'paragraph',
        content: { 
          text: 'NLP (Neuro Linguistic Programming) là một phương pháp tâm lý học ứng dụng được phát triển vào những năm 1970 bởi Richard Bandler và John Grinder. Đây là một tập hợp các kỹ thuật và nguyên tắc giúp hiểu cách thức hoạt động của tâm trí con người và cách chúng ta có thể tối ưu hóa hiệu suất cá nhân.'
        },
        order: 2
      },
      {
        id: '3',
        type: 'image',
        content: { 
          src: 'https://placehold.co/600x300/a0c4ff/ffffff?text=NLP+Brain+Diagram',
          alt: 'Sơ đồ hoạt động của não bộ trong NLP',
          caption: 'Cách NLP tác động đến não bộ và hành vi con người'
        },
        order: 3
      },
      {
        id: '4',
        type: 'heading',
        content: { text: 'Những lợi ích thiết thực của NLP', level: 2 },
        order: 4
      },
      {
        id: '5',
        type: 'list',
        content: { 
          type: 'ul',
          items: [
            'Cải thiện kỹ năng giao tiếp và thuyết phục',
            'Quản lý cảm xúc hiệu quả trong mọi tình huống',
            'Tăng cường tự tin và lòng tin vào bản thân',
            'Phát triển tư duy tích cực và mindset thành công',
            'Đạt được mục tiêu nhanh chóng và bền vững',
            'Xây dựng mối quan hệ tốt đẹp với người khác'
          ]
        },
        order: 5
      },
      {
        id: '6',
        type: 'quote',
        content: { 
          text: 'NLP không chỉ là một công cụ, mà là cách tiếp cận toàn diện để hiểu và thay đổi bản thân một cách tích cực. Nó giúp chúng ta mở khóa tiềm năng bên trong và tạo ra những thay đổi lâu dài.',
          author: 'Richard Bandler - Nhà sáng lập NLP'
        },
        order: 6
      },
      {
        id: '7',
        type: 'heading',
        content: { text: 'Kỹ thuật NLP cơ bản: Anchoring', level: 2 },
        order: 7
      },
      {
        id: '8',
        type: 'paragraph',
        content: { 
          text: 'Anchoring là một trong những kỹ thuật NLP mạnh mẽ nhất, giúp bạn tạo ra những trạng thái cảm xúc tích cực bất cứ khi nào cần thiết. Kỹ thuật này dựa trên nguyên tắc liên kết những cảm xúc tích cực với một hành động vật lý cụ thể.'
        },
        order: 8
      },
      {
        id: '9',
        type: 'list',
        content: { 
          type: 'ol',
          items: [
            'Nhớ lại một khoảnh khắc bạn cảm thấy rất tự tin và mạnh mẽ',
            'Khi cảm xúc đó đạt đỉnh điểm, thực hiện một hành động vật lý (như nắm tay, chạm vào vai)',
            'Lặp lại quá trình này 3-5 lần để củng cố liên kết',
            'Khi cần tự tin, kích hoạt anchor bằng cách thực hiện lại hành động đó'
          ]
        },
        order: 9
      }
    ]
  },
  {
    id: '2',
    title: 'Time Line Therapy: Hành trình chữa lành quá khứ',
    slug: 'time-line-therapy-hanh-trinh-chua-lanh-qua-khu',
    author: 'Chloe Quý Châu',
    publishedAt: '2025-01-10',
    tags: ['Time Line Therapy', 'Chữa lành', 'Tâm lý'],
    status: 'published',
    excerpt: 'Time Line Therapy® là phương pháp độc đáo giúp giải phóng cảm xúc tiêu cực từ quá khứ và tạo ra tương lai tích cực.',
    featuredImage: 'https://placehold.co/800x400/6b46c1/ffffff?text=Time+Line+Therapy',
    content: [
      {
        id: '10',
        type: 'heading',
        content: { text: 'Time Line Therapy® là gì?', level: 1 },
        order: 1
      },
      {
        id: '11',
        type: 'paragraph',
        content: { 
          text: 'Time Line Therapy® được phát triển bởi Tiến sĩ Tad James, là một phương pháp trị liệu độc đáo giúp con người giải phóng những cảm xúc tiêu cực và niềm tin giới hạn từ quá khứ. Phương pháp này dựa trên cách thức tâm trí con người lưu trữ và tổ chức ký ức theo dòng thời gian.'
        },
        order: 2
      },
      {
        id: '12',
        type: 'image',
        content: { 
          src: 'https://placehold.co/600x300/6b46c1/ffffff?text=Timeline+Visualization',
          alt: 'Hình ảnh minh họa dòng thời gian trong tâm trí',
          caption: 'Cách tâm trí tổ chức ký ức theo dòng thời gian'
        },
        order: 3
      },
      {
        id: '13',
        type: 'heading',
        content: { text: 'Ứng dụng của Time Line Therapy®', level: 2 },
        order: 4
      },
      {
        id: '14',
        type: 'list',
        content: { 
          type: 'ul',
          items: [
            'Giải phóng cảm xúc tiêu cực như tức giận, buồn bã, sợ hãi',
            'Loại bỏ niềm tin giới hạn và tự ti',
            'Chữa lành những tổn thương từ quá khứ',
            'Tạo ra mục tiêu rõ ràng cho tương lai',
            'Cải thiện các mối quan hệ cá nhân'
          ]
        },
        order: 5
      },
      {
        id: '15',
        type: 'quote',
        content: { 
          text: 'Quá khứ không thể thay đổi, nhưng cách chúng ta cảm nhận về quá khứ thì hoàn toàn có thể thay đổi. Time Line Therapy® giúp chúng ta làm điều đó.',
          author: 'Tiến sĩ Tad James'
        },
        order: 6
      }
    ]
  },
  {
    id: '3',
    title: '5 bước để bắt đầu hành trình coaching bản thân',
    slug: '5-buoc-bat-dau-hanh-trinh-coaching-ban-than',
    author: 'Chloe Quý Châu',
    publishedAt: '2025-01-08',
    tags: ['Coaching', 'Phát triển bản thân', 'Hướng dẫn'],
    status: 'draft',
    excerpt: 'Coaching bản thân là một kỹ năng quan trọng giúp bạn tự định hướng và phát triển. Hãy bắt đầu với 5 bước đơn giản này.',
    featuredImage: 'https://placehold.co/800x400/10b981/ffffff?text=Self+Coaching',
    content: [
      {
        id: '16',
        type: 'heading',
        content: { text: 'Tại sao cần coaching bản thân?', level: 1 },
        order: 1
      },
      {
        id: '17',
        type: 'paragraph',
        content: { 
          text: 'Trong cuộc sống hiện đại, việc có một coach cá nhân không phải lúc nào cũng khả thi. Tuy nhiên, việc học cách coaching bản thân sẽ giúp bạn luôn có thể tự định hướng, giải quyết vấn đề và phát triển bản thân một cách hiệu quả.'
        },
        order: 2
      },
      {
        id: '18',
        type: 'heading',
        content: { text: 'Bước 1: Xác định mục tiêu rõ ràng', level: 2 },
        order: 3
      },
      {
        id: '19',
        type: 'paragraph',
        content: { 
          text: 'Mục tiêu SMART (Specific, Measurable, Achievable, Relevant, Time-bound) là nền tảng của mọi quá trình coaching hiệu quả.'
        },
        order: 4
      },
      {
        id: '20',
        type: 'code',
        content: { 
          language: 'markdown',
          code: `## Template đặt mục tiêu SMART

**Cụ thể (Specific):** Tôi muốn...
**Đo lường được (Measurable):** Tôi sẽ biết mình thành công khi...
**Có thể đạt được (Achievable):** Tôi có thể làm điều này bằng cách...
**Phù hợp (Relevant):** Điều này quan trọng vì...
**Có thời hạn (Time-bound):** Tôi sẽ hoàn thành vào...`
        },
        order: 5
      }
    ]
  }
];

export const mockBlockTemplates: { [key: string]: BlockData[] } = {
  'intro-template': [
    {
      id: 'intro-1',
      type: 'heading',
      content: { text: 'Giới thiệu chủ đề', level: 1 },
      order: 1
    },
    {
      id: 'intro-2',
      type: 'paragraph',
      content: { text: 'Mở đầu hấp dẫn về chủ đề bạn muốn chia sẻ...' },
      order: 2
    },
    {
      id: 'intro-3',
      type: 'list',
      content: { 
        type: 'ul',
        items: [
          'Điểm chính thứ nhất',
          'Điểm chính thứ hai', 
          'Điểm chính thứ ba'
        ]
      },
      order: 3
    }
  ],
  'how-to-template': [
    {
      id: 'how-1',
      type: 'heading',
      content: { text: 'Hướng dẫn từng bước', level: 1 },
      order: 1
    },
    {
      id: 'how-2',
      type: 'heading',
      content: { text: 'Bước 1: Chuẩn bị', level: 2 },
      order: 2
    },
    {
      id: 'how-3',
      type: 'paragraph',
      content: { text: 'Mô tả chi tiết bước đầu tiên...' },
      order: 3
    },
    {
      id: 'how-4',
      type: 'heading',
      content: { text: 'Bước 2: Thực hiện', level: 2 },
      order: 4
    },
    {
      id: 'how-5',
      type: 'paragraph',
      content: { text: 'Mô tả chi tiết bước thứ hai...' },
      order: 5
    }
  ],
  'case-study-template': [
    {
      id: 'case-1',
      type: 'heading',
      content: { text: 'Case Study: [Tên case study]', level: 1 },
      order: 1
    },
    {
      id: 'case-2',
      type: 'heading',
      content: { text: 'Bối cảnh', level: 2 },
      order: 2
    },
    {
      id: 'case-3',
      type: 'paragraph',
      content: { text: 'Mô tả tình huống và bối cảnh...' },
      order: 3
    },
    {
      id: 'case-4',
      type: 'heading',
      content: { text: 'Thách thức', level: 2 },
      order: 4
    },
    {
      id: 'case-5',
      type: 'paragraph',
      content: { text: 'Những khó khăn và thách thức gặp phải...' },
      order: 5
    },
    {
      id: 'case-6',
      type: 'heading',
      content: { text: 'Giải pháp', level: 2 },
      order: 6
    },
    {
      id: 'case-7',
      type: 'paragraph',
      content: { text: 'Cách giải quyết vấn đề...' },
      order: 7
    },
    {
      id: 'case-8',
      type: 'heading',
      content: { text: 'Kết quả', level: 2 },
      order: 8
    },
    {
      id: 'case-9',
      type: 'paragraph',
      content: { text: 'Những kết quả đạt được...' },
      order: 9
    }
  ]
};

export const mockTags = [
  'NLP',
  'Time Line Therapy',
  'Coaching',
  'Phát triển bản thân',
  'Tâm lý học',
  'Giao tiếp',
  'Lãnh đạo',
  'Mindset',
  'Kỹ năng mềm',
  'Tự tin',
  'Mục tiêu',
  'Thành công'
];

export const mockAuthors = [
  'Chloe Quý Châu',
  'InnerBright Team',
  'Guest Author'
];

export default {
  mockPosts,
  mockBlockTemplates,
  mockTags,
  mockAuthors
};
