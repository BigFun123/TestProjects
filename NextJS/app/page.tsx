import DashboardClient from './ChartClient';

type Period = 'day' | 'week' | 'month';

interface DataPoint {
  name: string;
  value: number;
  revenue: number;
}

// Generate initial data on the server
function getInitialData(): { period: Period; data: DataPoint[]; timestamp: string } {
  const data = [
    { name: '12am', value: 45, revenue: 1200 },
    { name: '4am', value: 20, revenue: 500 },
    { name: '8am', value: 85, revenue: 2300 },
    { name: '12pm', value: 120, revenue: 3500 },
    { name: '4pm', value: 95, revenue: 2800 },
    { name: '8pm', value: 110, revenue: 3200 },
  ];

  return {
    period: 'day',
    data,
    timestamp: new Date().toISOString(),
  };
}

export default function Page() {
  const initialData = getInitialData();
  
  return (
    <div style={{ padding: '20px', maxWidth: '1200px', margin: '0 auto' }}>
      <h1 style={{ marginBottom: '20px', fontSize: '2rem', fontWeight: 'bold' }}>
        Sales Dashboard
      </h1>
      
      <DashboardClient initialData={initialData} />
    </div>
  );
}
