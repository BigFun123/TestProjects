'use client';

import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts';

interface DataPoint {
  date: string;
  value: number;
  revenue: number;
}

interface ChartProps {
  data: DataPoint[];
  timestamp: string;
  period?: string;
}

  // Month abbreviations for yearly period
  const monthAbbr = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  const dayAbbr = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  const xTickFormatter = (date: string) => {
    const d = new Date(date);
    if (period === 'yearly') {
      return monthAbbr[d.getMonth()];
    }
    if (period === 'week') {
      return dayAbbr[d.getDay()];
    }
    if (period === 'month') {
      // Format as mm/dd
      const mm = String(d.getMonth() + 1).padStart(2, '0');
      const dd = String(d.getDate()).padStart(2, '0');
      return `${mm}/${dd}`;
    }
    return d.toLocaleDateString();
  };

  return (
    <>
      <ResponsiveContainer width="100%" height={400}>
        <LineChart data={data}>
          <CartesianGrid strokeDasharray="3 3" />
          <XAxis
            dataKey="date"
            tickFormatter={xTickFormatter}
            domain={['auto', 'auto']}
            type="category"
          />
          <YAxis yAxisId="left" />
          <YAxis yAxisId="right" orientation="right" />
          <Tooltip labelFormatter={date => new Date(date).toLocaleString()} />
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
