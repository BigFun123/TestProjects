# HangFire Daily Job Demo

A .NET 8 web application that uses HangFire to execute a stored procedure every day at midnight.

## Features

- **HangFire Dashboard**: Monitor and manage background jobs
- **Recurring Job**: Automatically runs daily at midnight UTC
- **SQL Server Integration**: Executes stored procedures
- **Manual Trigger**: Endpoint to manually trigger the job for testing

## Prerequisites

- .NET 8 SDK
- SQL Server (or SQL Server Express)
- Two databases:
  - `HangFireDemo` - Your application database
  - `HangFireJobs` - HangFire storage database

## Setup Instructions

### 1. Create Databases

```sql
-- Create the application database
CREATE DATABASE HangFireDemo;

-- Create the HangFire jobs database
CREATE DATABASE HangFireJobs;
```

### 2. Create the Stored Procedure

Run the SQL script in `SQL/DailyMaintenanceProc.sql` against the `HangFireDemo` database to create the example stored procedure. Replace the example logic with your actual business requirements.

### 3. Update Connection Strings

Edit `appsettings.json` and update the connection strings to match your SQL Server configuration:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=YOUR_SERVER;Database=HangFireDemo;Trusted_Connection=True;TrustServerCertificate=True;",
    "HangfireConnection": "Server=YOUR_SERVER;Database=HangFireJobs;Trusted_Connection=True;TrustServerCertificate=True;"
  }
}
```

For SQL authentication instead of Windows authentication:
```
Server=YOUR_SERVER;Database=HangFireDemo;User Id=YOUR_USER;Password=YOUR_PASSWORD;TrustServerCertificate=True;
```

### 4. Restore NuGet Packages

```cmd
dotnet restore
```

### 5. Run the Application

```cmd
dotnet run
```

The application will:
- Start a web server (typically at https://localhost:5001)
- Initialize HangFire with SQL Server storage
- Create the recurring job schedule
- Redirect to the HangFire dashboard

## Usage

### Access the Dashboard

Navigate to `https://localhost:5001/hangfire` to view the HangFire dashboard where you can:
- Monitor job execution history
- View scheduled jobs
- Manually trigger jobs
- See failed jobs and retry them

### Manual Job Trigger

To manually trigger the job (useful for testing):

```
GET https://localhost:5001/trigger-job
```

Or simply visit that URL in your browser.

### Schedule Details

The job is configured to run:
- **Frequency**: Daily
- **Time**: Midnight (00:00) UTC
- **Job Name**: `daily-stored-procedure`
- **Stored Procedure**: `dbo.DailyMaintenanceProc`

### Customizing the Schedule

To change the schedule, modify the Cron expression in `Program.cs`:

```csharp
RecurringJob.AddOrUpdate<DailyJob>(
    "daily-stored-procedure",
    job => job.RunDailyStoredProcedure(),
    Cron.Daily(0, 0), // Change this line
    new RecurringJobOptions
    {
        TimeZone = TimeZoneInfo.Utc // Change timezone if needed
    });
```

Common Cron expressions:
- `Cron.Daily(0, 0)` - Every day at midnight
- `Cron.Daily(3, 30)` - Every day at 3:30 AM
- `Cron.Hourly()` - Every hour
- `Cron.Weekly()` - Every Sunday at midnight
- `"0 */6 * * *"` - Every 6 hours

### Changing the Stored Procedure

To execute a different stored procedure, update the procedure name in `Jobs/DailyJob.cs`:

```csharp
await _databaseService.ExecuteStoredProcedureAsync("dbo.YourProcedureName");
```

## Project Structure

```
HangFire/
├── Program.cs                          # Application startup and HangFire configuration
├── HangFire.csproj                     # Project file with dependencies
├── appsettings.json                    # Configuration and connection strings
├── Data/
│   └── DatabaseService.cs              # Database access service
├── Jobs/
│   └── DailyJob.cs                     # HangFire job implementation
└── SQL/
    └── DailyMaintenanceProc.sql        # Example stored procedure
```

## Production Considerations

1. **Authentication**: Implement proper authentication for the HangFire dashboard by modifying `HangfireAuthorizationFilter`
2. **Error Handling**: HangFire automatically retries failed jobs. Configure retry policies as needed
3. **Monitoring**: Set up logging to Application Insights or your preferred monitoring solution
4. **Connection Strings**: Store connection strings securely (Azure Key Vault, environment variables, etc.)
5. **Time Zones**: Ensure the correct timezone is set for your requirements
6. **Database Permissions**: Ensure the application has appropriate permissions to execute the stored procedure

## Troubleshooting

### Job Not Running
- Check the HangFire dashboard for failed jobs
- Verify connection strings are correct
- Ensure both databases exist
- Check that the stored procedure exists and has correct permissions

### Dashboard Not Accessible
- Verify the application is running
- Check firewall settings
- Ensure port is not in use by another application

### Database Connection Issues
- Test connection strings using SQL Server Management Studio
- Verify SQL Server is running and accepting connections
- Check Windows Firewall settings for SQL Server
