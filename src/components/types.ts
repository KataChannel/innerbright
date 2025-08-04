// 🔧 Types - TypeScript interfaces cho Components

export interface SectionProps {
  children: React.ReactNode;
  className?: string;
  backgroundColor?: 'white' | 'gray' | 'dark' | 'transparent';
  padding?: 'none' | 'small' | 'medium' | 'large';
  margin?: 'none' | 'small' | 'medium' | 'large';
  shadow?: boolean;
  rounded?: boolean;
  id?: string;
}

export interface HeroProps {
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

export interface CardProps {
  title?: React.ReactNode;
  content?: React.ReactNode;
  imageSrc?: string;
  imageAlt?: string;
  imagePosition?: 'top' | 'left' | 'right' | 'background';
  overlay?: boolean;
  gradientOverlay?: boolean;
  className?: string;
  onClick?: () => void;
}

export interface ButtonProps {
  children: React.ReactNode;
  onClick?: React.MouseEventHandler<HTMLButtonElement>;
  type?: 'button' | 'submit' | 'reset';
  variant?: 'primary' | 'secondary' | 'outline' | 'ghost' | 'danger';
  size?: 'sm' | 'md' | 'lg';
  disabled?: boolean;
  loading?: boolean;
  className?: string;
  icon?: React.ReactNode;
  iconPosition?: 'left' | 'right';
}

export interface InputProps {
  type?: 'text' | 'email' | 'password' | 'number' | 'tel' | 'url' | 'search';
  placeholder?: string;
  value?: string;
  defaultValue?: string;
  onChange?: (e: React.ChangeEvent<HTMLInputElement>) => void;
  onBlur?: (e: React.FocusEvent<HTMLInputElement>) => void;
  onFocus?: (e: React.FocusEvent<HTMLInputElement>) => void;
  disabled?: boolean;
  required?: boolean;
  readOnly?: boolean;
  error?: string;
  label?: string;
  helpText?: string;
  size?: 'sm' | 'md' | 'lg';
  variant?: 'default' | 'filled' | 'outline';
  className?: string;
  icon?: React.ReactNode;
  iconPosition?: 'left' | 'right';
}

export interface DialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  children: React.ReactNode;
  size?: 'sm' | 'md' | 'lg' | 'xl' | 'full';
  closeOnOverlayClick?: boolean;
  closeOnEscape?: boolean;
  className?: string;
}

// Utility types
export type BackgroundColor = 'white' | 'gray' | 'dark' | 'transparent';
export type PaddingSize = 'none' | 'small' | 'medium' | 'large';
export type MarginSize = 'none' | 'small' | 'medium' | 'large';
export type HeightSize = 'small' | 'medium' | 'large';
export type TextPosition = 'left' | 'center' | 'right';
export type TextColor = 'white' | 'black';
export type ImagePosition = 'top' | 'left' | 'right' | 'background';

// Color palette constants
export const INNERBRIGHT_COLORS = {
  primary: {
    blue: '#1E40AF',
    lightBlue: '#3B82F6',
    darkBlue: '#1E3A8A',
  },
  secondary: {
    dark: '#1A2A44',
    gray: '#F3F4F6',
    lightGray: '#E5E7EB',
  },
  text: {
    primary: '#1F2937',
    secondary: '#6B7280',
    white: '#FFFFFF',
  },
} as const;

// Responsive breakpoints
export const BREAKPOINTS = {
  sm: '640px',
  md: '768px',
  lg: '1024px',
  xl: '1280px',
  '2xl': '1536px',
} as const;

// Common component variants
export const COMPONENT_VARIANTS = {
  section: {
    hero: {
      padding: 'none' as PaddingSize,
      shadow: false,
      className: 'relative',
    },
    content: {
      backgroundColor: 'white' as BackgroundColor,
      padding: 'large' as PaddingSize,
    },
    highlight: {
      backgroundColor: 'gray' as BackgroundColor,
      padding: 'large' as PaddingSize,
    },
    cta: {
      backgroundColor: 'dark' as BackgroundColor,
      padding: 'large' as PaddingSize,
      className: 'text-white text-center',
    },
  },
  hero: {
    large: {
      height: 'large' as HeightSize,
      textPosition: 'left' as TextPosition,
    },
    medium: {
      height: 'medium' as HeightSize,
      textPosition: 'center' as TextPosition,
    },
    small: {
      height: 'small' as HeightSize,
      textPosition: 'center' as TextPosition,
    },
  },
  card: {
    standard: {
      imagePosition: 'top' as ImagePosition,
    },
    hero: {
      imagePosition: 'background' as ImagePosition,
      overlay: true,
      gradientOverlay: true,
      className: 'text-white',
    },
    horizontal: {
      imagePosition: 'left' as ImagePosition,
    },
  },
} as const;
