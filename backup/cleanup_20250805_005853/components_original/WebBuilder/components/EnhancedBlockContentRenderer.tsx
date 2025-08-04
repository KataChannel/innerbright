// 📝 Enhanced Block Content Renderer with Specialized Blocks
"use client";

import React from 'react';
import { PageBlockData } from '../types';
import { TherapyTimelineBlock, NLPBenefitsBlock, ProfessionalJourneyBlock } from './SpecializedBlocks';

interface EnhancedBlockContentRendererProps {
  block: PageBlockData;
  isEditMode: boolean;
  onUpdate: (content: any) => void;
}

// Text editing helper component
const EditableText: React.FC<{
  value: string;
  onChange: (value: string) => void;
  isEditMode: boolean;
  as?: 'h1' | 'h2' | 'h3' | 'h4' | 'p' | 'span';
  className?: string;
  placeholder?: string;
}> = ({ value, onChange, isEditMode, as = 'p', className = '', placeholder = 'Nhấp để chỉnh sửa' }) => {
  const Tag = as;

  if (isEditMode) {
    return as.startsWith('h') || as === 'span' ? (
      <input
        type="text"
        value={value}
        onChange={(e) => onChange(e.target.value)}
        className={`w-full border-b-2 border-gray-200 focus:border-blue-500 outline-none bg-transparent ${className}`}
        placeholder={placeholder}
      />
    ) : (
      <textarea
        value={value}
        onChange={(e) => onChange(e.target.value)}
        className={`w-full border border-gray-200 rounded-lg p-3 focus:border-blue-500 outline-none resize-none ${className}`}
        placeholder={placeholder}
        rows={as === 'p' ? 3 : 1}
      />
    );
  }

  return <Tag className={className}>{value}</Tag>;
};

export const EnhancedBlockContentRenderer: React.FC<EnhancedBlockContentRendererProps> = ({
  block,
  isEditMode,
  onUpdate
}) => {
  const renderEditableText = (value: string, field: string, placeholder?: string) => (
    <EditableText
      value={value}
      onChange={(newValue) => onUpdate({ ...block.content, [field]: newValue })}
      isEditMode={isEditMode}
      placeholder={placeholder}
    />
  );

  switch (block.type) {
    // Specialized Therapy Timeline Block
    case 'therapy-timeline':
      return (
        <TherapyTimelineBlock
          content={block.content}
          isEditMode={isEditMode}
          onUpdate={onUpdate}
        />
      );

    // Specialized NLP Benefits Block
    case 'nlp-benefits':
      return (
        <NLPBenefitsBlock
          content={block.content}
          isEditMode={isEditMode}
          onUpdate={onUpdate}
        />
      );

    // Specialized Professional Journey Block
    case 'professional-journey':
      return (
        <ProfessionalJourneyBlock
          content={block.content}
          isEditMode={isEditMode}
          onUpdate={onUpdate}
        />
      );

    // Enhanced Hero Block with Context-Aware Content
    case 'hero':
      return (
        <div className="relative min-h-[600px] flex items-center justify-center bg-gradient-to-r from-blue-600 to-purple-600 text-white">
          {block.content.backgroundImage && (
            <div
              className="absolute inset-0 bg-cover bg-center"
              style={{ backgroundImage: `url(${block.content.backgroundImage})` }}
            >
              <div className="absolute inset-0 bg-black bg-opacity-50"></div>
            </div>
          )}
          
          <div className="relative z-10 text-center max-w-4xl mx-auto px-6">
            {isEditMode ? (
              <div className="space-y-6">
                <input
                  type="text"
                  value={block.content.subtitle || ''}
                  onChange={(e) => onUpdate({ ...block.content, subtitle: e.target.value })}
                  className="text-lg font-medium bg-transparent border-b border-white border-opacity-50 text-center w-full outline-none"
                  placeholder="Subtitle"
                />
                
                <input
                  type="text"
                  value={block.content.title || ''}
                  onChange={(e) => onUpdate({ ...block.content, title: e.target.value })}
                  className="text-5xl font-bold bg-transparent border-b-2 border-white border-opacity-50 text-center w-full outline-none"
                  placeholder="Tiêu đề chính"
                />
                
                <textarea
                  value={block.content.description || ''}
                  onChange={(e) => onUpdate({ ...block.content, description: e.target.value })}
                  className="text-xl bg-transparent border border-white border-opacity-50 rounded-lg p-4 text-center w-full outline-none"
                  placeholder="Mô tả"
                  rows={3}
                />
                
                <div className="flex gap-4 justify-center">
                  <input
                    type="text"
                    value={block.content.buttonText || ''}
                    onChange={(e) => onUpdate({ ...block.content, buttonText: e.target.value })}
                    className="px-6 py-3 bg-transparent border border-white rounded-lg text-center outline-none"
                    placeholder="Text button"
                  />
                  
                  <input
                    type="text"
                    value={block.content.buttonLink || ''}
                    onChange={(e) => onUpdate({ ...block.content, buttonLink: e.target.value })}
                    className="px-6 py-3 bg-transparent border border-white rounded-lg text-center outline-none"
                    placeholder="Link button"
                  />
                </div>
                
                <input
                  type="url"
                  value={block.content.backgroundImage || ''}
                  onChange={(e) => onUpdate({ ...block.content, backgroundImage: e.target.value })}
                  className="w-full bg-transparent border border-white border-opacity-50 rounded-lg px-4 py-2 text-center outline-none"
                  placeholder="Background Image URL"
                />
              </div>
            ) : (
              <div className="space-y-6">
                {block.content.subtitle && (
                  <p className="text-lg font-medium opacity-90">{block.content.subtitle}</p>
                )}
                
                <h1 className="text-5xl font-bold leading-tight">
                  {block.content.title || 'Tiêu đề hero'}
                </h1>
                
                <p className="text-xl opacity-90 max-w-2xl mx-auto">
                  {block.content.description || 'Mô tả hero section'}
                </p>
                
                {block.content.buttonText && (
                  <div className="pt-4">
                    <a
                      href={block.content.buttonLink || '#'}
                      className="inline-flex items-center px-8 py-4 bg-white text-blue-600 font-semibold rounded-lg hover:bg-gray-100 transition-colors"
                    >
                      {block.content.buttonText}
                      <svg className="ml-2 w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 8l4 4m0 0l-4 4m4-4H3" />
                      </svg>
                    </a>
                  </div>
                )}
              </div>
            )}
          </div>
        </div>
      );

    // Enhanced About Section with Context Awareness
    case 'about-section':
      return (
        <div className="py-16 px-8 bg-white">
          <div className="max-w-6xl mx-auto">
            <div className={`grid ${block.content.layout === 'image-right' ? 'lg:grid-cols-2' : 'lg:grid-cols-2'} gap-12 items-center`}>
              <div className={block.content.layout === 'image-right' ? 'order-1' : 'order-2'}>
                {isEditMode ? (
                  <div className="space-y-4">
                    <input
                      type="text"
                      value={block.content.title || ''}
                      onChange={(e) => onUpdate({ ...block.content, title: e.target.value })}
                      className="text-3xl font-bold w-full border-b-2 border-gray-200 focus:border-blue-500 outline-none"
                      placeholder="Tiêu đề section"
                    />
                    
                    <textarea
                      value={block.content.description || ''}
                      onChange={(e) => onUpdate({ ...block.content, description: e.target.value })}
                      className="text-lg text-gray-600 w-full border border-gray-200 rounded-lg p-4 focus:border-blue-500 outline-none"
                      placeholder="Mô tả chi tiết"
                      rows={4}
                    />
                  </div>
                ) : (
                  <div className="space-y-6">
                    <h2 className="text-3xl font-bold text-gray-900">
                      {block.content.title || 'Về chúng tôi'}
                    </h2>
                    
                    <p className="text-lg text-gray-600 leading-relaxed">
                      {block.content.description || 'Mô tả về dịch vụ hoặc cá nhân'}
                    </p>
                    
                    {block.content.features && block.content.features.length > 0 && (
                      <div className="grid gap-4">
                        {block.content.features.map((feature: any, index: number) => (
                          <div key={index} className="flex items-start space-x-3">
                            <span className="text-2xl">{feature.icon}</span>
                            <div>
                              <h3 className="font-semibold text-gray-900">{feature.title}</h3>
                              <p className="text-gray-600">{feature.description}</p>
                            </div>
                          </div>
                        ))}
                      </div>
                    )}
                  </div>
                )}
              </div>
              
              <div className={block.content.layout === 'image-right' ? 'order-2' : 'order-1'}>
                {isEditMode ? (
                  <div className="space-y-4">
                    <input
                      type="url"
                      value={block.content.image || ''}
                      onChange={(e) => onUpdate({ ...block.content, image: e.target.value })}
                      className="w-full border border-gray-200 rounded-lg px-4 py-2 focus:border-blue-500 outline-none"
                      placeholder="URL hình ảnh"
                    />
                    
                    <select
                      value={block.content.layout || 'image-left'}
                      onChange={(e) => onUpdate({ ...block.content, layout: e.target.value })}
                      className="w-full border border-gray-200 rounded-lg px-4 py-2 focus:border-blue-500 outline-none"
                    >
                      <option value="image-left">Hình bên trái</option>
                      <option value="image-right">Hình bên phải</option>
                      <option value="centered">Căn giữa</option>
                    </select>
                  </div>
                ) : (
                  block.content.image && (
                    <img
                      src={block.content.image}
                      alt={block.content.title || 'About image'}
                      className="w-full h-auto rounded-lg shadow-lg"
                    />
                  )
                )}
              </div>
            </div>
          </div>
        </div>
      );

    // Enhanced Testimonials with Rich Content
    case 'testimonials':
      return (
        <div className="py-16 px-8 bg-gray-50">
          <div className="max-w-6xl mx-auto">
            <div className="text-center mb-12">
              {renderEditableText(
                block.content.title || 'Khách hàng nói gì về chúng tôi',
                'title',
                'Tiêu đề testimonials'
              )}
            </div>
            
            <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
              {(block.content.testimonials || []).map((testimonial: any, index: number) => (
                <div key={index} className="bg-white rounded-lg p-6 shadow-md">
                  <div className="flex items-center mb-4">
                    <img
                      src={testimonial.image || 'https://placehold.co/60x60/4f46e5/ffffff?text=User'}
                      alt={testimonial.name}
                      className="w-12 h-12 rounded-full mr-4"
                    />
                    <div>
                      <h4 className="font-semibold text-gray-900">{testimonial.name}</h4>
                      <p className="text-sm text-gray-600">
                        {testimonial.role} {testimonial.company && `at ${testimonial.company}`}
                      </p>
                    </div>
                  </div>
                  
                  <p className="text-gray-600 italic mb-4">"{testimonial.content}"</p>
                  
                  <div className="flex text-yellow-400">
                    {Array.from({ length: testimonial.rating || 5 }, (_, i) => (
                      <span key={i}>⭐</span>
                    ))}
                  </div>
                </div>
              ))}
            </div>
            
            {isEditMode && (
              <div className="text-center mt-8">
                <button
                  onClick={() => {
                    const newTestimonial = {
                      name: 'Tên khách hàng',
                      role: 'Chức vụ',
                      company: 'Công ty',
                      content: 'Nội dung testimonial',
                      image: 'https://placehold.co/60x60/4f46e5/ffffff?text=User',
                      rating: 5
                    };
                    onUpdate({
                      ...block.content,
                      testimonials: [...(block.content.testimonials || []), newTestimonial]
                    });
                  }}
                  className="px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
                >
                  Thêm testimonial
                </button>
              </div>
            )}
          </div>
        </div>
      );

    // Contact Form with Validation
    case 'contact-form':
      return (
        <div className="py-16 px-8 bg-blue-50">
          <div className="max-w-2xl mx-auto">
            <div className="text-center mb-8">
              {renderEditableText(
                block.content.title || 'Liên hệ với chúng tôi',
                'title',
                'Tiêu đề contact form'
              )}
              
              {renderEditableText(
                block.content.description || 'Gửi thông tin để được tư vấn miễn phí',
                'description',
                'Mô tả contact form'
              )}
            </div>
            
            <form className="bg-white rounded-lg p-8 shadow-md space-y-6">
              <div className="grid md:grid-cols-2 gap-6">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Họ và tên *
                  </label>
                  <input
                    type="text"
                    className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-blue-500 focus:border-blue-500"
                    placeholder="Nhập họ và tên"
                    required
                  />
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Số điện thoại *
                  </label>
                  <input
                    type="tel"
                    className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-blue-500 focus:border-blue-500"
                    placeholder="Nhập số điện thoại"
                    required
                  />
                </div>
              </div>
              
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Email *
                </label>
                <input
                  type="email"
                  className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-blue-500 focus:border-blue-500"
                  placeholder="Nhập địa chỉ email"
                  required
                />
              </div>
              
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Dịch vụ quan tâm
                </label>
                <select className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-blue-500 focus:border-blue-500">
                  <option value="">Chọn dịch vụ</option>
                  <option value="nlp">NLP Training</option>
                  <option value="timeline-therapy">Time-line Therapy®</option>
                  <option value="coaching">Personal Coaching</option>
                  <option value="workshop">Workshop</option>
                </select>
              </div>
              
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Tin nhắn
                </label>
                <textarea
                  className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-blue-500 focus:border-blue-500"
                  rows={4}
                  placeholder="Nhập tin nhắn của bạn"
                ></textarea>
              </div>
              
              <button
                type="submit"
                className="w-full px-6 py-3 bg-blue-600 text-white font-semibold rounded-lg hover:bg-blue-700 transition-colors"
              >
                {block.content.buttonText || 'Gửi thông tin'}
              </button>
            </form>
          </div>
        </div>
      );

    // Timeline with enhanced editing
    case 'timeline':
      return (
        <div className="py-16 px-8 bg-gray-50">
          <div className="max-w-4xl mx-auto">
            <div className="text-center mb-12">
              {renderEditableText(
                block.content.title || 'Lịch sử phát triển',
                'title',
                'Tiêu đề timeline'
              )}
            </div>
            
            <div className="space-y-8">
              {(block.content.items || []).map((item: any, index: number) => (
                <div key={index} className={`flex items-center gap-8 ${index % 2 === 1 ? 'flex-row-reverse' : ''}`}>
                  <div className="flex-1">
                    <div className="bg-blue-600 text-white px-4 py-2 rounded-full inline-block mb-4">
                      {item.year}
                    </div>
                    <h3 className="text-xl font-bold text-gray-900 mb-2">{item.title}</h3>
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
          </div>
        </div>
      );

    default:
      return (
        <div className="p-8 bg-gray-100 text-center">
          <p className="text-gray-500">Block type "{block.type}" chưa được hỗ trợ</p>
        </div>
      );
  }
};

export default EnhancedBlockContentRenderer;
