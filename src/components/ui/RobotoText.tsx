import { ReactNode } from 'react';
import { roboto } from '@/app/ui/fonts';

interface RobotoTextProps {
  children: ReactNode;
  className?: string;
  weight?: 'light' | 'normal' | 'medium' | 'bold' | 'black';
  as?: 'div' | 'span' | 'p' | 'h1' | 'h2' | 'h3' | 'h4' | 'h5' | 'h6';
}

export function RobotoText({ 
  children, 
  className = '', 
  weight = 'normal',
  as = 'div' 
}: RobotoTextProps) {
  const Component = as;
  const weightClass = {
    light: 'font-light',
    normal: 'font-normal', 
    medium: 'font-medium',
    bold: 'font-bold',
    black: 'font-black'
  }[weight];

  return (
    <Component className={`${roboto.className} ${weightClass} ${className}`}>
      {children}
    </Component>
  );
}

// Preset components với font Roboto
export function RobotoHeading({ children, className = '', level = 1 }: {
  children: ReactNode;
  className?: string;
  level?: 1 | 2 | 3 | 4 | 5 | 6;
}) {
  const headingTags = {
    1: 'h1' as const,
    2: 'h2' as const,
    3: 'h3' as const,
    4: 'h4' as const,
    5: 'h5' as const,
    6: 'h6' as const,
  };
  const HeadingTag = headingTags[level];
  
  return (
    <RobotoText as={HeadingTag} weight="bold" className={className}>
      {children}
    </RobotoText>
  );
}

export function RobotoParagraph({ children, className = '' }: {
  children: ReactNode;
  className?: string;
}) {
  return (
    <RobotoText as="p" className={className}>
      {children}
    </RobotoText>
  );
}
