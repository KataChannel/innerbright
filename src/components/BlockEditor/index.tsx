// 📝 Main BlockEditor Component - Tối ưu hóa và refactored
"use client";

import React, { useState } from 'react';
import { Save, Eye } from 'lucide-react';
import { BlockEditorProps } from './types';
import { mockPost } from './constants';
import { useBlockEditor } from './hooks/useBlockEditor';
import { useDragAndDrop } from './hooks/useDragAndDrop';
import { DraggableBlockRenderer } from './components/DraggableBlockRenderer';
import { AddBlockToolbar } from './components/AddBlock';
import { PostPreview } from './components/PostPreview';

const BlockEditor: React.FC<BlockEditorProps> = ({
  initialPost = mockPost,
  onSave,
  onPreview
}) => {
  const [isPreview, setIsPreview] = useState(false);

  // Use custom hooks
  const {
    post,
    setPost,
    activeBlockId,
    setActiveBlockId,
    expandedBlocks,
    setExpandedBlocks,
    addBlock,
    updateBlock,
    deleteBlock,
    moveBlock,
    cloneBlock,
    toggleExpanded
  } = useBlockEditor(initialPost);

  const {
    dragState,
    handleDragStart,
    handleDragEnd,
    handleDragOver,
    handleDragLeave,
    handleDrop
  } = useDragAndDrop(post, setPost, setExpandedBlocks);

  // Handle save
  const handleSave = () => {
    onSave?.(post);
  };

  // Handle preview
  const handlePreview = () => {
    setIsPreview(!isPreview);
    onPreview?.(post);
  };

  if (isPreview) {
    return <PostPreview post={post} onEditMode={() => setIsPreview(false)} />;
  }

  return (
    <div className="max-w-7xl mx-auto p-6 bg-white">
      {/* Drag Overlay */}
      {dragState.isDragging && (
        <div className="fixed inset-0 pointer-events-none z-50 bg-primary bg-opacity-5">
          <div className="absolute top-4 left-1/2 transform -translate-x-1/2 bg-blue-600 text-white px-4 py-2 rounded-lg shadow-lg">
            Đang di chuyển block...
          </div>
        </div>
      )}

      {/* Header */}
      <div className="border-b border-gray-200 pb-6 mb-8">
        <div className="flex justify-between items-start mb-4">
          <div className="flex-1">
            <input
              type="text"
              value={post.title}
              onChange={(e) => setPost(prev => ({ ...prev, title: e.target.value }))}
              className="text-3xl font-bold border-none outline-none w-full p-2 rounded"
              placeholder="Tiêu đề bài viết..."
            />
            <input
              type="text"
              value={post.excerpt}
              onChange={(e) => setPost(prev => ({ ...prev, excerpt: e.target.value }))}
              className="text-lg text-gray-600 border-none outline-none w-full p-2 rounded mt-2"
              placeholder="Mô tả ngắn..."
            />
          </div>
          <div className="flex space-x-2 ml-4">
            <button
              onClick={handlePreview}
              className="flex items-center px-4 py-2 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 transition-colors"
            >
              <Eye className="w-4 h-4 mr-2" />
              Xem trước
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

      {/* Enhanced Block Editor with Drag & Drop */}
      <div className="space-y-4">
        {post.content.map((block) => (
          <DraggableBlockRenderer
            key={block.id}
            block={block}
            isActive={activeBlockId === block.id}
            isExpanded={expandedBlocks.has(block.id)}
            isDragging={dragState.draggedBlockId === block.id}
            isDropTarget={dragState.dropTargetId === block.id}
            dropPosition={dragState.dropPosition}
            onActivate={() => setActiveBlockId(block.id)}
            onUpdate={(content) => updateBlock(block.id, content)}
            onDelete={() => deleteBlock(block.id)}
            onMove={moveBlock}
            onClone={() => cloneBlock(block.id)}
            onAddAfter={(type, parentId) => addBlock(type, block.id, parentId)}
            onToggleExpanded={() => toggleExpanded(block.id)}
            onDragStart={(e) => handleDragStart(e, block.id)}
            onDragEnd={handleDragEnd}
            onDragOver={handleDragOver}
            onDragLeave={handleDragLeave}
            onDrop={handleDrop}
            level={0}
          />
        ))}
      </div>

      {/* Enhanced Add Block Toolbar */}
      <AddBlockToolbar onAdd={addBlock} />
    </div>
  );
};

export default BlockEditor;
