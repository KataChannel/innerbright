// 📝 Enhanced Block Editor for Time-line Therapy, NLP & About Pages
"use client";

import React, { useState, useCallback } from 'react';
import { Plus, Move, Edit, Trash2, Copy, Eye, Settings, Save } from 'lucide-react';
import { PageData, PageBlockData, PageBlockType } from '../types';
import { useWebBuilder } from '../hooks/useWebBuilder';
import { BlockLibrary } from './BlockLibrary';
import { PageBlockRenderer } from './PageBlockRenderer';
import { PagePreview } from './PagePreview';

interface EnhancedBlockEditorProps {
  initialPage?: PageData;
  pageType: 'time-line-therapy' | 'nlp' | 'about';
  onSave?: (page: PageData) => void;
  onPreview?: (page: PageData) => void;
}

const getPageTypeInfo = (pageType: string) => {
  switch (pageType) {
    case 'time-line-therapy':
      return {
        title: 'Time-line Therapy® Page Builder',
        description: 'Tạo trang dynamic cho Time-line Therapy®',
        icon: '⏰',
        color: 'purple',
        defaultBlocks: ['hero', 'timeline', 'about-section', 'testimonials', 'contact-form']
      };
    case 'nlp':
      return {
        title: 'NLP Page Builder',
        description: 'Tạo trang dynamic cho Neuro Linguistic Programming',
        icon: '🧠',
        color: 'blue',
        defaultBlocks: ['hero', 'about-section', 'process-steps', 'feature-cards', 'testimonials']
      };
    case 'about':
      return {
        title: 'About Page Builder',
        description: 'Tạo trang giới thiệu cá nhân và chuyên môn',
        icon: '👋',
        color: 'green',
        defaultBlocks: ['hero', 'about-section', 'timeline', 'stats-counter', 'team-members']
      };
    default:
      return {
        title: 'Page Builder',
        description: 'Tạo trang dynamic',
        icon: '📄',
        color: 'gray',
        defaultBlocks: ['hero', 'about-section']
      };
  }
};

export const EnhancedBlockEditor: React.FC<EnhancedBlockEditorProps> = ({
  initialPage,
  pageType,
  onSave,
  onPreview
}) => {
  const [isPreviewMode, setIsPreviewMode] = useState(false);
  const [showBlockLibrary, setShowBlockLibrary] = useState(false);
  const [draggedBlock, setDraggedBlock] = useState<string | null>(null);

  const pageTypeInfo = getPageTypeInfo(pageType);

  const defaultPage: PageData = {
    id: `${pageType}-page-${Date.now()}`,
    title: `Trang ${pageTypeInfo.title}`,
    slug: `${pageType}-page`,
    content: [],
    author: 'Chloe Quý Châu',
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
    status: 'draft',
    pageType,
    metaDescription: `Trang ${pageTypeInfo.description}`,
    metaKeywords: pageType === 'time-line-therapy' 
      ? 'time-line therapy, therapy, healing, emotional healing'
      : pageType === 'nlp' 
      ? 'NLP, neuro linguistic programming, coaching, communication'
      : 'about, profile, biography, experience'
  };

  const {
    page,
    activeBlockId,
    setActiveBlockId,
    selectedBlocks,
    clipboard,
    canUndo,
    canRedo,
    addBlock,
    updateBlockContent,
    updateBlockStyles,
    deleteBlock,
    duplicateBlock,
    copyBlock,
    pasteBlock,
    moveBlock,
    undo,
    redo,
    updatePageMeta
  } = useWebBuilder(initialPage || defaultPage);

  // Quick add blocks for this page type
  const handleQuickAddBlock = useCallback((blockType: PageBlockType) => {
    addBlock(blockType);
    setShowBlockLibrary(false);
  }, [addBlock]);

  // Handle drag and drop
  const handleDragStart = useCallback((blockId: string) => {
    setDraggedBlock(blockId);
  }, []);

  const handleDragOver = useCallback((e: React.DragEvent) => {
    e.preventDefault();
  }, []);

  const handleDrop = useCallback((e: React.DragEvent, targetBlockId: string) => {
    e.preventDefault();
    if (draggedBlock && draggedBlock !== targetBlockId) {
      // Implement block reordering logic here
      // moveBlock(draggedBlock, targetBlockId);
    }
    setDraggedBlock(null);
  }, [draggedBlock]);

  const handleSave = useCallback(() => {
    onSave?.(page);
    // Show success notification
    alert('Trang đã được lưu thành công!');
  }, [page, onSave]);

  const handlePreview = useCallback(() => {
    setIsPreviewMode(true);
    onPreview?.(page);
  }, [page, onPreview]);

  // Quick templates for each page type
  const getQuickTemplates = () => {
    const templates = {
      'time-line-therapy': [
        { type: 'hero', name: 'Hero Banner', description: 'Banner chính với CTA' },
        { type: 'timeline', name: 'Therapy Timeline', description: 'Dòng thời gian trị liệu' },
        { type: 'about-section', name: 'Giới thiệu', description: 'Mô tả về Time-line Therapy®' },
        { type: 'testimonials', name: 'Testimonials', description: 'Lời chứng thực từ khách hàng' },
        { type: 'process-steps', name: 'Quy trình', description: 'Các bước trong quá trình trị liệu' },
        { type: 'faq-section', name: 'FAQ', description: 'Câu hỏi thường gặp' }
      ],
      'nlp': [
        { type: 'hero', name: 'Hero Banner', description: 'Banner chính về NLP' },
        { type: 'about-section', name: 'Về NLP', description: 'Giới thiệu về NLP' },
        { type: 'process-steps', name: 'Quy trình đào tạo', description: 'Các bước học NLP' },
        { type: 'feature-cards', name: 'Lợi ích NLP', description: 'Những lợi ích của NLP' },
        { type: 'testimonials', name: 'Success Stories', description: 'Câu chuyện thành công' },
        { type: 'pricing-table', name: 'Gói đào tạo', description: 'Các gói đào tạo NLP' }
      ],
      'about': [
        { type: 'hero', name: 'Personal Hero', description: 'Banner giới thiệu cá nhân' },
        { type: 'about-section', name: 'Về tôi', description: 'Giới thiệu chi tiết' },
        { type: 'timeline', name: 'Hành trình', description: 'Timeline sự nghiệp' },
        { type: 'stats-counter', name: 'Thành tựu', description: 'Số liệu thành tựu' },
        { type: 'team-members', name: 'Team', description: 'Đội ngũ cộng tác' },
        { type: 'contact-form', name: 'Liên hệ', description: 'Form liên hệ' }
      ]
    };
    return templates[pageType] || [];
  };

  if (isPreviewMode) {
    return (
      <PagePreview 
        page={page} 
        onEditMode={() => setIsPreviewMode(false)} 
      />
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-white shadow-sm border-b sticky top-0 z-40">
        <div className="max-w-7xl mx-auto px-6 py-4">
          <div className="flex items-center justify-between">
            {/* Page Info */}
            <div className="flex items-center space-x-4">
              <div className="text-2xl">{pageTypeInfo.icon}</div>
              <div>
                <h1 className="text-xl font-semibold text-gray-900">
                  {pageTypeInfo.title}
                </h1>
                <p className="text-sm text-gray-600">
                  {pageTypeInfo.description}
                </p>
              </div>
            </div>

            {/* Actions */}
            <div className="flex items-center space-x-3">
              <button
                onClick={undo}
                disabled={!canUndo}
                className="p-2 text-gray-600 hover:text-gray-800 disabled:opacity-50"
                title="Hoàn tác"
              >
                <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 10h10a8 8 0 018 8v2M3 10l6 6m-6-6l6-6" />
                </svg>
              </button>

              <button
                onClick={redo}
                disabled={!canRedo}
                className="p-2 text-gray-600 hover:text-gray-800 disabled:opacity-50"
                title="Làm lại"
              >
                <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 10H11a8 8 0 00-8 8v2m18-10l-6-6m6 6l-6 6" />
                </svg>
              </button>

              <div className="w-px h-6 bg-gray-300"></div>

              <button
                onClick={handlePreview}
                className="flex items-center px-4 py-2 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 transition-colors"
              >
                <Eye className="w-4 h-4 mr-2" />
                Xem trước
              </button>

              <button
                onClick={handleSave}
                className="flex items-center px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
              >
                <Save className="w-4 h-4 mr-2" />
                Lưu trang
              </button>
            </div>
          </div>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-6 py-8">
        <div className="flex gap-8">
          {/* Sidebar - Quick Blocks */}
          <div className="w-80 flex-shrink-0">
            <div className="bg-white rounded-lg shadow-sm p-6 sticky top-32">
              <div className="flex items-center justify-between mb-4">
                <h3 className="font-semibold text-gray-900">Quick Add Blocks</h3>
                <button
                  onClick={() => setShowBlockLibrary(true)}
                  className="text-blue-600 hover:text-blue-700 text-sm"
                >
                  Xem tất cả →
                </button>
              </div>

              <div className="space-y-2">
                {getQuickTemplates().map((template) => (
                  <button
                    key={template.type}
                    onClick={() => handleQuickAddBlock(template.type as PageBlockType)}
                    className="w-full text-left p-3 rounded-lg border border-gray-200 hover:border-blue-300 hover:bg-blue-50 transition-colors group"
                  >
                    <div className="font-medium text-gray-900 group-hover:text-blue-700">
                      {template.name}
                    </div>
                    <div className="text-sm text-gray-600">
                      {template.description}
                    </div>
                  </button>
                ))}
              </div>

              {/* Page Settings */}
              <div className="mt-8 pt-6 border-t border-gray-200">
                <h4 className="font-medium text-gray-900 mb-3">Cài đặt trang</h4>
                <div className="space-y-3">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      Tiêu đề trang
                    </label>
                    <input
                      type="text"
                      value={page.title}
                      onChange={(e) => updatePageMeta({ title: e.target.value })}
                      className="w-full px-3 py-2 border border-gray-300 rounded-md text-sm focus:ring-blue-500 focus:border-blue-500"
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      URL slug
                    </label>
                    <input
                      type="text"
                      value={page.slug}
                      onChange={(e) => updatePageMeta({ slug: e.target.value })}
                      className="w-full px-3 py-2 border border-gray-300 rounded-md text-sm focus:ring-blue-500 focus:border-blue-500"
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      Mô tả meta
                    </label>
                    <textarea
                      value={page.metaDescription || ''}
                      onChange={(e) => updatePageMeta({ metaDescription: e.target.value })}
                      className="w-full px-3 py-2 border border-gray-300 rounded-md text-sm focus:ring-blue-500 focus:border-blue-500"
                      rows={3}
                    />
                  </div>
                </div>
              </div>
            </div>
          </div>

          {/* Main Canvas */}
          <div className="flex-1">
            <div className="bg-white rounded-lg shadow-sm min-h-[800px]">
              {page.content.length === 0 ? (
                // Empty state
                <div className="h-96 flex items-center justify-center">
                  <div className="text-center">
                    <div className="text-6xl mb-4">{pageTypeInfo.icon}</div>
                    <h3 className="text-xl font-medium text-gray-900 mb-2">
                      Bắt đầu tạo trang {pageType}
                    </h3>
                    <p className="text-gray-600 mb-6">
                      Chọn blocks từ sidebar để bắt đầu xây dựng trang của bạn
                    </p>
                    <button
                      onClick={() => handleQuickAddBlock('hero')}
                      className="px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
                    >
                      Thêm Hero Banner
                    </button>
                  </div>
                </div>
              ) : (
                // Render blocks
                <div className="space-y-1">
                  {page.content
                    .sort((a, b) => a.order - b.order)
                    .map((block) => (
                      <div
                        key={block.id}
                        draggable
                        onDragStart={() => handleDragStart(block.id)}
                        onDragOver={handleDragOver}
                        onDrop={(e) => handleDrop(e, block.id)}
                        onClick={() => setActiveBlockId(block.id)}
                        className="cursor-pointer"
                      >
                        <PageBlockRenderer
                          block={block}
                          isActive={activeBlockId === block.id}
                          isEditMode={true}
                          onUpdate={(content) => updateBlockContent(block.id, content)}
                          onDelete={() => deleteBlock(block.id)}
                          onDuplicate={() => duplicateBlock(block.id)}
                          onStyleUpdate={(styles) => updateBlockStyles(block.id, styles)}
                          onAnimationUpdate={() => {}}
                        />
                      </div>
                    ))}
                </div>
              )}
            </div>
          </div>
        </div>
      </div>

      {/* Block Library Modal */}
      {showBlockLibrary && (
        <BlockLibrary
          onAddBlock={(type) => {
            handleQuickAddBlock(type);
            setShowBlockLibrary(false);
          }}
          pageType={pageType}
        />
      )}
    </div>
  );
};

export default EnhancedBlockEditor;
