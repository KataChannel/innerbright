// Site page template with animations
"use client";

import { ReactNode } from 'react';
import { PageTransition } from './PageAnimations';

interface SitePageTemplateProps {
  children: ReactNode;
  className?: string;
}

export const SitePageTemplate = ({ children, className = '' }: SitePageTemplateProps) => {
  return (
    <PageTransition className={`min-h-screen ${className}`}>
      {children}
    </PageTransition>
  );
};
