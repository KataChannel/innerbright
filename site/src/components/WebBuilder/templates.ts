// 📝 Web Builder Templates cho NLP, Time-line Therapy và About
import { PageTemplate, PageBlockData } from './types';

// NLP Page Templates
export const nlpPageTemplates: PageTemplate[] = [
  {
    id: 'nlp-landing',
    name: 'NLP Landing Page',
    description: 'Trang landing chuyên nghiệp cho dịch vụ NLP',
    thumbnail: 'https://placehold.co/400x300/4f46e5/ffffff?text=NLP+Landing',
    pageType: 'nlp',
    tags: ['landing', 'coaching', 'therapy'],
    blocks: [
      {
        id: 'hero-1',
        type: 'hero',
        content: {
          title: 'Khám Phá Sức Mạnh của NLP',
          subtitle: 'Neuro Linguistic Programming',
          description: 'Thay đổi cuộc sống của bạn với kỹ thuật lập trình ngôn ngữ tư duy hiện đại nhất',
          buttonText: 'Tư Vấn Miễn Phí',
          buttonLink: '/contact',
          backgroundImage: 'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=1200&h=600&fit=crop',
          overlayOpacity: 0.7,
          alignment: 'center'
        },
        order: 1,
        styles: {
          backgroundColor: '#1e293b',
          textColor: '#ffffff',
          padding: { top: 120, right: 40, bottom: 120, left: 40 }
        }
      },
      {
        id: 'about-1',
        type: 'about-section',
        content: {
          title: 'NLP - Công Cụ Thay Đổi Mạnh Mẽ',
          description: 'NLP (Neuro Linguistic Programming) là một phương pháp khoa học giúp bạn hiểu và điều khiển cách thức não bộ xử lý thông tin. Thông qua việc thay đổi ngôn ngữ và mô hình tư duy, bạn có thể đạt được những thay đổi tích cực trong cuộc sống.',
          image: 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=600&h=400&fit=crop',
          features: [
            {
              icon: '🧠',
              title: 'Tái lập trình tư duy',
              description: 'Thay đổi những niềm tin và mô hình tư duy tiêu cực'
            },
            {
              icon: '💬',
              title: 'Cải thiện giao tiếp',
              description: 'Nâng cao kỹ năng giao tiếp và thuyết phục'
            },
            {
              icon: '🎯',
              title: 'Đạt mục tiêu',
              description: 'Tập trung và đạt được mục tiêu một cách hiệu quả'
            }
          ],
          layout: 'image-right'
        },
        order: 2,
        styles: {
          backgroundColor: '#f8fafc',
          padding: { top: 80, right: 40, bottom: 80, left: 40 }
        }
      },
      {
        id: 'process-1',
        type: 'process-steps',
        content: {
          title: 'Quy Trình Đào Tạo NLP',
          description: 'Hành trình 4 bước để thành thạo NLP',
          steps: [
            {
              id: '1',
              number: 1,
              title: 'Đánh Giá Ban Đầu',
              description: 'Phân tích tình trạng hiện tại và xác định mục tiêu',
              icon: '📋'
            },
            {
              id: '2',
              number: 2,
              title: 'Học Kỹ Thuật Cơ Bản',
              description: 'Nắm vững các kỹ thuật NLP căn bản',
              icon: '📚'
            },
            {
              id: '3',
              number: 3,
              title: 'Thực Hành Ứng Dụng',
              description: 'Áp dụng thực tế trong cuộc sống hàng ngày',
              icon: '🎯'
            },
            {
              id: '4',
              number: 4,
              title: 'Theo Dõi & Cải Thiện',
              description: 'Đánh giá kết quả và điều chỉnh phương pháp',
              icon: '📈'
            }
          ]
        },
        order: 3,
        styles: {
          backgroundColor: '#ffffff',
          padding: { top: 80, right: 40, bottom: 80, left: 40 }
        }
      },
      {
        id: 'testimonials-1',
        type: 'testimonials',
        content: {
          testimonials: [
            {
              id: '1',
              name: 'Nguyễn Minh Anh',
              role: 'Giám đốc kinh doanh',
              company: 'ABC Corp',
              content: 'NLP đã thay đổi hoàn toàn cách tôi giao tiếp và lãnh đạo. Hiệu quả công việc tăng 300%.',
              image: 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=80&h=80&fit=crop&crop=face',
              rating: 5
            },
            {
              id: '2',
              name: 'Trần Thị Lan',
              role: 'Chuyên gia HR',
              company: 'XYZ Company',
              content: 'Kỹ thuật anchoring giúp tôi tự tin hơn rất nhiều trong các cuộc thuyết trình.',
              image: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=80&h=80&fit=crop&crop=face',
              rating: 5
            }
          ],
          layout: 'grid'
        },
        order: 4,
        styles: {
          backgroundColor: '#f1f5f9',
          padding: { top: 80, right: 40, bottom: 80, left: 40 }
        }
      },
      {
        id: 'cta-1',
        type: 'call-to-action',
        content: {
          title: 'Bắt Đầu Hành Trình Thay Đổi Ngay Hôm Nay',
          description: 'Đăng ký tư vấn miễn phí để khám phá sức mạnh của NLP',
          buttonText: 'Đăng Ký Ngay',
          buttonLink: '/contact',
          backgroundImage: 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=1200&h=400&fit=crop'
        },
        order: 5,
        styles: {
          backgroundColor: '#3b82f6',
          textColor: '#ffffff',
          padding: { top: 80, right: 40, bottom: 80, left: 40 }
        }
      }
    ]
  }
];

// Time-line Therapy Templates
export const timelineTherapyTemplates: PageTemplate[] = [
  {
    id: 'timeline-therapy-landing',
    name: 'Time-line Therapy Landing',
    description: 'Trang landing cho dịch vụ Time-line Therapy',
    thumbnail: 'https://placehold.co/400x300/6b46c1/ffffff?text=Timeline+Therapy',
    pageType: 'time-line-therapy',
    tags: ['therapy', 'healing', 'timeline'],
    blocks: [
      {
        id: 'hero-2',
        type: 'hero',
        content: {
          title: 'Time-line Therapy®',
          subtitle: 'Hành Trình Chữa Lành Quá Khứ',
          description: 'Giải phóng cảm xúc tiêu cực và tạo ra tương lai tích cực với phương pháp Time-line Therapy® được công nhận quốc tế',
          buttonText: 'Khám Phá Ngay',
          buttonLink: '/timeline-therapy/about',
          backgroundImage: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=1200&h=600&fit=crop',
          overlayOpacity: 0.6,
          alignment: 'center'
        },
        order: 1,
        styles: {
          backgroundColor: '#6b46c1',
          textColor: '#ffffff',
          padding: { top: 120, right: 40, bottom: 120, left: 40 }
        }
      },
      {
        id: 'timeline-1',
        type: 'timeline',
        content: {
          title: 'Lịch Sử Phát Triển Time-line Therapy®',
          items: [
            {
              id: '1',
              year: '1985',
              title: 'Khởi Nguồn',
              description: 'Tiến sĩ Tad James phát triển phương pháp Time-line Therapy® đầu tiên',
              image: 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=300&h=200&fit=crop'
            },
            {
              id: '2',
              year: '1990',
              title: 'Công Nhận',
              description: 'Time-line Therapy® được công nhận chính thức và lan rộng toàn cầu',
              image: 'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=300&h=200&fit=crop'
            },
            {
              id: '3',
              year: '2000',
              title: 'Phát Triển',
              description: 'Các kỹ thuật mới được bổ sung và hoàn thiện',
              image: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300&h=200&fit=crop'
            },
            {
              id: '4',
              year: '2020',
              title: 'Hiện Tại',
              description: 'Time-line Therapy® được ứng dụng rộng rãi tại Việt Nam',
              image: 'https://images.unsplash.com/photo-1573497019940-1c28c88b4f3e?w=300&h=200&fit=crop'
            }
          ],
          layout: 'vertical'
        },
        order: 2,
        styles: {
          backgroundColor: '#f8fafc',
          padding: { top: 80, right: 40, bottom: 80, left: 40 }
        }
      },
      {
        id: 'feature-cards-1',
        type: 'feature-cards',
        content: {
          title: 'Lợi Ích Của Time-line Therapy®',
          description: 'Những thay đổi tích cực mà bạn có thể đạt được',
          cards: [
            {
              id: '1',
              icon: '🔓',
              title: 'Giải Phóng Cảm Xúc Tiêu Cực',
              description: 'Loại bỏ các cảm xúc như tức giận, buồn bã, sợ hãi từ quá khứ',
              color: '#ef4444'
            },
            {
              id: '2',
              icon: '💭',
              title: 'Thay Đổi Niềm Tin Giới Hạn',
              description: 'Xóa bỏ những niềm tin cản trở sự phát triển cá nhân',
              color: '#3b82f6'
            },
            {
              id: '3',
              icon: '🌟',
              title: 'Tạo Tương Lai Tích Cực',
              description: 'Thiết lập mục tiêu và tương lai rõ ràng, khả thi',
              color: '#10b981'
            },
            {
              id: '4',
              icon: '❤️',
              title: 'Chữa Lành Tổn Thương',
              description: 'Hàn gắn những vết thương tinh thần từ quá khứ',
              color: '#8b5cf6'
            }
          ]
        },
        order: 3,
        styles: {
          backgroundColor: '#ffffff',
          padding: { top: 80, right: 40, bottom: 80, left: 40 }
        }
      }
    ]
  }
];

// About Page Templates
export const aboutPageTemplates: PageTemplate[] = [
  {
    id: 'about-chloe',
    name: 'About Chloe Quý Châu',
    description: 'Trang giới thiệu về Chloe Quý Châu',
    thumbnail: 'https://placehold.co/400x300/10b981/ffffff?text=About+Chloe',
    pageType: 'about',
    tags: ['personal', 'coach', 'biography'],
    blocks: [
      {
        id: 'hero-3',
        type: 'hero',
        content: {
          title: 'Chloe Quý Châu',
          subtitle: 'Master Trainer NLP & Time-line Therapy®',
          description: 'Chuyên gia hàng đầu về NLP và Time-line Therapy® tại Việt Nam với hơn 15 năm kinh nghiệm',
          buttonText: 'Tìm Hiểu Thêm',
          buttonLink: '#about',
          backgroundImage: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=1200&h=600&fit=crop',
          overlayOpacity: 0.5,
          alignment: 'left'
        },
        order: 1,
        styles: {
          backgroundColor: '#10b981',
          textColor: '#ffffff',
          padding: { top: 120, right: 40, bottom: 120, left: 40 }
        }
      },
      {
        id: 'about-2',
        type: 'about-section',
        content: {
          title: 'Hành Trình Của Tôi',
          description: 'Từ một người đầy trăn trở về cuộc sống, tôi đã tìm thấy NLP và Time-line Therapy® - những công cụ mạnh mẽ đã thay đổi hoàn toàn cuộc đời tôi. Giờ đây, tôi muốn chia sẻ những kiến thức và kinh nghiệm này để giúp mọi người tìm thấy con đường của chính mình.',
          image: 'https://images.unsplash.com/photo-1573497019940-1c28c88b4f3e?w=600&h=400&fit=crop',
          features: [
            {
              icon: '🎓',
              title: 'Chứng Chỉ Quốc Tế',
              description: 'Master Trainer được công nhận bởi Time Line Therapy® Association'
            },
            {
              icon: '👥',
              title: '1000+ Học Viên',
              description: 'Đã đào tạo và hỗ trợ hơn 1000 học viên thay đổi cuộc sống'
            },
            {
              icon: '🏆',
              title: '15 Năm Kinh Nghiệm',
              description: 'Hơn 15 năm nghiên cứu và ứng dụng NLP & Time-line Therapy®'
            }
          ],
          layout: 'image-left'
        },
        order: 2,
        styles: {
          backgroundColor: '#f8fafc',
          padding: { top: 80, right: 40, bottom: 80, left: 40 }
        }
      },
      {
        id: 'stats-1',
        type: 'stats-counter',
        content: {
          title: 'Thành Tựu Đạt Được',
          stats: [
            {
              id: '1',
              number: 1000,
              suffix: '+',
              label: 'Học Viên',
              description: 'Đã được đào tạo'
            },
            {
              id: '2',
              number: 15,
              suffix: '',
              label: 'Năm Kinh Nghiệm',
              description: 'Trong lĩnh vực NLP'
            },
            {
              id: '3',
              number: 50,
              suffix: '+',
              label: 'Doanh Nghiệp',
              description: 'Đã hợp tác'
            },
            {
              id: '4',
              number: 95,
              suffix: '%',
              label: 'Hài Lòng',
              description: 'Khách hàng đánh giá tích cực'
            }
          ]
        },
        order: 3,
        styles: {
          backgroundColor: '#1e293b',
          textColor: '#ffffff',
          padding: { top: 80, right: 40, bottom: 80, left: 40 }
        }
      }
    ]
  }
];

// Combine all templates
export const allPageTemplates: PageTemplate[] = [
  ...nlpPageTemplates,
  ...timelineTherapyTemplates,
  ...aboutPageTemplates
];

// Template helpers
export const getTemplatesByType = (pageType: string): PageTemplate[] => {
  return allPageTemplates.filter(template => template.pageType === pageType);
};

export const getTemplateById = (id: string): PageTemplate | undefined => {
  return allPageTemplates.find(template => template.id === id);
};
