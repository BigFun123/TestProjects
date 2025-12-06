# TestRechart Backend API

A simple ASP.NET Core Web API that connects to SQL Server and provides data endpoints for the Recharts frontend.

## Features

- 📊 Fetches data from SQL Server database
- 🔄 Fallback to sample data if database connection fails
- 🌐 CORS enabled for frontend communication
- ⚡ Fast and lightweight minimal API

## Prerequisites

- .NET 8.0 SDK or later
- SQL Server (LocalDB, Express, or full version)
- A database with an `Orders` table (or modify the query in `Program.cs`)

## Database Setup

The API expects a database with the following structure:

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

-- Insert sample data
INSERT INTO Orders (OrderDate, TotalAmount) VALUES
    ('2024-01-15', 4000),
    ('2024-02-20', 3000),
    ('2024-03-10', 2000),
    ('2024-04-05', 2780),
    ('2024-05-12', 1890),
    ('2024-06-18', 2390),
    ('2024-07-25', 3490);
```

## Configuration

Update the connection string in `appsettings.json`:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Database=TestDB;Integrated Security=true;TrustServerCertificate=true;"
  }
}
```

For SQL Server authentication instead of Windows authentication:
```
"DefaultConnection": "Server=localhost;Database=TestDB;User Id=your_user;Password=your_password;TrustServerCertificate=true;"
```

## Running the Application

1. Restore dependencies and run:
   ```cmd
   dotnet restore
   dotnet run
   ```

2. The API will start on `http://localhost:5000`

## API Endpoints

### GET /api/chartdata
Returns chart data from the SQL database. Falls back to sample data if connection fails.

**Response:**
```json
[
  { "name": "January", "value": 4000 },
  { "name": "February", "value": 3000 }
]
```

### GET /api/sampledata
Returns hardcoded sample data (useful for testing).

### GET /
Health check endpoint.

## Customizing the Query

To use your own database schema, modify the SQL query in `Program.cs`:

```csharp
var query = @"
    SELECT TOP 10 
        YourNameColumn as Name,
        YourValueColumn as Value
    FROM YourTable
    WHERE YourCondition
    ORDER BY YourOrderColumn";
```

## Troubleshooting

**Connection Issues:**
- Verify SQL Server is running
- Check connection string in `appsettings.json`
- Ensure database and table exist
- Check firewall settings

**CORS Issues:**
- Frontend origin is configured for `http://localhost:5173` and `http://localhost:3000`
- Add additional origins in `Program.cs` if needed

## Technologies Used

- ASP.NET Core 8.0
- Microsoft.Data.SqlClient 5.2.0
- Minimal APIs
