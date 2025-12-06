# TestRechart - SQL Data Visualization Demo

A full-stack application demonstrating how to visualize SQL Server data using Recharts in a React application.

## 📁 Project Structure

```
TestRechart/
├── backend/          # ASP.NET Core Web API
│   ├── Program.cs
│   ├── TestRechart.Backend.csproj
│   ├── appsettings.json
│   └── README.md
└── frontend/         # React + Vite + Recharts
    ├── src/
    │   ├── App.jsx
    │   ├── App.css
    │   ├── main.jsx
    │   └── index.css
    ├── package.json
    ├── vite.config.js
    └── README.md
```

## 🚀 Quick Start

### 1. Setup Database (Optional)

If you want to use real SQL Server data:

```sql
CREATE DATABASE TestDB;
GO

USE TestDB;
GO

CREATE TABLE Orders (
    OrderId INT PRIMARY KEY IDENTITY(1,1),
    OrderDate DATE NOT NULL,
    TotalAmount DECIMAL(18,2) NOT NULL
);
GO

INSERT INTO Orders (OrderDate, TotalAmount) VALUES
    ('2024-01-15', 4000),
    ('2024-02-20', 3000),
    ('2024-03-10', 2000),
    ('2024-04-05', 2780),
    ('2024-05-12', 1890),
    ('2024-06-18', 2390),
    ('2024-07-25', 3490);
```

### 2. Start Backend API

```cmd
cd backend
dotnet restore
dotnet run
```

The API will be available at `http://localhost:5000`

### 3. Start Frontend

Open a new terminal:

```cmd
cd frontend
npm install
npm run dev
```

The frontend will be available at `http://localhost:5173`

## 🎯 Features

- **Multiple Chart Types**: Bar, Line, and Area charts
- **SQL Server Integration**: Fetches data from SQL Server database
- **Fallback Sample Data**: Works without a database using sample data
- **Responsive Design**: Mobile-friendly UI
- **Real-time Updates**: Refresh data on demand
- **Data Preview**: See the raw data in a table

## 🛠️ Technologies

### Backend
- ASP.NET Core 8.0
- Microsoft.Data.SqlClient
- Minimal APIs

### Frontend
- React 18
- Vite 5
- Recharts 2.12
- Modern CSS

## 📖 Usage

1. **Choose Data Source**: Switch between SQL Database and Sample Data
2. **Select Chart Type**: Choose from Bar, Line, or Area charts
3. **Refresh Data**: Click the refresh button to reload data from the backend
4. **View Raw Data**: Check the data preview table at the bottom

## 🔧 Configuration

### Backend Connection String
Edit `backend/appsettings.json`:
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Database=TestDB;Integrated Security=true;TrustServerCertificate=true;"
  }
}
```

### Frontend API URL
Edit `frontend/src/App.jsx`:
```javascript
const API_URL = 'http://localhost:5000'
```

## 📚 Documentation

- [Backend README](backend/README.md) - API documentation and setup
- [Frontend README](frontend/README.md) - React app details and customization

## ⚠️ Notes

- The backend automatically falls back to sample data if the database connection fails
- CORS is pre-configured for `localhost:5173` and `localhost:3000`
- The SQL query in the backend can be customized for your database schema

## 🐛 Troubleshooting

**Backend won't start:**
- Ensure .NET 8.0 SDK is installed
- Check if port 5000 is available

**Frontend can't connect to backend:**
- Verify backend is running on port 5000
- Check browser console for CORS errors
- Ensure both apps are running

**Database connection fails:**
- Verify SQL Server is running
- Check connection string in `appsettings.json`
- The app will use sample data automatically

## 📄 License

This is a demonstration project for educational purposes.
