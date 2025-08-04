// 📝 Block Content Renderer - Render nội dung của từng loại block
"use client";

import React from 'react';
import { PageBlockData } from '../types';

interface BlockContentRendererProps {
  block: PageBlockData;
  isEditMode: boolean;
  onUpdate: (content: any) => void;
}

export const BlockContentRenderer: React.FC<BlockContentRendererProps> = ({
  block,
  isEditMode,
  onUpdate
}) => {
  const handleContentChange = (updates: any) => {
    onUpdate({ ...block.content, ...updates });
  };

  const renderEditableText = (
    text: string,
    field: string,
    placeholder: string = 'Nhấp để chỉnh sửa...',
    element: 'input' | 'textarea' = 'input'
  ) => {
    if (!isEditMode) {
      return text || placeholder;
    }

    const Component = element === 'textarea' ? 'textarea' : 'input';
    
    return (
      <Component
        value={text || ''}
        onChange={(e) => handleContentChange({ [field]: e.target.value })}
        placeholder={placeholder}
        className="w-full bg-transparent border-none outline-none resize-none"
        style={{ minHeight: element === 'textarea' ? '100px' : 'auto' }}
      />
    );
  };

  switch (block.type) {
    case 'hero':
      return (
        <div className="relative min-h-[400px] flex items-center justify-center text-center">
          {block.content.backgroundImage && (
            <div 
              className="absolute inset-0 bg-cover bg-center"
              style={{ backgroundImage: `url(${block.content.backgroundImage})` }}
            >
              <div 
                className="absolute inset-0 bg-black"
                style={{ opacity: block.content.overlayOpacity || 0.5 }}
              ></div>
            </div>
          )}
          
          <div className="relative z-10 max-w-4xl mx-auto px-6">
            {block.content.subtitle && (
              <div className="text-lg opacity-90 mb-4">
                {renderEditableText(block.content.subtitle, 'subtitle', 'Phụ đề')}
              </div>
            )}
            
            <h1 className="text-4xl md:text-6xl font-bold mb-6">
              {renderEditableText(block.content.title, 'title', 'Tiêu đề Hero')}
            </h1>
            
            <div className="text-xl opacity-90 mb-8 max-w-2xl mx-auto">
              {renderEditableText(block.content.description, 'description', 'Mô tả ngắn gọn...', 'textarea')}
            </div>
            
            {block.content.buttonText && (
              <div className="inline-block">
                <button className="bg-blue-600 hover:bg-blue-700 text-white px-8 py-3 rounded-lg font-medium transition-colors">
                  {renderEditableText(block.content.buttonText, 'buttonText', 'Text nút')}
                </button>
              </div>
            )}
          </div>
        </div>
      );

    case 'about-section':
      return (
        <div className={`flex items-center gap-12 ${block.content.layout === 'image-left' ? 'flex-row' : 'flex-row-reverse'}`}>
          <div className="flex-1">
            <h2 className="text-3xl font-bold mb-6">
              {renderEditableText(block.content.title, 'title', 'Tiêu đề phần')}
            </h2>
            
            <div className="text-lg text-gray-600 mb-8">
              {renderEditableText(block.content.description, 'description', 'Mô tả chi tiết...', 'textarea')}
            </div>
            
            {block.content.features && block.content.features.length > 0 && (
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                {block.content.features.map((feature: any, index: number) => (
                  <div key={index} className="flex items-start space-x-3">
                    <span className="text-2xl">{feature.icon}</span>
                    <div>
                      <h4 className="font-semibold mb-2">{feature.title}</h4>
                      <p className="text-gray-600">{feature.description}</p>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
          
          <div className="flex-1">
            {block.content.image ? (
              <img 
                src={block.content.image} 
                alt={block.content.title}
                className="w-full h-auto rounded-lg shadow-lg"
              />
            ) : (
              <div className="w-full h-64 bg-gray-200 rounded-lg flex items-center justify-center">
                <span className="text-gray-500">Thêm hình ảnh</span>
              </div>
            )}
          </div>
        </div>
      );

    case 'process-steps':
      return (
        <div className="text-center">
          <h2 className="text-3xl font-bold mb-4">
            {renderEditableText(block.content.title, 'title', 'Tiêu đề quy trình')}
          </h2>
          
          <div className="text-lg text-gray-600 mb-12 max-w-2xl mx-auto">
            {renderEditableText(block.content.description, 'description', 'Mô tả quy trình...', 'textarea')}
          </div>
          
          {block.content.steps && block.content.steps.length > 0 && (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8">
              {block.content.steps.map((step: any, index: number) => (
                <div key={step.id} className="text-center">
                  <div className="w-16 h-16 bg-blue-600 text-white rounded-full flex items-center justify-center text-xl font-bold mx-auto mb-4">
                    {step.number}
                  </div>
                  <h4 className="font-semibold mb-3">{step.title}</h4>
                  <p className="text-gray-600">{step.description}</p>
                </div>
              ))}
            </div>
          )}
        </div>
      );

    case 'testimonials':
      return (
        <div className="text-center">
          <h2 className="text-3xl font-bold mb-12">Khách hàng nói gì về chúng tôi</h2>
          
          {block.content.testimonials && block.content.testimonials.length > 0 && (
            <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
              {block.content.testimonials.map((testimonial: any) => (
                <div key={testimonial.id} className="bg-white p-6 rounded-lg shadow-md">
                  <div className="flex items-center mb-4">
                    <img 
                      src={testimonial.image} 
                      alt={testimonial.name}
                      className="w-12 h-12 rounded-full mr-4"
                    />
                    <div className="text-left">
                      <h4 className="font-semibold">{testimonial.name}</h4>
                      <p className="text-gray-600 text-sm">
                        {testimonial.role} - {testimonial.company}
                      </p>
                    </div>
                  </div>
                  <p className="text-gray-700 italic">"{testimonial.content}"</p>
                  <div className="flex mt-4">
                    {[...Array(testimonial.rating)].map((_, i) => (
                      <span key={i} className="text-yellow-400">⭐</span>
                    ))}
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      );

    case 'timeline':
      return (
        <div>
          <h2 className="text-3xl font-bold text-center mb-12">
            {renderEditableText(block.content.title, 'title', 'Tiêu đề dòng thời gian')}
          </h2>
          
          {block.content.items && block.content.items.length > 0 && (
            <div className="space-y-8">
              {block.content.items.map((item: any, index: number) => (
                <div key={item.id} className={`flex items-center gap-8 ${index % 2 === 1 ? 'flex-row-reverse' : ''}`}>
                  <div className="flex-1">
                    <div className="bg-blue-600 text-white px-4 py-2 rounded-full inline-block mb-4">
                      {item.year}
                    </div>
                    <h3 className="text-xl font-bold mb-3">{item.title}</h3>
                    <p className="text-gray-600">{item.description}</p>
                  </div>
                  {item.image && (
                    <div className="flex-1">
                      <img 
                        src={item.image} 
                        alt={item.title}
                        className="w-full h-48 object-cover rounded-lg"
                      />
                    </div>
                  )}
                </div>
              ))}
            </div>
          )}
        </div>
      );

    case 'feature-cards':
      return (
        <div className="text-center">
          <h2 className="text-3xl font-bold mb-4">
            {renderEditableText(block.content.title, 'title', 'Tiêu đề tính năng')}
          </h2>
          
          <div className="text-lg text-gray-600 mb-12 max-w-2xl mx-auto">
            {renderEditableText(block.content.description, 'description', 'Mô tả tính năng...', 'textarea')}
          </div>
          
          {block.content.cards && block.content.cards.length > 0 && (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
              {block.content.cards.map((card: any) => (
                <div key={card.id} className="bg-white p-6 rounded-lg shadow-md text-center">
                  <div className="text-4xl mb-4">{card.icon}</div>
                  <h4 className="font-semibold mb-3">{card.title}</h4>
                  <p className="text-gray-600">{card.description}</p>
                </div>
              ))}
            </div>
          )}
        </div>
      );

    case 'call-to-action':
      return (
        <div className="text-center relative">
          {block.content.backgroundImage && (
            <div 
              className="absolute inset-0 bg-cover bg-center rounded-lg"
              style={{ backgroundImage: `url(${block.content.backgroundImage})` }}
            >
              <div className="absolute inset-0 bg-black opacity-50 rounded-lg"></div>
            </div>
          )}
          
          <div className="relative z-10 py-16">
            <h2 className="text-3xl font-bold mb-4 text-white">
              {renderEditableText(block.content.title, 'title', 'Tiêu đề CTA')}
            </h2>
            
            <div className="text-lg mb-8 text-white opacity-90 max-w-2xl mx-auto">
              {renderEditableText(block.content.description, 'description', 'Mô tả CTA...', 'textarea')}
            </div>
            
            <button className="bg-white text-blue-600 px-8 py-3 rounded-lg font-medium hover:bg-gray-100 transition-colors">
              {renderEditableText(block.content.buttonText, 'buttonText', 'Text nút CTA')}
            </button>
          </div>
        </div>
      );

    case 'stats-counter':
      return (
        <div className="text-center">
          <h2 className="text-3xl font-bold mb-12 text-white">
            {renderEditableText(block.content.title, 'title', 'Tiêu đề thống kê')}
          </h2>
          
          {block.content.stats && block.content.stats.length > 0 && (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8">
              {block.content.stats.map((stat: any) => (
                <div key={stat.id} className="text-center">
                  <div className="text-4xl font-bold text-white mb-2">
                    {stat.number}{stat.suffix}
                  </div>
                  <h4 className="font-semibold text-white mb-1">{stat.label}</h4>
                  <p className="text-white opacity-75">{stat.description}</p>
                </div>
              ))}
            </div>
          )}
        </div>
      );

    case 'contact-form':
      return (
        <div className="max-w-2xl mx-auto">
          <h2 className="text-3xl font-bold text-center mb-4">
            {renderEditableText(block.content.title, 'title', 'Tiêu đề form liên hệ')}
          </h2>
          
          <div className="text-lg text-gray-600 text-center mb-8">
            {renderEditableText(block.content.description, 'description', 'Mô tả form...', 'textarea')}
          </div>
          
          <form className="space-y-6">
            {block.content.fields && block.content.fields.map((field: any) => (
              <div key={field.id}>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  {field.label}
                  {field.required && <span className="text-red-500">*</span>}
                </label>
                {field.type === 'textarea' ? (
                  <textarea
                    placeholder={field.placeholder}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                    rows={4}
                  />
                ) : (
                  <input
                    type={field.type}
                    placeholder={field.placeholder}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                  />
                )}
              </div>
            ))}
            
            <button
              type="submit"
              className="w-full bg-blue-600 text-white py-3 rounded-lg font-medium hover:bg-blue-700 transition-colors"
            >
              {block.content.buttonText || 'Gửi tin nhắn'}
            </button>
          </form>
        </div>
      );

    // Basic elements
    case 'heading':
      const level = block.content.level || 2;
      const className = `font-bold ${level === 1 ? 'text-4xl' : level === 2 ? 'text-3xl' : 'text-2xl'}`;
      const text = renderEditableText(block.content.text, 'text', 'Tiêu đề');
      
      if (level === 1) {
        return <h1 className={className}>{text}</h1>;
      } else if (level === 2) {
        return <h2 className={className}>{text}</h2>;
      } else if (level === 3) {
        return <h3 className={className}>{text}</h3>;
      } else if (level === 4) {
        return <h4 className={className}>{text}</h4>;
      } else if (level === 5) {
        return <h5 className={className}>{text}</h5>;
      } else {
        return <h6 className={className}>{text}</h6>;
      }

    case 'paragraph':
      return (
        <div className="text-gray-700">
          {renderEditableText(block.content.text, 'text', 'Đoạn văn bản...', 'textarea')}
        </div>
      );

    case 'image':
      return (
        <div className="text-center">
          {block.content.src ? (
            <img 
              src={block.content.src} 
              alt={block.content.alt || 'Image'}
              className="w-full h-auto rounded-lg"
            />
          ) : (
            <div className="w-full h-64 bg-gray-200 rounded-lg flex items-center justify-center">
              <span className="text-gray-500">Thêm hình ảnh</span>
            </div>
          )}
          {block.content.caption && (
            <p className="text-sm text-gray-600 mt-2">{block.content.caption}</p>
          )}
        </div>
      );

    case 'button':
      return (
        <div>
          <button className={`px-6 py-3 rounded-lg font-medium transition-colors ${
            block.content.style === 'primary' ? 'bg-blue-600 text-white hover:bg-blue-700' :
            block.content.style === 'secondary' ? 'bg-gray-200 text-gray-800 hover:bg-gray-300' :
            'border border-gray-300 text-gray-700 hover:bg-gray-50'
          }`}>
            {renderEditableText(block.content.text, 'text', 'Text nút')}
          </button>
        </div>
      );

    case 'spacer':
      return (
        <div 
          style={{ height: `${block.content.height || 50}px` }}
          className="w-full"
        >
          {isEditMode && (
            <div className="w-full h-full border-2 border-dashed border-gray-300 flex items-center justify-center text-gray-500">
              Spacer ({block.content.height || 50}px)
            </div>
          )}
        </div>
      );

    default:
      return (
        <div className="p-4 bg-gray-100 rounded-lg text-center text-gray-500">
          Block type "{block.type}" chưa được implement
        </div>
      );
  }
};
