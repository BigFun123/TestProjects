'use client';

import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts';

interface DataPoint {
  name: string;
  value: number;
  revenue: number;
}

interface ChartProps {
  data: DataPoint[];
  timestamp: string;
}

export default function Chart({ data, timestamp }: ChartProps) {
  return (
    <>
      <ResponsiveContainer width="100%" height={400}>
        <LineChart data={data}>
          <CartesianGrid strokeDasharray="3 3" />
          <XAxis dataKey="name" />
          <YAxis yAxisId="left" />
          <YAxis yAxisId="right" orientation="right" />
          <Tooltip />
          <Legend />
          <Line 
            yAxisId="left"
            type="monotone" 
            dataKey="value" 
            stroke="#8884d8" 
            strokeWidth={2}
            name="Units Sold"
          />
          <Line 
            yAxisId="right"
            type="monotone" 
            dataKey="revenue" 
            stroke="#82ca9d" 
            strokeWidth={2}
            name="Revenue ($)"
          />
        </LineChart>
      </ResponsiveContainer>

      <p style={{ marginTop: '20px', fontSize: '14px', color: '#666' }}>
        Last updated: {new Date(timestamp).toLocaleString()}
      </p>
    </>
  );
}
