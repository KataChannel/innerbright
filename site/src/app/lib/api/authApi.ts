// src/lib/api/authApi.ts
// Client-side functions to interact with auth related backend APIs

import { ApiResponse } from '@/types'; // Assuming you have a types file

export const fetchAuth = async (id: string): Promise<ApiResponse<any>> => {
    try {
        const res = await fetch(`/api/auths?id=${id}`);
        if (!res.ok) {
            const errorData = await res.json();
            throw new Error(errorData.message || 'Failed to fetch auth');
        }
        return await res.json();
    } catch (error: any) {
        console.error('Error fetching auth:', error.message);
        return { success: false, message: error.message };
    }
};

export const fetchAllAuths = async (): Promise<ApiResponse<any[]>> => {
    try {
        const res = await fetch(`/api/auths`);
        if (!res.ok) {
            const errorData = await res.json();
            throw new Error(errorData.message || 'Failed to fetch all auths');
        }
        return await res.json();
    } catch (error: any) {
        console.error('Error fetching all auths:', error.message);
        return { success: false, message: error.message };
    }
};