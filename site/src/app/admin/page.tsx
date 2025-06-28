import React from 'react';
import { Metadata } from 'next';
export const metadata: Metadata = {
    title: 'Admin Page - Your E-commerce',
    description: 'This is the Admin page for Your E-commerce.',
};

export default function AdminPage() {
    return (
        <div className="container mx-auto p-4">
            <h1>Welcome to the Admin Page</h1>
            {/* Add your admin content here */}
        </div>
    );
}