// 📝 Web Builder Utilities
import { PageBlockData, PageBlockType, BlockStyles, PageData } from './types';

// Generate unique ID
export const generateUniqueId = (): string => {
  return `block_${Date.now()}_${Math.random().toString(36).substring(2, 9)}`;
};

// Get default content for block types
export const getDefaultBlockContent = (type: PageBlockType): any => {
  switch (type) {
    case 'hero':
      return {
        title: 'Tiêu đề Hero',
        subtitle: 'Phụ đề',
        description: 'Mô tả ngắn gọn về nội dung',
        buttonText: 'Liên hệ',
        buttonLink: '#contact',
        backgroundImage: '',
        overlayOpacity: 0.5,
        alignment: 'center'
      };

    case 'about-section':
      return {
        title: 'Giới thiệu',
        description: 'Mô tả về dịch vụ hoặc cá nhân',
        image: '',
        features: [],
        layout: 'image-right'
      };

    case 'services-grid':
      return {
        title: 'Dịch vụ của chúng tôi',
        description: 'Các dịch vụ chuyên nghiệp',
        services: []
      };

    case 'testimonials':
      return {
        testimonials: [],
        layout: 'grid'
      };

    case 'contact-form':
      return {
        title: 'Liên hệ với chúng tôi',
        description: 'Gửi thông tin để được tư vấn',
        fields: [
          { id: '1', type: 'text', label: 'Họ tên', placeholder: 'Nhập họ tên', required: true },
          { id: '2', type: 'email', label: 'Email', placeholder: 'Nhập email', required: true },
          { id: '3', type: 'phone', label: 'Số điện thoại', placeholder: 'Nhập số điện thoại', required: false },
          { id: '4', type: 'textarea', label: 'Tin nhắn', placeholder: 'Nhập tin nhắn', required: true }
        ],
        buttonText: 'Gửi tin nhắn',
        successMessage: 'Cảm ơn bạn đã liên hệ! Chúng tôi sẽ phản hồi sớm.'
      };

    case 'team-members':
      return {
        title: 'Đội ngũ của chúng tôi',
        description: 'Gặp gỡ các chuyên gia',
        members: []
      };

    case 'pricing-table':
      return {
        title: 'Bảng giá dịch vụ',
        description: 'Chọn gói phù hợp với bạn',
        plans: []
      };

    case 'faq-section':
      return {
        title: 'Câu hỏi thường gặp',
        description: 'Tìm câu trả lời cho thắc mắc của bạn',
        faqs: []
      };

    case 'timeline':
      return {
        title: 'Lịch sử phát triển',
        items: [],
        layout: 'vertical'
      };

    case 'process-steps':
      return {
        title: 'Quy trình làm việc',
        description: 'Các bước thực hiện',
        steps: []
      };

    case 'feature-cards':
      return {
        title: 'Tính năng nổi bật',
        description: 'Những điểm mạnh của chúng tôi',
        cards: []
      };

    case 'call-to-action':
      return {
        title: 'Bắt đầu ngay hôm nay',
        description: 'Liên hệ để được tư vấn miễn phí',
        buttonText: 'Liên hệ ngay',
        buttonLink: '#contact',
        backgroundImage: ''
      };

    case 'blog-posts':
      return {
        title: 'Bài viết mới nhất',
        description: 'Cập nhật kiến thức từ blog',
        posts: [],
        layout: 'grid'
      };

    case 'gallery':
      return {
        title: 'Thư viện ảnh',
        description: 'Hình ảnh hoạt động',
        images: [],
        layout: 'masonry'
      };

    case 'video-section':
      return {
        title: 'Video giới thiệu',
        description: 'Tìm hiểu thêm qua video',
        videoUrl: '',
        thumbnail: '',
        autoplay: false
      };

    case 'stats-counter':
      return {
        title: 'Thành tựu đạt được',
        stats: []
      };

    case 'newsletter-signup':
      return {
        title: 'Đăng ký nhận tin',
        description: 'Nhận thông tin mới nhất từ chúng tôi',
        buttonText: 'Đăng ký',
        successMessage: 'Cảm ơn bạn đã đăng ký!'
      };

    case 'social-proof':
      return {
        title: 'Khách hàng tin tưởng',
        description: 'Được sự tin tưởng từ',
        logos: []
      };

    case 'section':
      return {
        backgroundColor: '#ffffff',
        padding: 'medium'
      };

    case 'container':
      return {
        maxWidth: '1200px',
        centered: true
      };

    case 'columns':
      return {
        columnCount: 2,
        gap: 'medium'
      };

    case 'spacer':
      return {
        height: 50
      };

    case 'divider':
      return {
        style: 'solid',
        color: '#e5e7eb',
        thickness: 1
      };

    case 'heading':
      return {
        text: 'Tiêu đề mới',
        level: 2,
        alignment: 'left'
      };

    case 'paragraph':
      return {
        text: 'Đây là đoạn văn bản mới. Nhấp để chỉnh sửa nội dung.',
        alignment: 'left'
      };

    case 'image':
      return {
        src: 'https://placehold.co/600x400/f3f4f6/6b7280?text=Image',
        alt: 'Hình ảnh',
        caption: '',
        alignment: 'center'
      };

    case 'button':
      return {
        text: 'Nút bấm',
        link: '#',
        style: 'primary',
        size: 'medium'
      };

    case 'icon':
      return {
        icon: '⭐',
        size: 'medium',
        color: '#3b82f6'
      };

    case 'list':
      return {
        type: 'ul',
        items: ['Mục thứ nhất', 'Mục thứ hai', 'Mục thứ ba']
      };

    // Specialized Blocks
    case 'therapy-timeline':
      return {
        title: 'Quy Trình Time-line Therapy®',
        description: 'Hành trình chữa lành cảm xúc theo từng giai đoạn',
        items: [
          {
            id: '1',
            phase: 'Giai đoạn 1',
            title: 'Đánh giá và xác định vấn đề',
            description: 'Tìm hiểu và xác định những cảm xúc tiêu cực cần được giải phóng',
            duration: '1-2 buổi',
            techniques: ['Phỏng vấn sâu', 'Timeline mapping', 'Emotional assessment'],
            outcomes: ['Xác định được vấn đề cốt lõi', 'Hiểu rõ nguồn gốc cảm xúc tiêu cực']
          },
          {
            id: '2',
            phase: 'Giai đoạn 2',
            title: 'Giải phóng cảm xúc tiêu cực',
            description: 'Sử dụng kỹ thuật Time-line để loại bỏ những cảm xúc không mong muốn',
            duration: '2-3 buổi',
            techniques: ['Timeline release', 'Anchoring', 'Reframing'],
            outcomes: ['Giải phóng cảm xúc tiêu cực', 'Cảm thấy nhẹ nhõm và tự do hơn']
          }
        ]
      };

    case 'nlp-benefits':
      return {
        title: 'Lợi Ích Của NLP',
        description: 'Khám phá những thay đổi tích cực mà NLP mang lại',
        benefits: [
          {
            id: '1',
            category: 'Cá nhân',
            title: 'Tăng cường tự tin',
            description: 'Xây dựng niềm tin vào bản thân và khả năng của mình',
            icon: '💪',
            techniques: ['Anchoring', 'State management', 'Reframing'],
            examples: ['Vượt qua nỗi sợ nói trước đám đông', 'Tự tin trong các cuộc phỏng vấn']
          },
          {
            id: '2',
            category: 'Giao tiếp',
            title: 'Cải thiện kỹ năng giao tiếp',
            description: 'Giao tiếp hiệu quả và tạo ảnh hưởng tích cực',
            icon: '💬',
            techniques: ['Mirroring', 'Rapport building', 'Language patterns'],
            examples: ['Thuyết phục khách hàng', 'Xây dựng mối quan hệ tốt']
          }
        ]
      };

    case 'professional-journey':
      return {
        title: 'Hành Trình Chuyên Môn',
        description: 'Những cột mốc quan trọng trong sự nghiệp',
        milestones: [
          {
            id: '1',
            year: '2010',
            title: 'Bắt đầu hành trình',
            description: 'Khởi đầu con đường nghiên cứu và ứng dụng NLP',
            category: 'Học tập',
            achievements: ['Hoàn thành khóa học NLP Practitioner', 'Bắt đầu thực hành'],
            image: 'https://placehold.co/300x200/4f46e5/ffffff?text=Journey+Start'
          }
        ]
      };

    case 'success-stories':
      return {
        title: 'Câu Chuyện Thành Công',
        description: 'Những thay đổi tích cực từ khách hàng',
        stories: [
          {
            id: '1',
            name: 'Nguyễn Minh Anh',
            role: 'Giám đốc kinh doanh',
            company: 'ABC Corp',
            challenge: 'Khó khăn trong giao tiếp và lãnh đạo đội nhóm',
            solution: 'Áp dụng kỹ thuật NLP trong quản lý và giao tiếp',
            results: ['Tăng 40% hiệu suất đội nhóm', 'Cải thiện mối quan hệ với khách hàng'],
            image: 'https://placehold.co/300x300/4f46e5/ffffff?text=Success',
            beforeAfter: {
              before: 'Thường xuyên căng thẳng và mất phương hướng',
              after: 'Tự tin, rõ ràng trong việc đưa ra quyết định'
            },
            testimonial: 'NLP đã thay đổi hoàn toàn cách tôi làm việc và sống'
          }
        ]
      };

    case 'certification-showcase':
      return {
        title: 'Chứng Chỉ & Bằng Cấp',
        description: 'Các chứng nhận chuyên môn quốc tế',
        certifications: [
          {
            id: '1',
            name: 'Master Trainer NLP',
            organization: 'Time Line Therapy® Association',
            year: '2015',
            level: 'Master',
            image: 'https://placehold.co/200x150/4f46e5/ffffff?text=Certificate',
            description: 'Chứng nhận Master Trainer về NLP và Time-line Therapy®',
            skills: ['NLP Training', 'Timeline Therapy', 'Coaching']
          }
        ]
      };

    case 'therapy-process':
      return {
        title: 'Quy Trình Trị Liệu',
        description: 'Các bước trong quá trình Time-line Therapy®',
        phases: [
          {
            id: '1',
            name: 'Consultation',
            duration: '60 phút',
            description: 'Tư vấn và đánh giá ban đầu',
            steps: ['Lắng nghe và hiểu vấn đề', 'Đánh giá tình trạng hiện tại', 'Đề xuất phương án'],
            techniques: ['Active listening', 'Assessment tools', 'Goal setting'],
            outcomes: ['Hiểu rõ vấn đề', 'Xây dựng mục tiêu', 'Lập kế hoạch trị liệu'],
            icon: '🎯'
          }
        ]
      };

    case 'nlp-techniques':
      return {
        title: 'Kỹ Thuật NLP',
        description: 'Các kỹ thuật NLP hiệu quả được áp dụng',
        categories: [
          {
            id: '1',
            name: 'Cơ bản',
            techniques: [
              {
                id: '1',
                name: 'Anchoring',
                description: 'Liên kết trạng thái cảm xúc tích cực với một kích hoạt cụ thể',
                applications: ['Tăng cường tự tin', 'Quản lý căng thẳng', 'Cải thiện hiệu suất'],
                difficulty: 'Beginner',
                duration: '2-3 buổi học'
              }
            ]
          }
        ]
      };

    case 'coaching-programs':
      return {
        title: 'Chương Trình Coaching',
        description: 'Các gói coaching và đào tạo chuyên nghiệp',
        programs: [
          {
            id: '1',
            name: 'NLP Practitioner',
            type: 'Group',
            duration: '7 ngày',
            price: '15,000,000 VNĐ',
            description: 'Khóa học cơ bản về NLP cho người mới bắt đầu',
            modules: ['Foundations of NLP', 'Communication Skills', 'Basic Techniques'],
            benefits: ['Chứng chỉ quốc tế', 'Tài liệu học tập', 'Hỗ trợ sau khóa học'],
            requirements: ['Không yêu cầu kinh nghiệm', 'Độ tuổi từ 18+'],
            schedule: 'Cuối tuần trong 4 tuần',
            featured: true
          }
        ]
      };

    default:
      return {};
  }
};

// Insert block into tree structure
export const insertBlockIntoTree = (
  blocks: PageBlockData[],
  newBlock: PageBlockData,
  afterId?: string,
  parentId?: string
): PageBlockData[] => {
  if (parentId) {
    // Insert into specific parent
    return blocks.map(block => {
      if (block.id === parentId) {
        return {
          ...block,
          children: [...(block.children || []), newBlock].sort((a, b) => a.order - b.order)
        };
      }
      if (block.children) {
        return {
          ...block,
          children: insertBlockIntoTree(block.children, newBlock, afterId, parentId)
        };
      }
      return block;
    });
  }

  if (afterId) {
    // Insert after specific block
    const index = blocks.findIndex(block => block.id === afterId);
    if (index !== -1) {
      const newBlocks = [...blocks];
      newBlocks.splice(index + 1, 0, newBlock);
      return newBlocks;
    }
  }

  // Insert at end
  return [...blocks, newBlock].sort((a, b) => a.order - b.order);
};

// Update block in tree structure
export const updateBlockInTree = (
  blocks: PageBlockData[],
  id: string,
  updates: Partial<PageBlockData>
): PageBlockData[] => {
  return blocks.map(block => {
    if (block.id === id) {
      return { ...block, ...updates };
    }
    if (block.children) {
      return {
        ...block,
        children: updateBlockInTree(block.children, id, updates)
      };
    }
    return block;
  });
};

// Remove block from tree structure
export const removeBlockFromTree = (
  blocks: PageBlockData[],
  id: string
): PageBlockData[] => {
  return blocks.filter(block => {
    if (block.id === id) {
      return false;
    }
    if (block.children) {
      block.children = removeBlockFromTree(block.children, id);
    }
    return true;
  });
};

// Find block by ID in tree structure
export const findBlockInTree = (
  blocks: PageBlockData[],
  id: string
): PageBlockData | null => {
  for (const block of blocks) {
    if (block.id === id) {
      return block;
    }
    if (block.children) {
      const found = findBlockInTree(block.children, id);
      if (found) return found;
    }
  }
  return null;
};

// Get block depth in tree
export const getBlockDepth = (
  blocks: PageBlockData[],
  id: string,
  depth = 0
): number => {
  for (const block of blocks) {
    if (block.id === id) {
      return depth;
    }
    if (block.children) {
      const childDepth = getBlockDepth(block.children, id, depth + 1);
      if (childDepth !== -1) return childDepth;
    }
  }
  return -1;
};

// Check if block type is container
export const isContainerBlock = (type: PageBlockType): boolean => {
  return [
    'section',
    'container',
    'columns',
    'hero',
    'about-section',
    'services-grid',
    'feature-cards'
  ].includes(type);
};

// Get block icon for UI
export const getBlockIcon = (type: PageBlockType): string => {
  const icons: Record<PageBlockType, string> = {
    hero: '🎯',
    'about-section': '👋',
    'services-grid': '⚡',
    testimonials: '💬',
    'contact-form': '📝',
    'team-members': '👥',
    'pricing-table': '💰',
    'faq-section': '❓',
    timeline: '📅',
    'process-steps': '🔄',
    'feature-cards': '⭐',
    'call-to-action': '📢',
    'blog-posts': '📰',
    gallery: '🖼️',
    'video-section': '🎥',
    'stats-counter': '📊',
    'newsletter-signup': '📧',
    'social-proof': '🏆',
    // Specialized blocks
    'therapy-timeline': '⏰',
    'nlp-benefits': '🧠',
    'professional-journey': '🎓',
    'success-stories': '🌟',
    'certification-showcase': '🏅',
    'therapy-process': '🔄',
    'nlp-techniques': '🛠️',
    'coaching-programs': '📚',
    // Layout blocks
    section: '📦',
    container: '📋',
    columns: '📱',
    spacer: '📏',
    divider: '➖',
    heading: '📝',
    paragraph: '📄',
    image: '🖼️',
    button: '🔘',
    icon: '⭐',
    list: '📋'
  };
  
  return icons[type] || '📄';
};

// Get responsive breakpoints
export const getResponsiveBreakpoints = () => {
  return {
    mobile: '(max-width: 768px)',
    tablet: '(min-width: 769px) and (max-width: 1024px)',
    desktop: '(min-width: 1025px)'
  };
};

// Convert styles to CSS
export const stylesToCSS = (styles: BlockStyles): React.CSSProperties => {
  const css: React.CSSProperties = {};

  if (styles.backgroundColor) css.backgroundColor = styles.backgroundColor;
  if (styles.textColor) css.color = styles.textColor;
  if (styles.borderRadius) css.borderRadius = `${styles.borderRadius}px`;
  if (styles.boxShadow) css.boxShadow = styles.boxShadow;
  if (styles.backgroundImage) {
    css.backgroundImage = `url(${styles.backgroundImage})`;
    css.backgroundSize = styles.backgroundSize || 'cover';
    css.backgroundPosition = styles.backgroundPosition || 'center';
  }

  if (styles.padding) {
    css.paddingTop = `${styles.padding.top}px`;
    css.paddingRight = `${styles.padding.right}px`;
    css.paddingBottom = `${styles.padding.bottom}px`;
    css.paddingLeft = `${styles.padding.left}px`;
  }

  if (styles.margin) {
    css.marginTop = `${styles.margin.top}px`;
    css.marginRight = `${styles.margin.right}px`;
    css.marginBottom = `${styles.margin.bottom}px`;
    css.marginLeft = `${styles.margin.left}px`;
  }

  if (styles.borderWidth && styles.borderColor && styles.borderStyle) {
    css.border = `${styles.borderWidth}px ${styles.borderStyle} ${styles.borderColor}`;
  }

  return css;
};

// Validate block content
export const validateBlockContent = (type: PageBlockType, content: any): boolean => {
  switch (type) {
    case 'hero':
      return !!(content.title && content.description);
    case 'contact-form':
      return !!(content.title && content.fields && content.fields.length > 0);
    case 'testimonials':
      return !!(content.testimonials && content.testimonials.length > 0);
    default:
      return true;
  }
};

// Export block data for backup
export const exportPageData = (page: PageData): string => {
  return JSON.stringify(page, null, 2);
};

// Import block data from backup
export const importPageData = (jsonString: string): PageData | null => {
  try {
    const data = JSON.parse(jsonString);
    // Basic validation
    if (data.id && data.title && data.content && Array.isArray(data.content)) {
      return data as PageData;
    }
    return null;
  } catch (error) {
    console.error('Error importing page data:', error);
    return null;
  }
};
