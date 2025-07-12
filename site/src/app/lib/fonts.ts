// lib/fonts.ts
import localFont from 'next/font/local';

const myCustomFont = localFont({
  src: [
    // Extra Light
    {
      path: '../../../public/font/SVN-Opinion XLight.ttf',
      weight: '100',
      style: 'normal',
    },
    {
      path: '../../../public/font/SVN-Opinion XLight Italic.ttf',
      weight: '100',
      style: 'italic',
    },
    // Thin
    {
      path: '../../../public/font/SVN-Opinion Thin.ttf',
      weight: '200',
      style: 'normal',
    },
    {
      path: '../../../public/font/SVN-Opinion Thin Italic.ttf',
      weight: '200',
      style: 'italic',
    },
    // Light
    {
      path: '../../../public/font/SVN-Opinion Light.ttf',
      weight: '300',
      style: 'normal',
    },
    {
      path: '../../../public/font/SVN-Opinion Light Italic.ttf',
      weight: '300',
      style: 'italic',
    },
    // Regular
    {
      path: '../../../public/font/SVN-Opinion Regular.ttf',
      weight: '400',
      style: 'normal',
    },
    {
      path: '../../../public/font/SVN-Opinion Italic.ttf',
      weight: '400',
      style: 'italic',
    },
    // Medium
    {
      path: '../../../public/font/SVN-Opinion Medium.ttf',
      weight: '500',
      style: 'normal',
    },
    {
      path: '../../../public/font/SVN-Opinion Medium Italic.ttf',
      weight: '500',
      style: 'italic',
    },
    // SemiBold
    {
      path: '../../../public/font/SVN-Opinion SemiBold.ttf',
      weight: '600',
      style: 'normal',
    },
    {
      path: '../../../public/font/SVN-Opinion SemiBold Italic.ttf',
      weight: '600',
      style: 'italic',
    },
    // Bold
    {
      path: '../../../public/font/SVN-Opinion Bold.ttf',
      weight: '700',
      style: 'normal',
    },
    {
      path: '../../../public/font/SVN-Opinion Bold Italic.ttf',
      weight: '700',
      style: 'italic',
    },
    // Extra Bold
    {
      path: '../../../public/font/SVN-Opinion XBold.ttf',
      weight: '800',
      style: 'normal',
    },
    {
      path: '../../../public/font/SVN-Opinion XBold Italic.ttf',
      weight: '800',
      style: 'italic',
    },
  ],
  display: 'swap', // Đảm bảo font được tải mượt mà, tránh CLS
  variable: '--font-svn-opinion', // CSS variable for easier usage
});

export default myCustomFont;