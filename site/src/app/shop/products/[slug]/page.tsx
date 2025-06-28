import React from 'react';
import { Metadata } from 'next';

export const metadata: Metadata = {
    title: 'ProductDetail Page - Your E-commerce',
    description: 'This is the ProductDetail page for Your E-commerce.',
};

export default function ProductDetailPage() {
    return (
        <div className="container mx-auto p-4">
            <h1>Welcome to the ProductDetail Page</h1>
            {/* Add your page content here */}
        </div>
    );
}