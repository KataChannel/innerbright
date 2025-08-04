// 📝 Block Content Components
"use client";

import React from 'react';
import { BlockContentProps } from '../types';

export const BlockContent: React.FC<BlockContentProps> = ({ block, onUpdate }) => {
  switch (block.type) {
    case 'columns':
      return (
        <div className="space-y-4">
          <div className="flex items-center space-x-4">
            <label className="text-sm font-medium">Số cột:</label>
            <select
              value={block.content.columnCount}
              onChange={(e) => onUpdate({ ...block.content, columnCount: parseInt(e.target.value) })}
              className="px-3 py-1 border border-gray-300 rounded text-sm"
            >
              <option value={1}>1 cột</option>
              <option value={2}>2 cột</option>
              <option value={3}>3 cột</option>
              <option value={4}>4 cột</option>
            </select>
            
            <label className="text-sm font-medium">Khoảng cách:</label>
            <select
              value={block.content.gap}
              onChange={(e) => onUpdate({ ...block.content, gap: e.target.value })}
              className="px-3 py-1 border border-gray-300 rounded text-sm"
            >
              <option value="small">Nhỏ</option>
              <option value="medium">Trung bình</option>
              <option value="large">Lớn</option>
            </select>

            <label className="text-sm font-medium">Phân bố:</label>
            <select
              value={block.content.distribution}
              onChange={(e) => onUpdate({ ...block.content, distribution: e.target.value })}
              className="px-3 py-1 border border-gray-300 rounded text-sm"
            >
              <option value="equal">Đều nhau</option>
              <option value="1-2">1:2</option>
              <option value="2-1">2:1</option>
              <option value="1-2-1">1:2:1</option>
            </select>
          </div>
          
          <div className={`grid gap-${block.content.gap === 'small' ? '2' : block.content.gap === 'medium' ? '4' : '6'} grid-cols-${block.content.columnCount}`}>
            {Array.from({ length: block.content.columnCount }, (_, i) => (
              <div key={i} className="border-2 border-dashed border-gray-300 p-4 min-h-[100px] rounded">
                <span className="text-sm text-gray-500">Cột {i + 1}</span>
              </div>
            ))}
          </div>
        </div>
      );

    case 'section':
      return (
        <div className="space-y-4">
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium mb-1">Màu nền:</label>
              <input
                type="color"
                value={block.content.backgroundColor}
                onChange={(e) => onUpdate({ ...block.content, backgroundColor: e.target.value })}
                className="w-full h-10 border border-gray-300 rounded"
              />
            </div>
            <div>
              <label className="block text-sm font-medium mb-1">Padding:</label>
              <select
                value={block.content.padding}
                onChange={(e) => onUpdate({ ...block.content, padding: e.target.value })}
                className="w-full px-3 py-2 border border-gray-300 rounded"
              >
                <option value="small">Nhỏ</option>
                <option value="medium">Trung bình</option>
                <option value="large">Lớn</option>
              </select>
            </div>
          </div>
          <div
            className="border-2 border-dashed border-gray-300 p-8 rounded min-h-[150px]"
            style={{ backgroundColor: block.content.backgroundColor }}
          >
            <span className="text-sm text-gray-500">Nội dung section</span>
          </div>
        </div>
      );

    case 'card':
      return (
        <div className="space-y-4">
          <input
            type="text"
            value={block.content.title}
            onChange={(e) => onUpdate({ ...block.content, title: e.target.value })}
            className="w-full p-2 border border-gray-300 rounded"
            placeholder="Tiêu đề card..."
          />
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium mb-1">Màu nền:</label>
              <input
                type="color"
                value={block.content.backgroundColor}
                onChange={(e) => onUpdate({ ...block.content, backgroundColor: e.target.value })}
                className="w-full h-10 border border-gray-300 rounded"
              />
            </div>
            <div className="flex items-center space-x-4">
              <label className="flex items-center">
                <input
                  type="checkbox"
                  checked={block.content.shadow}
                  onChange={(e) => onUpdate({ ...block.content, shadow: e.target.checked })}
                  className="mr-2"
                />
                Bóng đổ
              </label>
            </div>
          </div>
          <div
            className={`border-2 border-dashed border-gray-300 p-6 rounded min-h-[120px] ${
              block.content.shadow ? 'shadow-lg' : ''
            }`}
            style={{ backgroundColor: block.content.backgroundColor }}
          >
            {block.content.title && (
              <h3 className="text-lg font-semibold mb-4">{block.content.title}</h3>
            )}
            <span className="text-sm text-gray-500">Nội dung card</span>
          </div>
        </div>
      );

    case 'heading':
      return (
        <div className="flex items-center space-x-2">
          <select
            value={block.content.level}
            onChange={(e) => onUpdate({ ...block.content, level: parseInt(e.target.value) })}
            className="px-2 py-1 border border-gray-300 rounded text-sm"
          >
            <option value={1}>H1</option>
            <option value={2}>H2</option>
            <option value={3}>H3</option>
          </select>
          <input
            type="text"
            value={block.content.text}
            onChange={(e) => onUpdate({ ...block.content, text: e.target.value })}
            className={`flex-1 border-none outline-none font-bold ${
              block.content.level === 1 ? 'text-3xl' :
              block.content.level === 2 ? 'text-2xl' : 'text-xl'
            }`}
            placeholder="Nhập tiêu đề..."
          />
        </div>
      );

    case 'paragraph':
      return (
        <textarea
          value={block.content.text}
          onChange={(e) => onUpdate({ ...block.content, text: e.target.value })}
          className="w-full border-none outline-none resize-none min-h-[60px] text-gray-800 leading-relaxed"
          placeholder="Nhập nội dung đoạn văn..."
          rows={3}
        />
      );

    case 'image':
      return (
        <div className="space-y-3">
          <input
            type="text"
            value={block.content.src}
            onChange={(e) => onUpdate({ ...block.content, src: e.target.value })}
            className="w-full p-2 border border-gray-300 rounded"
            placeholder="URL hình ảnh..."
          />
          {block.content.src && (
            <img
              src={block.content.src}
              alt={block.content.alt}
              className="max-w-full h-auto rounded-lg"
            />
          )}
          <input
            type="text"
            value={block.content.caption}
            onChange={(e) => onUpdate({ ...block.content, caption: e.target.value })}
            className="w-full p-2 border border-gray-300 rounded text-sm"
            placeholder="Chú thích hình ảnh..."
          />
        </div>
      );

    case 'quote':
      return (
        <div className="space-y-3">
          <textarea
            value={block.content.text}
            onChange={(e) => onUpdate({ ...block.content, text: e.target.value })}
            className="w-full p-3 border border-gray-300 rounded italic text-gray-700"
            placeholder="Nhập trích dẫn..."
            rows={3}
          />
          <input
            type="text"
            value={block.content.author}
            onChange={(e) => onUpdate({ ...block.content, author: e.target.value })}
            className="w-full p-2 border border-gray-300 rounded text-sm"
            placeholder="Tác giả..."
          />
        </div>
      );

    case 'list':
      return (
        <div className="space-y-3">
          <select
            value={block.content.type}
            onChange={(e) => onUpdate({ ...block.content, type: e.target.value })}
            className="px-3 py-1 border border-gray-300 rounded text-sm"
          >
            <option value="ul">Danh sách không đánh số</option>
            <option value="ol">Danh sách có đánh số</option>
          </select>
          {block.content.items.map((item: string, index: number) => (
            <div key={index} className="flex items-center space-x-2">
              <input
                type="text"
                value={item}
                onChange={(e) => {
                  const newItems = [...block.content.items];
                  newItems[index] = e.target.value;
                  onUpdate({ ...block.content, items: newItems });
                }}
                className="flex-1 p-2 border border-gray-300 rounded"
                placeholder={`Mục ${index + 1}...`}
              />
              <button
                onClick={() => {
                  const newItems = block.content.items.filter((_: any, i: number) => i !== index);
                  onUpdate({ ...block.content, items: newItems });
                }}
                className="text-red-500 hover:text-red-700"
              >
                ×
              </button>
            </div>
          ))}
          <button
            onClick={() => {
              const newItems = [...block.content.items, ''];
              onUpdate({ ...block.content, items: newItems });
            }}
            className="text-blue-500 hover:text-blue-700 text-sm"
          >
            + Thêm mục
          </button>
        </div>
      );

    case 'code':
      return (
        <div className="space-y-3">
          <select
            value={block.content.language}
            onChange={(e) => onUpdate({ ...block.content, language: e.target.value })}
            className="px-3 py-1 border border-gray-300 rounded text-sm"
          >
            <option value="javascript">JavaScript</option>
            <option value="typescript">TypeScript</option>
            <option value="python">Python</option>
            <option value="html">HTML</option>
            <option value="css">CSS</option>
          </select>
          <textarea
            value={block.content.code}
            onChange={(e) => onUpdate({ ...block.content, code: e.target.value })}
            className="w-full p-3 border border-gray-300 rounded font-mono text-sm bg-gray-50"
            placeholder="Nhập code..."
            rows={6}
          />
        </div>
      );

    case 'video':
      return (
        <div className="space-y-3">
          <input
            type="text"
            value={block.content.src}
            onChange={(e) => onUpdate({ ...block.content, src: e.target.value })}
            className="w-full p-2 border border-gray-300 rounded"
            placeholder="URL video..."
          />
          <input
            type="text"
            value={block.content.title}
            onChange={(e) => onUpdate({ ...block.content, title: e.target.value })}
            className="w-full p-2 border border-gray-300 rounded"
            placeholder="Tiêu đề video..."
          />
          {block.content.src && (
            <div className="aspect-video bg-gray-200 rounded-lg flex items-center justify-center">
              <span className="text-gray-500">Video Preview</span>
            </div>
          )}
        </div>
      );
    
    default:
      return <div className="text-gray-500">Block type: {block.type}</div>;
  }
};
