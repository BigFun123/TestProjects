# Next.js Recharts Demo

A Next.js application with React 18 that demonstrates server-side data fetching and interactive charts using Recharts.

## Features

- Server-side component for initial data fetching
- Interactive Recharts line graph with dual Y-axes
- Three period buttons: Day, Week, Month
- Client-side data fetching on button click
- Built with Next.js 14 and React 18

## Getting Started

1. Install dependencies:
```bash
npm install
```

2. Run the development server:
```bash
npm run dev
```

3. Open [http://localhost:3000](http://localhost:3000) in your browser.

## How It Works

- The main page is a server component that fetches initial data from `/api/data?period=day`
- Users can click "Day", "Week", or "Month" buttons to fetch new data
- The chart displays two metrics: Units Sold and Revenue
- Data is fetched from the API route that generates sample data based on the selected period

## Tech Stack

- Next.js 14
- React 18
- TypeScript
- Recharts
