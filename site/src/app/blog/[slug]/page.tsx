import React from 'react';
import { Metadata } from 'next';

export const metadata: Metadata = {
    title: 'BlogPost Page - Your E-commerce',
    description: 'This is the BlogPost page for Your E-commerce.',
};

export default function BlogPostPage() {
    return (
        <div className="container mx-auto p-4">
            <h1>Welcome to the BlogPost Page</h1>
            {/* Add your page content here */}
        </div>
    );
}