// src/lib/api/productApi.ts
// Client-side functions to interact with product related backend APIs

import { ApiResponse } from '@/types'; // Assuming you have a types file

export const fetchProduct = async (id: string): Promise<ApiResponse<any>> => {
    try {
        const res = await fetch(`/api/products?id=${id}`);
        if (!res.ok) {
            const errorData = await res.json();
            throw new Error(errorData.message || 'Failed to fetch product');
        }
        return await res.json();
    } catch (error: any) {
        console.error('Error fetching product:', error.message);
        return { success: false, message: error.message };
    }
};

export const fetchAllProducts = async (): Promise<ApiResponse<any[]>> => {
    try {
        const res = await fetch(`/api/products`);
        if (!res.ok) {
            const errorData = await res.json();
            throw new Error(errorData.message || 'Failed to fetch all products');
        }
        return await res.json();
    } catch (error: any) {
        console.error('Error fetching all products:', error.message);
        return { success: false, message: error.message };
    }
};