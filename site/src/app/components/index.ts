// 🔧 App Components Re-exports
// This file provides easy access to the main components from the centralized /components folder

// Main Components (re-exported from centralized location)
export { 
  Section,
  Hero,
  Card,
  Button,
  Input,
  Dialog,
  DialogHeader,
  DialogTitle,
  DialogContent,
  DialogFooter,
  BlockEditor,
  BlockEditorDemo
} from '@/components';

// App-specific components
export { default as Header } from './common/Header';
export { default as Footer } from './common/Footer';
export { default as Navbar } from './ui/Navbars';

// Shop components
export { default as AddToCartButton } from './shop/AddToCartButton';

// Other app-specific components
export { default as Promo } from './common/Promo';
export { default as PopularProducts } from './common/PopularProducts';
export { default as Swipe } from './common/swipe';

// Types (re-exported from centralized location)
export type {
  SectionProps,
  HeroProps,
  CardProps,
  ButtonProps,
  InputProps,
  DialogProps,
  BackgroundColor,
  PaddingSize,
  MarginSize,
  HeightSize,
  TextPosition,
  TextColor,
  ImagePosition
} from '@/components/types';

// App-specific types
export type { NavigationItem } from './common/Header';
export type { FooterProps } from './common/Footer';
