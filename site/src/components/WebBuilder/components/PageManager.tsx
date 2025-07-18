// 📝 Admin Pages Manager - Quản lý các trang dynamic
"use client";

import React, { useState, useEffect } from 'react';
import { Plus, Edit, Trash2, Eye, FileText, Copy, Download } from 'lucide-react';
import { PageData, PageBlockType } from '../types';
import { WebBuilder } from '../index';

interface PageManagerProps {
  pageType?: 'nlp' | 'time-line-therapy' | 'about' | 'custom';
}

export const PageManager: React.FC<PageManagerProps> = ({ pageType = 'custom' }) => {
  const [pages, setPages] = useState<PageData[]>([]);
  const [selectedPage, setSelectedPage] = useState<PageData | null>(null);
  const [isEditing, setIsEditing] = useState(false);
  const [searchTerm, setSearchTerm] = useState('');
  const [filterStatus, setFilterStatus] = useState<'all' | 'draft' | 'published'>('all');

  // Load pages from localStorage on mount
  useEffect(() => {
    const savedPages = localStorage.getItem(`pages_${pageType}`);
    if (savedPages) {
      setPages(JSON.parse(savedPages));
    }
  }, [pageType]);

  // Save pages to localStorage
  const savePages = (newPages: PageData[]) => {
    localStorage.setItem(`pages_${pageType}`, JSON.stringify(newPages));
    setPages(newPages);
  };

  // Create new page
  const handleCreatePage = () => {
    const newPage: PageData = {
      id: Date.now().toString(),
      title: `Trang ${pageType} mới`,
      slug: `trang-${pageType}-${Date.now()}`,
      content: [],
      author: 'Chloe Quý Châu',
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
      status: 'draft',
      pageType
    };
    
    setSelectedPage(newPage);
    setIsEditing(true);
  };

  // Edit existing page
  const handleEditPage = (page: PageData) => {
    setSelectedPage(page);
    setIsEditing(true);
  };

  // Save page from editor
  const handleSavePage = (page: PageData) => {
    const existingIndex = pages.findIndex(p => p.id === page.id);
    let newPages: PageData[];
    
    if (existingIndex >= 0) {
      newPages = [...pages];
      newPages[existingIndex] = { ...page, updatedAt: new Date().toISOString() };
    } else {
      newPages = [...pages, page];
    }
    
    savePages(newPages);
    alert('Trang đã được lưu thành công!');
  };

  // Delete page
  const handleDeletePage = (id: string) => {
    if (confirm('Bạn có chắc chắn muốn xóa trang này?')) {
      const newPages = pages.filter(p => p.id !== id);
      savePages(newPages);
    }
  };

  // Duplicate page
  const handleDuplicatePage = (page: PageData) => {
    const duplicatedPage: PageData = {
      ...JSON.parse(JSON.stringify(page)),
      id: Date.now().toString(),
      title: `${page.title} (Copy)`,
      slug: `${page.slug}-copy-${Date.now()}`,
      status: 'draft',
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    };
    
    const newPages = [...pages, duplicatedPage];
    savePages(newPages);
  };

  // Publish/Unpublish page
  const handleTogglePublish = (page: PageData) => {
    const newStatus: 'draft' | 'published' = page.status === 'published' ? 'draft' : 'published';
    const updatedPage = { ...page, status: newStatus, updatedAt: new Date().toISOString() };
    const newPages = pages.map(p => p.id === page.id ? updatedPage : p);
    savePages(newPages);
  };

  // Export page
  const handleExportPage = (page: PageData) => {
    const dataStr = JSON.stringify(page, null, 2);
    const dataBlob = new Blob([dataStr], { type: 'application/json' });
    const url = URL.createObjectURL(dataBlob);
    const link = document.createElement('a');
    link.href = url;
    link.download = `${page.slug}.json`;
    link.click();
    URL.revokeObjectURL(url);
  };

  // Filter pages
  const filteredPages = pages.filter(page => {
    const matchesSearch = page.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         page.slug.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesStatus = filterStatus === 'all' || page.status === filterStatus;
    return matchesSearch && matchesStatus;
  });

  // Get page type info
  const getPageTypeInfo = () => {
    switch (pageType) {
      case 'nlp':
        return {
          title: 'Trang NLP',
          description: 'Quản lý các trang về Neuro Linguistic Programming',
          icon: '🧠',
          color: 'blue'
        };
      case 'time-line-therapy':
        return {
          title: 'Trang Time-line Therapy',
          description: 'Quản lý các trang về Time-line Therapy®',
          icon: '⏰',
          color: 'purple'
        };
      case 'about':
        return {
          title: 'Trang About',
          description: 'Quản lý các trang giới thiệu',
          icon: '👋',
          color: 'green'
        };
      default:
        return {
          title: 'Trang tùy chỉnh',
          description: 'Quản lý các trang tùy chỉnh',
          icon: '📄',
          color: 'gray'
        };
    }
  };

  const pageTypeInfo = getPageTypeInfo();

  // Show editor if editing
  if (isEditing && selectedPage) {
    return (
      <div className="min-h-screen bg-gray-50">
        <div className="bg-white shadow-sm border-b">
          <div className="max-w-7xl mx-auto px-6 py-4">
            <div className="flex items-center justify-between">
              <div className="flex items-center space-x-3">
                <span className="text-2xl">{pageTypeInfo.icon}</span>
                <div>
                  <h1 className="text-2xl font-bold text-gray-900">
                    {pages.find(p => p.id === selectedPage.id) ? 'Chỉnh sửa' : 'Tạo mới'} {pageTypeInfo.title}
                  </h1>
                  <p className="text-gray-600">{selectedPage.title}</p>
                </div>
              </div>
              
              <button
                onClick={() => {
                  setIsEditing(false);
                  setSelectedPage(null);
                }}
                className="px-4 py-2 text-gray-600 hover:text-gray-900 border border-gray-300 rounded-lg hover:bg-gray-50 transition-colors"
              >
                ← Quay lại
              </button>
            </div>
          </div>
        </div>
        
        <WebBuilder
          initialPage={selectedPage}
          onSave={handleSavePage}
          onPreview={(page: PageData) => console.log('Preview:', page)}
          pageType={pageType}
        />
      </div>
    );
  }

  return (
    <div className="max-w-7xl mx-auto p-6">
      {/* Header */}
      <div className="flex items-center justify-between mb-8">
        <div className="flex items-center space-x-3">
          <span className="text-3xl">{pageTypeInfo.icon}</span>
          <div>
            <h1 className="text-3xl font-bold text-gray-900">{pageTypeInfo.title}</h1>
            <p className="text-gray-600 mt-1">{pageTypeInfo.description}</p>
          </div>
        </div>
        
        <button
          onClick={handleCreatePage}
          className={`flex items-center px-6 py-3 bg-${pageTypeInfo.color}-600 text-white rounded-lg hover:bg-${pageTypeInfo.color}-700 transition-colors font-medium`}
        >
          <Plus className="w-5 h-5 mr-2" />
          Tạo trang mới
        </button>
      </div>

      {/* Filters */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-4 mb-6">
        <div className="flex items-center justify-between">
          <div className="flex items-center space-x-4">
            <input
              type="text"
              placeholder="Tìm kiếm trang..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
            
            <select
              value={filterStatus}
              onChange={(e) => setFilterStatus(e.target.value as 'all' | 'draft' | 'published')}
              className="px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
              <option value="all">Tất cả trạng thái</option>
              <option value="draft">Bản nháp</option>
              <option value="published">Đã xuất bản</option>
            </select>
          </div>
          
          <div className="text-sm text-gray-500">
            {filteredPages.length} / {pages.length} trang
          </div>
        </div>
      </div>

      {/* Pages List */}
      {filteredPages.length === 0 ? (
        <div className="text-center py-12">
          <div className="text-6xl mb-4">{pageTypeInfo.icon}</div>
          <h3 className="text-xl font-medium text-gray-900 mb-2">
            {pages.length === 0 ? 'Chưa có trang nào' : 'Không tìm thấy trang nào'}
          </h3>
          <p className="text-gray-600 mb-6">
            {pages.length === 0 
              ? `Tạo trang ${pageTypeInfo.title.toLowerCase()} đầu tiên để bắt đầu`
              : 'Thử thay đổi bộ lọc hoặc từ khóa tìm kiếm'
            }
          </p>
          {pages.length === 0 && (
            <button
              onClick={handleCreatePage}
              className={`px-6 py-3 bg-${pageTypeInfo.color}-600 text-white rounded-lg hover:bg-${pageTypeInfo.color}-700 transition-colors font-medium`}
            >
              Tạo trang đầu tiên
            </button>
          )}
        </div>
      ) : (
        <div className="grid grid-cols-1 lg:grid-cols-2 xl:grid-cols-3 gap-6">
          {filteredPages.map((page) => (
            <div key={page.id} className="bg-white rounded-lg border border-gray-200 shadow-sm overflow-hidden hover:shadow-md transition-shadow">
              {/* Page Preview */}
              <div className="h-48 bg-gradient-to-br from-gray-100 to-gray-200 flex items-center justify-center">
                <div className="text-center">
                  <span className="text-4xl mb-2 block">{pageTypeInfo.icon}</span>
                  <div className="text-sm text-gray-600">{page.content.length} blocks</div>
                </div>
              </div>
              
              {/* Page Info */}
              <div className="p-4">
                <div className="flex items-start justify-between mb-3">
                  <div className="flex-1">
                    <h3 className="font-semibold text-gray-900 mb-1">{page.title}</h3>
                    <p className="text-sm text-gray-600">/{page.slug}</p>
                  </div>
                  
                  <span className={`px-2 py-1 text-xs rounded-full ${
                    page.status === 'published' 
                      ? 'bg-green-100 text-green-800' 
                      : 'bg-gray-100 text-gray-800'
                  }`}>
                    {page.status === 'published' ? 'Published' : 'Draft'}
                  </span>
                </div>
                
                <div className="text-xs text-gray-500 mb-4">
                  <div>Tạo: {new Date(page.createdAt).toLocaleDateString('vi-VN')}</div>
                  <div>Cập nhật: {new Date(page.updatedAt).toLocaleDateString('vi-VN')}</div>
                </div>
                
                {/* Actions */}
                <div className="flex items-center space-x-2">
                  <button
                    onClick={() => handleEditPage(page)}
                    className="flex-1 flex items-center justify-center px-3 py-2 bg-blue-600 text-white text-sm rounded hover:bg-blue-700 transition-colors"
                  >
                    <Edit className="w-4 h-4 mr-1" />
                    Sửa
                  </button>
                  
                  <button
                    onClick={() => handleTogglePublish(page)}
                    className={`px-3 py-2 text-sm rounded transition-colors ${
                      page.status === 'published'
                        ? 'bg-gray-200 text-gray-700 hover:bg-gray-300'
                        : 'bg-green-600 text-white hover:bg-green-700'
                    }`}
                    title={page.status === 'published' ? 'Unpublish' : 'Publish'}
                  >
                    <Eye className="w-4 h-4" />
                  </button>
                  
                  <button
                    onClick={() => handleDuplicatePage(page)}
                    className="px-3 py-2 bg-gray-200 text-gray-700 text-sm rounded hover:bg-gray-300 transition-colors"
                    title="Duplicate"
                  >
                    <Copy className="w-4 h-4" />
                  </button>
                  
                  <button
                    onClick={() => handleExportPage(page)}
                    className="px-3 py-2 bg-gray-200 text-gray-700 text-sm rounded hover:bg-gray-300 transition-colors"
                    title="Export"
                  >
                    <Download className="w-4 h-4" />
                  </button>
                  
                  <button
                    onClick={() => handleDeletePage(page.id)}
                    className="px-3 py-2 bg-red-600 text-white text-sm rounded hover:bg-red-700 transition-colors"
                    title="Delete"
                  >
                    <Trash2 className="w-4 h-4" />
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
};
