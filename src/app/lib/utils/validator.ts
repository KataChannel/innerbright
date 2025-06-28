// src/lib/utils/validator.ts
// Utility functions for validator

export const formatValidator = (data: any): string => {
    // Add your formatting logic here
    return JSON.stringify(data, null, 2);
};

export const validateValidator = (data: any): boolean => {
    // Add your validation logic here
    return !!data;
};