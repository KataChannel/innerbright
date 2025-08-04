"use client";

import React, { useState } from 'react';
import BlockEditor, { Post } from '@/components/BlockEditor';
import { Section } from '@/components';

const BlockEditorDemo: React.FC = () => {
  const [savedPosts, setSavedPosts] = useState<Post[]>([]);
  const [selectedPost, setSelectedPost] = useState<Post | null>(null);

  const handleSave = (post: Post) => {
    const existingIndex = savedPosts.findIndex(p => p.id === post.id);
    if (existingIndex >= 0) {
      const updatedPosts = [...savedPosts];
      updatedPosts[existingIndex] = post;
      setSavedPosts(updatedPosts);
    } else {
      setSavedPosts(prev => [...prev, post]);
    }
    
    // Show success message
    alert('Bài viết đã được lưu thành công!');
  };

  const handlePreview = (post: Post) => {
    console.log('Preview post:', post);
  };

  const handleNewPost = () => {
    setSelectedPost({
      id: Date.now().toString(),
      title: '',
      slug: '',
      content: [],
      author: 'Chloe Quý Châu',
      publishedAt: new Date().toISOString().split('T')[0],
      tags: ['NLP'],
      status: 'draft',
      excerpt: '',
    });
  };

  const handleEditPost = (post: Post) => {
    setSelectedPost(post);
  };

  const handleBackToList = () => {
    setSelectedPost(null);
  };

  if (selectedPost) {
    return (
      <div className="min-h-screen bg-gray-50">
        <div className="bg-white shadow-sm border-b">
          <div className="max-w-6xl mx-auto px-6 py-4">
            <div className="flex items-center justify-between">
              <h1 className="text-2xl font-bold text-gray-900">Block Editor</h1>
              <button
                onClick={handleBackToList}
                className="px-4 py-2 text-gray-600 hover:text-gray-900 border border-gray-300 rounded-lg hover:bg-gray-50 transition-colors"
              >
                ← Quay lại danh sách
              </button>
            </div>
          </div>
        </div>
        
        <div className="py-8">
          <BlockEditor
            initialPost={selectedPost}
            onSave={handleSave}
            onPreview={handlePreview}
          />
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-white shadow-sm border-b">
        <div className="max-w-6xl mx-auto px-6 py-4">
          <div className="flex items-center justify-between">
            <div>
              <h1 className="text-3xl font-bold text-gray-900">Quản lý bài viết</h1>
              <p className="text-gray-600 mt-1">Tạo và chỉnh sửa bài viết với Block Editor</p>
            </div>
            <button
              onClick={handleNewPost}
              className="px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors font-medium"
            >
              + Tạo bài viết mới
            </button>
          </div>
        </div>
      </div>

      {/* Content */}
      <div className="max-w-6xl mx-auto px-6 py-8">
        {/* Stats */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
          <div className="bg-white p-6 rounded-xl shadow-sm border">
            <div className="flex items-center">
              <div className="p-3 bg-blue-100 rounded-lg">
                <svg className="w-6 h-6 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                </svg>
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-600">Tổng bài viết</p>
                <p className="text-2xl font-bold text-gray-900">{savedPosts.length}</p>
              </div>
            </div>
          </div>

          <div className="bg-white p-6 rounded-xl shadow-sm border">
            <div className="flex items-center">
              <div className="p-3 bg-green-100 rounded-lg">
                <svg className="w-6 h-6 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                </svg>
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-600">Đã xuất bản</p>
                <p className="text-2xl font-bold text-gray-900">
                  {savedPosts.filter(p => p.status === 'published').length}
                </p>
              </div>
            </div>
          </div>

          <div className="bg-white p-6 rounded-xl shadow-sm border">
            <div className="flex items-center">
              <div className="p-3 bg-yellow-100 rounded-lg">
                <svg className="w-6 h-6 text-yellow-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.572L16.732 3.732z" />
                </svg>
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-600">Bản nháp</p>
                <p className="text-2xl font-bold text-gray-900">
                  {savedPosts.filter(p => p.status === 'draft').length}
                </p>
              </div>
            </div>
          </div>
        </div>

        {/* Posts List */}
        <Section>
          <div className="flex items-center justify-between mb-6">
            <h2 className="text-xl font-bold text-gray-900">Danh sách bài viết</h2>
            <div className="flex space-x-2">
              <select className="px-3 py-2 border border-gray-300 rounded-lg text-sm">
                <option>Tất cả trạng thái</option>
                <option>Đã xuất bản</option>
                <option>Bản nháp</option>
              </select>
              <select className="px-3 py-2 border border-gray-300 rounded-lg text-sm">
                <option>Tất cả tags</option>
                <option>NLP</option>
                <option>Phát triển bản thân</option>
                <option>Coaching</option>
              </select>
            </div>
          </div>

          {savedPosts.length === 0 ? (
            <div className="text-center py-12">
              <div className="mx-auto w-24 h-24 bg-gray-100 rounded-full flex items-center justify-center mb-4">
                <svg className="w-12 h-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1} d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                </svg>
              </div>
              <h3 className="text-lg font-medium text-gray-900 mb-2">Chưa có bài viết nào</h3>
              <p className="text-gray-600 mb-6">Tạo bài viết đầu tiên để bắt đầu</p>
              <button
                onClick={handleNewPost}
                className="px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors font-medium"
              >
                Tạo bài viết mới
              </button>
            </div>
          ) : (
            <div className="space-y-4">
              {savedPosts.map((post) => (
                <div
                  key={post.id}
                  className="bg-white border border-gray-200 rounded-lg p-6 hover:shadow-md transition-shadow"
                >
                  <div className="flex items-start justify-between">
                    <div className="flex-1">
                      <h3 className="text-lg font-semibold text-gray-900 mb-2">
                        {post.title || 'Bài viết không có tiêu đề'}
                      </h3>
                      <p className="text-gray-600 mb-3">
                        {post.excerpt || 'Không có mô tả'}
                      </p>
                      <div className="flex items-center space-x-4 text-sm text-gray-500">
                        <span>Tác giả: {post.author}</span>
                        <span>•</span>
                        <span>{new Date(post.publishedAt).toLocaleDateString('vi-VN')}</span>
                        <span>•</span>
                        <span className={`px-2 py-1 rounded-full text-xs ${
                          post.status === 'published' 
                            ? 'bg-green-100 text-green-800' 
                            : 'bg-yellow-100 text-yellow-800'
                        }`}>
                          {post.status === 'published' ? 'Đã xuất bản' : 'Bản nháp'}
                        </span>
                      </div>
                      <div className="flex flex-wrap gap-2 mt-3">
                        {post.tags.map((tag, index) => (
                          <span
                            key={index}
                            className="px-2 py-1 bg-blue-100 text-blue-800 text-xs rounded-full"
                          >
                            {tag}
                          </span>
                        ))}
                      </div>
                    </div>
                    <div className="flex space-x-2 ml-4">
                      <button
                        onClick={() => handleEditPost(post)}
                        className="px-4 py-2 text-blue-600 hover:text-blue-800 border border-blue-300 rounded-lg hover:bg-blue-50 transition-colors"
                      >
                        Chỉnh sửa
                      </button>
                      <button className="px-4 py-2 text-gray-600 hover:text-gray-800 border border-gray-300 rounded-lg hover:bg-gray-50 transition-colors">
                        Xóa
                      </button>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          )}
        </Section>
      </div>
    </div>
  );
};

export default BlockEditorDemo;
