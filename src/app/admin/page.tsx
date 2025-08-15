'use client'

import React, { useState, useEffect } from 'react';
import Link from 'next/link';
import { 
  FileText, 
  Folder, 
  Tag, 
  Eye, 
  Heart, 
  TrendingUp,
  Plus,
  Edit3,
  Calendar,
  Users
} from 'lucide-react';

interface DashboardStats {
  posts: {
    total: number;
    published: number;
    draft: number;
    archived: number;
  };
  categories: {
    total: number;
    active: number;
  };
  tags: {
    total: number;
  };
  engagement: {
    totalViews: number;
    totalLikes: number;
    avgViews: number;
  };
  recentPosts: Array<{
    id: string;
    title: string;
    slug: string;
    status: string;
    views: number;
    likes: number;
    createdAt: string;
    category?: {
      name: string;
      color: string;
    };
  }>;
}

const AdminDashboard: React.FC = () => {
  const [stats, setStats] = useState<DashboardStats | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchDashboardStats();
  }, []);

  const fetchDashboardStats = async () => {
    setLoading(true);
    try {
      // Fetch posts stats
      const postsResponse = await fetch('/api/posts?limit=5&includeStats=true');
      const postsData = await postsResponse.json();
      
      // Fetch categories stats
      const categoriesResponse = await fetch('/api/categories?includeCount=true');
      const categoriesData = await categoriesResponse.json();
      
      // Fetch tags stats
      const tagsResponse = await fetch('/api/tags?includeCount=true');
      const tagsData = await tagsResponse.json();

      if (postsData.success && categoriesData.success && tagsData.success) {
        const allPosts = postsData.data.posts;
        const totalViews = allPosts.reduce((sum: number, post: any) => sum + post.views, 0);
        const totalLikes = allPosts.reduce((sum: number, post: any) => sum + post.likes, 0);
        
        setStats({
          posts: {
            total: postsData.data.pagination?.total || allPosts.length,
            published: allPosts.filter((p: any) => p.status === 'PUBLISHED').length,
            draft: allPosts.filter((p: any) => p.status === 'DRAFT').length,
            archived: allPosts.filter((p: any) => p.status === 'ARCHIVED').length
          },
          categories: {
            total: categoriesData.data.length,
            active: categoriesData.data.filter((c: any) => c.isActive).length
          },
          tags: {
            total: tagsData.data.length
          },
          engagement: {
            totalViews,
            totalLikes,
            avgViews: allPosts.length > 0 ? Math.round(totalViews / allPosts.length) : 0
          },
          recentPosts: allPosts.slice(0, 5)
        });
      }
    } catch (error) {
      console.error('Error fetching dashboard stats:', error);
    } finally {
      setLoading(false);
    }
  };

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('vi-VN', {
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });
  };

  const getStatusBadge = (status: string) => {
    const styles = {
      PUBLISHED: 'bg-green-100 text-green-800',
      DRAFT: 'bg-yellow-100 text-yellow-800',
      ARCHIVED: 'bg-gray-100 text-gray-800'
    };
    const labels = {
      PUBLISHED: 'Đã xuất bản',
      DRAFT: 'Bản nháp',
      ARCHIVED: 'Đã lưu trữ'
    };
    
    return (
      <span className={`px-2 py-1 text-xs font-medium rounded-full ${styles[status as keyof typeof styles]}`}>
        {labels[status as keyof typeof labels]}
      </span>
    );
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary mx-auto"></div>
          <p className="mt-4 text-gray-500">Đang tải dashboard...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="bg-white rounded-lg shadow p-6">
        <h1 className="text-3xl font-bold text-gray-900 mb-2">Dashboard</h1>
        <p className="text-gray-600">Tổng quan hệ thống quản lý blog InnerBright</p>
      </div>

      {/* Quick Actions */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <Link
          href="/admin/posts/new"
          className="bg-primary hover:bg-primary-hover text-white p-6 rounded-lg transition-colors group"
        >
          <div className="flex items-center">
            <Plus className="w-8 h-8 mr-3" />
            <div>
              <h3 className="font-semibold">Tạo bài viết</h3>
              <p className="text-primary-hover/70 text-sm">Viết bài mới</p>
            </div>
          </div>
        </Link>
        
        <Link
          href="/admin/posts"
          className="bg-white hover:bg-gray-50 border border-gray-200 p-6 rounded-lg transition-colors group"
        >
          <div className="flex items-center">
            <FileText className="w-8 h-8 mr-3 text-gray-600" />
            <div>
              <h3 className="font-semibold text-gray-900">Quản lý bài viết</h3>
              <p className="text-gray-500 text-sm">Xem tất cả bài viết</p>
            </div>
          </div>
        </Link>
        
        <Link
          href="/admin/categories"
          className="bg-white hover:bg-gray-50 border border-gray-200 p-6 rounded-lg transition-colors group"
        >
          <div className="flex items-center">
            <Folder className="w-8 h-8 mr-3 text-gray-600" />
            <div>
              <h3 className="font-semibold text-gray-900">Danh mục</h3>
              <p className="text-gray-500 text-sm">Quản lý danh mục</p>
            </div>
          </div>
        </Link>
        
        <Link
          href="/posts"
          className="bg-white hover:bg-gray-50 border border-gray-200 p-6 rounded-lg transition-colors group"
        >
          <div className="flex items-center">
            <Eye className="w-8 h-8 mr-3 text-gray-600" />
            <div>
              <h3 className="font-semibold text-gray-900">Xem Blog</h3>
              <p className="text-gray-500 text-sm">Trang công khai</p>
            </div>
          </div>
        </Link>
      </div>

      {/* Stats Grid */}
      {stats && (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          {/* Posts Stats */}
          <div className="bg-white rounded-lg shadow p-6">
            <div className="flex items-center">
              <div className="p-3 bg-primary/10 rounded-lg">
                <FileText className="w-6 h-6 text-primary" />
              </div>
              <div className="ml-4">
                <h3 className="text-lg font-semibold text-gray-900">{stats.posts.total}</h3>
                <p className="text-sm text-gray-500">Tổng bài viết</p>
              </div>
            </div>
            <div className="mt-4 text-sm text-gray-600">
              <div className="flex justify-between">
                <span>Đã xuất bản:</span>
                <span className="font-medium text-green-600">{stats.posts.published}</span>
              </div>
              <div className="flex justify-between">
                <span>Bản nháp:</span>
                <span className="font-medium text-yellow-600">{stats.posts.draft}</span>
              </div>
            </div>
          </div>

          {/* Categories Stats */}
          <div className="bg-white rounded-lg shadow p-6">
            <div className="flex items-center">
              <div className="p-3 bg-green-100 rounded-lg">
                <Folder className="w-6 h-6 text-green-600" />
              </div>
              <div className="ml-4">
                <h3 className="text-lg font-semibold text-gray-900">{stats.categories.total}</h3>
                <p className="text-sm text-gray-500">Danh mục</p>
              </div>
            </div>
            <div className="mt-4 text-sm text-gray-600">
              <div className="flex justify-between">
                <span>Kích hoạt:</span>
                <span className="font-medium text-green-600">{stats.categories.active}</span>
              </div>
            </div>
          </div>

          {/* Tags Stats */}
          <div className="bg-white rounded-lg shadow p-6">
            <div className="flex items-center">
              <div className="p-3 bg-purple-100 rounded-lg">
                <Tag className="w-6 h-6 text-purple-600" />
              </div>
              <div className="ml-4">
                <h3 className="text-lg font-semibold text-gray-900">{stats.tags.total}</h3>
                <p className="text-sm text-gray-500">Thẻ</p>
              </div>
            </div>
          </div>

          {/* Engagement Stats */}
          <div className="bg-white rounded-lg shadow p-6">
            <div className="flex items-center">
              <div className="p-3 bg-red-100 rounded-lg">
                <TrendingUp className="w-6 h-6 text-red-600" />
              </div>
              <div className="ml-4">
                <h3 className="text-lg font-semibold text-gray-900">{stats.engagement.totalViews.toLocaleString()}</h3>
                <p className="text-sm text-gray-500">Lượt xem</p>
              </div>
            </div>
            <div className="mt-4 text-sm text-gray-600">
              <div className="flex justify-between">
                <span>Lượt thích:</span>
                <span className="font-medium text-red-600">{stats.engagement.totalLikes}</span>
              </div>
              <div className="flex justify-between">
                <span>TB/bài:</span>
                <span className="font-medium">{stats.engagement.avgViews}</span>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Recent Posts */}
      {stats && stats.recentPosts.length > 0 && (
        <div className="bg-white rounded-lg shadow">
          <div className="p-6 border-b border-gray-200">
            <div className="flex items-center justify-between">
              <h2 className="text-xl font-semibold text-gray-900">Bài viết gần đây</h2>
              <Link
                href="/admin/posts"
                className="text-primary hover:text-primary-hover text-sm font-medium transition-colors"
              >
                Xem tất cả →
              </Link>
            </div>
          </div>
          <div className="overflow-x-auto">
            <table className="min-w-full">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Bài viết
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Trạng thái
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Thống kê
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Ngày tạo
                  </th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {stats.recentPosts.map((post) => (
                  <tr key={post.id} className="hover:bg-gray-50">
                    <td className="px-6 py-4">
                      <div className="flex items-center">
                        <div className="flex-1">
                          <Link
                            href={`/admin/posts/${post.slug}/edit`}
                            className="text-sm font-medium text-gray-900 hover:text-primary transition-colors"
                          >
                            {post.title}
                          </Link>
                          {post.category && (
                            <div className="mt-1">
                              <span
                                className="px-2 py-1 text-xs text-white rounded-full"
                                style={{ backgroundColor: post.category.color }}
                              >
                                {post.category.name}
                              </span>
                            </div>
                          )}
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      {getStatusBadge(post.status)}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="flex items-center gap-4 text-sm text-gray-500">
                        <div className="flex items-center gap-1">
                          <Eye className="w-4 h-4" />
                          <span>{post.views}</span>
                        </div>
                        <div className="flex items-center gap-1">
                          <Heart className="w-4 h-4" />
                          <span>{post.likes}</span>
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      <div className="flex items-center gap-1">
                        <Calendar className="w-4 h-4" />
                        <span>{formatDate(post.createdAt)}</span>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}
    </div>
  );
};

export default AdminDashboard;