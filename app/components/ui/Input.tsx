// This is deprecated - use @/components/Input instead
import React from 'react';
import Input from '@/components/Input';

interface DeprecatedInputProps {
    message?: string;
}

const DeprecatedInput: React.FC<DeprecatedInputProps> = ({ message = 'Hello from Input!' }) => {
    return (
        <Input 
            placeholder={message}
            className="p-4 border rounded shadow"
        />
    );
};

export default DeprecatedInput;