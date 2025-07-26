import '@/app/globals.css';
import { inter } from '@/app/ui/fonts';
import { Metadata } from 'next';
import { siteConfig } from '@/app/lib/config/site';

export const metadata: Metadata = {
  title: siteConfig.title,
  description: siteConfig.description,
  manifest: '/manifest.json',
  themeColor: '#000000',
  appleWebApp: {
    capable: true,
    statusBarStyle: 'default',
    title: siteConfig.title,
  },
  icons: {
    icon: '/favicon.ico',
    apple: '/icon-192x192.png',
  },
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body className={`${inter.className} antialiased`}>
        {children}
      </body>
    </html>
  );
}