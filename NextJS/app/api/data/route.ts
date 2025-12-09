import { NextRequest, NextResponse } from 'next/server';

type Period = 'day' | 'week' | 'month';

interface DataPoint {
  name: string;
  value: number;
  revenue: number;
}

// Generate sample data based on the period
function generateData(period: Period): DataPoint[] {
  const data: Record<Period, DataPoint[]> = {
    day: [
      { name: '12am', value: 45, revenue: 1200 },
      { name: '4am', value: 20, revenue: 500 },
      { name: '8am', value: 85, revenue: 2300 },
      { name: '12pm', value: 120, revenue: 3500 },
      { name: '4pm', value: 95, revenue: 2800 },
      { name: '8pm', value: 110, revenue: 3200 },
    ],
    week: [
      { name: 'Mon', value: 650, revenue: 18000 },
      { name: 'Tue', value: 720, revenue: 21000 },
      { name: 'Wed', value: 580, revenue: 16500 },
      { name: 'Thu', value: 810, revenue: 24000 },
      { name: 'Fri', value: 920, revenue: 28000 },
      { name: 'Sat', value: 1100, revenue: 35000 },
      { name: 'Sun', value: 890, revenue: 27000 },
    ],
    month: [
      { name: 'Week 1', value: 4200, revenue: 120000 },
      { name: 'Week 2', value: 5100, revenue: 145000 },
      { name: 'Week 3', value: 4800, revenue: 138000 },
      { name: 'Week 4', value: 5500, revenue: 165000 },
    ],
  };

  return data[period] || data.day;
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
