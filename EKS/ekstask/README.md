# EKS Task - Scheduled API Caller

A .NET 8 console application that schedules and executes API calls using cron expressions.

## Features

- **Cron-based scheduling** using NCrontab for flexible timing
- **Configurable via appsettings.json**
- **Robust error handling and logging**
- **Time zone support**
- **Background service using .NET Hosting**

## Configuration

Edit `appsettings.json` to configure the scheduled task:

```json
{
  "ScheduledTask": {
    "ApiBaseUrl": "https://your-api-domain.com",
    "Endpoint": "money/api/updatetotals",
    "CronExpression": "0 0 * * *",
    "TimeZone": "UTC"
  }
}
```

### Configuration Options

- **ApiBaseUrl**: The base URL of your API
- **Endpoint**: The API endpoint to call (relative path)
- **CronExpression**: Cron expression defining when to run the task
- **TimeZone**: Time zone for scheduling (use .NET time zone IDs)

### Cron Expression Examples

- `0 0 * * *` - Daily at midnight
- `0 */6 * * *` - Every 6 hours
- `0 0 * * 1` - Every Monday at midnight
- `30 8 * * 1-5` - Weekdays at 8:30 AM
- `0 0 1 * *` - First day of every month at midnight

## Building and Running

### Development

```bash
dotnet restore
dotnet build
dotnet run
```

### Production

```bash
dotnet publish -c Release -o ./publish
cd publish
dotnet ekstask.dll
```

## Running as a Windows Service

To run this as a Windows service, you can use `sc.exe` or install it with a tool like NSSM (Non-Sucking Service Manager).

### Using NSSM

1. Download NSSM from https://nssm.cc/download
2. Run: `nssm install EksTask "C:\path\to\ekstask.exe"`
3. Configure service parameters in NSSM GUI
4. Start the service: `nssm start EksTask`

### Using sc.exe

```cmd
sc create EksTask binPath="C:\path\to\ekstask.exe"
sc start EksTask
```

## Docker Deployment

Create a `Dockerfile`:

```dockerfile
FROM mcr.microsoft.com/dotnet/runtime:8.0
WORKDIR /app
COPY ./publish .
ENTRYPOINT ["dotnet", "ekstask.dll"]
```

Build and run:

```bash
docker build -t ekstask .
docker run -d --name ekstask ekstask
```

## Logging

The application uses Microsoft.Extensions.Logging. Logs include:
- Task initialization and schedule calculation
- Execution timing and next run information
- API call results and errors
- Service lifecycle events

## Error Handling

- Failed API calls are logged but don't stop the scheduler
- Invalid cron expressions will prevent startup
- Network errors are caught and logged
- The service will continue running even after errors

## Time Zones

Use .NET time zone IDs (not IANA). Common examples:
- `UTC`
- `Eastern Standard Time`
- `Pacific Standard Time`
- `Central European Standard Time`

Get all available time zones: `TimeZoneInfo.GetSystemTimeZones()`

## Dependencies

- Microsoft.Extensions.Hosting (8.0.0)
- Microsoft.Extensions.Http (8.0.0)
- NCrontab (3.3.3)
