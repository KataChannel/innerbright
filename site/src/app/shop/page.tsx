import React from 'react';
import { Metadata } from 'next';

export const metadata: Metadata = {
    title: 'Shop Page - Your E-commerce',
    description: 'This is the Shop page for Your E-commerce.',
};

export default function ShopPage() {
    return (
        <div className="container mx-auto p-4">
            <h1>Welcome to the Shop Page</h1>
            {/* Add your page content here */}
        </div>
    );
}