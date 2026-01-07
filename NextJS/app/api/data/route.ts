import { NextRequest, NextResponse } from 'next/server';

type Period = 'day' | 'week' | 'month';

interface DataPoint {
  date: string; // ISO date string
  value: number;
  revenue: number;
}

// Generate sample data based on the period
export function generateData(period: Period): DataPoint[] {
  const now = new Date();
  if (period === 'day') {
    // 6 points, every 4 hours
    return Array.from({ length: 6 }, (_, i) => {
      const d = new Date(now.getFullYear(), now.getMonth(), now.getDate(), i * 4);
      return {
        date: d.toISOString(),
        value: [45, 20, 85, 120, 95, 110][i],
        revenue: [1200, 500, 2300, 3500, 2800, 3200][i],
      };
    });
  } else if (period === 'week') {
    // 7 points, each day of week
    return Array.from({ length: 7 }, (_, i) => {
      const d = new Date(now.getFullYear(), now.getMonth(), now.getDate() - now.getDay() + i);
      return {
        date: d.toISOString(),
        value: [650, 720, 580, 810, 920, 1100, 890][i],
        revenue: [18000, 21000, 16500, 24000, 28000, 35000, 27000][i],
      };
    });
  } else {
    // 4 points, each week
    return Array.from({ length: 4 }, (_, i) => {
      const d = new Date(now.getFullYear(), now.getMonth(), now.getDate() - now.getDay() + i * 7);
      return {
        date: d.toISOString(),
        value: [4200, 5100, 4800, 5500][i],
        revenue: [120000, 145000, 138000, 165000][i],
      };
    });
  }
}

export async function GET(request: NextRequest) {
  // Get the period parameter from the URL
  const searchParams = request.nextUrl.searchParams;
  const period = (searchParams.get('period') as Period) || 'day';

  // Validate period parameter
  if (!['day', 'week', 'month'].includes(period)) {
    return NextResponse.json(
      { error: 'Invalid period. Must be day, week, or month.' },
      { status: 400 }
    );
  }

  // Simulate a small delay to mimic real API behavior
  await new Promise(resolve => setTimeout(resolve, 200));

  // Generate and return data
  const data = generateData(period);
  
  return NextResponse.json({
    period,
    data,
    timestamp: new Date().toISOString(),
  });
}
