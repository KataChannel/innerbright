import { ReactNode } from 'react';
import { cn } from '@/lib/utils';

// Roboto Typography System cho InnerBright

interface TypographyProps {
  children: ReactNode;
  className?: string;
}

export function RobotoDisplay({ children, className }: TypographyProps) {
  return (
    <h1 className={cn(
      'font-roboto text-4xl md:text-6xl font-black leading-tight tracking-tight text-gray-900',
      className
    )}>
      {children}
    </h1>
  );
}

export function RobotoHeadline({ children, className }: TypographyProps) {
  return (
    <h2 className={cn(
      'font-roboto text-3xl md:text-4xl font-bold leading-tight text-gray-900',
      className
    )}>
      {children}
    </h2>
  );
}

export function RobotoTitle({ children, className }: TypographyProps) {
  return (
    <h3 className={cn(
      'font-roboto text-2xl md:text-3xl font-bold leading-snug text-gray-900',
      className
    )}>
      {children}
    </h3>
  );
}

export function RobotoSubtitle({ children, className }: TypographyProps) {
  return (
    <h4 className={cn(
      'font-roboto text-xl md:text-2xl font-medium leading-relaxed text-gray-700',
      className
    )}>
      {children}
    </h4>
  );
}

export function RobotoBody({ children, className }: TypographyProps) {
  return (
    <p className={cn(
      'font-roboto text-base leading-relaxed text-gray-600',
      className
    )}>
      {children}
    </p>
  );
}

export function RobotoBodyLarge({ children, className }: TypographyProps) {
  return (
    <p className={cn(
      'font-roboto text-lg leading-relaxed text-gray-600',
      className
    )}>
      {children}
    </p>
  );
}

export function RobotoCaption({ children, className }: TypographyProps) {
  return (
    <span className={cn(
      'font-roboto text-sm leading-normal text-gray-500',
      className
    )}>
      {children}
    </span>
  );
}

export function RobotoOverline({ children, className }: TypographyProps) {
  return (
    <span className={cn(
      'font-roboto text-xs uppercase tracking-wide font-medium text-gray-500',
      className
    )}>
      {children}
    </span>
  );
}

// Button typography variants
export function RobotoButton({ children, className }: TypographyProps) {
  return (
    <span className={cn(
      'font-roboto text-sm font-medium tracking-wide uppercase',
      className
    )}>
      {children}
    </span>
  );
}

// Link typography
export function RobotoLink({ children, className }: TypographyProps) {
  return (
    <span className={cn(
      'font-roboto text-base font-medium text-blue-600 hover:text-blue-800 transition-colors',
      className
    )}>
      {children}
    </span>
  );
}
