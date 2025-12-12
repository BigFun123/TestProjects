using Hangfire;
using Hangfire.SqlServer;
using HangFire.Data;
using HangFire.Jobs;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container
builder.Services.AddScoped<DatabaseService>();
builder.Services.AddScoped<DailyJob>();

// Add Hangfire services
builder.Services.AddHangfire(configuration => configuration
    .SetDataCompatibilityLevel(CompatibilityLevel.Version_180)
    .UseSimpleAssemblyNameTypeSerializer()
    .UseRecommendedSerializerSettings()
    .UseSqlServerStorage(
        builder.Configuration.GetConnectionString("HangfireConnection"),
        new SqlServerStorageOptions
        {
            CommandBatchMaxTimeout = TimeSpan.FromMinutes(5),
            SlidingInvisibilityTimeout = TimeSpan.FromMinutes(5),
            QueuePollInterval = TimeSpan.Zero,
            UseRecommendedIsolationLevel = true,
            DisableGlobalLocks = true
        }));

// Add the processing server as IHostedService
builder.Services.AddHangfireServer();

var app = builder.Build();

// Configure the HTTP request pipeline
app.UseHttpsRedirection();

// Enable Hangfire Dashboard
app.UseHangfireDashboard("/hangfire", new DashboardOptions
{
    Authorization = new[] { new HangfireAuthorizationFilter() }
});

// Configure recurring job - runs daily at midnight UTC
RecurringJob.AddOrUpdate<DailyJob>(
    "daily-stored-procedure",
    job => job.RunDailyStoredProcedure(),
    Cron.Daily(0, 0), // Midnight UTC (00:00)
    new RecurringJobOptions
    {
        TimeZone = TimeZoneInfo.Utc
    });

app.MapGet("/", () => Results.Redirect("/hangfire"));

app.MapGet("/trigger-job", (IBackgroundJobClient backgroundJobs) =>
{
    var jobId = backgroundJobs.Enqueue<DailyJob>(job => job.RunDailyStoredProcedure());
    return Results.Ok(new { message = "Job triggered", jobId });
});

app.Run();

// Custom authorization filter for Hangfire Dashboard
public class HangfireAuthorizationFilter : Hangfire.Dashboard.IDashboardAuthorizationFilter
{
    public bool Authorize(Hangfire.Dashboard.DashboardContext context)
    {
        // In production, implement proper authentication
        // For development, allow all requests
        return true;
    }
}
