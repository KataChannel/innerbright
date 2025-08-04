// 📝 Enhanced Web Builder Admin Page
"use client";
import React, { useState } from 'react';
import { Plus, Eye, Settings, FileText, Clock, Brain, User } from 'lucide-react';
import { PageManager } from '@/components/WebBuilder/components/PageManager';
import { EnhancedBlockEditor } from '@/components/WebBuilder/components/EnhancedBlockEditor';
import { PageData } from '@/components/WebBuilder/types';

type PageType = 'time-line-therapy' | 'nlp' | 'about';

interface PageTypeInfo {
  id: PageType;
  name: string;
  description: string;
  icon: React.ReactNode;
  color: string;
  features: string[];
  examples: string[];
}

const pageTypes: PageTypeInfo[] = [
  {
    id: 'time-line-therapy',
    name: 'Time-line Therapy®',
    description: 'Tạo trang dynamic cho dịch vụ Time-line Therapy®',
    icon: <Clock className="w-8 h-8" />,
    color: 'purple',
    features: [
      'Therapy Timeline với quy trình chi tiết',
      'Success Stories từ khách hàng',
      'Therapy Process visualization',
      'Certification showcase',
      'Testimonials chuyên biệt'
    ],
    examples: [
      'Trang landing Time-line Therapy®',
      'Giới thiệu quy trình trị liệu',
      'Case studies và thành công',
      'Chứng chỉ và uy tín'
    ]
  },
  {
    id: 'nlp',
    name: 'NLP (Neuro Linguistic Programming)',
    description: 'Tạo trang dynamic cho dịch vụ NLP',
    icon: <Brain className="w-8 h-8" />,
    color: 'blue',
    features: [
      'NLP Benefits theo từng lĩnh vực',
      'NLP Techniques được phân loại',
      'Coaching Programs chi tiết',
      'Success Stories với before/after',
      'Process Steps cho đào tạo'
    ],
    examples: [
      'Trang landing NLP training',
      'Giới thiệu lợi ích NLP',
      'Các chương trình đào tạo',
      'Kỹ thuật NLP cơ bản'
    ]
  },
  {
    id: 'about',
    name: 'About - Giới thiệu',
    description: 'Tạo trang giới thiệu cá nhân và chuyên môn',
    icon: <User className="w-8 h-8" />,
    color: 'green',
    features: [
      'Professional Journey timeline',
      'Certification Showcase',
      'Success Stories và testimonials',
      'Team Members và cộng tác viên',
      'Stats Counter thành tựu'
    ],
    examples: [
      'Trang About cá nhân',
      'Hành trình sự nghiệp',
      'Thành tựu và chứng chỉ',
      'Đội ngũ và partner'
    ]
  }
];

export default function WebBuilderAdmin() {
  const [selectedPageType, setSelectedPageType] = useState<PageType | null>(null);
  const [viewMode, setViewMode] = useState<'overview' | 'manage' | 'create'>('overview');
  const [editingPage, setEditingPage] = useState<PageData | null>(null);

  const getColorClasses = (color: string) => {
    const colorMap = {
      purple: {
        bg: 'bg-purple-50',
        border: 'border-purple-200',
        text: 'text-purple-600',
        button: 'bg-purple-600 hover:bg-purple-700',
        icon: 'text-purple-600'
      },
      blue: {
        bg: 'bg-blue-50',
        border: 'border-blue-200',
        text: 'text-blue-600',
        button: 'bg-blue-600 hover:bg-blue-700',
        icon: 'text-blue-600'
      },
      green: {
        bg: 'bg-green-50',
        border: 'border-green-200',
        text: 'text-green-600',
        button: 'bg-green-600 hover:bg-green-700',
        icon: 'text-green-600'
      }
    };
    return colorMap[color as keyof typeof colorMap] || colorMap.blue;
  };

  const handlePageSave = (page: PageData) => {
    // Save page logic
    console.log('Saving page:', page);
    setEditingPage(null);
    setViewMode('manage');
  };

  const handlePagePreview = (page: PageData) => {
    // Preview page logic
    console.log('Previewing page:', page);
  };

  const handleCreateNewPage = (pageType: PageType) => {
    setSelectedPageType(pageType);
    setViewMode('create');
  };

  const handleManagePages = (pageType: PageType) => {
    setSelectedPageType(pageType);
    setViewMode('manage');
  };

  // Overview mode - selection of page types
  if (viewMode === 'overview') {
    return (
      <div className="min-h-screen bg-gray-50">
        {/* Header */}
        <div className="bg-white shadow-sm border-b">
          <div className="max-w-7xl mx-auto px-6 py-8">
            <div className="text-center">
              <h1 className="text-4xl font-bold text-gray-900 mb-4">
                🚀 Web Builder cho Time-line Therapy, NLP & About
              </h1>
              <p className="text-xl text-gray-600 max-w-3xl mx-auto">
                Tạo các trang dynamic chuyên nghiệp với block editor tiên tiến. 
                Hỗ trợ đầy đủ các tính năng chuyên biệt cho từng loại dịch vụ.
              </p>
            </div>
          </div>
        </div>

        {/* Page Type Selection */}
        <div className="max-w-7xl mx-auto px-6 py-12">
          <div className="grid md:grid-cols-3 gap-8">
            {pageTypes.map((pageType) => {
              const colors = getColorClasses(pageType.color);
              
              return (
                <div
                  key={pageType.id}
                  className={`${colors.bg} ${colors.border} border-2 rounded-xl p-8 transition-all duration-200 hover:shadow-lg group`}
                >
                  {/* Icon & Title */}
                  <div className="text-center mb-6">
                    <div className={`${colors.icon} mb-4 flex justify-center`}>
                      {pageType.icon}
                    </div>
                    <h2 className="text-2xl font-bold text-gray-900 mb-2">
                      {pageType.name}
                    </h2>
                    <p className="text-gray-600">
                      {pageType.description}
                    </p>
                  </div>

                  {/* Features */}
                  <div className="mb-6">
                    <h3 className="font-semibold text-gray-900 mb-3">Tính năng chuyên biệt:</h3>
                    <ul className="space-y-2">
                      {pageType.features.map((feature, index) => (
                        <li key={index} className="flex items-start text-sm text-gray-600">
                          <span className={`${colors.text} mr-2 mt-0.5`}>•</span>
                          {feature}
                        </li>
                      ))}
                    </ul>
                  </div>

                  {/* Examples */}
                  <div className="mb-8">
                    <h3 className="font-semibold text-gray-900 mb-3">Ví dụ ứng dụng:</h3>
                    <ul className="space-y-2">
                      {pageType.examples.map((example, index) => (
                        <li key={index} className="flex items-start text-sm text-gray-600">
                          <span className="text-gray-400 mr-2 mt-0.5">→</span>
                          {example}
                        </li>
                      ))}
                    </ul>
                  </div>

                  {/* Actions */}
                  <div className="space-y-3">
                    <button
                      onClick={() => handleCreateNewPage(pageType.id)}
                      className={`w-full flex items-center justify-center px-6 py-3 ${colors.button} text-white font-semibold rounded-lg transition-colors`}
                    >
                      <Plus className="w-5 h-5 mr-2" />
                      Tạo trang mới
                    </button>
                    
                    <button
                      onClick={() => handleManagePages(pageType.id)}
                      className="w-full flex items-center justify-center px-6 py-3 bg-gray-200 text-gray-700 font-semibold rounded-lg hover:bg-gray-300 transition-colors"
                    >
                      <Settings className="w-5 h-5 mr-2" />
                      Quản lý trang
                    </button>
                  </div>
                </div>
              );
            })}
          </div>

          {/* Quick Stats */}
          <div className="mt-16 bg-white rounded-xl p-8 shadow-sm">
            <h2 className="text-2xl font-bold text-gray-900 mb-6 text-center">
              📊 Thống kê & Tính năng nổi bật
            </h2>
            
            <div className="grid md:grid-cols-3 gap-8">
              <div className="text-center">
                <div className="text-3xl font-bold text-blue-600 mb-2">25+</div>
                <div className="text-gray-600">Block types chuyên biệt</div>
              </div>
              
              <div className="text-center">
                <div className="text-3xl font-bold text-green-600 mb-2">3</div>
                <div className="text-gray-600">Page types được tối ưu</div>
              </div>
              
              <div className="text-center">
                <div className="text-3xl font-bold text-purple-600 mb-2">∞</div>
                <div className="text-gray-600">Khả năng tùy chỉnh</div>
              </div>
            </div>

            <div className="mt-8 p-6 bg-gradient-to-r from-blue-50 to-purple-50 rounded-lg">
              <h3 className="font-semibold text-gray-900 mb-3">🎯 Tính năng nổi bật:</h3>
              <div className="grid md:grid-cols-2 gap-4 text-sm text-gray-600">
                <div className="flex items-center">
                  <span className="text-green-500 mr-2">✓</span>
                  Drag & Drop interface trực quan
                </div>
                <div className="flex items-center">
                  <span className="text-green-500 mr-2">✓</span>
                  Real-time preview
                </div>
                <div className="flex items-center">
                  <span className="text-green-500 mr-2">✓</span>
                  Responsive design tự động
                </div>
                <div className="flex items-center">
                  <span className="text-green-500 mr-2">✓</span>
                  SEO optimization
                </div>
                <div className="flex items-center">
                  <span className="text-green-500 mr-2">✓</span>
                  Template library phong phú
                </div>
                <div className="flex items-center">
                  <span className="text-green-500 mr-2">✓</span>
                  Export/Import pages
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    );
  }

  // Create mode - enhanced block editor
  if (viewMode === 'create' && selectedPageType) {
    return (
      <div className="min-h-screen bg-gray-50">
        {/* Header with back button */}
        <div className="bg-white shadow-sm border-b">
          <div className="max-w-7xl mx-auto px-6 py-4">
            <div className="flex items-center justify-between">
              <button
                onClick={() => setViewMode('overview')}
                className="flex items-center text-gray-600 hover:text-gray-800"
              >
                <span className="mr-2">←</span>
                Quay lại tổng quan
              </button>
              
              <div className="text-center">
                <h1 className="text-xl font-semibold text-gray-900">
                  Tạo trang {pageTypes.find(p => p.id === selectedPageType)?.name}
                </h1>
              </div>
              
              <div></div>
            </div>
          </div>
        </div>

        <EnhancedBlockEditor
          pageType={selectedPageType}
          onSave={handlePageSave}
          onPreview={handlePagePreview}
        />
      </div>
    );
  }

  // Manage mode - page manager
  if (viewMode === 'manage' && selectedPageType) {
    return (
      <div className="min-h-screen bg-gray-50">
        {/* Header with back button */}
        <div className="bg-white shadow-sm border-b">
          <div className="max-w-7xl mx-auto px-6 py-4">
            <div className="flex items-center justify-between">
              <button
                onClick={() => setViewMode('overview')}
                className="flex items-center text-gray-600 hover:text-gray-800"
              >
                <span className="mr-2">←</span>
                Quay lại tổng quan
              </button>
              
              <div className="text-center">
                <h1 className="text-xl font-semibold text-gray-900">
                  Quản lý trang {pageTypes.find(p => p.id === selectedPageType)?.name}
                </h1>
              </div>
              
              <button
                onClick={() => handleCreateNewPage(selectedPageType)}
                className="flex items-center px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
              >
                <Plus className="w-4 h-4 mr-2" />
                Tạo mới
              </button>
            </div>
          </div>
        </div>

        <PageManager pageType={selectedPageType} />
      </div>
    );
  }

  return null;
}
