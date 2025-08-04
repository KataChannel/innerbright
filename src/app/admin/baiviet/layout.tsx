'use client';

export default function BaiVietLayout({
    children,
}: {
    children: React.ReactNode;
}) {
    return (
        <div className="container mx-auto p-6 max-w-6xl">
            {children}
        </div>
    );
}
