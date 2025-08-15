'use client'

import React, { useState, useEffect } from 'react';
import WebBuilder from '@/components/WebBuilder';
import { PlusIcon, SaveIcon, EyeIcon } from 'lucide-react';

interface Category {
  id: string;
  name: string;
  slug: string;
  color?: string;
}

interface Tag {
  id: string;
  name: string;
  slug: string;
  color?: string;
}

interface Post {
  id?: string;
  title: string;
  slug: string;
  excerpt: string;
  content: any[];
  htmlContent: string;
  metaTitle: string;
  metaDescription: string;
  featuredImage: string;
  status: 'DRAFT' | 'PUBLISHED' | 'ARCHIVED';
  categoryId: string;
  tags: string[];
  isSticky: boolean;
}

const PostEditor: React.FC = () => {
  const [post, setPost] = useState<Post>({
    title: '',
    slug: '',
    excerpt: '',
    content: [],
    htmlContent: '',
    metaTitle: '',
    metaDescription: '',
    featuredImage: '',
    status: 'DRAFT',
    categoryId: '',
    tags: [],
    isSticky: false
  });

  const [categories, setCategories] = useState<Category[]>([]);
  const [tags, setTags] = useState<Tag[]>([]);
  const [loading, setLoading] = useState(false);
  const [showPreview, setShowPreview] = useState(false);

  useEffect(() => {
    fetchCategories();
    fetchTags();
  }, []);

  const fetchCategories = async () => {
    try {
      const response = await fetch('/api/categories');
      const data = await response.json();
      if (data.success) {
        setCategories(data.data);
      }
    } catch (error) {
      console.error('Error fetching categories:', error);
    }
  };

  const fetchTags = async () => {
    try {
      const response = await fetch('/api/tags');
      const data = await response.json();
      if (data.success) {
        setTags(data.data);
      }
    } catch (error) {
      console.error('Error fetching tags:', error);
    }
  };

  const generateSlug = (title: string) => {
    return title
      .toLowerCase()
      .normalize('NFD')
      .replace(/[\u0300-\u036f]/g, '')
      .replace(/[đĐ]/g, 'd')
      .replace(/[^a-z0-9\s-]/g, '')
      .replace(/\s+/g, '-')
      .replace(/-+/g, '-')
      .trim();
  };

  const handleTitleChange = (title: string) => {
    const slug = generateSlug(title);
    setPost(prev => ({
      ...prev,
      title,
      slug,
      metaTitle: title
    }));
  };

  const handleWebBuilderChange = (content: any[], htmlContent: string) => {
    setPost(prev => ({
      ...prev,
      content,
      htmlContent
    }));
  };

  const handleSave = async (status: 'DRAFT' | 'PUBLISHED') => {
    setLoading(true);
    try {
      const postData = {
        ...post,
        status,
        authorId: 'temp-user-id' // Replace with actual user ID from auth
      };

      const response = await fetch('/api/posts', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(postData),
      });

      const data = await response.json();
      
      if (data.success) {
        alert(`Bài viết đã được ${status === 'PUBLISHED' ? 'xuất bản' : 'lưu nháp'} thành công!`);
        // Reset form or redirect
      } else {
        alert(`Lỗi: ${data.error}`);
      }
    } catch (error) {
      console.error('Error saving post:', error);
      alert('Có lỗi xảy ra khi lưu bài viết');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="max-w-7xl mx-auto py-6 px-4">
        {/* Header */}
        <div className="mb-6 flex items-center justify-between">
          <h1 className="text-3xl font-bold text-gray-900">Tạo bài viết mới</h1>
          <div className="flex gap-2">
            <button
              onClick={() => setShowPreview(!showPreview)}
              className="px-4 py-2 text-gray-600 border border-gray-300 rounded-lg hover:bg-gray-50 flex items-center gap-2"
            >
              <EyeIcon className="w-4 h-4" />
              {showPreview ? 'Ẩn xem trước' : 'Xem trước'}
            </button>
            <button
              onClick={() => handleSave('DRAFT')}
              disabled={loading}
              className="px-4 py-2 text-gray-600 border border-gray-300 rounded-lg hover:bg-gray-50 flex items-center gap-2"
            >
              <SaveIcon className="w-4 h-4" />
              Lưu nháp
            </button>
            <button
              onClick={() => handleSave('PUBLISHED')}
              disabled={loading}
              className="px-4 py-2 bg-primary text-white rounded-lg hover:bg-primary-hover flex items-center gap-2"
            >
              <PlusIcon className="w-4 h-4" />
              Xuất bản
            </button>
          </div>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {/* Main Content */}
          <div className="lg:col-span-2 space-y-6">
            {/* Post Info */}
            <div className="bg-white rounded-lg shadow p-6">
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Tiêu đề bài viết *
                  </label>
                  <input
                    type="text"
                    value={post.title}
                    onChange={(e) => handleTitleChange(e.target.value)}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary focus:border-primary"
                    placeholder="Nhập tiêu đề bài viết..."
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Slug URL
                  </label>
                  <input
                    type="text"
                    value={post.slug}
                    onChange={(e) => setPost(prev => ({ ...prev, slug: e.target.value }))}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary focus:border-primary"
                    placeholder="url-bai-viet"
                  />
                  <p className="text-sm text-gray-500 mt-1">
                    URL: /posts/{post.slug}
                  </p>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Mô tả ngắn
                  </label>
                  <textarea
                    value={post.excerpt}
                    onChange={(e) => setPost(prev => ({ ...prev, excerpt: e.target.value }))}
                    rows={3}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary focus:border-primary"
                    placeholder="Mô tả ngắn gọn về bài viết..."
                  />
                </div>
              </div>
            </div>

            {/* Web Builder */}
            <WebBuilder
              initialContent={post.content}
              onChange={handleWebBuilderChange}
            />
          </div>

          {/* Sidebar */}
          <div className="space-y-6">
            {/* Post Settings */}
            <div className="bg-white rounded-lg shadow p-6">
              <h3 className="text-lg font-medium text-gray-900 mb-4">Cài đặt bài viết</h3>
              
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Danh mục
                  </label>
                  <select
                    value={post.categoryId}
                    onChange={(e) => setPost(prev => ({ ...prev, categoryId: e.target.value }))}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary focus:border-primary"
                  >
                    <option value="">Chọn danh mục...</option>
                    {categories.map(category => (
                      <option key={category.id} value={category.id}>
                        {category.name}
                      </option>
                    ))}
                  </select>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Tags
                  </label>
                  <div className="space-y-2">
                    {tags.map(tag => (
                      <label key={tag.id} className="flex items-center">
                        <input
                          type="checkbox"
                          checked={post.tags.includes(tag.id)}
                          onChange={(e) => {
                            if (e.target.checked) {
                              setPost(prev => ({ ...prev, tags: [...prev.tags, tag.id] }));
                            } else {
                              setPost(prev => ({ 
                                ...prev, 
                                tags: prev.tags.filter(t => t !== tag.id) 
                              }));
                            }
                          }}
                          className="rounded border-gray-300 text-primary shadow-sm focus:border-primary focus:ring focus:ring-primary/20 focus:ring-opacity-50"
                        />
                        <span className="ml-2 text-sm text-gray-700">{tag.name}</span>
                      </label>
                    ))}
                  </div>
                </div>

                <div>
                  <label className="flex items-center">
                    <input
                      type="checkbox"
                      checked={post.isSticky}
                      onChange={(e) => setPost(prev => ({ ...prev, isSticky: e.target.checked }))}
                      className="rounded border-gray-300 text-primary shadow-sm focus:border-primary focus:ring focus:ring-primary/20 focus:ring-opacity-50"
                    />
                    <span className="ml-2 text-sm text-gray-700">Ghim bài viết</span>
                  </label>
                </div>
              </div>
            </div>

            {/* Featured Image */}
            <div className="bg-white rounded-lg shadow p-6">
              <h3 className="text-lg font-medium text-gray-900 mb-4">Hình ảnh đại diện</h3>
              <input
                type="url"
                value={post.featuredImage}
                onChange={(e) => setPost(prev => ({ ...prev, featuredImage: e.target.value }))}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary focus:border-primary"
                placeholder="URL hình ảnh..."
              />
              {post.featuredImage && (
                <div className="mt-3">
                  <img
                    src={post.featuredImage}
                    alt="Featured"
                    className="w-full h-32 object-cover rounded-lg"
                  />
                </div>
              )}
            </div>

            {/* SEO */}
            <div className="bg-white rounded-lg shadow p-6">
              <h3 className="text-lg font-medium text-gray-900 mb-4">SEO</h3>
              
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Meta Title
                  </label>
                  <input
                    type="text"
                    value={post.metaTitle}
                    onChange={(e) => setPost(prev => ({ ...prev, metaTitle: e.target.value }))}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary focus:border-primary"
                    placeholder="Tiêu đề SEO..."
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Meta Description
                  </label>
                  <textarea
                    value={post.metaDescription}
                    onChange={(e) => setPost(prev => ({ ...prev, metaDescription: e.target.value }))}
                    rows={3}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary focus:border-primary"
                    placeholder="Mô tả SEO..."
                  />
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Preview Modal */}
        {showPreview && (
          <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
            <div className="bg-white rounded-lg max-w-4xl w-full max-h-[90vh] overflow-y-auto">
              <div className="p-6 border-b">
                <div className="flex items-center justify-between">
                  <h2 className="text-xl font-semibold">Xem trước bài viết</h2>
                  <button
                    onClick={() => setShowPreview(false)}
                    className="text-gray-500 hover:text-gray-700"
                  >
                    ✕
                  </button>
                </div>
              </div>
              <div className="p-6">
                <article className="prose prose-lg max-w-none">
                  <h1>{post.title}</h1>
                  {post.excerpt && <p className="lead text-gray-600">{post.excerpt}</p>}
                  <div dangerouslySetInnerHTML={{ __html: post.htmlContent }} />
                </article>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default PostEditor;
