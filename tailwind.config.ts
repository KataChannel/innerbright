import type { Config } from 'tailwindcss'

const config: Config = {
  content: [
    './src/pages/**/*.{js,ts,jsx,tsx,mdx}',
    './src/components/**/*.{js,ts,jsx,tsx,mdx}',
    './src/app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      fontFamily: {
        'sans': ['Roboto', 'ui-sans-serif', 'system-ui', '-apple-system', 'BlinkMacSystemFont', 'Segoe UI', 'Arial', 'Noto Sans', 'sans-serif'],
        'roboto': ['Roboto', 'sans-serif'],
      },
      colors: {
        primary: {
          DEFAULT: '#011d56',
          50: '#f0f4ff',
          100: '#e0e8ff', 
          500: '#011d56',
          600: '#011d56',
          700: '#3b82f6', // Màu xanh sáng để dễ thấy hover effect
        },
        secondary: '#F05A30',
      },
    },
  },
  plugins: [],
}

export default config
