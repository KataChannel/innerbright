import React from 'react';
import { Metadata } from 'next';
import Swipe from '@/app/components/common/Swipe';
import FeaturedCategories from '../components/common/FeaturedCategories';
import Promo from '../components/common/Promo';
import PopularProducts from '../components/common/PopularProducts';
export const metadata: Metadata = {
    title: 'Home Page - Your E-commerce',
    description: 'This is the Home page for Your E-commerce.',
};

export default function HomePage() {
    return (
        <div className="mx-auto">
            <Swipe
                slides={[
                    { id: 1, content: <div>Slide 1 Content</div> },
                    { id: 2, content: <div>Slide 2 Content</div> },
                    { id: 3, content: <div>Slide 3 Content</div> },
                ]}
            />
            <FeaturedCategories />
            <Promo />
            <PopularProducts />
            <PopularProducts />
            <PopularProducts />
        </div>
    );
}