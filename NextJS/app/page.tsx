import DashboardClient from './ChartClient';
import { generateData } from './api/data/route';
import { useState } from 'react';

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

async function getData(period: Period): Promise<ChartData> {
  // Use the same logic as the API route for SSR
  const data = generateData(period);
  return {
    period,
    data,
    timestamp: new Date().toISOString(),
  };
}

let selectedPeriod: Period = 'day';

export default async function Page() {

  const data = await getData(selectedPeriod);

  return (
    <div style={{ padding: '20px', maxWidth: '1200px', margin: '0 auto' }}>
      <h1 style={{ marginBottom: '20px', fontSize: '2rem', fontWeight: 'bold' }}>
        Sales Dashboard
      </h1>
      <DashboardClient data={data} loading={false} setPeriod={setPeriod} />
    </div>
  );
}
