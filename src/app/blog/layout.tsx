import React from 'react';

export default function BlogLayout({ children }: { children: React.ReactNode }) {
    return (
        <div className="blog-layout">
            {/* Add common layout elements here, like header/footer specific to this layout */}
            {children}
        </div>
    );
}