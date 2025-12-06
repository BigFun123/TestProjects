# TestRechart Frontend

A React + Vite application that visualizes data from a SQL database using Recharts.

## Features

- 📊 Multiple chart types (Bar, Line, Area)
- 🔄 Real-time data fetching from backend API
- 🎨 Beautiful, responsive UI
- 📱 Mobile-friendly design
- 🔀 Switch between SQL database and sample data
- 📋 Data preview table

## Prerequisites

- Node.js 18+ and npm

## Installation

1. Install dependencies:
   ```cmd
   npm install
   ```

## Running the Application

1. Make sure the backend API is running on `http://localhost:5000`

2. Start the development server:
   ```cmd
   npm run dev
   ```

3. Open your browser to `http://localhost:5173`

## Building for Production

```cmd
npm run build
npm run preview
```

## Configuration

The API URL is configured in `src/App.jsx`. Change it if your backend runs on a different port:

```javascript
const API_URL = 'http://localhost:5000'
```

## Features Explained

### Data Sources
- **SQL Database**: Fetches real data from your SQL Server via the backend API
- **Sample Data**: Uses hardcoded sample data (useful for testing without a database)

### Chart Types
- **Bar Chart**: Best for comparing values across categories
- **Line Chart**: Great for showing trends over time
- **Area Chart**: Emphasizes magnitude of change over time

### Data Preview
The table at the bottom shows the raw data being visualized in the chart.

## Technologies Used

- React 18
- Vite 5
- Recharts 2.12
- Modern CSS with responsive design

## Troubleshooting

**Backend Connection Issues:**
- Verify the backend is running on `http://localhost:5000`
- Check browser console for CORS errors
- Ensure backend CORS is configured correctly

**Charts Not Displaying:**
- Check that data is being received (look in the data preview table)
- Verify the data structure matches what Recharts expects: `[{ name: string, value: number }]`

## Customization

### Styling
Edit `src/App.css` and `src/index.css` to customize colors and layout.

### Chart Configuration
Modify chart properties in `src/App.jsx`:
```javascript
<Bar dataKey="value" fill="#8884d8" />
<XAxis dataKey="name" stroke="#333" />
```

### Adding More Chart Types
Import additional chart components from Recharts:
```javascript
import { PieChart, Pie, RadarChart, Radar } from 'recharts'
```
