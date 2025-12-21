import React from 'react';

type ButtonVariant = 'primary' | 'secondary' | 'accent';
type ButtonSize = 'sm' | 'md' | 'lg';

interface ThemeButtonProps {
  children: React.ReactNode;
  variant?: ButtonVariant;
  size?: ButtonSize;
  onClick?: () => void;
}

const ThemeButton: React.FC<ThemeButtonProps> = ({ 
  children, 
  variant = 'primary',
  size = 'md',
  onClick 
}) => {
  // Define styles using theme colors
  const variantStyles = {
    primary: 'bg-primary-500 hover:bg-primary-600 active:bg-primary-700 text-white',
    secondary: 'bg-secondary-500 hover:bg-secondary-600 active:bg-secondary-700 text-white',
    accent: 'bg-accent-500 hover:bg-accent-600 active:bg-accent-700 text-white',
  };

  const sizeStyles = {
    sm: 'px-3 py-1.5 text-sm',
    md: 'px-4 py-2 text-base',
    lg: 'px-6 py-3 text-lg',
  };

  return (
    <button
      onClick={onClick}
      className={`
        ${variantStyles[variant]}
        ${sizeStyles[size]}
        rounded-lg font-semibold
        transition-all duration-200
        shadow-md hover:shadow-lg
        focus:outline-none focus:ring-2 focus:ring-offset-2
        ${variant === 'primary' ? 'focus:ring-primary-500' : ''}
        ${variant === 'secondary' ? 'focus:ring-secondary-500' : ''}
        ${variant === 'accent' ? 'focus:ring-accent-500' : ''}
        transform hover:scale-105 active:scale-95
      `}
    >
      {children}
    </button>
  );
};

export default ThemeButton;
