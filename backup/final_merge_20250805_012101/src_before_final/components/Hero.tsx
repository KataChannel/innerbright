import React from 'react';

interface HeroProps {
  title: React.ReactNode;
  subtitle?: React.ReactNode;
  description?: string;
  imageSrc: string;
  imageAlt: string;
  gradientOverlay?: boolean;
  height?: 'small' | 'medium' | 'large';
  textPosition?: 'left' | 'center' | 'right';
  textColor?: 'white' | 'black';
  className?: string;
}

const Hero: React.FC<HeroProps> = ({
  title,
  subtitle,
  description,
  imageSrc,
  imageAlt,
  gradientOverlay = true,
  height = 'large',
  textPosition = 'left',
  textColor = 'white',
  className = '',
}) => {
  const getHeightClass = () => {
    switch (height) {
      case 'small':
        return 'h-48 lg:h-56';
      case 'medium':
        return 'h-64 lg:h-72';
      case 'large':
        return 'h-80 lg:h-96';
      default:
        return 'h-80 lg:h-96';
    }
  };

  const getTextPositionClass = () => {
    switch (textPosition) {
      case 'left':
        return 'items-center';
      case 'center':
        return 'items-center justify-center text-center';
      case 'right':
        return 'items-center justify-end';
      default:
        return 'items-center';
    }
  };

  const getTextColorClass = () => textColor === 'white' ? 'text-white' : 'text-black';

  return (
    <div className={`relative ${getHeightClass()} ${className}`}>
      <img
        src={imageSrc}
        alt={imageAlt}
        className="w-full h-full object-cover object-center"
      />
      {gradientOverlay && (
        <div className="absolute inset-0 bg-gradient-to-r from-black/60 to-transparent" />
      )}

      <div className={`absolute inset-0 flex ${getTextPositionClass()}`}>
        <div className="container mx-auto px-8 lg:px-12">
          <div className={textPosition === 'center' ? 'w-full' : 'w-1/2'}>
            <h1 className={`text-3xl lg:text-5xl font-bold ${getTextColorClass()} mb-6 leading-tight`}>
              {title}
            </h1>
            {subtitle && (
              <h2 className={`text-xl lg:text-2xl font-semibold ${getTextColorClass()} mb-4`}>
                {subtitle}
              </h2>
            )}
            {description && (
              <p className={`text-lg lg:text-xl ${getTextColorClass()}/90 leading-relaxed`}>
                {description}
              </p>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

export default Hero;
