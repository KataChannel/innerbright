// 📝 Page Preview Component
"use client";

import React from 'react';
import { Edit } from 'lucide-react';
import { PagePreviewProps } from '../types';
import { BlockContentRenderer } from './BlockContentRenderer';

export const PagePreview: React.FC<PagePreviewProps> = ({ page, onEditMode }) => {
  return (
    <div className="min-h-screen bg-white">
      {/* Preview Header */}
      <div className="bg-gray-900 text-white py-4 sticky top-0 z-40">
        <div className="max-w-7xl mx-auto px-4 flex items-center justify-between">
          <div>
            <h1 className="text-xl font-semibold">{page.title}</h1>
            <p className="text-gray-300 text-sm">Preview Mode</p>
          </div>
          
          <button
            onClick={onEditMode}
            className="flex items-center px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
          >
            <Edit className="w-4 h-4 mr-2" />
            Chỉnh sửa
          </button>
        </div>
      </div>

      {/* Page Content */}
      <div className="overflow-hidden">
        {page.content
          .sort((a, b) => a.order - b.order)
          .map((block) => (
            <div key={block.id}>
              <BlockContentRenderer
                block={block}
                isEditMode={false}
                onUpdate={() => {}}
              />
            </div>
          ))}
      </div>

      {/* SEO Meta Preview */}
      {page.seoSettings && (
        <div className="fixed bottom-4 right-4 bg-white border border-gray-200 rounded-lg shadow-lg p-4 max-w-sm">
          <h4 className="font-medium mb-2">SEO Preview</h4>
          <div className="text-sm">
            <div className="text-blue-600 font-medium">{page.seoSettings.title || page.title}</div>
            <div className="text-green-600 text-xs">{window.location.origin}/{page.slug}</div>
            <div className="text-gray-600 mt-1">
              {page.seoSettings.description || page.metaDescription}
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
