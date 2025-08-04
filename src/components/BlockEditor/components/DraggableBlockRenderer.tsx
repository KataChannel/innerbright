// 📝 Draggable Block Renderer Component
"use client";

import React, { useState } from 'react';
import { 
  Trash2, 
  Plus, 
  ChevronUp,
  ChevronDown,
  Copy,
  ArrowRight,
  ArrowLeft,
  GripVertical
} from 'lucide-react';
import { DraggableBlockRendererProps } from '../types';
import { isContainerBlock, getBlockTypeIcon } from '../utils';
import { BlockContent } from './BlockContent';
import { AddBlockMenu } from './AddBlock';

export const DraggableBlockRenderer: React.FC<DraggableBlockRendererProps> = ({
  block,
  isActive,
  isExpanded,
  isDragging,
  isDropTarget,
  dropPosition,
  onActivate,
  onUpdate,
  onDelete,
  onMove,
  onClone,
  onAddAfter,
  onToggleExpanded,
  onDragStart,
  onDragEnd,
  onDragOver,
  onDragLeave,
  onDrop,
  level
}) => {
  const [showAddMenu, setShowAddMenu] = useState(false);
  const isContainer = isContainerBlock(block.type);
  const hasChildren = block.children && block.children.length > 0;

  return (
    <div
      className={`group relative transition-all ${
        level > 0 ? 'ml-4' : ''
      } ${isDragging ? 'opacity-50' : ''}`}
      style={{ marginLeft: level * 16 }}
    >
      {/* Drop Indicators */}
      {isDropTarget && dropPosition === 'before' && (
        <div className="absolute -top-1 left-0 right-0 h-0.5 bg-blue-500 z-10"></div>
      )}
      {isDropTarget && dropPosition === 'after' && (
        <div className="absolute -bottom-1 left-0 right-0 h-0.5 bg-blue-500 z-10"></div>
      )}
      {isDropTarget && dropPosition === 'inside' && isContainer && (
        <div className="absolute inset-0 border-2 border-blue-500 bg-blue-50 bg-opacity-20 rounded-lg z-10 pointer-events-none"></div>
      )}

      <div
        className={`border-2 rounded-lg p-4 transition-all cursor-pointer ${
          isActive ? 'border-blue-500 bg-blue-50' : 'border-transparent hover:border-gray-300'
        } ${isContainer ? 'border-dashed' : ''} ${
          isDropTarget ? 'ring-2 ring-blue-300' : ''
        }`}
        onClick={onActivate}
        draggable
        onDragStart={onDragStart}
        onDragEnd={onDragEnd}
        onDragOver={(e) => {
          e.preventDefault();
          const rect = e.currentTarget.getBoundingClientRect();
          const midY = rect.top + rect.height / 2;
          const position = isContainer && e.clientY > midY && e.clientY < rect.bottom - 20
            ? 'inside'
            : e.clientY < midY
            ? 'before'
            : 'after';
          onDragOver(e, block.id, position);
        }}
        onDragLeave={onDragLeave}
        onDrop={(e) => {
          const rect = e.currentTarget.getBoundingClientRect();
          const midY = rect.top + rect.height / 2;
          const position = isContainer && e.clientY > midY && e.clientY < rect.bottom - 20
            ? 'inside'
            : e.clientY < midY
            ? 'before'
            : 'after';
          onDrop(e, block.id, position);
        }}
      >
        {/* Enhanced Block Controls with Drag Handle */}
        {isActive && (
          <div className="absolute -top-3 right-2 flex space-x-1 bg-white border border-gray-300 rounded-lg shadow-lg p-1 z-10">
            {/* Drag Handle */}
            <div
              className="p-1 hover:bg-gray-100 rounded cursor-grab active:cursor-grabbing"
              title="Kéo thả"
              onMouseDown={(e) => e.stopPropagation()}
            >
              <GripVertical className="w-4 h-4 text-gray-500" />
            </div>
            
            {isContainer && (
              <button
                onClick={(e) => { 
                  e.stopPropagation(); 
                  onToggleExpanded(); 
                }}
                className="p-1 hover:bg-gray-100 rounded"
                title={isExpanded ? "Thu gọn" : "Mở rộng"}
              >
                {isExpanded ? <ChevronUp className="w-4 h-4" /> : <ChevronDown className="w-4 h-4" />}
              </button>
            )}
            <button
              onClick={(e) => { e.stopPropagation(); onMove(block.id, 'up'); }}
              className="p-1 hover:bg-gray-100 rounded"
              title="Di chuyển lên"
            >
              <ChevronUp className="w-4 h-4" />
            </button>
            <button
              onClick={(e) => { e.stopPropagation(); onMove(block.id, 'down'); }}
              className="p-1 hover:bg-gray-100 rounded"
              title="Di chuyển xuống"
            >
              <ChevronDown className="w-4 h-4" />
            </button>
            {level > 0 && (
              <>
                <button
                  onClick={(e) => { e.stopPropagation(); onMove(block.id, 'left'); }}
                  className="p-1 hover:bg-gray-100 rounded"
                  title="Ra ngoài"
                >
                  <ArrowLeft className="w-4 h-4" />
                </button>
                <button
                  onClick={(e) => { e.stopPropagation(); onMove(block.id, 'right'); }}
                  className="p-1 hover:bg-gray-100 rounded"
                  title="Vào trong"
                >
                  <ArrowRight className="w-4 h-4" />
                </button>
              </>
            )}
            <button
              onClick={(e) => { e.stopPropagation(); onClone(); }}
              className="p-1 hover:bg-gray-100 rounded"
              title="Sao chép"
            >
              <Copy className="w-4 h-4" />
            </button>
            <button
              onClick={(e) => { 
                e.stopPropagation(); 
                setShowAddMenu(!showAddMenu); 
              }}
              className="p-1 hover:bg-gray-100 rounded"
              title="Thêm block"
            >
              <Plus className="w-4 h-4" />
            </button>
            <button
              onClick={(e) => { e.stopPropagation(); onDelete(); }}
              className="p-1 hover:bg-red-100 text-red-600 rounded"
              title="Xóa"
            >
              <Trash2 className="w-4 h-4" />
            </button>
          </div>
        )}

        {/* Block Type Indicator */}
        <div className="absolute -left-2 top-2 w-4 h-4 bg-blue-500 text-white rounded-full flex items-center justify-center text-xs font-bold">
          {getBlockTypeIcon(block.type)}
        </div>

        {/* Enhanced Block Content */}
        <BlockContent block={block} onUpdate={onUpdate} />

        {/* Add Block Menu */}
        {showAddMenu && (
          <div className="absolute top-full left-0 mt-2 bg-white border border-gray-300 rounded-lg shadow-lg p-2 z-20">
            <AddBlockMenu 
              onAdd={(type) => {
                if (isContainer) {
                  onAddAfter(type, block.id);
                } else {
                  onAddAfter(type, block.parentId);
                }
                setShowAddMenu(false);
              }}
              showContainers={true}
            />
          </div>
        )}
      </div>

      {/* Render Children with Drag & Drop */}
      {isContainer && hasChildren && isExpanded && (
        <div className="mt-4 space-y-4 border-l-2 border-gray-200 pl-4">
          {block.children!
            .sort((a, b) => a.order - b.order)
            .map((child) => (
              <DraggableBlockRenderer
                key={child.id}
                block={child}
                isActive={false}
                isExpanded={true}
                isDragging={false}
                isDropTarget={false}
                dropPosition={null}
                onActivate={() => {}}
                onUpdate={onUpdate}
                onDelete={onDelete}
                onMove={onMove}
                onClone={onClone}
                onAddAfter={onAddAfter}
                onToggleExpanded={onToggleExpanded}
                onDragStart={onDragStart}
                onDragEnd={onDragEnd}
                onDragOver={onDragOver}
                onDragLeave={onDragLeave}
                onDrop={onDrop}
                level={level + 1}
              />
            ))}
        </div>
      )}
    </div>
  );
};
