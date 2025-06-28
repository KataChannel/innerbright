import React from 'react';
import { Metadata } from 'next';

export const metadata: Metadata = {
    title: 'AccountDashboard Page - Your E-commerce',
    description: 'This is the AccountDashboard page for Your E-commerce.',
};

export default function AccountDashboardPage() {
    return (
        <div className="container mx-auto p-4">
            <h1>Welcome to the AccountDashboard Page</h1>
            {/* Add your page content here */}
        </div>
    );
}