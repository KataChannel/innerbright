// src/types/cart.d.ts

export interface Cart {
    id: string;
    name: string;
    // Add other properties for Cart
    [key: string]: any;
}

// Generic API response type
export interface ApiResponse<T> {
    success: boolean;
    data?: T;
    message?: string;
    status?: number;
}