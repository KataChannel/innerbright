// 📝 Specialized Block Content Components for Time-line Therapy, NLP & About
"use client";

import React, { useState } from 'react';
import { Edit2, Plus, Trash2, Move, Calendar, Brain, User, Star, Clock, Award, Users, Target } from 'lucide-react';

// Time-line Therapy Specialized Blocks
export const TherapyTimelineBlock: React.FC<{
  content: any;
  isEditMode: boolean;
  onUpdate: (content: any) => void;
}> = ({ content, isEditMode, onUpdate }) => {
  const [editingItem, setEditingItem] = useState<string | null>(null);

  const addTimelineItem = () => {
    const newItem = {
      id: Date.now().toString(),
      phase: `Giai đoạn ${(content.items?.length || 0) + 1}`,
      title: 'Tiêu đề mới',
      description: 'Mô tả chi tiết về giai đoạn này',
      duration: '1-2 tuần',
      techniques: ['Kỹ thuật 1', 'Kỹ thuật 2'],
      outcomes: ['Kết quả 1', 'Kết quả 2']
    };

    onUpdate({
      ...content,
      items: [...(content.items || []), newItem]
    });
  };

  const updateItem = (itemId: string, updates: any) => {
    const updatedItems = (content.items || []).map((item: any) =>
      item.id === itemId ? { ...item, ...updates } : item
    );
    onUpdate({ ...content, items: updatedItems });
  };

  const removeItem = (itemId: string) => {
    const updatedItems = (content.items || []).filter((item: any) => item.id !== itemId);
    onUpdate({ ...content, items: updatedItems });
  };

  return (
    <div className="py-16 px-8 bg-gradient-to-b from-purple-50 to-white">
      {/* Header */}
      <div className="text-center mb-12">
        <div className="flex items-center justify-center mb-4">
          <Clock className="w-8 h-8 text-purple-600 mr-3" />
          {isEditMode ? (
            <input
              type="text"
              value={content.title || 'Quy Trình Time-line Therapy®'}
              onChange={(e) => onUpdate({ ...content, title: e.target.value })}
              className="text-3xl font-bold text-center border-b-2 border-purple-200 focus:border-purple-600 outline-none bg-transparent"
            />
          ) : (
            <h2 className="text-3xl font-bold text-gray-900">
              {content.title || 'Quy Trình Time-line Therapy®'}
            </h2>
          )}
        </div>
        
        {isEditMode ? (
          <textarea
            value={content.description || 'Hành trình chữa lành cảm xúc theo từng giai đoạn'}
            onChange={(e) => onUpdate({ ...content, description: e.target.value })}
            className="text-lg text-gray-600 text-center w-full border border-gray-200 rounded-lg p-3"
            rows={2}
          />
        ) : (
          <p className="text-lg text-gray-600 max-w-2xl mx-auto">
            {content.description || 'Hành trình chữa lành cảm xúc theo từng giai đoạn'}
          </p>
        )}
      </div>

      {/* Timeline Items */}
      <div className="max-w-4xl mx-auto">
        {(content.items || []).map((item: any, index: number) => (
          <div key={item.id} className="relative mb-12">
            {/* Timeline Line */}
            {index < (content.items?.length || 0) - 1 && (
              <div className="absolute left-6 top-16 w-0.5 h-full bg-purple-200"></div>
            )}

            {/* Timeline Node */}
            <div className="flex items-start">
              <div className="flex-shrink-0 w-12 h-12 bg-purple-600 rounded-full flex items-center justify-center text-white font-bold text-lg mr-6">
                {index + 1}
              </div>

              <div className="flex-1 bg-white rounded-lg shadow-md p-6 border-l-4 border-purple-600">
                {isEditMode && editingItem === item.id ? (
                  <div className="space-y-4">
                    <input
                      type="text"
                      value={item.phase}
                      onChange={(e) => updateItem(item.id, { phase: e.target.value })}
                      className="text-sm font-medium text-purple-600 border border-gray-200 rounded px-2 py-1"
                      placeholder="Giai đoạn"
                    />
                    
                    <input
                      type="text"
                      value={item.title}
                      onChange={(e) => updateItem(item.id, { title: e.target.value })}
                      className="text-xl font-bold text-gray-900 w-full border border-gray-200 rounded px-3 py-2"
                      placeholder="Tiêu đề"
                    />
                    
                    <textarea
                      value={item.description}
                      onChange={(e) => updateItem(item.id, { description: e.target.value })}
                      className="text-gray-600 w-full border border-gray-200 rounded px-3 py-2"
                      rows={3}
                      placeholder="Mô tả"
                    />
                    
                    <input
                      type="text"
                      value={item.duration}
                      onChange={(e) => updateItem(item.id, { duration: e.target.value })}
                      className="text-sm text-gray-500 border border-gray-200 rounded px-2 py-1"
                      placeholder="Thời gian"
                    />

                    <div className="flex gap-2">
                      <button
                        onClick={() => setEditingItem(null)}
                        className="px-3 py-1 bg-green-600 text-white rounded text-sm"
                      >
                        Lưu
                      </button>
                      <button
                        onClick={() => removeItem(item.id)}
                        className="px-3 py-1 bg-red-600 text-white rounded text-sm"
                      >
                        Xóa
                      </button>
                    </div>
                  </div>
                ) : (
                  <div>
                    <div className="flex items-center justify-between mb-3">
                      <span className="text-sm font-medium text-purple-600 bg-purple-100 px-3 py-1 rounded-full">
                        {item.phase}
                      </span>
                      <span className="text-sm text-gray-500 flex items-center">
                        <Clock className="w-4 h-4 mr-1" />
                        {item.duration}
                      </span>
                      {isEditMode && (
                        <button
                          onClick={() => setEditingItem(item.id)}
                          className="text-gray-400 hover:text-gray-600"
                        >
                          <Edit2 className="w-4 h-4" />
                        </button>
                      )}
                    </div>
                    
                    <h3 className="text-xl font-bold text-gray-900 mb-3">{item.title}</h3>
                    <p className="text-gray-600 mb-4">{item.description}</p>
                    
                    {item.techniques && item.techniques.length > 0 && (
                      <div className="mb-4">
                        <h4 className="font-semibold text-gray-800 mb-2">Kỹ thuật áp dụng:</h4>
                        <div className="flex flex-wrap gap-2">
                          {item.techniques.map((technique: string, i: number) => (
                            <span key={i} className="px-2 py-1 bg-blue-100 text-blue-800 text-sm rounded">
                              {technique}
                            </span>
                          ))}
                        </div>
                      </div>
                    )}
                    
                    {item.outcomes && item.outcomes.length > 0 && (
                      <div>
                        <h4 className="font-semibold text-gray-800 mb-2">Kết quả mong đợi:</h4>
                        <ul className="text-gray-600 text-sm space-y-1">
                          {item.outcomes.map((outcome: string, i: number) => (
                            <li key={i} className="flex items-center">
                              <span className="w-2 h-2 bg-green-500 rounded-full mr-2"></span>
                              {outcome}
                            </li>
                          ))}
                        </ul>
                      </div>
                    )}
                  </div>
                )}
              </div>
            </div>
          </div>
        ))}

        {/* Add New Item Button */}
        {isEditMode && (
          <div className="text-center">
            <button
              onClick={addTimelineItem}
              className="flex items-center mx-auto px-6 py-3 bg-purple-600 text-white rounded-lg hover:bg-purple-700 transition-colors"
            >
              <Plus className="w-4 h-4 mr-2" />
              Thêm giai đoạn mới
            </button>
          </div>
        )}
      </div>
    </div>
  );
};

// NLP Benefits & Techniques Block
export const NLPBenefitsBlock: React.FC<{
  content: any;
  isEditMode: boolean;
  onUpdate: (content: any) => void;
}> = ({ content, isEditMode, onUpdate }) => {
  const [editingBenefit, setEditingBenefit] = useState<string | null>(null);

  const addBenefit = () => {
    const newBenefit = {
      id: Date.now().toString(),
      category: 'Cá nhân',
      title: 'Lợi ích mới',
      description: 'Mô tả chi tiết về lợi ích này',
      icon: '🎯',
      techniques: ['Technique 1', 'Technique 2'],
      examples: ['Ví dụ 1', 'Ví dụ 2']
    };

    onUpdate({
      ...content,
      benefits: [...(content.benefits || []), newBenefit]
    });
  };

  const updateBenefit = (benefitId: string, updates: any) => {
    const updatedBenefits = (content.benefits || []).map((benefit: any) =>
      benefit.id === benefitId ? { ...benefit, ...updates } : benefit
    );
    onUpdate({ ...content, benefits: updatedBenefits });
  };

  const removeBenefit = (benefitId: string) => {
    const updatedBenefits = (content.benefits || []).filter((benefit: any) => benefit.id !== benefitId);
    onUpdate({ ...content, benefits: updatedBenefits });
  };

  const categories = ['Cá nhân', 'Nghề nghiệp', 'Giao tiếp', 'Lãnh đạo'];

  return (
    <div className="py-16 px-8 bg-gradient-to-b from-blue-50 to-white">
      {/* Header */}
      <div className="text-center mb-12">
        <div className="flex items-center justify-center mb-4">
          <Brain className="w-8 h-8 text-blue-600 mr-3" />
          {isEditMode ? (
            <input
              type="text"
              value={content.title || 'Lợi Ích Của NLP'}
              onChange={(e) => onUpdate({ ...content, title: e.target.value })}
              className="text-3xl font-bold text-center border-b-2 border-blue-200 focus:border-blue-600 outline-none bg-transparent"
            />
          ) : (
            <h2 className="text-3xl font-bold text-gray-900">
              {content.title || 'Lợi Ích Của NLP'}
            </h2>
          )}
        </div>
        
        {isEditMode ? (
          <textarea
            value={content.description || 'Khám phá những thay đổi tích cực mà NLP mang lại'}
            onChange={(e) => onUpdate({ ...content, description: e.target.value })}
            className="text-lg text-gray-600 text-center w-full border border-gray-200 rounded-lg p-3"
            rows={2}
          />
        ) : (
          <p className="text-lg text-gray-600 max-w-2xl mx-auto">
            {content.description || 'Khám phá những thay đổi tích cực mà NLP mang lại'}
          </p>
        )}
      </div>

      {/* Benefits by Category */}
      <div className="max-w-6xl mx-auto">
        {categories.map((category) => {
          const categoryBenefits = (content.benefits || []).filter((benefit: any) => benefit.category === category);
          
          if (categoryBenefits.length === 0 && !isEditMode) return null;

          return (
            <div key={category} className="mb-12">
              <h3 className="text-2xl font-bold text-gray-900 mb-6 text-center">
                {category}
              </h3>
              
              <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
                {categoryBenefits.map((benefit: any) => (
                  <div key={benefit.id} className="bg-white rounded-lg shadow-md p-6 border-t-4 border-blue-600">
                    {isEditMode && editingBenefit === benefit.id ? (
                      <div className="space-y-3">
                        <input
                          type="text"
                          value={benefit.icon}
                          onChange={(e) => updateBenefit(benefit.id, { icon: e.target.value })}
                          className="text-2xl w-16 text-center border border-gray-200 rounded"
                          placeholder="🎯"
                        />
                        
                        <select
                          value={benefit.category}
                          onChange={(e) => updateBenefit(benefit.id, { category: e.target.value })}
                          className="w-full border border-gray-200 rounded px-2 py-1 text-sm"
                        >
                          {categories.map(cat => (
                            <option key={cat} value={cat}>{cat}</option>
                          ))}
                        </select>
                        
                        <input
                          type="text"
                          value={benefit.title}
                          onChange={(e) => updateBenefit(benefit.id, { title: e.target.value })}
                          className="text-lg font-bold w-full border border-gray-200 rounded px-2 py-1"
                          placeholder="Tiêu đề"
                        />
                        
                        <textarea
                          value={benefit.description}
                          onChange={(e) => updateBenefit(benefit.id, { description: e.target.value })}
                          className="w-full border border-gray-200 rounded px-2 py-1"
                          rows={3}
                          placeholder="Mô tả"
                        />

                        <div className="flex gap-2">
                          <button
                            onClick={() => setEditingBenefit(null)}
                            className="px-3 py-1 bg-green-600 text-white rounded text-sm"
                          >
                            Lưu
                          </button>
                          <button
                            onClick={() => removeBenefit(benefit.id)}
                            className="px-3 py-1 bg-red-600 text-white rounded text-sm"
                          >
                            Xóa
                          </button>
                        </div>
                      </div>
                    ) : (
                      <div>
                        <div className="flex items-center justify-between mb-3">
                          <span className="text-3xl">{benefit.icon}</span>
                          {isEditMode && (
                            <button
                              onClick={() => setEditingBenefit(benefit.id)}
                              className="text-gray-400 hover:text-gray-600"
                            >
                              <Edit2 className="w-4 h-4" />
                            </button>
                          )}
                        </div>
                        
                        <h4 className="text-lg font-bold text-gray-900 mb-3">{benefit.title}</h4>
                        <p className="text-gray-600 mb-4">{benefit.description}</p>
                        
                        {benefit.techniques && benefit.techniques.length > 0 && (
                          <div className="mb-3">
                            <h5 className="font-semibold text-gray-800 text-sm mb-2">Kỹ thuật:</h5>
                            <div className="flex flex-wrap gap-1">
                              {benefit.techniques.map((technique: string, i: number) => (
                                <span key={i} className="px-2 py-1 bg-blue-100 text-blue-800 text-xs rounded">
                                  {technique}
                                </span>
                              ))}
                            </div>
                          </div>
                        )}
                        
                        {benefit.examples && benefit.examples.length > 0 && (
                          <div>
                            <h5 className="font-semibold text-gray-800 text-sm mb-2">Ví dụ thực tế:</h5>
                            <ul className="text-gray-600 text-sm space-y-1">
                              {benefit.examples.map((example: string, i: number) => (
                                <li key={i} className="flex items-start">
                                  <span className="w-1.5 h-1.5 bg-primary rounded-full mr-2 mt-2 flex-shrink-0"></span>
                                  {example}
                                </li>
                              ))}
                            </ul>
                          </div>
                        )}
                      </div>
                    )}
                  </div>
                ))}
              </div>
              
              {isEditMode && (
                <div className="text-center mt-6">
                  <button
                    onClick={() => {
                      const newBenefit = {
                        id: Date.now().toString(),
                        category,
                        title: 'Lợi ích mới',
                        description: 'Mô tả chi tiết về lợi ích này',
                        icon: '🎯',
                        techniques: [],
                        examples: []
                      };
                      updateBenefit('new', newBenefit);
                      onUpdate({
                        ...content,
                        benefits: [...(content.benefits || []), newBenefit]
                      });
                    }}
                    className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors text-sm"
                  >
                    <Plus className="w-4 h-4 inline mr-1" />
                    Thêm lợi ích {category}
                  </button>
                </div>
              )}
            </div>
          );
        })}
      </div>
    </div>
  );
};

// Professional Journey Block for About Page
export const ProfessionalJourneyBlock: React.FC<{
  content: any;
  isEditMode: boolean;
  onUpdate: (content: any) => void;
}> = ({ content, isEditMode, onUpdate }) => {
  const [editingMilestone, setEditingMilestone] = useState<string | null>(null);

  const addMilestone = () => {
    const newMilestone = {
      id: Date.now().toString(),
      year: new Date().getFullYear().toString(),
      title: 'Cột mốc mới',
      description: 'Mô tả về cột mốc này',
      category: 'Học tập',
      achievements: ['Thành tựu 1', 'Thành tựu 2'],
      image: 'https://placehold.co/300x200/4f46e5/ffffff?text=Milestone'
    };

    onUpdate({
      ...content,
      milestones: [...(content.milestones || []), newMilestone]
    });
  };

  const updateMilestone = (milestoneId: string, updates: any) => {
    const updatedMilestones = (content.milestones || []).map((milestone: any) =>
      milestone.id === milestoneId ? { ...milestone, ...updates } : milestone
    );
    onUpdate({ ...content, milestones: updatedMilestones });
  };

  const removeMilestone = (milestoneId: string) => {
    const updatedMilestones = (content.milestones || []).filter((milestone: any) => milestone.id !== milestoneId);
    onUpdate({ ...content, milestones: updatedMilestones });
  };

  const categoryIcons = {
    'Học tập': '🎓',
    'Nghề nghiệp': '💼',
    'Giải thưởng': '🏆',
    'Dự án': '🚀',
    'Cá nhân': '👤'
  };

  return (
    <div className="py-16 px-8 bg-gradient-to-b from-green-50 to-white">
      {/* Header */}
      <div className="text-center mb-12">
        <div className="flex items-center justify-center mb-4">
          <Award className="w-8 h-8 text-green-600 mr-3" />
          {isEditMode ? (
            <input
              type="text"
              value={content.title || 'Hành Trình Chuyên Môn'}
              onChange={(e) => onUpdate({ ...content, title: e.target.value })}
              className="text-3xl font-bold text-center border-b-2 border-green-200 focus:border-green-600 outline-none bg-transparent"
            />
          ) : (
            <h2 className="text-3xl font-bold text-gray-900">
              {content.title || 'Hành Trình Chuyên Môn'}
            </h2>
          )}
        </div>
        
        {isEditMode ? (
          <textarea
            value={content.description || 'Những cột mốc quan trọng trong sự nghiệp'}
            onChange={(e) => onUpdate({ ...content, description: e.target.value })}
            className="text-lg text-gray-600 text-center w-full border border-gray-200 rounded-lg p-3"
            rows={2}
          />
        ) : (
          <p className="text-lg text-gray-600 max-w-2xl mx-auto">
            {content.description || 'Những cột mốc quan trọng trong sự nghiệp'}
          </p>
        )}
      </div>

      {/* Timeline */}
      <div className="max-w-4xl mx-auto">
        <div className="relative">
          {/* Timeline Line */}
          <div className="absolute left-8 top-0 bottom-0 w-0.5 bg-green-200"></div>
          
          {/* Milestones */}
          {(content.milestones || [])
            .sort((a: any, b: any) => parseInt(b.year) - parseInt(a.year))
            .map((milestone: any, index: number) => (
              <div key={milestone.id} className="relative mb-12 flex items-start">
                {/* Year Badge */}
                <div className="flex-shrink-0 w-16 h-16 bg-green-600 rounded-full flex items-center justify-center text-white font-bold text-lg mr-8 relative z-10">
                  {milestone.year}
                </div>

                {/* Content Card */}
                <div className="flex-1 bg-white rounded-lg shadow-md p-6 border-l-4 border-green-600">
                  {isEditMode && editingMilestone === milestone.id ? (
                    <div className="space-y-4">
                      <div className="grid grid-cols-2 gap-4">
                        <input
                          type="text"
                          value={milestone.year}
                          onChange={(e) => updateMilestone(milestone.id, { year: e.target.value })}
                          className="border border-gray-200 rounded px-3 py-2"
                          placeholder="Năm"
                        />
                        
                        <select
                          value={milestone.category}
                          onChange={(e) => updateMilestone(milestone.id, { category: e.target.value })}
                          className="border border-gray-200 rounded px-3 py-2"
                        >
                          {Object.keys(categoryIcons).map(cat => (
                            <option key={cat} value={cat}>{cat}</option>
                          ))}
                        </select>
                      </div>
                      
                      <input
                        type="text"
                        value={milestone.title}
                        onChange={(e) => updateMilestone(milestone.id, { title: e.target.value })}
                        className="text-xl font-bold w-full border border-gray-200 rounded px-3 py-2"
                        placeholder="Tiêu đề"
                      />
                      
                      <textarea
                        value={milestone.description}
                        onChange={(e) => updateMilestone(milestone.id, { description: e.target.value })}
                        className="w-full border border-gray-200 rounded px-3 py-2"
                        rows={3}
                        placeholder="Mô tả"
                      />
                      
                      <input
                        type="url"
                        value={milestone.image}
                        onChange={(e) => updateMilestone(milestone.id, { image: e.target.value })}
                        className="w-full border border-gray-200 rounded px-3 py-2"
                        placeholder="URL hình ảnh"
                      />

                      <div className="flex gap-2">
                        <button
                          onClick={() => setEditingMilestone(null)}
                          className="px-3 py-1 bg-green-600 text-white rounded text-sm"
                        >
                          Lưu
                        </button>
                        <button
                          onClick={() => removeMilestone(milestone.id)}
                          className="px-3 py-1 bg-red-600 text-white rounded text-sm"
                        >
                          Xóa
                        </button>
                      </div>
                    </div>
                  ) : (
                    <div className="grid md:grid-cols-3 gap-6">
                      <div className="md:col-span-2">
                        <div className="flex items-center justify-between mb-3">
                          <span className="text-sm font-medium text-green-600 bg-green-100 px-3 py-1 rounded-full flex items-center">
                            <span className="mr-2">{categoryIcons[milestone.category as keyof typeof categoryIcons]}</span>
                            {milestone.category}
                          </span>
                          {isEditMode && (
                            <button
                              onClick={() => setEditingMilestone(milestone.id)}
                              className="text-gray-400 hover:text-gray-600"
                            >
                              <Edit2 className="w-4 h-4" />
                            </button>
                          )}
                        </div>
                        
                        <h3 className="text-xl font-bold text-gray-900 mb-3">{milestone.title}</h3>
                        <p className="text-gray-600 mb-4">{milestone.description}</p>
                        
                        {milestone.achievements && milestone.achievements.length > 0 && (
                          <div>
                            <h4 className="font-semibold text-gray-800 mb-2">Thành tựu:</h4>
                            <ul className="space-y-1">
                              {milestone.achievements.map((achievement: string, i: number) => (
                                <li key={i} className="flex items-center text-gray-600 text-sm">
                                  <Star className="w-4 h-4 text-yellow-500 mr-2" />
                                  {achievement}
                                </li>
                              ))}
                            </ul>
                          </div>
                        )}
                      </div>
                      
                      {milestone.image && (
                        <div className="md:col-span-1">
                          <img
                            src={milestone.image}
                            alt={milestone.title}
                            className="w-full h-48 object-cover rounded-lg"
                          />
                        </div>
                      )}
                    </div>
                  )}
                </div>
              </div>
            ))}

          {/* Add New Milestone Button */}
          {isEditMode && (
            <div className="text-center">
              <button
                onClick={addMilestone}
                className="flex items-center mx-auto px-6 py-3 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors"
              >
                <Plus className="w-4 h-4 mr-2" />
                Thêm cột mốc mới
              </button>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};
