// src/lib/api/blogApi.ts
// Client-side functions to interact with blog related backend APIs

import { ApiResponse } from '@/types'; // Assuming you have a types file

export const fetchBlog = async (id: string): Promise<ApiResponse<any>> => {
    try {
        const res = await fetch(`/api/blogs?id=${id}`);
        if (!res.ok) {
            const errorData = await res.json();
            throw new Error(errorData.message || 'Failed to fetch blog');
        }
        return await res.json();
    } catch (error: any) {
        console.error('Error fetching blog:', error.message);
        return { success: false, message: error.message };
    }
};

export const fetchAllBlogs = async (): Promise<ApiResponse<any[]>> => {
    try {
        const res = await fetch(`/api/blogs`);
        if (!res.ok) {
            const errorData = await res.json();
            throw new Error(errorData.message || 'Failed to fetch all blogs');
        }
        return await res.json();
    } catch (error: any) {
        console.error('Error fetching all blogs:', error.message);
        return { success: false, message: error.message };
    }
};