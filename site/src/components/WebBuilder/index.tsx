// 📝 Main Web Builder Component
"use client";

import React, { useState } from 'react';
import { Save, Eye, Settings, Download, Upload, Undo, Redo } from 'lucide-react';
import { WebBuilderProps, PageData } from './types';
import { useWebBuilder } from './hooks/useWebBuilder';
import { BlockLibrary } from './components/BlockLibrary';
import { PageBlockRenderer } from './components/PageBlockRenderer';
import { getTemplatesByType } from './templates';
import { PagePreview } from './exports';

const defaultPage: PageData = {
  id: 'new-page',
  title: 'Trang mới',
  slug: 'trang-moi',
  content: [],
  author: 'Chloe Quý Châu',
  createdAt: new Date().toISOString(),
  updatedAt: new Date().toISOString(),
  status: 'draft',
  pageType: 'custom'
};

export const WebBuilder: React.FC<WebBuilderProps> = ({
  initialPage = defaultPage,
  onSave,
  onPreview,
  pageType = 'custom'
}) => {
  const [showTemplates, setShowTemplates] = useState(false);
  
  const {
    page,
    setPage,
    activeBlockId,
    setActiveBlockId,
    isEditMode,
    setIsEditMode,
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
    toggleBlockSelection,
    clearSelection,
    undo,
    redo,
    updatePageMeta,
    findBlockById
  } = useWebBuilder({ ...initialPage, pageType });

  const handleSave = () => {
    onSave?.(page);
    // Show success message
    alert('Trang đã được lưu thành công!');
  };

  const handlePreview = () => {
    setIsEditMode(false);
    onPreview?.(page);
  };

  const handleTemplateSelect = (templateId: string) => {
    const templates = getTemplatesByType(pageType);
    const template = templates.find(t => t.id === templateId);
    
    if (template) {
      setPage({
        ...page,
        content: template.blocks,
        title: template.name
      });
      setShowTemplates(false);
    }
  };

  const exportPage = () => {
    const dataStr = JSON.stringify(page, null, 2);
    const dataBlob = new Blob([dataStr], { type: 'application/json' });
    const url = URL.createObjectURL(dataBlob);
    const link = document.createElement('a');
    link.href = url;
    link.download = `${page.slug}.json`;
    link.click();
    URL.revokeObjectURL(url);
  };

  const importPage = (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (file) {
      const reader = new FileReader();
      reader.onload = (e) => {
        try {
          const importedPage = JSON.parse(e.target?.result as string);
          setPage(importedPage);
        } catch (error) {
          alert('Lỗi khi import file. Vui lòng kiểm tra lại format file.');
        }
      };
      reader.readAsText(file);
    }
  };

  if (!isEditMode) {
    return (
      <PagePreview 
        page={page} 
        onEditMode={() => setIsEditMode(true)} 
      />
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header Toolbar */}
      <div className="bg-white border-b border-gray-200 sticky top-0 z-40">
        <div className="max-w-7xl mx-auto px-4 py-3">
          <div className="flex items-center justify-between">
            {/* Left - Page Info */}
            <div className="flex items-center space-x-4">
              <div>
                <input
                  type="text"
                  value={page.title}
                  onChange={(e) => updatePageMeta({ title: e.target.value })}
                  className="text-xl font-semibold bg-transparent border-none outline-none"
                  placeholder="Tên trang"
                />
                <p className="text-sm text-gray-500">
                  {pageType === 'nlp' ? '🧠 NLP Page' :
                   pageType === 'time-line-therapy' ? '⏰ Time-line Therapy' :
                   pageType === 'about' ? '👋 About Page' : '📄 Custom Page'}
                </p>
              </div>
            </div>

            {/* Center - Actions */}
            <div className="flex items-center space-x-2">
              <button
                onClick={undo}
                disabled={!canUndo}
                className="p-2 text-gray-600 hover:text-gray-800 disabled:opacity-50"
                title="Undo"
              >
                <Undo className="w-4 h-4" />
              </button>
              
              <button
                onClick={redo}
                disabled={!canRedo}
                className="p-2 text-gray-600 hover:text-gray-800 disabled:opacity-50"
                title="Redo"
              >
                <Redo className="w-4 h-4" />
              </button>
              
              <div className="w-px h-6 bg-gray-300"></div>
              
              <button
                onClick={() => setShowTemplates(true)}
                className="px-3 py-2 text-sm bg-gray-100 text-gray-700 rounded hover:bg-gray-200 transition-colors"
              >
                Templates
              </button>
              
              <button
                onClick={exportPage}
                className="p-2 text-gray-600 hover:text-gray-800"
                title="Export page"
              >
                <Download className="w-4 h-4" />
              </button>
              
              <label className="p-2 text-gray-600 hover:text-gray-800 cursor-pointer" title="Import page">
                <Upload className="w-4 h-4" />
                <input
                  type="file"
                  accept=".json"
                  onChange={importPage}
                  className="hidden"
                />
              </label>
            </div>

            {/* Right - Save & Preview */}
            <div className="flex items-center space-x-3">
              <span className="text-sm text-gray-500">
                {selectedBlocks.size > 0 && `${selectedBlocks.size} blocks selected`}
                {clipboard && ' • 1 in clipboard'}
              </span>
              
              <button
                onClick={handlePreview}
                className="flex items-center px-4 py-2 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 transition-colors"
              >
                <Eye className="w-4 h-4 mr-2" />
                Preview
              </button>
              
              <button
                onClick={handleSave}
                className="flex items-center px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
              >
                <Save className="w-4 h-4 mr-2" />
                Lưu
              </button>
            </div>
          </div>
        </div>
      </div>

      {/* Main Content */}
      <div className="max-w-7xl mx-auto py-8">
        {/* Page Canvas */}
        <div className="bg-white min-h-[800px] shadow-sm rounded-lg overflow-hidden">
          {page.content.length === 0 ? (
            // Empty state
            <div className="h-96 flex items-center justify-center text-gray-500">
              <div className="text-center">
                <div className="text-6xl mb-4">📄</div>
                <h3 className="text-xl font-medium mb-2">Trang trống</h3>
                <p className="mb-6">Thêm blocks để bắt đầu tạo trang của bạn</p>
                <button
                  onClick={() => setShowTemplates(true)}
                  className="px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
                >
                  Chọn Template
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
                    onClick={() => setActiveBlockId(block.id)}
                  >
                    <PageBlockRenderer
                      block={block}
                      isActive={activeBlockId === block.id}
                      isEditMode={true}
                      onUpdate={(content) => updateBlockContent(block.id, content)}
                      onDelete={() => deleteBlock(block.id)}
                      onDuplicate={() => duplicateBlock(block.id)}
                      onStyleUpdate={(styles) => updateBlockStyles(block.id, styles)}
                      onAnimationUpdate={(animations) => {
                        // Update animations
                      }}
                    />
                  </div>
                ))}
            </div>
          )}
        </div>
      </div>

      {/* Block Library */}
      <BlockLibrary
        onAddBlock={addBlock}
        pageType={pageType}
      />

      {/* Templates Modal */}
      {showTemplates && (
        <div className="fixed inset-0 bg-black bg-opacity-50 z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-lg max-w-4xl w-full max-h-[80vh] overflow-hidden">
            <div className="p-6 border-b border-gray-200">
              <div className="flex items-center justify-between">
                <h3 className="text-xl font-semibold">Chọn Template</h3>
                <button
                  onClick={() => setShowTemplates(false)}
                  className="text-gray-400 hover:text-gray-600"
                >
                  ×
                </button>
              </div>
            </div>
            
            <div className="p-6 overflow-y-auto">
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                {getTemplatesByType(pageType).map((template) => (
                  <div
                    key={template.id}
                    className="border border-gray-200 rounded-lg overflow-hidden hover:border-blue-300 cursor-pointer transition-colors"
                    onClick={() => handleTemplateSelect(template.id)}
                  >
                    <img
                      src={template.thumbnail}
                      alt={template.name}
                      className="w-full h-40 object-cover"
                    />
                    <div className="p-4">
                      <h4 className="font-medium mb-2">{template.name}</h4>
                      <p className="text-sm text-gray-600 mb-3">{template.description}</p>
                      <div className="flex flex-wrap gap-1">
                        {template.tags.map((tag) => (
                          <span
                            key={tag}
                            className="px-2 py-1 bg-gray-100 text-gray-600 text-xs rounded"
                          >
                            {tag}
                          </span>
                        ))}
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
