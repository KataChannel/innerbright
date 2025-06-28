// src/types/user.d.ts

export interface User {
    id: string;
    name: string;
    // Add other properties for User
    [key: string]: any;
}

// Generic API response type
export interface ApiResponse<T> {
    success: boolean;
    data?: T;
    message?: string;
    status?: number;
}