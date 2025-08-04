import React from 'react';
import { InputProps } from './types';

const Input: React.FC<InputProps> = ({
  type = 'text',
  placeholder,
  value,
  defaultValue,
  onChange,
  onBlur,
  onFocus,
  disabled = false,
  required = false,
  readOnly = false,
  error,
  label,
  helpText,
  size = 'md',
  variant = 'default',
  className = '',
  icon,
  iconPosition = 'left',
  ...props
}) => {
  const getVariantClasses = () => {
    const baseClasses = 'w-full rounded-lg border transition-colors focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent';
    
    switch (variant) {
      case 'filled':
        return `${baseClasses} bg-gray-100 border-gray-300 focus:bg-white`;
      case 'outline':
        return `${baseClasses} bg-transparent border-gray-300 hover:border-gray-400`;
      case 'default':
      default:
        return `${baseClasses} bg-white border-gray-300 hover:border-gray-400`;
    }
  };

  const getSizeClasses = () => {
    switch (size) {
      case 'sm':
        return 'px-3 py-1.5 text-sm';
      case 'md':
        return 'px-4 py-2 text-base';
      case 'lg':
        return 'px-4 py-3 text-lg';
      default:
        return 'px-4 py-2 text-base';
    }
  };

  const getErrorClasses = () => {
    return error ? 'border-red-500 focus:ring-red-500' : '';
  };

  const variantClasses = getVariantClasses();
  const sizeClasses = getSizeClasses();
  const errorClasses = getErrorClasses();
  
  const inputClasses = [
    variantClasses,
    sizeClasses,
    errorClasses,
    disabled && 'opacity-50 cursor-not-allowed bg-gray-100',
    icon && iconPosition === 'left' && 'pl-10',
    icon && iconPosition === 'right' && 'pr-10',
    className
  ].filter(Boolean).join(' ');

  return (
    <div className="space-y-1">
      {label && (
        <label className="block text-sm font-medium text-gray-700">
          {label}
          {required && <span className="text-red-500 ml-1">*</span>}
        </label>
      )}
      
      <div className="relative">
        {icon && iconPosition === 'left' && (
          <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
            <div className="h-5 w-5 text-gray-400">
              {icon}
            </div>
          </div>
        )}
        
        <input
          type={type}
          placeholder={placeholder}
          value={value}
          defaultValue={defaultValue}
          onChange={onChange}
          onBlur={onBlur}
          onFocus={onFocus}
          disabled={disabled}
          required={required}
          readOnly={readOnly}
          className={inputClasses}
          {...props}
        />
        
        {icon && iconPosition === 'right' && (
          <div className="absolute inset-y-0 right-0 pr-3 flex items-center pointer-events-none">
            <div className="h-5 w-5 text-gray-400">
              {icon}
            </div>
          </div>
        )}
      </div>
      
      {error && (
        <p className="text-sm text-red-600">
          {error}
        </p>
      )}
      
      {helpText && !error && (
        <p className="text-sm text-gray-500">
          {helpText}
        </p>
      )}
    </div>
  );
};

export default Input;
