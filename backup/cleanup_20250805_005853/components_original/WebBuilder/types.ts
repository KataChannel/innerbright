// 📝 Web Builder Types
export interface PageData {
  id: string;
  title: string;
  slug: string;
  content: PageBlockData[];
  metaDescription?: string;
  metaKeywords?: string;
  featuredImage?: string;
  author: string;
  createdAt: string;
  updatedAt: string;
  status: 'draft' | 'published';
  pageType: 'time-line-therapy' | 'nlp' | 'about' | 'custom';
  customStyles?: string;
  seoSettings?: SEOSettings;
}

export interface PageBlockData {
  id: string;
  type: PageBlockType;
  content: any;
  order: number;
  parentId?: string;
  children?: PageBlockData[];
  styles?: BlockStyles;
  animations?: BlockAnimations;
  responsiveSettings?: ResponsiveSettings;
}

export type PageBlockType = 
  // Content Blocks
  | 'hero'
  | 'about-section'
  | 'services-grid'
  | 'testimonials'
  | 'contact-form'
  | 'team-members'
  | 'pricing-table'
  | 'faq-section'
  | 'timeline'
  | 'process-steps'
  | 'feature-cards'
  | 'call-to-action'
  | 'blog-posts'
  | 'gallery'
  | 'video-section'
  | 'stats-counter'
  | 'newsletter-signup'
  | 'social-proof'
  // Specialized Blocks for Time-line Therapy, NLP & About
  | 'therapy-timeline'
  | 'nlp-benefits'
  | 'professional-journey'
  | 'success-stories'
  | 'certification-showcase'
  | 'therapy-process'
  | 'nlp-techniques'
  | 'coaching-programs'
  // Layout Blocks  
  | 'section'
  | 'container'
  | 'columns'
  | 'spacer'
  | 'divider'
  // Basic Content
  | 'heading'
  | 'paragraph'
  | 'image'
  | 'button'
  | 'icon'
  | 'list';

export interface BlockStyles {
  backgroundColor?: string;
  textColor?: string;
  padding?: {
    top: number;
    right: number;
    bottom: number;
    left: number;
  };
  margin?: {
    top: number;
    right: number;
    bottom: number;
    left: number;
  };
  borderRadius?: number;
  boxShadow?: string;
  backgroundImage?: string;
  backgroundSize?: 'cover' | 'contain' | 'auto';
  backgroundPosition?: string;
  borderWidth?: number;
  borderColor?: string;
  borderStyle?: 'solid' | 'dashed' | 'dotted';
}

export interface BlockAnimations {
  entrance?: 'fadeIn' | 'slideUp' | 'slideDown' | 'slideLeft' | 'slideRight' | 'zoomIn' | 'bounceIn';
  duration?: number;
  delay?: number;
  repeat?: boolean;
}

export interface ResponsiveSettings {
  desktop?: Partial<BlockStyles>;
  tablet?: Partial<BlockStyles>;
  mobile?: Partial<BlockStyles>;
}

export interface SEOSettings {
  title?: string;
  description?: string;
  keywords?: string[];
  openGraph?: {
    title?: string;
    description?: string;
    image?: string;
    type?: string;
  };
  twitter?: {
    card?: string;
    title?: string;
    description?: string;
    image?: string;
  };
}

// Component Props Types
export interface WebBuilderProps {
  initialPage?: PageData;
  onSave?: (page: PageData) => void;
  onPreview?: (page: PageData) => void;
  pageType?: 'time-line-therapy' | 'nlp' | 'about' | 'custom';
}

export interface PageBlockRendererProps {
  block: PageBlockData;
  isActive: boolean;
  isEditMode: boolean;
  onUpdate: (content: any) => void;
  onDelete: () => void;
  onDuplicate: () => void;
  onStyleUpdate: (styles: BlockStyles) => void;
  onAnimationUpdate: (animations: BlockAnimations) => void;
}

export interface PagePreviewProps {
  page: PageData;
  onEditMode: () => void;
}

export interface BlockLibraryProps {
  onAddBlock: (type: PageBlockType) => void;
  pageType: string;
}

export interface StyleEditorProps {
  block: PageBlockData;
  onStyleUpdate: (styles: BlockStyles) => void;
  isOpen: boolean;
  onClose: () => void;
}

// Template Types
export interface PageTemplate {
  id: string;
  name: string;
  description: string;
  thumbnail: string;
  pageType: 'time-line-therapy' | 'nlp' | 'about' | 'custom';
  blocks: PageBlockData[];
  tags: string[];
}

// Block Content Types
export interface HeroContent {
  title: string;
  subtitle: string;
  description: string;
  buttonText: string;
  buttonLink: string;
  backgroundImage: string;
  overlayOpacity: number;
  alignment: 'left' | 'center' | 'right';
}

export interface AboutSectionContent {
  title: string;
  description: string;
  image: string;
  features: Array<{
    icon: string;
    title: string;
    description: string;
  }>;
  layout: 'image-left' | 'image-right' | 'centered';
}

export interface TestimonialContent {
  testimonials: Array<{
    id: string;
    name: string;
    role: string;
    company: string;
    content: string;
    image: string;
    rating: number;
  }>;
  layout: 'grid' | 'slider' | 'single';
}

export interface ContactFormContent {
  title: string;
  description: string;
  fields: Array<{
    id: string;
    type: 'text' | 'email' | 'phone' | 'textarea' | 'select';
    label: string;
    placeholder: string;
    required: boolean;
    options?: string[];
  }>;
  buttonText: string;
  successMessage: string;
}

export interface TimelineContent {
  title: string;
  items: Array<{
    id: string;
    year: string;
    title: string;
    description: string;
    image?: string;
  }>;
  layout: 'vertical' | 'horizontal';
}

export interface ProcessStepsContent {
  title: string;
  description: string;
  steps: Array<{
    id: string;
    number: number;
    title: string;
    description: string;
    icon: string;
  }>;
}

export interface PricingTableContent {
  title: string;
  description: string;
  plans: Array<{
    id: string;
    name: string;
    price: string;
    period: string;
    features: string[];
    highlighted: boolean;
    buttonText: string;
    buttonLink: string;
  }>;
}

// Specialized Block Content Types
export interface TherapyTimelineContent {
  title: string;
  description: string;
  items: Array<{
    id: string;
    phase: string;
    title: string;
    description: string;
    duration: string;
    techniques: string[];
    outcomes: string[];
  }>;
}

export interface NLPBenefitsContent {
  title: string;
  description: string;
  benefits: Array<{
    id: string;
    category: 'Cá nhân' | 'Nghề nghiệp' | 'Giao tiếp' | 'Lãnh đạo';
    title: string;
    description: string;
    icon: string;
    techniques: string[];
    examples: string[];
  }>;
}

export interface ProfessionalJourneyContent {
  title: string;
  description: string;
  milestones: Array<{
    id: string;
    year: string;
    title: string;
    description: string;
    category: 'Học tập' | 'Nghề nghiệp' | 'Giải thưởng' | 'Dự án' | 'Cá nhân';
    achievements: string[];
    image?: string;
  }>;
}

export interface SuccessStoriesContent {
  title: string;
  description: string;
  stories: Array<{
    id: string;
    name: string;
    role: string;
    company: string;
    challenge: string;
    solution: string;
    results: string[];
    image: string;
    beforeAfter: {
      before: string;
      after: string;
    };
    testimonial: string;
  }>;
}

export interface CertificationShowcaseContent {
  title: string;
  description: string;
  certifications: Array<{
    id: string;
    name: string;
    organization: string;
    year: string;
    level: string;
    image: string;
    description: string;
    skills: string[];
  }>;
}

export interface TherapyProcessContent {
  title: string;
  description: string;
  phases: Array<{
    id: string;
    name: string;
    duration: string;
    description: string;
    steps: string[];
    techniques: string[];
    outcomes: string[];
    icon: string;
  }>;
}

export interface NLPTechniquesContent {
  title: string;
  description: string;
  categories: Array<{
    id: string;
    name: string;
    techniques: Array<{
      id: string;
      name: string;
      description: string;
      applications: string[];
      difficulty: 'Beginner' | 'Intermediate' | 'Advanced';
      duration: string;
    }>;
  }>;
}

export interface CoachingProgramsContent {
  title: string;
  description: string;
  programs: Array<{
    id: string;
    name: string;
    type: 'Individual' | 'Group' | 'Workshop' | 'Intensive';
    duration: string;
    price: string;
    description: string;
    modules: string[];
    benefits: string[];
    requirements: string[];
    schedule: string;
    featured: boolean;
  }>;
}
