# SQL Server Windows Authentication Demo

A simple C# console application demonstrating how to connect to SQL Server using Windows Authentication.

## Prerequisites

- .NET 8.0 SDK or later
- SQL Server instance accessible from your machine
- Windows Authentication enabled on SQL Server
- Your Windows account must have access permissions on the target database

## Configuration

Update the connection string in `Program.cs`:

```csharp
string connectionString = "Server=YOUR_SERVER_NAME;Database=YOUR_DATABASE_NAME;Integrated Security=true;TrustServerCertificate=true;";
```

Replace:
- `YOUR_SERVER_NAME` - Your SQL Server instance name (e.g., `localhost`, `.\SQLEXPRESS`, or `myserver.database.windows.net`)
- `YOUR_DATABASE_NAME` - The database you want to connect to (e.g., `master`, `TestDB`)

## How to Run

1. Restore dependencies:
   ```
   dotnet restore
   ```

2. Build the project:
   ```
   dotnet build
   ```

3. Run the application:
   ```
   dotnet run
   ```

## Connection String Options

- `Integrated Security=true` - Uses Windows Authentication
- `TrustServerCertificate=true` - Trusts the server certificate (useful for development/local instances)

## What It Does

The application:
1. Connects to SQL Server using your Windows credentials
2. Displays connection information
3. Executes a simple query showing the current server time and the Windows user account being used
4. Properly disposes of connections and commands

## Troubleshooting

- **Login failed**: Ensure your Windows account has permissions on the SQL Server instance
- **Server not found**: Check the server name and ensure SQL Server is running
- **Network error**: Verify SQL Server allows remote connections and Windows Firewall rules
