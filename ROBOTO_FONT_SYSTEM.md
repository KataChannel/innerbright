# Roboto Font System - InnerBright

## Overview
InnerBright sử dụng font Roboto làm font chính cho toàn bộ website, đảm bảo tính nhất quán và trải nghiệm người dùng tốt.

## Font Configuration

### Google Fonts Integration
- **Font Family**: Roboto
- **Weights**: 300 (Light), 400 (Regular), 500 (Medium), 700 (Bold), 900 (Black)
- **Subset**: Vietnamese, Latin
- **Display**: swap (tối ưu performance)

### CSS Variables
```css
:root {
  --font-roboto: '__Roboto_<hash>', 'Roboto', sans-serif;
}
```

### Tailwind Configuration
```js
fontFamily: {
  roboto: ['var(--font-roboto)', 'Roboto', 'sans-serif'],
  sans: ['var(--font-roboto)', 'Roboto', 'system-ui', 'sans-serif'],
}
```

## Typography Components

### RobotoDisplay
- **Usage**: Hero headings, main page titles
- **Styling**: `text-4xl md:text-6xl font-black`
- **Example**: 
```jsx
<RobotoDisplay>InnerBright</RobotoDisplay>
```

### RobotoHeadline  
- **Usage**: Section headings, important titles
- **Styling**: `text-3xl md:text-4xl font-bold`
- **Example**:
```jsx
<RobotoHeadline>Dịch vụ của chúng tôi</RobotoHeadline>
```

### RobotoTitle
- **Usage**: Subsection titles, card headers  
- **Styling**: `text-2xl md:text-3xl font-bold`
- **Example**:
```jsx
<RobotoTitle>Coaching cá nhân</RobotoTitle>
```

### RobotoSubtitle
- **Usage**: Secondary headings, emphasized text
- **Styling**: `text-xl md:text-2xl font-medium`
- **Example**:
```jsx
<RobotoSubtitle>Subtitle text</RobotoSubtitle>
```

### RobotoBody
- **Usage**: Regular paragraph text
- **Styling**: `text-base leading-relaxed`
- **Example**:
```jsx
<RobotoBody>Regular body text content</RobotoBody>
```

### RobotoBodyLarge
- **Usage**: Lead paragraphs, intro text
- **Styling**: `text-lg leading-relaxed`
- **Example**:
```jsx
<RobotoBodyLarge>Important introductory text</RobotoBodyLarge>
```

### RobotoCaption
- **Usage**: Small text, captions, metadata
- **Styling**: `text-sm leading-normal`
- **Example**:
```jsx
<RobotoCaption>Image caption or metadata</RobotoCaption>
```

### RobotoOverline
- **Usage**: Category labels, section tags
- **Styling**: `text-xs uppercase tracking-wide font-medium`
- **Example**:
```jsx
<RobotoOverline>Category</RobotoOverline>
```

### RobotoButton
- **Usage**: Button text styling
- **Styling**: `text-sm font-medium tracking-wide uppercase`
- **Example**:
```jsx
<button>
  <RobotoButton>Click Here</RobotoButton>
</button>
```

### RobotoLink
- **Usage**: Link text styling
- **Styling**: `text-base font-medium text-blue-600 hover:text-blue-800`
- **Example**:
```jsx
<a href="#"><RobotoLink>Read more</RobotoLink></a>
```

## Best Practices

### 1. Consistency
- Luôn sử dụng Typography components thay vì hardcode styles
- Không mix fonts khác với Roboto

### 2. Hierarchy
- Display → Headline → Title → Subtitle → Body
- Sử dụng đúng component cho đúng mục đích

### 3. Responsive Design
- Components tự động responsive với breakpoints md:
- Mobile-first approach

### 4. Performance
- Font được load với `display: swap`
- CSS variables để tránh FOUC (Flash of Unstyled Content)
- Subset Vietnamese cho website tiếng Việt

## Files Structure
```
src/
├── app/
│   ├── layout.tsx (Roboto provider)
│   ├── globals.css (CSS variables)
│   └── ui/
│       └── fonts.ts (Google Fonts config)
├── components/
│   └── ui/
│       ├── Typography.tsx (Main components)
│       └── RobotoText.tsx (Flexible component)
└── lib/
    └── utils.ts (cn utility function)
```

## Implementation Status
✅ Google Fonts integration  
✅ CSS variables setup  
✅ Tailwind configuration  
✅ Typography components  
✅ Layout integration  
✅ Homepage implementation  
✅ Utility functions  

## Usage Example
```jsx
import { 
  RobotoDisplay, 
  RobotoHeadline, 
  RobotoBody 
} from '@/components/ui/Typography';

export default function Page() {
  return (
    <div>
      <RobotoDisplay>Main Title</RobotoDisplay>
      <RobotoHeadline>Section Title</RobotoHeadline>
      <RobotoBody>Content paragraph with proper typography.</RobotoBody>
    </div>
  );
}
```
