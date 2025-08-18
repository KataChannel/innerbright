'use client'

import React, { useState, useCallback } from 'react';
import { PlusIcon, TrashIcon, MoveIcon } from 'lucide-react';

interface Block {
  id: string;
  type: 'heading' | 'paragraph' | 'image' | 'quote' | 'list' | 'hero' | 'card' | 'feature';
  content: any;
  order: number;
}

interface WebBuilderProps {
  initialContent?: Block[];
  onChange: (content: Block[], htmlContent: string) => void;
}

const WebBuilder: React.FC<WebBuilderProps> = ({ initialContent = [], onChange }) => {
  const [blocks, setBlocks] = useState<Block[]>(initialContent);
  const [draggedBlock, setDraggedBlock] = useState<string | null>(null);

  const generateId = () => `block_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;

  const addBlock = useCallback((type: Block['type']) => {
    const newBlock: Block = {
      id: generateId(),
      type,
      content: getDefaultContent(type),
      order: blocks.length
    };
    
    const updatedBlocks = [...blocks, newBlock];
    setBlocks(updatedBlocks);
    updateOutput(updatedBlocks);
  }, [blocks]);

  const updateBlock = useCallback((id: string, content: any) => {
    const updatedBlocks = blocks.map(block => 
      block.id === id ? { ...block, content } : block
    );
    setBlocks(updatedBlocks);
    updateOutput(updatedBlocks);
  }, [blocks]);

  const deleteBlock = useCallback((id: string) => {
    const updatedBlocks = blocks.filter(block => block.id !== id);
    setBlocks(updatedBlocks);
    updateOutput(updatedBlocks);
  }, [blocks]);

  const moveBlock = useCallback((fromIndex: number, toIndex: number) => {
    const updatedBlocks = [...blocks];
    const [movedBlock] = updatedBlocks.splice(fromIndex, 1);
    updatedBlocks.splice(toIndex, 0, movedBlock);
    
    // Update order
    updatedBlocks.forEach((block, index) => {
      block.order = index;
    });
    
    setBlocks(updatedBlocks);
    updateOutput(updatedBlocks);
  }, [blocks]);

  const updateOutput = (blocks: Block[]) => {
    const htmlContent = blocksToHtml(blocks);
    onChange(blocks, htmlContent);
  };

  const getDefaultContent = (type: Block['type']) => {
    switch (type) {
      case 'heading':
        return { text: 'Tiêu đề mới', level: 2 };
      case 'paragraph':
        return { text: 'Đoạn văn bản mới...' };
      case 'image':
        return { src: '', alt: '', caption: '' };
      case 'quote':
        return { text: 'Trích dẫn...', author: '' };
      case 'list':
        return { items: ['Mục 1', 'Mục 2'], ordered: false };
      case 'hero':
        return { title: 'Tiêu đề Hero', subtitle: 'Phụ đề', backgroundImage: '', description: 'Mô tả...' };
      case 'card':
        return { title: 'Tiêu đề Card', text: 'Nội dung card...', image: '' };
      case 'feature':
        return { title: 'Tính năng', description: 'Mô tả tính năng...', image: '' };
      default:
        return {};
    }
  };

  const blocksToHtml = (blocks: Block[]) => {
    return blocks.map(block => {
      switch (block.type) {
        case 'heading':
          return `<h${block.content.level}>${block.content.text}</h${block.content.level}>`;
        case 'paragraph':
          return `<p>${block.content.text}</p>`;
        case 'image':
          return `<figure><img src="${block.content.src}" alt="${block.content.alt}" />${block.content.caption ? `<figcaption>${block.content.caption}</figcaption>` : ''}</figure>`;
        case 'quote':
          return `<blockquote><p>${block.content.text}</p>${block.content.author ? `<cite>— ${block.content.author}</cite>` : ''}</blockquote>`;
        case 'list':
          const tag = block.content.ordered ? 'ol' : 'ul';
          const items = block.content.items.map((item: string) => `<li>${item}</li>`).join('');
          return `<${tag}>${items}</${tag}>`;
        case 'hero':
          return `<div class="hero-section relative h-96 bg-cover bg-center rounded-xl overflow-hidden mb-8" style="background-image: url('${block.content.backgroundImage}')">
            <div class="absolute inset-0 bg-gradient-to-r from-black/60 to-transparent"></div>
            <div class="absolute inset-0 flex items-center">
              <div class="container mx-auto px-8">
                <div class="max-w-2xl">
                  <h1 class="text-5xl font-bold text-white mb-6">${block.content.title}</h1>
                  <p class="text-xl text-white/90">${block.content.subtitle}</p>
                  <p class="text-lg text-white/80 mt-4">${block.content.description}</p>
                </div>
              </div>
            </div>
          </div>`;
        case 'card':
          return `<div class="bg-white rounded-lg shadow-md p-6 text-center">
            <img src="${block.content.image}" alt="${block.content.title}" class="w-full h-48 object-cover rounded-lg mb-4">
            <h3 class="text-xl font-bold mb-3">${block.content.title}</h3>
            <p class="text-gray-700">${block.content.text}</p>
          </div>`;
        case 'feature':
          return `<div class="bg-white rounded-lg shadow-md overflow-hidden mb-6">
            <img src="${block.content.image}" alt="${block.content.title}" class="w-full h-64 object-cover">
            <div class="p-6">
              <h3 class="text-2xl font-bold mb-3">${block.content.title}</h3>
              <p class="text-gray-700 leading-relaxed">${block.content.description}</p>
            </div>
          </div>`;
        default:
          return '';
      }
    }).join('\n');
  };

  const handleDragStart = (e: React.DragEvent, blockId: string) => {
    setDraggedBlock(blockId);
    e.dataTransfer.effectAllowed = 'move';
  };

  const handleDragOver = (e: React.DragEvent) => {
    e.preventDefault();
    e.dataTransfer.dropEffect = 'move';
  };

  const handleDrop = (e: React.DragEvent, targetIndex: number) => {
    e.preventDefault();
    if (!draggedBlock) return;
    
    const fromIndex = blocks.findIndex(block => block.id === draggedBlock);
    if (fromIndex !== -1 && fromIndex !== targetIndex) {
      moveBlock(fromIndex, targetIndex);
    }
    setDraggedBlock(null);
  };

  return (
    <div className="web-builder bg-white rounded-lg border p-6">
      <div className="mb-6">
        <h3 className="text-lg font-semibold text-gray-900 mb-4">Web Builder</h3>
        
        {/* Block Toolbar */}
        <div className="flex flex-wrap gap-2 mb-6 p-4 bg-gray-50 rounded-lg">
          <button
            onClick={() => addBlock('heading')}
            className="px-3 py-2 text-sm bg-blue-500 text-white rounded hover:bg-blue-600 transition-colors"
          >
            <PlusIcon className="w-4 h-4 inline mr-1" />
            Tiêu đề
          </button>
          <button
            onClick={() => addBlock('paragraph')}
            className="px-3 py-2 text-sm bg-green-500 text-white rounded hover:bg-green-600 transition-colors"
          >
            <PlusIcon className="w-4 h-4 inline mr-1" />
            Đoạn văn
          </button>
          <button
            onClick={() => addBlock('image')}
            className="px-3 py-2 text-sm bg-purple-500 text-white rounded hover:bg-purple-600 transition-colors"
          >
            <PlusIcon className="w-4 h-4 inline mr-1" />
            Hình ảnh
          </button>
          <button
            onClick={() => addBlock('quote')}
            className="px-3 py-2 text-sm bg-orange-500 text-white rounded hover:bg-orange-600 transition-colors"
          >
            <PlusIcon className="w-4 h-4 inline mr-1" />
            Trích dẫn
          </button>
          <button
            onClick={() => addBlock('list')}
            className="px-3 py-2 text-sm bg-indigo-500 text-white rounded hover:bg-indigo-600 transition-colors"
          >
            <PlusIcon className="w-4 h-4 inline mr-1" />
            Danh sách
          </button>
          <button
            onClick={() => addBlock('hero')}
            className="px-3 py-2 text-sm bg-red-500 text-white rounded hover:bg-red-600 transition-colors"
          >
            <PlusIcon className="w-4 h-4 inline mr-1" />
            Hero
          </button>
          <button
            onClick={() => addBlock('card')}
            className="px-3 py-2 text-sm bg-teal-500 text-white rounded hover:bg-teal-600 transition-colors"
          >
            <PlusIcon className="w-4 h-4 inline mr-1" />
            Card
          </button>
          <button
            onClick={() => addBlock('feature')}
            className="px-3 py-2 text-sm bg-pink-500 text-white rounded hover:bg-pink-600 transition-colors"
          >
            <PlusIcon className="w-4 h-4 inline mr-1" />
            Feature
          </button>
        </div>
      </div>

      {/* Blocks */}
      <div className="space-y-4">
        {blocks.map((block, index) => (
          <div
            key={block.id}
            draggable
            onDragStart={(e) => handleDragStart(e, block.id)}
            onDragOver={handleDragOver}
            onDrop={(e) => handleDrop(e, index)}
            className="group relative border rounded-lg p-4 hover:border-blue-300 transition-colors"
          >
            {/* Block Controls */}
            <div className="absolute top-2 right-2 opacity-0 group-hover:opacity-100 transition-opacity flex gap-1">
              <button
                className="p-1 text-gray-400 hover:text-gray-600 cursor-move"
                title="Di chuyển"
              >
                <MoveIcon className="w-4 h-4" />
              </button>
              <button
                onClick={() => deleteBlock(block.id)}
                className="p-1 text-red-400 hover:text-red-600"
                title="Xóa"
              >
                <TrashIcon className="w-4 h-4" />
              </button>
            </div>

            {/* Block Content */}
            <BlockEditor
              block={block}
              onChange={(content) => updateBlock(block.id, content)}
            />
          </div>
        ))}
        
        {blocks.length === 0 && (
          <div className="text-center py-12 text-gray-500">
            <p className="mb-4">Chưa có nội dung nào.</p>
            <p className="text-sm">Nhấn vào các nút phía trên để thêm nội dung.</p>
          </div>
        )}
      </div>
    </div>
  );
};

// Block Editor Component
interface BlockEditorProps {
  block: Block;
  onChange: (content: any) => void;
}

const BlockEditor: React.FC<BlockEditorProps> = ({ block, onChange }) => {
  const updateContent = (updates: any) => {
    onChange({ ...block.content, ...updates });
  };

  switch (block.type) {
    case 'heading':
      return (
        <div>
          <div className="flex items-center gap-2 mb-2">
            <select
              value={block.content.level}
              onChange={(e) => updateContent({ level: parseInt(e.target.value) })}
              className="text-sm border rounded px-2 py-1"
            >
              <option value={1}>H1</option>
              <option value={2}>H2</option>
              <option value={3}>H3</option>
              <option value={4}>H4</option>
              <option value={5}>H5</option>
              <option value={6}>H6</option>
            </select>
          </div>
          <input
            type="text"
            value={block.content.text}
            onChange={(e) => updateContent({ text: e.target.value })}
            className="w-full text-xl font-bold border-none outline-none focus:ring-0"
            placeholder="Nhập tiêu đề..."
          />
        </div>
      );

    case 'paragraph':
      return (
        <textarea
          value={block.content.text}
          onChange={(e) => updateContent({ text: e.target.value })}
          rows={4}
          className="w-full border-none outline-none resize-none focus:ring-0"
          placeholder="Nhập nội dung đoạn văn..."
        />
      );

    case 'image':
      return (
        <div>
          <input
            type="url"
            value={block.content.src}
            onChange={(e) => updateContent({ src: e.target.value })}
            className="w-full mb-2 px-3 py-2 border rounded"
            placeholder="URL hình ảnh..."
          />
          <input
            type="text"
            value={block.content.alt}
            onChange={(e) => updateContent({ alt: e.target.value })}
            className="w-full mb-2 px-3 py-2 border rounded"
            placeholder="Mô tả hình ảnh (Alt text)..."
          />
          <input
            type="text"
            value={block.content.caption}
            onChange={(e) => updateContent({ caption: e.target.value })}
            className="w-full px-3 py-2 border rounded"
            placeholder="Chú thích hình ảnh..."
          />
          {block.content.src && (
            <div className="mt-3">
              <img
                src={block.content.src}
                alt={block.content.alt}
                className="max-w-full h-auto rounded"
              />
              {block.content.caption && (
                <p className="text-sm text-gray-600 mt-1">{block.content.caption}</p>
              )}
            </div>
          )}
        </div>
      );

    case 'quote':
      return (
        <div>
          <textarea
            value={block.content.text}
            onChange={(e) => updateContent({ text: e.target.value })}
            rows={3}
            className="w-full mb-2 px-3 py-2 border rounded italic"
            placeholder="Nhập trích dẫn..."
          />
          <input
            type="text"
            value={block.content.author}
            onChange={(e) => updateContent({ author: e.target.value })}
            className="w-full px-3 py-2 border rounded"
            placeholder="Tác giả (tùy chọn)..."
          />
        </div>
      );

    case 'list':
      return (
        <div>
          <div className="flex items-center gap-2 mb-2">
            <label className="flex items-center">
              <input
                type="radio"
                checked={!block.content.ordered}
                onChange={() => updateContent({ ordered: false })}
                className="mr-1"
              />
              Danh sách gạch đầu dòng
            </label>
            <label className="flex items-center">
              <input
                type="radio"
                checked={block.content.ordered}
                onChange={() => updateContent({ ordered: true })}
                className="mr-1"
              />
              Danh sách có số thứ tự
            </label>
          </div>
          {block.content.items.map((item: string, index: number) => (
            <div key={index} className="flex items-center gap-2 mb-1">
              <span className="text-sm text-gray-500 w-6">
                {block.content.ordered ? `${index + 1}.` : '•'}
              </span>
              <input
                type="text"
                value={item}
                onChange={(e) => {
                  const newItems = [...block.content.items];
                  newItems[index] = e.target.value;
                  updateContent({ items: newItems });
                }}
                className="flex-1 px-2 py-1 border rounded"
                placeholder={`Mục ${index + 1}...`}
              />
              <button
                onClick={() => {
                  const newItems = block.content.items.filter((_: any, i: number) => i !== index);
                  updateContent({ items: newItems });
                }}
                className="text-red-500 hover:text-red-700"
              >
                <TrashIcon className="w-4 h-4" />
              </button>
            </div>
          ))}
          <button
            onClick={() => {
              const newItems = [...block.content.items, ''];
              updateContent({ items: newItems });
            }}
            className="text-sm text-blue-500 hover:text-blue-700"
          >
            + Thêm mục
          </button>
        </div>
      );

    case 'hero':
      return (
        <div className="space-y-3">
          <input
            type="text"
            value={block.content.title}
            onChange={(e) => updateContent({ title: e.target.value })}
            className="w-full text-2xl font-bold border-none outline-none focus:ring-0"
            placeholder="Tiêu đề Hero..."
          />
          <input
            type="text"
            value={block.content.subtitle}
            onChange={(e) => updateContent({ subtitle: e.target.value })}
            className="w-full text-lg border-none outline-none focus:ring-0"
            placeholder="Phụ đề..."
          />
          <input
            type="url"
            value={block.content.backgroundImage}
            onChange={(e) => updateContent({ backgroundImage: e.target.value })}
            className="w-full px-3 py-2 border rounded"
            placeholder="URL hình nền..."
          />
          <textarea
            value={block.content.description}
            onChange={(e) => updateContent({ description: e.target.value })}
            rows={3}
            className="w-full px-3 py-2 border rounded resize-none"
            placeholder="Mô tả..."
          />
        </div>
      );

    case 'card':
      return (
        <div className="space-y-3">
          <input
            type="text"
            value={block.content.title}
            onChange={(e) => updateContent({ title: e.target.value })}
            className="w-full text-xl font-bold border-none outline-none focus:ring-0"
            placeholder="Tiêu đề Card..."
          />
          <input
            type="url"
            value={block.content.image}
            onChange={(e) => updateContent({ image: e.target.value })}
            className="w-full px-3 py-2 border rounded"
            placeholder="URL hình ảnh..."
          />
          <textarea
            value={block.content.text}
            onChange={(e) => updateContent({ text: e.target.value })}
            rows={3}
            className="w-full px-3 py-2 border rounded resize-none"
            placeholder="Nội dung card..."
          />
        </div>
      );

    case 'feature':
      return (
        <div className="space-y-3">
          <input
            type="text"
            value={block.content.title}
            onChange={(e) => updateContent({ title: e.target.value })}
            className="w-full text-xl font-bold border-none outline-none focus:ring-0"
            placeholder="Tiêu đề Feature..."
          />
          <input
            type="url"
            value={block.content.image}
            onChange={(e) => updateContent({ image: e.target.value })}
            className="w-full px-3 py-2 border rounded"
            placeholder="URL hình ảnh..."
          />
          <textarea
            value={block.content.description}
            onChange={(e) => updateContent({ description: e.target.value })}
            rows={4}
            className="w-full px-3 py-2 border rounded resize-none"
            placeholder="Mô tả feature..."
          />
        </div>
      );

    default:
      return <div>Loại block không hỗ trợ</div>;
  }
};

export default WebBuilder;
