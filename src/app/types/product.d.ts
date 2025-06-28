// src/types/product.d.ts

export interface Product {
    id: string;
    name: string;
    // Add other properties for Product
    [key: string]: any;
}

// Generic API response type
export interface ApiResponse<T> {
    success: boolean;
    data?: T;
    message?: string;
    status?: number;
}