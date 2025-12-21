'use client';

import React from 'react';
import { AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Legend } from 'recharts';
import resolveConfig from 'tailwindcss/resolveConfig';
import tailwindConfig from '../../tailwind.config';

const fullConfig = resolveConfig(tailwindConfig);
const themeColors = fullConfig.theme?.colors as any;

const data = [
  { month: 'Jan', primary: 4000, secondary: 2400, accent: 2400 },
  { month: 'Feb', primary: 3000, secondary: 1398, accent: 2210 },
  { month: 'Mar', primary: 2000, secondary: 9800, accent: 2290 },
  { month: 'Apr', primary: 2780, secondary: 3908, accent: 2000 },
  { month: 'May', primary: 1890, secondary: 4800, accent: 2181 },
  { month: 'Jun', primary: 2390, secondary: 3800, accent: 2500 },
  { month: 'Jul', primary: 3490, secondary: 4300, accent: 2100 },
];

type ChartVariant = 'primary' | 'secondary' | 'accent' | 'all';

interface ThemeChartProps {
  variant?: ChartVariant;
  title?: string;
}

const ThemeChart: React.FC<ThemeChartProps> = ({ 
  variant = 'all',
  title = 'Theme Color Area Chart'
}) => {
  return (
    <div className="card">
      <h3 className="mb-4">{title}</h3>
      <ResponsiveContainer width="100%" height={300}>
        <AreaChart data={data}>
          <defs>
            <linearGradient id="colorPrimary" x1="0" y1="0" x2="0" y2="1">
              <stop offset="5%" stopColor={themeColors.primary[500]} stopOpacity={0.8}/>
              <stop offset="95%" stopColor={themeColors.primary[500]} stopOpacity={0.1}/>
            </linearGradient>
            <linearGradient id="colorSecondary" x1="0" y1="0" x2="0" y2="1">
              <stop offset="5%" stopColor={themeColors.secondary[500]} stopOpacity={0.8}/>
              <stop offset="95%" stopColor={themeColors.secondary[500]} stopOpacity={0.1}/>
            </linearGradient>
            <linearGradient id="colorAccent" x1="0" y1="0" x2="0" y2="1">
              <stop offset="5%" stopColor={themeColors.accent[500]} stopOpacity={0.8}/>
              <stop offset="95%" stopColor={themeColors.accent[500]} stopOpacity={0.1}/>
            </linearGradient>
          </defs>
          <CartesianGrid strokeDasharray="3 3" opacity={0.3} />
          <XAxis 
            dataKey="month" 
            tick={{ fill: '#6b7280' }}
            tickLine={{ stroke: '#6b7280' }}
          />
          <YAxis 
            tick={{ fill: '#6b7280' }}
            tickLine={{ stroke: '#6b7280' }}
          />
          <Tooltip 
            contentStyle={{ 
              backgroundColor: 'white',
              border: '1px solid #e5e7eb',
              borderRadius: '8px',
              boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.1)'
            }}
          />
          <Legend />
          
          {(variant === 'primary' || variant === 'all') && (
            <Area 
              type="monotone" 
              dataKey="primary" 
              stroke={themeColors.primary[500]}
              strokeWidth={2}
              fillOpacity={1} 
              fill="url(#colorPrimary)"
              name="Primary Theme"
            />
          )}
          
          {(variant === 'secondary' || variant === 'all') && (
            <Area 
              type="monotone" 
              dataKey="secondary" 
              stroke={themeColors.secondary[500]}
              strokeWidth={2}
              fillOpacity={1} 
              fill="url(#colorSecondary)"
              name="Secondary Theme"
            />
          )}
          
          {(variant === 'accent' || variant === 'all') && (
            <Area 
              type="monotone" 
              dataKey="accent" 
              stroke={themeColors.accent[500]}
              strokeWidth={2}
              fillOpacity={1} 
              fill="url(#colorAccent)"
              name="Accent Theme"
            />
          )}
        </AreaChart>
      </ResponsiveContainer>
    </div>
  );
};

export default ThemeChart;
