import type { Metadata } from "next";
import localFont from "next/font/local";
import "./globals.css";

const svnOpinion = localFont({
  src: [
    { path: './fonts/SVN-OpinionThin.ttf', weight: '100', style: 'normal' },
    { path: './fonts/SVN-OpinionThinItalic.ttf', weight: '100', style: 'italic' },
    { path: './fonts/SVN-OpinionXLight.ttf', weight: '200', style: 'normal' },
    { path: './fonts/SVN-OpinionXLightItalic.ttf', weight: '200', style: 'italic' },
    { path: './fonts/SVN-OpinionLight.ttf', weight: '300', style: 'normal' },
    { path: './fonts/SVN-OpinionLightItalic.ttf', weight: '300', style: 'italic' },
    { path: './fonts/SVN-OpinionRegular.ttf', weight: '400', style: 'normal' },
    { path: './fonts/SVN-OpinionItalic.ttf', weight: '400', style: 'italic' },
    { path: './fonts/SVN-OpinionMedium.ttf', weight: '500', style: 'normal' },
    { path: './fonts/SVN-OpinionMediumItalic.ttf', weight: '500', style: 'italic' },
    { path: './fonts/SVN-OpinionSemiBold.ttf', weight: '600', style: 'normal' },
    { path: './fonts/SVN-OpinionSemiBoldItalic.ttf', weight: '600', style: 'italic' },
    { path: './fonts/SVN-OpinionBold.ttf', weight: '700', style: 'normal' },
    { path: './fonts/SVN-OpinionBoldItalic.ttf', weight: '700', style: 'italic' },
    { path: './fonts/SVN-OpinionXBold.ttf', weight: '800', style: 'normal' },
    { path: './fonts/SVN-OpinionXBoldItalic.ttf', weight: '800', style: 'italic' },
  ],
  variable: '--font-svn-opinion',
  display: 'swap',
});

export const metadata: Metadata = {
  title: "InnerBright",
  description: "InnerBright App",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body
        className={`${svnOpinion.variable} antialiased`}
      >
        {children}
      </body>
    </html>
  );
}
