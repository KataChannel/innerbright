import React from 'react';

interface SectionProps {
  children: React.ReactNode;
  className?: string;
  backgroundColor?: 'white' | 'gray' | 'dark' | 'transparent';
  padding?: 'none' | 'small' | 'medium' | 'large';
  margin?: 'none' | 'small' | 'medium' | 'large';
  shadow?: boolean;
  rounded?: boolean;
  id?: string;
}

const Section: React.FC<SectionProps> = ({
  children,
  className = '',
  backgroundColor = 'white',
  padding = 'large',
  margin = 'medium',
  shadow = true,
  rounded = true,
  id,
}) => {
  const getBackgroundClass = () => {
    switch (backgroundColor) {
      case 'white':
        return 'bg-white';
      case 'gray':
        return 'bg-gray-100';
      case 'dark':
        return 'bg-[#1A2A44]';
      case 'transparent':
        return 'bg-transparent';
      default:
        return 'bg-white';
    }
  };

  const getPaddingClass = () => {
    switch (padding) {
      case 'none':
        return '';
      case 'small':
        return 'p-4';
      case 'medium':
        return 'p-6';
      case 'large':
        return 'p-8';
      default:
        return 'p-8';
    }
  };

  const getMarginClass = () => {
    switch (margin) {
      case 'none':
        return '';
      case 'small':
        return 'mb-4';
      case 'medium':
        return 'mb-6';
      case 'large':
        return 'mb-8';
      default:
        return 'mb-8';
    }
  };

  const getShadowClass = () => shadow ? 'shadow-lg' : '';
  const getRoundedClass = () => rounded ? 'rounded-xl' : '';

  const combinedClassName = [
    getBackgroundClass(),
    getPaddingClass(),
    getMarginClass(),
    getShadowClass(),
    getRoundedClass(),
    'overflow-hidden',
    className
  ].filter(Boolean).join(' ');

  return (
    <section id={id} className={combinedClassName}>
      {children}
    </section>
  );
};

export default Section;
