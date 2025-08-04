import React from 'react';

interface CardProps {
  title?: React.ReactNode;
  content?: React.ReactNode;
  imageSrc?: string;
  imageAlt?: string;
  imagePosition?: 'top' | 'left' | 'right' | 'background';
  className?: string;
  imageClassName?: string;
  contentClassName?: string;
  overlay?: boolean;
  gradientOverlay?: boolean;
}

const Card: React.FC<CardProps> = ({
  title,
  content,
  imageSrc,
  imageAlt = '',
  imagePosition = 'top',
  className = '',
  imageClassName = '',
  contentClassName = '',
  overlay = false,
  gradientOverlay = false,
}) => {
  const baseCardClass = "relative bg-white rounded-xl shadow-lg overflow-hidden";
  
  const renderImage = () => {
    if (!imageSrc) return null;
    
    return (
      <img
        src={imageSrc}
        alt={imageAlt}
        className={`object-cover object-center ${imageClassName}`}
      />
    );
  };

  const renderContent = () => {
    if (!title && !content) return null;
    
    return (
      <div className={contentClassName}>
        {title && (
          <h3 className="text-xl lg:text-2xl font-bold mb-4 leading-tight">
            {title}
          </h3>
        )}
        {content && (
          <div className="text-sm lg:text-base leading-relaxed">
            {content}
          </div>
        )}
      </div>
    );
  };

  if (imagePosition === 'background') {
    return (
      <div className={`${baseCardClass} ${className}`}>
        <div className="relative h-48 lg:h-56">
          {renderImage()}
          {gradientOverlay && (
            <div className="absolute inset-0 bg-gradient-to-r from-black/60 to-transparent" />
          )}
          {overlay && (
            <div className="absolute inset-0 flex items-center">
              <div className="container mx-auto px-8 lg:px-12">
                <div className="max-w-2xl">
                  {renderContent()}
                </div>
              </div>
            </div>
          )}
        </div>
      </div>
    );
  }

  if (imagePosition === 'left') {
    return (
      <div className={`${baseCardClass} flex flex-col md:flex-row ${className}`}>
        {imageSrc && (
          <div className="md:w-1/2">
            {renderImage()}
          </div>
        )}
        <div className="md:w-1/2 p-6 md:p-8 flex flex-col justify-center">
          {renderContent()}
        </div>
      </div>
    );
  }

  if (imagePosition === 'right') {
    return (
      <div className={`${baseCardClass} flex flex-col md:flex-row ${className}`}>
        <div className="md:w-1/2 p-6 md:p-8 flex flex-col justify-center">
          {renderContent()}
        </div>
        {imageSrc && (
          <div className="md:w-1/2">
            {renderImage()}
          </div>
        )}
      </div>
    );
  }

  // Default: image on top
  return (
    <div className={`${baseCardClass} ${className}`}>
      {imageSrc && renderImage()}
      <div className="p-6">
        {renderContent()}
      </div>
    </div>
  );
};

export default Card;
