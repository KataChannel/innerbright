// 📝 Page Block Renderer - Render từng block trong edit mode
"use client";

import React, { useState } from 'react';
import { 
  Edit, 
  Trash2, 
  Copy, 
  Move, 
  Eye, 
  EyeOff, 
  Settings,
  ChevronUp,
  ChevronDown,
  MoreHorizontal
} from 'lucide-react';
import { PageBlockRendererProps } from '../types';
import { getBlockIcon, stylesToCSS } from '../utils';
import { BlockContentRenderer } from './BlockContentRenderer';


export const PageBlockRenderer: React.FC<PageBlockRendererProps> = ({
  block,
  isActive,
  isEditMode,
  onUpdate,
  onDelete,
  onDuplicate,
  onStyleUpdate,
  onAnimationUpdate
}) => {
  const [isHovered, setIsHovered] = useState(false);
  const [showActions, setShowActions] = useState(false);

  const blockStyles = stylesToCSS(block.styles || {});

  if (!isEditMode) {
    // Preview mode - just render the content
    return (
      <div style={blockStyles} className="relative">
        <BlockContentRenderer block={block} isEditMode={false} onUpdate={onUpdate} />
      </div>
    );
  }

  // Edit mode - render with editing controls
  return (
    <div
      className={`relative group transition-all duration-200 ${
        isActive ? 'ring-2 ring-blue-500 ring-opacity-50' : ''
      } ${isHovered ? 'ring-1 ring-gray-300' : ''}`}
      onMouseEnter={() => setIsHovered(true)}
      onMouseLeave={() => setIsHovered(false)}
    >
      {/* Block Label & Actions */}
      {(isHovered || isActive || showActions) && (
        <div className="absolute -top-8 left-0 right-0 z-10 flex items-center justify-between">
          {/* Block Info */}
          <div className="flex items-center space-x-2 bg-gray-900 text-white px-2 py-1 rounded text-xs">
            <span>{getBlockIcon(block.type)}</span>
            <span className="font-medium">
              {block.type.charAt(0).toUpperCase() + block.type.slice(1).replace('-', ' ')}
            </span>
          </div>

          {/* Actions */}
          <div className="flex items-center space-x-1">
            <button
              onClick={() => setShowActions(!showActions)}
              className="p-1 bg-gray-700 text-white rounded hover:bg-gray-600 transition-colors"
              title="More actions"
            >
              <MoreHorizontal className="w-3 h-3" />
            </button>
          </div>
        </div>
      )}

      {/* Expanded Actions Menu */}
      {showActions && (
        <div className="absolute -top-12 right-0 z-20 bg-white border border-gray-200 rounded-lg shadow-lg p-2 flex items-center space-x-1">
          <button
            onClick={() => {/* Open style editor */}}
            className="p-1 hover:bg-gray-100 rounded transition-colors"
            title="Chỉnh sửa style"
          >
            <Settings className="w-4 h-4 text-gray-600" />
          </button>
          
          <button
            onClick={onDuplicate}
            className="p-1 hover:bg-gray-100 rounded transition-colors"
            title="Nhân bản"
          >
            <Copy className="w-4 h-4 text-gray-600" />
          </button>
          
          <button
            onClick={() => {/* Move up */}}
            className="p-1 hover:bg-gray-100 rounded transition-colors"
            title="Di chuyển lên"
          >
            <ChevronUp className="w-4 h-4 text-gray-600" />
          </button>
          
          <button
            onClick={() => {/* Move down */}}
            className="p-1 hover:bg-gray-100 rounded transition-colors"
            title="Di chuyển xuống"
          >
            <ChevronDown className="w-4 h-4 text-gray-600" />
          </button>
          
          <div className="w-px h-4 bg-gray-300"></div>
          
          <button
            onClick={onDelete}
            className="p-1 hover:bg-red-100 rounded transition-colors"
            title="Xóa"
          >
            <Trash2 className="w-4 h-4 text-red-600" />
          </button>
          
          <button
            onClick={() => setShowActions(false)}
            className="p-1 hover:bg-gray-100 rounded transition-colors"
            title="Đóng"
          >
            ×
          </button>
        </div>
      )}

      {/* Block Content */}
      <div 
        style={blockStyles}
        className={`min-h-[40px] transition-all duration-200 ${
          isActive ? 'bg-blue-50 bg-opacity-50' : ''
        }`}
      >
        <BlockContentRenderer 
          block={block} 
          isEditMode={true} 
          onUpdate={onUpdate} 
        />
      </div>

      {/* Drop Zone Indicators */}
      <div className="absolute -top-1 left-0 right-0 h-1 bg-blue-500 opacity-0 group-hover:opacity-100 transition-opacity"></div>
      <div className="absolute -bottom-1 left-0 right-0 h-1 bg-blue-500 opacity-0 group-hover:opacity-100 transition-opacity"></div>
    </div>
  );
};
