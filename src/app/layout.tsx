import './globals.css';
import React from 'react';
import { siteConfig } from '@/app/lib/config/site';
export const metadata = {
    title: siteConfig.title,
    description: siteConfig.description,
};
export default function RootLayout({ children }: { children: React.ReactNode }) {
    return (
        <html lang="en">
            <body>
                {children}
            </body>
        </html>
    );
}