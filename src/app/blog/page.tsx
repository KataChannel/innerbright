import React from 'react';
import { Metadata } from 'next';

export const metadata: Metadata = {
    title: 'Blog Page - Your E-commerce',
    description: 'This is the Blog page for Your E-commerce.',
};

export default function BlogPage() {
    return (
        <div className="container mx-auto p-4">
            <h1>Welcome to the Blog Page</h1>
            {/* Add your page content here */}
        </div>
    );
}