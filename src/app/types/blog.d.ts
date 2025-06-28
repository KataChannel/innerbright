// src/types/blog.d.ts

export interface Blog {
    id: string;
    name: string;
    // Add other properties for Blog
    [key: string]: any;
}

// Generic API response type
export interface ApiResponse<T> {
    success: boolean;
    data?: T;
    message?: string;
    status?: number;
}