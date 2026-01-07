import React from "react";

type Period = 'day' | 'week' | 'month';

type PeriodSelectorProps = {
  period: Period;
  loading?: boolean;
  onSelect: (period: Period) => void;
};

const periods: { label: string; value: Period }[] = [
  { label: 'Day', value: 'day' },
  { label: 'Week', value: 'week' },
  { label: 'Month', value: 'month' },
];

export default function PeriodSelector({ period, loading, onSelect }: PeriodSelectorProps) {
  return (
    <div style={{ marginBottom: '20px', display: 'flex', gap: '10px' }}>
      {periods.map((p) => (
        <button
          key={p.value}
          onClick={() => onSelect(p.value)}
          disabled={loading}
          style={{
            padding: '10px 20px',
            fontSize: '16px',
            borderRadius: '6px',
            border: '1px solid #ccc',
            backgroundColor: period === p.value ? '#0070f3' : '#fff',
            color: period === p.value ? '#fff' : '#000',
            cursor: loading ? 'not-allowed' : 'pointer',
            fontWeight: period === p.value ? 'bold' : 'normal',
            opacity: loading ? 0.6 : 1,
          }}
        >
          {p.label}
        </button>
      ))}
    </div>
  );
}
