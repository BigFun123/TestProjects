'use client';

import { useState } from 'react';
import Chart from './Chart';
import PeriodSelector from './PeriodSelector';

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
  data: ChartData;
  loading: boolean;
  setPeriod?: (formData: FormData) => Promise<void>;
}

export default function DashboardClient({ data, loading, setPeriod }: DashboardClientProps) {
  const period = data.period;
  return (
    <>
      <PeriodSelector
        period={period}
        loading={loading}
        onSelect={() => {}}
      />

      <Chart data={data.data} timestamp={data.timestamp} period={period}/>
    </>
  );
}
