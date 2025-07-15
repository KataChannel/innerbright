// 📝 Add Block Components
"use client";

import React, { useState } from 'react';
import { 
  Type, 
  Image, 
  Video, 
  Quote, 
  List, 
  Code, 
  Plus, 
  Columns,
  Layout,
  Grid3X3,
  Square
} from 'lucide-react';
import { AddBlockToolbarProps, AddBlockMenuProps, BlockType } from '../types';
import { CONTENT_BLOCKS, LAYOUT_BLOCKS } from '../constants';

export const AddBlockToolbar: React.FC<AddBlockToolbarProps> = ({ onAdd }) => {
  const [isOpen, setIsOpen] = useState(false);

  return (
    <div className="relative mt-8">
      <button
        onClick={() => setIsOpen(!isOpen)}
        className="flex items-center justify-center w-full py-4 border-2 border-dashed border-gray-300 rounded-lg hover:border-blue-500 hover:bg-blue-50 transition-colors"
      >
        <Plus className="w-5 h-5 mr-2 text-gray-500" />
        <span className="text-gray-500">Thêm block</span>
      </button>

      {isOpen && (
        <div className="absolute top-full left-0 right-0 mt-2 bg-white border border-gray-300 rounded-lg shadow-lg p-4 z-10">
          <AddBlockMenu 
            onAdd={(type) => { 
              onAdd(type); 
              setIsOpen(false); 
            }} 
            showContainers={true}
          />
        </div>
      )}
    </div>
  );
};

export const AddBlockMenu: React.FC<AddBlockMenuProps> = ({ onAdd, showContainers = false }) => {
  const getIcon = (type: BlockType) => {
    switch (type) {
      case 'heading': return Type;
      case 'paragraph': return Type;
      case 'image': return Image;
      case 'quote': return Quote;
      case 'list': return List;
      case 'code': return Code;
      case 'video': return Video;
      case 'columns': return Columns;
      case 'section': return Layout;
      case 'card': return Square;
      case 'container': return Grid3X3;
      default: return Type;
    }
  };

  return (
    <div className="space-y-4">
      <div>
        <h4 className="text-sm font-medium text-gray-700 mb-2">Nội dung</h4>
        <div className="grid grid-cols-3 gap-2">
          {CONTENT_BLOCKS.map(({ type, label }) => {
            const Icon = getIcon(type);
            return (
              <button
                key={type}
                onClick={() => onAdd(type)}
                className="flex flex-col items-center space-y-1 p-3 rounded-lg hover:bg-gray-100 transition-colors"
              >
                <Icon className="w-5 h-5 text-gray-600" />
                <span className="text-xs">{label}</span>
              </button>
            );
          })}
        </div>
      </div>

      {showContainers && (
        <div>
          <h4 className="text-sm font-medium text-gray-700 mb-2">Bố cục</h4>
          <div className="grid grid-cols-2 gap-2">
            {LAYOUT_BLOCKS.map(({ type, label }) => {
              const Icon = getIcon(type);
              return (
                <button
                  key={type}
                  onClick={() => onAdd(type)}
                  className="flex flex-col items-center space-y-1 p-3 rounded-lg hover:bg-gray-100 transition-colors"
                >
                  <Icon className="w-5 h-5 text-gray-600" />
                  <span className="text-xs">{label}</span>
                </button>
              );
            })}
          </div>
        </div>
      )}
    </div>
  );
};
