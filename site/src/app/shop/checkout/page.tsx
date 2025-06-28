import React from 'react';
import { Metadata } from 'next';

export const metadata: Metadata = {
    title: 'Checkout Page - Your E-commerce',
    description: 'This is the Checkout page for Your E-commerce.',
};

export default function CheckoutPage() {
    return (
        <div className="container mx-auto p-4">
            <h1>Welcome to the Checkout Page</h1>
            {/* Add your page content here */}
        </div>
    );
}