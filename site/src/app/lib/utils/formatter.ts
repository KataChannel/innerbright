// src/lib/utils/formatter.ts
// Utility functions for formatter

export const formatFormatter = (data: any): string => {
    // Add your formatting logic here
    return JSON.stringify(data, null, 2);
};

export const validateFormatter = (data: any): boolean => {
    // Add your validation logic here
    return !!data;
};