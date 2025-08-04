// 📝 Post Preview Component
"use client";

import React from 'react';
import { PostPreviewProps, BlockData } from '../types';

export const PostPreview: React.FC<PostPreviewProps> = ({ post, onEditMode }) => {
  const renderBlockTree = (blocks: BlockData[]): React.ReactNode => {
    return blocks
      .sort((a, b) => a.order - b.order)
      .map((block) => (
        <div key={block.id}>
          <BlockPreview block={block} />
          {block.children && block.children.length > 0 && (
            <div className="ml-4">
              {renderBlockTree(block.children)}
            </div>
          )}
        </div>
      ));
  };

  return (
    <div className="max-w-6xl mx-auto p-6 bg-white">
      <div className="border-b border-gray-200 pb-6 mb-8">
        <div className="flex justify-between items-start mb-4">
          <div className="flex-1">
            <h1 className="text-4xl font-bold text-gray-900 mb-4">{post.title}</h1>
            <p className="text-xl text-gray-600 mb-4">{post.excerpt}</p>
            <div className="flex items-center space-x-4 text-sm text-gray-500">
              <span>Tác giả: {post.author}</span>
              <span>•</span>
              <span>{new Date(post.publishedAt).toLocaleDateString('vi-VN')}</span>
            </div>
          </div>
          <button
            onClick={onEditMode}
            className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
          >
            Chỉnh sửa
          </button>
        </div>

        <div className="flex flex-wrap gap-2">
          {post.tags.map((tag, index) => (
            <span
              key={index}
              className="px-3 py-1 bg-blue-100 text-blue-800 text-sm rounded-full"
            >
              {tag}
            </span>
          ))}
        </div>
      </div>

      <div className="prose prose-lg max-w-none">
        {renderBlockTree(post.content)}
      </div>
    </div>
  );
};

// Block Preview Component
const BlockPreview: React.FC<{ block: BlockData }> = ({ block }) => {
  switch (block.type) {
    case 'columns':
      const { columnCount, gap } = block.content;
      const gapClass = gap === 'small' ? 'gap-2' : gap === 'medium' ? 'gap-4' : 'gap-6';
      
      return (
        <div className={`grid grid-cols-${columnCount} ${gapClass} my-8`}>
          {block.children?.map((child) => (
            <div key={child.id} className="min-h-[100px]">
              <BlockPreview block={child} />
            </div>
          ))}
        </div>
      );

    case 'section':
      const sectionPadding = block.content.padding === 'small' ? 'p-4' : 
                           block.content.padding === 'medium' ? 'p-8' : 'p-12';
      
      return (
        <section 
          className={`${sectionPadding} rounded-lg my-8`}
          style={{ backgroundColor: block.content.backgroundColor }}
        >
          {block.children?.map((child) => (
            <BlockPreview key={child.id} block={child} />
          ))}
        </section>
      );

    case 'card':
      return (
        <div className={`rounded-lg p-6 my-6 ${block.content.shadow ? 'shadow-lg' : ''}`} style={{ backgroundColor: block.content.backgroundColor }}>
          {block.content.title && (
            <h3 className="text-xl font-semibold mb-4">{block.content.title}</h3>
          )}
          {block.children?.map((child) => (
            <BlockPreview key={child.id} block={child} />
          ))}
        </div>
      );

    case 'heading':
      if (block.content.level === 1) {
        return <h1 className="text-4xl font-bold text-gray-900 mt-8 mb-4">{block.content.text}</h1>;
      } else if (block.content.level === 2) {
        return <h2 className="text-3xl font-bold text-gray-900 mt-8 mb-4">{block.content.text}</h2>;
      } else {
        return <h3 className="text-2xl font-bold text-gray-900 mt-8 mb-4">{block.content.text}</h3>;
      }

    case 'paragraph':
      return <p className="text-gray-800 leading-relaxed mb-6">{block.content.text}</p>;

    case 'image':
      return (
        <figure className="my-8">
          <img
            src={block.content.src}
            alt={block.content.alt}
            className="w-full h-auto rounded-lg shadow-lg"
          />
          {block.content.caption && (
            <figcaption className="text-center text-sm text-gray-600 mt-3">
              {block.content.caption}
            </figcaption>
          )}
        </figure>
      );

    case 'quote':
      return (
        <blockquote className="border-l-4 border-blue-500 pl-6 py-4 my-8 italic text-gray-700 bg-gray-50 rounded-r-lg">
          <p className="text-lg mb-2">"{block.content.text}"</p>
          {block.content.author && (
            <cite className="text-sm text-gray-600">— {block.content.author}</cite>
          )}
        </blockquote>
      );

    case 'list':
      if (block.content.type === 'ol') {
        return (
          <ol className="list-decimal list-inside space-y-2 my-6 text-gray-800">
            {block.content.items.map((item: string, index: number) => (
              <li key={index}>{item}</li>
            ))}
          </ol>
        );
      } else {
        return (
          <ul className="list-disc list-inside space-y-2 my-6 text-gray-800">
            {block.content.items.map((item: string, index: number) => (
              <li key={index}>{item}</li>
            ))}
          </ul>
        );
      }

    case 'code':
      return (
        <div className="my-8">
          <div className="bg-gray-800 text-gray-100 p-4 rounded-t-lg text-sm">
            {block.content.language}
          </div>
          <pre className="bg-gray-900 text-gray-100 p-4 rounded-b-lg overflow-x-auto">
            <code>{block.content.code}</code>
          </pre>
        </div>
      );

    case 'video':
      return (
        <div className="my-8">
          {block.content.title && (
            <h4 className="text-lg font-semibold mb-4">{block.content.title}</h4>
          )}
          <div className="aspect-video bg-gray-200 rounded-lg flex items-center justify-center">
            {block.content.src ? (
              <video controls className="w-full h-full rounded-lg">
                <source src={block.content.src} />
                Video không thể tải
              </video>
            ) : (
              <span className="text-gray-500">Video Preview</span>
            )}
          </div>
        </div>
      );

    default:
      return null;
  }
};
