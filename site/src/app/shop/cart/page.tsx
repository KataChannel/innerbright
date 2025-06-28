import React from 'react';
import { Metadata } from 'next';

export const metadata: Metadata = {
    title: 'Cart Page - Your E-commerce',
    description: 'This is the Cart page for Your E-commerce.',
};

export default function CartPage() {
    return (
        <div className="container mx-auto p-4">
            <h1>Welcome to the Cart Page</h1>
            {/* Add your page content here */}
        </div>
    );
}