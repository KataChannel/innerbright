'use client'

import React, { useState, useEffect } from 'react';
import { PlusIcon, EditIcon, TrashIcon, SaveIcon, TagIcon } from 'lucide-react';

interface Tag {
  id: string;
  name: string;
  slug: string;
  color?: string;
  postCount?: number;
  createdAt: string;
}

const TagsManager: React.FC = () => {
  const [tags, setTags] = useState<Tag[]>([]);
  const [loading, setLoading] = useState(true);
  const [showForm, setShowForm] = useState(false);
  const [editingTag, setEditingTag] = useState<Tag | null>(null);
  
  // Form states
  const [name, setName] = useState('');
  const [color, setColor] = useState('#6B7280');
  const [submitting, setSubmitting] = useState(false);

  useEffect(() => {
    fetchTags();
  }, []);

  const fetchTags = async () => {
    setLoading(true);
    try {
      const response = await fetch('/api/tags?includeCount=true');
      const data = await response.json();
      if (data.success) {
        setTags(data.data);
      }
    } catch (error) {
      console.error('Error fetching tags:', error);
    } finally {
      setLoading(false);
    }
  };

  const generateSlug = (text: string) => {
    return text
      .toLowerCase()
      .normalize('NFD')
      .replace(/[\u0300-\u036f]/g, '')
      .replace(/[đĐ]/g, 'd')
      .replace(/[^a-z0-9\s-]/g, '')
      .replace(/\s+/g, '-')
      .replace(/-+/g, '-')
      .trim();
  };

  const resetForm = () => {
    setName('');
    setColor('#6B7280');
    setEditingTag(null);
    setShowForm(false);
  };

  const handleEdit = (tag: Tag) => {
    setEditingTag(tag);
    setName(tag.name);
    setColor(tag.color || '#6B7280');
    setShowForm(true);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!name.trim()) {
      alert('Vui lòng nhập tên thẻ');
      return;
    }

    setSubmitting(true);

    try {
      const tagData = {
        name: name.trim(),
        slug: generateSlug(name.trim()),
        color: color
      };

      const url = editingTag 
        ? `/api/tags/${editingTag.id}`
        : '/api/tags';
      
      const method = editingTag ? 'PUT' : 'POST';

      const response = await fetch(url, {
        method,
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(tagData),
      });

      const data = await response.json();

      if (data.success) {
        alert(editingTag ? 'Đã cập nhật thẻ thành công!' : 'Đã tạo thẻ mới thành công!');
        resetForm();
        fetchTags();
      } else {
        alert(`Có lỗi xảy ra: ${data.error}`);
      }
    } catch (error) {
      console.error('Error saving tag:', error);
      alert('Có lỗi xảy ra khi lưu thẻ');
    } finally {
      setSubmitting(false);
    }
  };

  const handleDelete = async (id: string, name: string) => {
    if (!confirm(`Bạn có chắc chắn muốn xóa thẻ "${name}"?`)) return;

    try {
      const response = await fetch(`/api/tags/${id}`, {
        method: 'DELETE',
      });

      if (response.ok) {
        alert('Đã xóa thẻ thành công!');
        fetchTags();
      } else {
        const data = await response.json();
        alert(`Có lỗi xảy ra: ${data.error || 'Không thể xóa thẻ'}`);
      }
    } catch (error) {
      console.error('Error deleting tag:', error);
      alert('Có lỗi xảy ra khi xóa thẻ');
    }
  };

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('vi-VN', {
      year: 'numeric',
      month: 'short',
      day: 'numeric'
    });
  };

  const getColorPresets = () => [
    '#6B7280', '#EF4444', '#F59E0B', '#10B981', '#3B82F6', 
    '#8B5CF6', '#EC4899', '#F97316', '#84CC16', '#06B6D4',
    '#6366F1', '#8B5A2B', '#059669', '#DC2626', '#7C3AED'
  ];

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="max-w-6xl mx-auto py-6 px-4">
        {/* Header */}
        <div className="mb-6">
          <div className="flex items-center justify-between">
            <div>
              <h1 className="text-3xl font-bold text-gray-900">Quản lý thẻ</h1>
              <p className="text-gray-600 mt-1">Quản lý các thẻ để phân loại bài viết</p>
            </div>
            <button
              onClick={() => setShowForm(true)}
              className="px-4 py-2 bg-primary text-white rounded-lg hover:bg-primary-hover flex items-center gap-2 transition-colors"
            >
              <PlusIcon className="w-4 h-4" />
              Thêm thẻ
            </button>
          </div>
        </div>

        {/* Form Modal */}
        {showForm && (
          <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
            <div className="bg-white rounded-lg max-w-md w-full p-6">
              <h2 className="text-xl font-semibold mb-4">
                {editingTag ? 'Chỉnh sửa thẻ' : 'Thêm thẻ mới'}
              </h2>
              
              <form onSubmit={handleSubmit} className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Tên thẻ *
                  </label>
                  <input
                    type="text"
                    value={name}
                    onChange={(e) => setName(e.target.value)}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary focus:border-primary"
                    placeholder="Nhập tên thẻ..."
                    required
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Màu sắc
                  </label>
                  <div className="space-y-3">
                    <div className="flex items-center gap-2">
                      <input
                        type="color"
                        value={color}
                        onChange={(e) => setColor(e.target.value)}
                        className="w-12 h-8 border border-gray-300 rounded cursor-pointer"
                      />
                      <input
                        type="text"
                        value={color}
                        onChange={(e) => setColor(e.target.value)}
                        className="flex-1 px-3 py-1 border border-gray-300 rounded text-sm"
                        placeholder="#6B7280"
                      />
                    </div>
                    
                    <div>
                      <p className="text-xs text-gray-500 mb-2">Màu sẵn có:</p>
                      <div className="grid grid-cols-8 gap-2">
                        {getColorPresets().map((presetColor) => (
                          <button
                            key={presetColor}
                            type="button"
                            onClick={() => setColor(presetColor)}
                            className={`w-6 h-6 rounded border-2 ${
                              color === presetColor ? 'border-gray-900' : 'border-gray-300'
                            }`}
                            style={{ backgroundColor: presetColor }}
                          />
                        ))}
                      </div>
                    </div>
                  </div>
                </div>

                {/* Preview */}
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Xem trước
                  </label>
                  <div className="p-3 bg-gray-50 rounded-lg">
                    <span
                      className="inline-block px-3 py-1 text-sm rounded-full text-white"
                      style={{ backgroundColor: color }}
                    >
                      {name || 'Tên thẻ'}
                    </span>
                  </div>
                </div>

                <div className="flex justify-end gap-2 pt-4">
                  <button
                    type="button"
                    onClick={resetForm}
                    className="px-4 py-2 text-gray-700 border border-gray-300 rounded-lg hover:bg-gray-50"
                  >
                    Hủy
                  </button>
                  <button
                    type="submit"
                    disabled={submitting}
                    className="px-4 py-2 bg-primary text-white rounded-lg hover:bg-primary-hover disabled:opacity-50 flex items-center gap-2 transition-colors"
                  >
                    <SaveIcon className="w-4 h-4" />
                    {submitting ? 'Đang lưu...' : (editingTag ? 'Cập nhật' : 'Tạo mới')}
                  </button>
                </div>
              </form>
            </div>
          </div>
        )}

        {/* Tags Grid */}
        <div className="bg-white rounded-lg shadow">
          {loading ? (
            <div className="p-8 text-center">
              <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary mx-auto"></div>
              <p className="mt-2 text-gray-500">Đang tải...</p>
            </div>
          ) : tags.length === 0 ? (
            <div className="p-8 text-center">
              <TagIcon className="w-12 h-12 text-gray-300 mx-auto mb-4" />
              <p className="text-gray-500">Chưa có thẻ nào.</p>
              <button
                onClick={() => setShowForm(true)}
                className="mt-4 px-4 py-2 bg-primary text-white rounded-lg hover:bg-primary-hover transition-colors"
              >
                Tạo thẻ đầu tiên
              </button>
            </div>
          ) : (
            <div className="p-6">
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                {tags.map((tag) => (
                  <div key={tag.id} className="border border-gray-200 rounded-lg p-4 hover:shadow-md transition-shadow">
                    <div className="flex items-center justify-between mb-2">
                      <span
                        className="inline-block px-3 py-1 text-sm rounded-full text-white font-medium"
                        style={{ backgroundColor: tag.color }}
                      >
                        {tag.name}
                      </span>
                      <div className="flex items-center gap-1">
                        <button
                          onClick={() => handleEdit(tag)}
                          className="text-primary hover:text-primary-hover p-1 transition-colors"
                          title="Chỉnh sửa"
                        >
                          <EditIcon className="w-4 h-4" />
                        </button>
                        <button
                          onClick={() => handleDelete(tag.id, tag.name)}
                          className="text-red-600 hover:text-red-900 p-1"
                          title="Xóa"
                        >
                          <TrashIcon className="w-4 h-4" />
                        </button>
                      </div>
                    </div>
                    
                    <div className="text-sm text-gray-500 space-y-1">
                      <div>Slug: /{tag.slug}</div>
                      <div>{tag.postCount || 0} bài viết</div>
                      <div>Tạo: {formatDate(tag.createdAt)}</div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}
        </div>

        {/* Summary Stats */}
        {tags.length > 0 && (
          <div className="mt-6 bg-white rounded-lg shadow p-6">
            <h3 className="text-lg font-medium text-gray-900 mb-4">Thống kê</h3>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              <div className="text-center">
                <div className="text-2xl font-bold text-primary">{tags.length}</div>
                <div className="text-sm text-gray-500">Tổng số thẻ</div>
              </div>
              <div className="text-center">
                <div className="text-2xl font-bold text-green-600">
                  {tags.reduce((sum, tag) => sum + (tag.postCount || 0), 0)}
                </div>
                <div className="text-sm text-gray-500">Tổng lượt sử dụng</div>
              </div>
              <div className="text-center">
                <div className="text-2xl font-bold text-purple-600">
                  {Math.round(tags.reduce((sum, tag) => sum + (tag.postCount || 0), 0) / tags.length * 10) / 10}
                </div>
                <div className="text-sm text-gray-500">Trung bình/thẻ</div>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default TagsManager;
