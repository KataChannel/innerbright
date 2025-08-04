// 📝 Block Library Component - Danh sách blocks có sẵn
"use client";

import React, { useState } from 'react';
import { Plus, Search, Grid, Type, Image as ImageIcon, Video, Users, Star, MessageCircle, FileText, Clock, Brain, User } from 'lucide-react';
import { BlockLibraryProps, PageBlockType } from '../types';
import { getBlockIcon } from '../utils';

interface BlockCategory {
  id: string;
  name: string;
  icon: React.ReactNode;
  blocks: Array<{
    type: PageBlockType;
    name: string;
    description: string;
    icon: string;
  }>;
}

export const BlockLibrary: React.FC<BlockLibraryProps> = ({ onAddBlock, pageType }) => {
  const [isOpen, setIsOpen] = useState(false);
  const [searchTerm, setSearchTerm] = useState('');
  const [activeCategory, setActiveCategory] = useState('hero');

  const blockCategories: BlockCategory[] = [
    {
      id: 'hero',
      name: 'Hero & Headers',
      icon: <Star className="w-4 h-4" />,
      blocks: [
        {
          type: 'hero',
          name: 'Hero Section',
          description: 'Banner chính với tiêu đề, mô tả và call-to-action',
          icon: '🎯'
        },
        {
          type: 'call-to-action',
          name: 'Call to Action',
          description: 'Khu vực kêu gọi hành động',
          icon: '📢'
        }
      ]
    },
    {
      id: 'content',
      name: 'Content',
      icon: <FileText className="w-4 h-4" />,
      blocks: [
        {
          type: 'about-section',
          name: 'About Section',
          description: 'Phần giới thiệu với hình ảnh và tính năng',
          icon: '👋'
        },
        {
          type: 'feature-cards',
          name: 'Feature Cards',
          description: 'Lưới các thẻ tính năng',
          icon: '⭐'
        },
        {
          type: 'process-steps',
          name: 'Process Steps',
          description: 'Các bước quy trình làm việc',
          icon: '🔄'
        },
        {
          type: 'timeline',
          name: 'Timeline',
          description: 'Dòng thời gian sự kiện',
          icon: '📅'
        },
        {
          type: 'stats-counter',
          name: 'Stats Counter',
          description: 'Bộ đếm thống kê',
          icon: '📊'
        }
      ]
    },
    {
      id: 'services',
      name: 'Services',
      icon: <Grid className="w-4 h-4" />,
      blocks: [
        {
          type: 'services-grid',
          name: 'Services Grid',
          description: 'Lưới dịch vụ với icon và mô tả',
          icon: '⚡'
        },
        {
          type: 'pricing-table',
          name: 'Pricing Table',
          description: 'Bảng giá dịch vụ',
          icon: '💰'
        },
        {
          type: 'faq-section',
          name: 'FAQ Section',
          description: 'Câu hỏi thường gặp',
          icon: '❓'
        }
      ]
    },
    {
      id: 'social',
      name: 'Social & Trust',
      icon: <MessageCircle className="w-4 h-4" />,
      blocks: [
        {
          type: 'testimonials',
          name: 'Testimonials',
          description: 'Phần đánh giá khách hàng',
          icon: '💬'
        },
        {
          type: 'team-members',
          name: 'Team Members',
          description: 'Giới thiệu đội ngũ',
          icon: '👥'
        },
        {
          type: 'social-proof',
          name: 'Social Proof',
          description: 'Logo đối tác, khách hàng',
          icon: '🏆'
        }
      ]
    },
    {
      id: 'forms',
      name: 'Forms & Contact',
      icon: <FileText className="w-4 h-4" />,
      blocks: [
        {
          type: 'contact-form',
          name: 'Contact Form',
          description: 'Form liên hệ tùy chỉnh',
          icon: '📝'
        },
        {
          type: 'newsletter-signup',
          name: 'Newsletter',
          description: 'Form đăng ký nhận tin',
          icon: '📧'
        }
      ]
    },
    {
      id: 'media',
      name: 'Media',
      icon: <ImageIcon className="w-4 h-4" />,
      blocks: [
        {
          type: 'gallery',
          name: 'Gallery',
          description: 'Thư viện hình ảnh',
          icon: '🖼️'
        },
        {
          type: 'video-section',
          name: 'Video Section',
          description: 'Phần video giới thiệu',
          icon: '🎥'
        },
        {
          type: 'blog-posts',
          name: 'Blog Posts',
          description: 'Danh sách bài viết blog',
          icon: '📰'
        }
      ]
    },
    {
      id: 'layout',
      name: 'Layout',
      icon: <Grid className="w-4 h-4" />,
      blocks: [
        {
          type: 'section',
          name: 'Section',
          description: 'Container phần với background',
          icon: '📦'
        },
        {
          type: 'container',
          name: 'Container',
          description: 'Container nội dung',
          icon: '📋'
        },
        {
          type: 'columns',
          name: 'Columns',
          description: 'Layout cột',
          icon: '📱'
        },
        {
          type: 'spacer',
          name: 'Spacer',
          description: 'Khoảng trống',
          icon: '📏'
        },
        {
          type: 'divider',
          name: 'Divider',
          description: 'Đường phân cách',
          icon: '➖'
        }
      ]
    },
    {
      id: 'basic',
      name: 'Basic Elements',
      icon: <Type className="w-4 h-4" />,
      blocks: [
        {
          type: 'heading',
          name: 'Heading',
          description: 'Tiêu đề các cấp',
          icon: '📝'
        },
        {
          type: 'paragraph',
          name: 'Paragraph',
          description: 'Đoạn văn bản',
          icon: '📄'
        },
        {
          type: 'image',
          name: 'Image',
          description: 'Hình ảnh đơn',
          icon: '🖼️'
        },
        {
          type: 'button',
          name: 'Button',
          description: 'Nút bấm',
          icon: '🔘'
        },
        {
          type: 'icon',
          name: 'Icon',
          description: 'Icon đơn',
          icon: '⭐'
        },
        {
          type: 'list',
          name: 'List',
          description: 'Danh sách có/không đánh số',
          icon: '📋'
        }
      ]
    }
  ];

  // Filter blocks based on page type
  const getRelevantBlocks = () => {
    let relevantCategories = [...blockCategories];

    // Add specialized categories based on page type
    if (pageType === 'time-line-therapy') {
      relevantCategories.unshift({
        id: 'therapy-specialized',
        name: 'Time-line Therapy®',
        icon: <Clock className="w-4 h-4" />,
        blocks: [
          {
            type: 'therapy-timeline',
            name: 'Therapy Timeline',
            description: 'Quy trình Time-line Therapy® chi tiết',
            icon: '⏰'
          },
          {
            type: 'therapy-process',
            name: 'Therapy Process',
            description: 'Các giai đoạn trong quá trình trị liệu',
            icon: '🔄'
          },
          {
            type: 'success-stories',
            name: 'Success Stories',
            description: 'Câu chuyện thành công của khách hàng',
            icon: '🌟'
          },
          {
            type: 'certification-showcase',
            name: 'Certifications',
            description: 'Chứng chỉ và bằng cấp chuyên môn',
            icon: '🏅'
          }
        ]
      });
    } else if (pageType === 'nlp') {
      relevantCategories.unshift({
        id: 'nlp-specialized',
        name: 'NLP Specialized',
        icon: <Brain className="w-4 h-4" />,
        blocks: [
          {
            type: 'nlp-benefits',
            name: 'NLP Benefits',
            description: 'Lợi ích của NLP theo từng lĩnh vực',
            icon: '🧠'
          },
          {
            type: 'nlp-techniques',
            name: 'NLP Techniques',
            description: 'Các kỹ thuật NLP được phân loại',
            icon: '🛠️'
          },
          {
            type: 'coaching-programs',
            name: 'Coaching Programs',
            description: 'Các chương trình đào tạo và coaching',
            icon: '📚'
          },
          {
            type: 'success-stories',
            name: 'Success Stories',
            description: 'Câu chuyện thành công từ NLP',
            icon: '🌟'
          }
        ]
      });
    } else if (pageType === 'about') {
      relevantCategories.unshift({
        id: 'about-specialized',
        name: 'About Specialized',
        icon: <User className="w-4 h-4" />,
        blocks: [
          {
            type: 'professional-journey',
            name: 'Professional Journey',
            description: 'Hành trình chuyên môn với timeline',
            icon: '🎓'
          },
          {
            type: 'certification-showcase',
            name: 'Certifications',
            description: 'Trưng bày chứng chỉ và bằng cấp',
            icon: '🏅'
          },
          {
            type: 'success-stories',
            name: 'Success Stories',
            description: 'Những thành tựu và câu chuyện',
            icon: '🌟'
          }
        ]
      });
    }

    return relevantCategories;
  };

  const filteredCategories = getRelevantBlocks().map(category => ({
    ...category,
    blocks: category.blocks.filter(block =>
      block.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      block.description.toLowerCase().includes(searchTerm.toLowerCase())
    )
  })).filter(category => category.blocks.length > 0);

  const activeBlocks = filteredCategories.find(cat => cat.id === activeCategory)?.blocks || [];

  if (!isOpen) {
    return (
      <div className="fixed bottom-6 right-6 z-50">
        <button
          onClick={() => setIsOpen(true)}
          className="bg-blue-600 hover:bg-blue-700 text-white p-4 rounded-full shadow-lg transition-colors"
          title="Thêm block"
        >
          <Plus className="w-6 h-6" />
        </button>
      </div>
    );
  }

  return (
    <div className="fixed inset-y-0 right-0 w-80 bg-white shadow-xl z-50 flex flex-col">
      {/* Header */}
      <div className="p-4 border-b border-gray-200">
        <div className="flex items-center justify-between mb-4">
          <h3 className="text-lg font-semibold">Block Library</h3>
          <button
            onClick={() => setIsOpen(false)}
            className="text-gray-400 hover:text-gray-600"
          >
            ×
          </button>
        </div>
        
        {/* Search */}
        <div className="relative">
          <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-4 h-4" />
          <input
            type="text"
            placeholder="Tìm kiếm blocks..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
        </div>
      </div>

      {/* Categories */}
      <div className="flex-1 flex">
        {/* Category Sidebar */}
        <div className="w-20 bg-gray-50 border-r border-gray-200">
          <div className="py-2">
            {filteredCategories.map((category) => (
              <button
                key={category.id}
                onClick={() => setActiveCategory(category.id)}
                className={`w-full p-3 flex flex-col items-center space-y-1 hover:bg-gray-100 transition-colors ${
                  activeCategory === category.id ? 'bg-blue-50 text-blue-600' : 'text-gray-600'
                }`}
                title={category.name}
              >
                {category.icon}
                <span className="text-xs text-center leading-tight">
                  {category.name.split(' ')[0]}
                </span>
              </button>
            ))}
          </div>
        </div>

        {/* Blocks Grid */}
        <div className="flex-1 overflow-y-auto">
          <div className="p-4">
            <h4 className="font-medium text-gray-900 mb-3">
              {filteredCategories.find(cat => cat.id === activeCategory)?.name}
            </h4>
            <div className="space-y-2">
              {activeBlocks.map((block) => (
                <button
                  key={block.type}
                  onClick={() => {
                    onAddBlock(block.type);
                    setIsOpen(false);
                  }}
                  className="w-full p-3 border border-gray-200 rounded-lg hover:border-blue-300 hover:bg-blue-50 transition-colors text-left group"
                >
                  <div className="flex items-start space-x-3">
                    <span className="text-2xl flex-shrink-0 group-hover:scale-110 transition-transform">
                      {block.icon}
                    </span>
                    <div className="flex-1 min-w-0">
                      <h5 className="font-medium text-gray-900 text-sm">
                        {block.name}
                      </h5>
                      <p className="text-xs text-gray-500 mt-1 line-clamp-2">
                        {block.description}
                      </p>
                    </div>
                  </div>
                </button>
              ))}
            </div>
          </div>
        </div>
      </div>

      {/* Page Type Info */}
      {pageType !== 'custom' && (
        <div className="p-3 bg-blue-50 border-t border-blue-200">
          <p className="text-sm text-blue-700">
            <span className="font-medium">
              {pageType === 'nlp' ? '🧠 NLP Page' : 
               pageType === 'time-line-therapy' ? '⏰ Time-line Therapy' : 
               '👋 About Page'}
            </span>
            <br />
            Blocks được tối ưu cho loại trang này
          </p>
        </div>
      )}
    </div>
  );
};
