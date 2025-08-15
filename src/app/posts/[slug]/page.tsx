'use client'

import React, { useState, useEffect } from 'react';
import { useParams, notFound } from 'next/navigation';
import Head from 'next/head';
import Link from 'next/link';
import { CalendarIcon, UserIcon, EyeIcon, TagIcon, ArrowLeftIcon, ShareIcon, HeartIcon } from 'lucide-react';

interface Post {
  id: string;
  title: string;
  slug: string;
  content: string;
  excerpt?: string;
  status: 'DRAFT' | 'PUBLISHED' | 'ARCHIVED';
  publishedAt?: string;
  createdAt: string;
  updatedAt: string;
  views: number;
  likes: number;
  isSticky: boolean;
  metaTitle?: string;
  metaDescription?: string;
  category?: {
    id: string;
    name: string;
    slug: string;
    color?: string;
    description?: string;
  };
  author?: {
    id: string;
    displayName?: string;
    username?: string;
  };
  tags: Array<{
    tag: {
      id: string;
      name: string;
      slug: string;
      color?: string;
    };
  }>;
}

interface RelatedPost {
  id: string;
  title: string;
  slug: string;
  excerpt?: string;
  publishedAt?: string;
  category?: {
    name: string;
    color?: string;
  };
}

const PostPage: React.FC = () => {
  const params = useParams();
  const slug = params.slug as string;
  
  const [post, setPost] = useState<Post | null>(null);
  const [relatedPosts, setRelatedPosts] = useState<RelatedPost[]>([]);
  const [loading, setLoading] = useState(true);
  const [liked, setLiked] = useState(false);

  useEffect(() => {
    if (slug) {
      fetchPost();
    }
  }, [slug]);

  const fetchPost = async () => {
    setLoading(true);
    try {
      const response = await fetch(`/api/posts/${slug}`);
      if (response.status === 404) {
        notFound();
        return;
      }
      
      const data = await response.json();
      if (data.success) {
        setPost(data.data);
        // Increment view count
        await fetch(`/api/posts/${slug}/view`, { method: 'POST' });
        
        // Fetch related posts
        if (data.data.category) {
          fetchRelatedPosts(data.data.category.slug, data.data.id);
        }
      }
    } catch (error) {
      console.error('Error fetching post:', error);
    } finally {
      setLoading(false);
    }
  };

  const fetchRelatedPosts = async (categorySlug: string, excludeId: string) => {
    try {
      const response = await fetch(`/api/posts?category=${categorySlug}&limit=3&exclude=${excludeId}`);
      const data = await response.json();
      if (data.success) {
        setRelatedPosts(data.data.posts);
      }
    } catch (error) {
      console.error('Error fetching related posts:', error);
    }
  };

  const handleLike = async () => {
    if (!post) return;
    
    try {
      const response = await fetch(`/api/posts/${slug}/like`, {
        method: 'POST',
      });
      
      if (response.ok) {
        setLiked(!liked);
        setPost(prev => prev ? {
          ...prev,
          likes: liked ? prev.likes - 1 : prev.likes + 1
        } : null);
      }
    } catch (error) {
      console.error('Error toggling like:', error);
    }
  };

  const handleShare = async () => {
    if (navigator.share) {
      try {
        await navigator.share({
          title: post?.title,
          text: post?.excerpt,
          url: window.location.href,
        });
      } catch (error) {
        console.log('Error sharing:', error);
      }
    } else {
      // Fallback: copy to clipboard
      navigator.clipboard.writeText(window.location.href);
      alert('Đã sao chép liên kết!');
    }
  };

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('vi-VN', {
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    });
  };

  const renderContent = (content: string) => {
    // Parse JSON content from WebBuilder or render HTML
    try {
      const blocks = JSON.parse(content);
      return (
        <div className="prose prose-lg max-w-none">
          {blocks.map((block: any, index: number) => {
            switch (block.type) {
              case 'heading':
                const headingLevel = Math.min(Math.max(block.level || 1, 1), 6);
                const headingClasses = {
                  1: 'text-3xl font-bold leading-tight mb-6',
                  2: 'text-2xl font-bold leading-tight mb-5',
                  3: 'text-xl font-bold leading-tight mb-4',
                  4: 'text-lg font-bold leading-tight mb-4',
                  5: 'text-base font-bold leading-tight mb-3',
                  6: 'text-sm font-bold leading-tight mb-3'
                };
                
                if (headingLevel === 1) {
                  return (
                    <h1 key={index} className={`text-gray-900 ${headingClasses[1]}`}>
                      {block.content}
                    </h1>
                  );
                } else if (headingLevel === 2) {
                  return (
                    <h2 key={index} className={`text-gray-900 ${headingClasses[2]}`}>
                      {block.content}
                    </h2>
                  );
                } else if (headingLevel === 3) {
                  return (
                    <h3 key={index} className={`text-gray-900 ${headingClasses[3]}`}>
                      {block.content}
                    </h3>
                  );
                } else if (headingLevel === 4) {
                  return (
                    <h4 key={index} className={`text-gray-900 ${headingClasses[4]}`}>
                      {block.content}
                    </h4>
                  );
                } else if (headingLevel === 5) {
                  return (
                    <h5 key={index} className={`text-gray-900 ${headingClasses[5]}`}>
                      {block.content}
                    </h5>
                  );
                } else {
                  return (
                    <h6 key={index} className={`text-gray-900 ${headingClasses[6]}`}>
                      {block.content}
                    </h6>
                  );
                }
              case 'paragraph':
                return (
                  <p key={index} className="text-gray-700 leading-relaxed mb-4">
                    {block.content}
                  </p>
                );
              case 'image':
                return (
                  <div key={index} className="my-8">
                    <img
                      src={block.src}
                      alt={block.alt}
                      className="w-full h-auto rounded-lg shadow-md"
                    />
                    {block.caption && (
                      <p className="text-sm text-gray-500 text-center mt-2 italic">
                        {block.caption}
                      </p>
                    )}
                  </div>
                );
              case 'quote':
                return (
                  <blockquote key={index} className="border-l-4 border-blue-500 pl-6 py-4 my-6 bg-gray-50 rounded-r-lg">
                    <p className="text-gray-700 italic text-lg leading-relaxed">
                      "{block.content}"
                    </p>
                    {block.author && (
                      <cite className="text-gray-500 text-sm mt-2 block">
                        — {block.author}
                      </cite>
                    )}
                  </blockquote>
                );
              case 'list':
                const ListTag = block.style === 'ordered' ? 'ol' : 'ul';
                return (
                  <ListTag key={index} className={`my-4 ${block.style === 'ordered' ? 'list-decimal' : 'list-disc'} list-inside space-y-2`}>
                    {block.items.map((item: string, itemIndex: number) => (
                      <li key={itemIndex} className="text-gray-700 leading-relaxed">
                        {item}
                      </li>
                    ))}
                  </ListTag>
                );
              default:
                return null;
            }
          })}
        </div>
      );
    } catch (error) {
      // Fallback: render as HTML
      return (
        <div 
          className="prose prose-lg max-w-none"
          dangerouslySetInnerHTML={{ __html: content }}
        />
      );
    }
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-4 text-gray-500">Đang tải bài viết...</p>
        </div>
      </div>
    );
  }

  if (!post) {
    return notFound();
  }

  return (
    <>
      <Head>
        <title>{post.metaTitle || post.title}</title>
        <meta name="description" content={post.metaDescription || post.excerpt} />
        <meta property="og:title" content={post.title} />
        <meta property="og:description" content={post.excerpt} />
        <meta property="og:type" content="article" />
        <meta name="article:published_time" content={post.publishedAt || post.createdAt} />
        <meta name="article:modified_time" content={post.updatedAt} />
        {post.category && <meta name="article:section" content={post.category.name} />}
        {post.tags.map(postTag => (
          <meta key={postTag.tag.id} name="article:tag" content={postTag.tag.name} />
        ))}
      </Head>

      <div className="min-h-screen bg-gray-50">
        {/* Header Navigation */}
        <div className="bg-white shadow-sm border-b">
          <div className="max-w-4xl mx-auto px-4 py-3">
            <Link 
              href="/posts"
              className="inline-flex items-center gap-2 text-gray-600 hover:text-gray-900 transition-colors"
            >
              <ArrowLeftIcon className="w-4 h-4" />
              Quay lại danh sách bài viết
            </Link>
          </div>
        </div>

        {/* Main Content */}
        <article className="max-w-4xl mx-auto px-4 py-8">
          {/* Category Badge */}
          {post.category && (
            <div className="mb-4">
              <Link
                href={`/posts?category=${post.category.slug}`}
                className="inline-block px-3 py-1 text-sm font-medium text-white rounded-full hover:opacity-80 transition-opacity"
                style={{ backgroundColor: post.category.color || '#3B82F6' }}
              >
                {post.category.name}
              </Link>
            </div>
          )}

          {/* Title */}
          <h1 className="text-4xl md:text-5xl font-bold text-gray-900 leading-tight mb-6">
            {post.title}
            {post.isSticky && (
              <span className="ml-3 inline-block text-2xl">📌</span>
            )}
          </h1>

          {/* Excerpt */}
          {post.excerpt && (
            <p className="text-xl text-gray-600 leading-relaxed mb-8">
              {post.excerpt}
            </p>
          )}

          {/* Meta Information */}
          <div className="flex flex-wrap items-center gap-6 mb-8 text-sm text-gray-500">
            {post.author && (
              <div className="flex items-center gap-2">
                <UserIcon className="w-4 h-4" />
                <span>{post.author.displayName || post.author.username}</span>
              </div>
            )}
            <div className="flex items-center gap-2">
              <CalendarIcon className="w-4 h-4" />
              <span>{formatDate(post.publishedAt || post.createdAt)}</span>
            </div>
            <div className="flex items-center gap-2">
              <EyeIcon className="w-4 h-4" />
              <span>{post.views.toLocaleString()} lượt xem</span>
            </div>
          </div>

          {/* Content */}
          <div className="bg-white rounded-lg shadow-sm p-8 mb-8">
            {renderContent(post.content)}
          </div>

          {/* Tags */}
          {post.tags.length > 0 && (
            <div className="mb-8">
              <div className="flex items-center gap-2 mb-3">
                <TagIcon className="w-4 h-4 text-gray-500" />
                <span className="text-sm font-medium text-gray-700">Thẻ:</span>
              </div>
              <div className="flex flex-wrap gap-2">
                {post.tags.map((postTag) => (
                  <Link
                    key={postTag.tag.id}
                    href={`/posts?tag=${postTag.tag.slug}`}
                    className="px-3 py-1 text-sm bg-blue-100 text-blue-800 rounded-full hover:bg-blue-200 transition-colors"
                  >
                    {postTag.tag.name}
                  </Link>
                ))}
              </div>
            </div>
          )}

          {/* Actions */}
          <div className="flex items-center justify-between py-6 border-t border-gray-200">
            <button
              onClick={handleLike}
              className={`flex items-center gap-2 px-4 py-2 rounded-lg transition-colors ${
                liked 
                  ? 'bg-red-100 text-red-700 hover:bg-red-200' 
                  : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
              }`}
            >
              <HeartIcon className={`w-4 h-4 ${liked ? 'fill-current' : ''}`} />
              <span>{post.likes.toLocaleString()}</span>
            </button>

            <button
              onClick={handleShare}
              className="flex items-center gap-2 px-4 py-2 bg-blue-100 text-blue-700 rounded-lg hover:bg-blue-200 transition-colors"
            >
              <ShareIcon className="w-4 h-4" />
              Chia sẻ
            </button>
          </div>
        </article>

        {/* Related Posts */}
        {relatedPosts.length > 0 && (
          <section className="max-w-4xl mx-auto px-4 pb-16">
            <h2 className="text-2xl font-bold text-gray-900 mb-6">Bài viết liên quan</h2>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
              {relatedPosts.map((relatedPost) => (
                <article key={relatedPost.id} className="bg-white rounded-lg shadow-sm overflow-hidden hover:shadow-md transition-shadow">
                  <div className="p-6">
                    {relatedPost.category && (
                      <div className="mb-3">
                        <span
                          className="px-2 py-1 text-xs font-medium text-white rounded-full"
                          style={{ backgroundColor: relatedPost.category.color || '#3B82F6' }}
                        >
                          {relatedPost.category.name}
                        </span>
                      </div>
                    )}
                    <h3 className="text-lg font-semibold text-gray-900 mb-2 line-clamp-2">
                      <Link 
                        href={`/posts/${relatedPost.slug}`}
                        className="hover:text-blue-600 transition-colors"
                      >
                        {relatedPost.title}
                      </Link>
                    </h3>
                    {relatedPost.excerpt && (
                      <p className="text-gray-600 text-sm line-clamp-3 mb-3">
                        {relatedPost.excerpt}
                      </p>
                    )}
                    {relatedPost.publishedAt && (
                      <p className="text-xs text-gray-500">
                        {formatDate(relatedPost.publishedAt)}
                      </p>
                    )}
                  </div>
                </article>
              ))}
            </div>
          </section>
        )}
      </div>
    </>
  );
};

export default PostPage;
