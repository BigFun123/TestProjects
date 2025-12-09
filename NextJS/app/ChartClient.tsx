'use client';

import { useState } from 'react';
import Chart from './Chart';

type Period = 'day' | 'week' | 'month';

interface DataPoint {
  name: string;
  value: number;
  revenue: number;
}

interface ChartData {
  period: Period;
  data: DataPoint[];
  timestamp: string;
}

interface DashboardClientProps {
  initialData: ChartData;
}

export default function DashboardClient({ initialData }: DashboardClientProps) {
  const [period, setPeriod] = useState<Period>(initialData.period);
  const [data, setData] = useState<ChartData>(initialData);
  const [loading, setLoading] = useState(false);

  const handlePeriodChange = async (newPeriod: Period) => {
    if (newPeriod === period) return;
    
    setLoading(true);
    setPeriod(newPeriod);
    
    try {
      const response = await fetch(`/api/data?period=${newPeriod}`);
      const result = await response.json();
      setData(result);
    } catch (error) {
      console.error('Error fetching data:', error);
    } finally {
      setLoading(false);
    }
  };

  return (
    <>
      <div style={{ marginBottom: '20px', display: 'flex', gap: '10px' }}>
        <button
          onClick={() => handlePeriodChange('day')}
          disabled={loading}
          style={{
            padding: '10px 20px',
            fontSize: '16px',
            borderRadius: '6px',
            border: '1px solid #ccc',
            backgroundColor: period === 'day' ? '#0070f3' : '#fff',
            color: period === 'day' ? '#fff' : '#000',
            cursor: loading ? 'not-allowed' : 'pointer',
            fontWeight: period === 'day' ? 'bold' : 'normal',
            opacity: loading ? 0.6 : 1,
          }}
        >
          Day
        </button>
        <button
          onClick={() => handlePeriodChange('week')}
          disabled={loading}
          style={{
            padding: '10px 20px',
            fontSize: '16px',
            borderRadius: '6px',
            border: '1px solid #ccc',
            backgroundColor: period === 'week' ? '#0070f3' : '#fff',
            color: period === 'week' ? '#fff' : '#000',
            cursor: loading ? 'not-allowed' : 'pointer',
            fontWeight: period === 'week' ? 'bold' : 'normal',
            opacity: loading ? 0.6 : 1,
          }}
        >
          Week
        </button>
        <button
          onClick={() => handlePeriodChange('month')}
          disabled={loading}
          style={{
            padding: '10px 20px',
            fontSize: '16px',
            borderRadius: '6px',
            border: '1px solid #ccc',
            backgroundColor: period === 'month' ? '#0070f3' : '#fff',
            color: period === 'month' ? '#fff' : '#000',
            cursor: loading ? 'not-allowed' : 'pointer',
            fontWeight: period === 'month' ? 'bold' : 'normal',
            opacity: loading ? 0.6 : 1,
          }}
        >
          Month
        </button>
      </div>

      {loading && (
        <p style={{ marginBottom: '10px', fontSize: '14px', color: '#666' }}>
          Loading data...
        </p>
      )}

      <Chart data={data.data} timestamp={data.timestamp} />
    </>
  );
}
