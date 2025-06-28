import React from 'react';

export default function ShopLayout({ children }: { children: React.ReactNode }) {
    return (
        <div className="shop-layout">
            {/* Add common layout elements here, like header/footer specific to this layout */}
            {children}
        </div>
    );
}