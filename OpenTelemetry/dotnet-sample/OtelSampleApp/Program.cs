using OpenTelemetry.Resources;
using OpenTelemetry.Trace;
using OpenTelemetry.Metrics;
using OpenTelemetry.Logs;
using System.Diagnostics;
using System.Diagnostics.Metrics;

var builder = WebApplication.CreateBuilder(args);

// Create ActivitySource for custom spans
var activitySource = new ActivitySource("OtelSampleApp");

// Create custom metrics
var meter = new Meter("OtelSampleApp", "1.0.0");
var requestCounter = meter.CreateCounter<long>("app.requests.total", "requests", "Total number of requests");
var processingTimeHistogram = meter.CreateHistogram<double>("app.request.duration", "ms", "Request processing time");
var activeRequestsGauge = meter.CreateUpDownCounter<int>("app.requests.active", "requests", "Number of active requests");

// Get OpenTelemetry endpoint from environment, configuration, or use default
var otlpEndpoint = Environment.GetEnvironmentVariable("OTEL_EXPORTER_OTLP_ENDPOINT") 
    ?? builder.Configuration["OpenTelemetry:OtlpEndpoint"]
    ?? "http://localhost:4317";

// Register HttpClient BEFORE building
builder.Services.AddHttpClient();

// Configure OpenTelemetry
builder.Services.AddOpenTelemetry()
    .ConfigureResource(resource => resource
        .AddService(
            serviceName: "otel-sample-app",
            serviceVersion: "1.0.0",
            serviceInstanceId: Environment.MachineName))
    .WithTracing(tracing => tracing
        .AddAspNetCoreInstrumentation()
        .AddHttpClientInstrumentation()
        .AddSource("OtelSampleApp")
        .AddConsoleExporter()
        .AddOtlpExporter(options =>
        {
            options.Endpoint = new Uri(otlpEndpoint);
        }))
    .WithMetrics(metrics => metrics
        .AddAspNetCoreInstrumentation()
        .AddHttpClientInstrumentation()
        .AddRuntimeInstrumentation()
        .AddMeter("OtelSampleApp")
        .AddConsoleExporter()
        .AddOtlpExporter(options =>
        {
            options.Endpoint = new Uri(otlpEndpoint);
        }));

// Configure logging with OpenTelemetry
builder.Logging.AddOpenTelemetry(logging =>
{
    logging.AddConsoleExporter();
    logging.AddOtlpExporter(options =>
    {
        options.Endpoint = new Uri(otlpEndpoint);
    });
});

var app = builder.Build();

// Sample endpoints for testing
app.MapGet("/", () => 
{
    var stopwatch = Stopwatch.StartNew();
    activeRequestsGauge.Add(1);
    
    app.Logger.LogInformation("Root endpoint called");
    requestCounter.Add(1, new KeyValuePair<string, object?>("endpoint", "/"));
    
    var result = Results.Ok(new { message = "Hello from OpenTelemetry Sample!", timestamp = DateTime.UtcNow });
    
    stopwatch.Stop();
    processingTimeHistogram.Record(stopwatch.ElapsedMilliseconds, new KeyValuePair<string, object?>("endpoint", "/"));
    activeRequestsGauge.Add(-1);
    
    return result;
});

app.MapGet("/api/users/{id}", async (int id, ILogger<Program> logger, HttpClient httpClient) =>
{
    var stopwatch = Stopwatch.StartNew();
    activeRequestsGauge.Add(1);
    
    using var activity = activitySource.StartActivity("ProcessUserRequest", ActivityKind.Internal);
    activity?.SetTag("user.id", id);
    activity?.SetTag("request.type", "user_lookup");
    
    requestCounter.Add(1, 
        new KeyValuePair<string, object?>("endpoint", "/api/users"),
        new KeyValuePair<string, object?>("user_id", id));
    
    logger.LogInformation("Fetching user with ID: {UserId}", id);
    
    // Create a span for data validation
    using (var validationActivity = activitySource.StartActivity("ValidateUserId"))
    {
        validationActivity?.SetTag("validation.field", "userId");
        await Task.Delay(Random.Shared.Next(5, 15)); // Simulate validation
        
        if (id <= 0 || id > 1000)
        {
            validationActivity?.SetTag("validation.result", "invalid");
            validationActivity?.SetStatus(ActivityStatusCode.Error, "Invalid user ID");
            logger.LogWarning("Invalid user ID: {UserId}", id);
            return Results.BadRequest(new { error = "User ID must be between 1 and 1000" });
        }
        validationActivity?.SetTag("validation.result", "valid");
    }
    
    // Simulate some processing
    using (var processingActivity = activitySource.StartActivity("ProcessBusinessLogic"))
    {
        processingActivity?.SetTag("operation", "user_data_enrichment");
        await Task.Delay(Random.Shared.Next(10, 100));
        processingActivity?.AddEvent(new ActivityEvent("User data processing completed"));
    }
    
    // Simulate external API call
    try
    {
        using var apiCallActivity = activitySource.StartActivity("FetchExternalUserData", ActivityKind.Client);
        apiCallActivity?.SetTag("external.api", "jsonplaceholder.typicode.com");
        apiCallActivity?.SetTag("http.method", "GET");
        
        var response = await httpClient.GetAsync($"https://jsonplaceholder.typicode.com/users/{id}");
        var content = await response.Content.ReadAsStringAsync();
        
        apiCallActivity?.SetTag("http.status_code", (int)response.StatusCode);
        apiCallActivity?.AddEvent(new ActivityEvent("External API call successful"));
        
        logger.LogInformation("Successfully fetched user {UserId}", id);
        
        activity?.SetTag("result", "success");
        activity?.AddEvent(new ActivityEvent("Request completed successfully"));
        
        stopwatch.Stop();
        processingTimeHistogram.Record(stopwatch.ElapsedMilliseconds, 
            new KeyValuePair<string, object?>("endpoint", "/api/users"),
            new KeyValuePair<string, object?>("status", "success"));
        activeRequestsGauge.Add(-1);
        
        return Results.Ok(new { userId = id, external = content, timestamp = DateTime.UtcNow });
    }
    catch (Exception ex)
    {
        activity?.SetStatus(ActivityStatusCode.Error, ex.Message);
        activity?.RecordException(ex);
        logger.LogError(ex, "Error fetching user {UserId}", id);
        
        stopwatch.Stop();
        processingTimeHistogram.Record(stopwatch.ElapsedMilliseconds, 
            new KeyValuePair<string, object?>("endpoint", "/api/users"),
            new KeyValuePair<string, object?>("status", "error"));
        activeRequestsGauge.Add(-1);
        
        return Results.Problem("Failed to fetch user data");
    }
});

app.MapGet("/api/slow", async (ILogger<Program> logger) =>
{
    var stopwatch = Stopwatch.StartNew();
    activeRequestsGauge.Add(1);
    
    using var activity = activitySource.StartActivity("SlowOperation", ActivityKind.Internal);
    activity?.SetTag("operation.type", "slow_processing");
    
    requestCounter.Add(1, new KeyValuePair<string, object?>("endpoint", "/api/slow"));
    logger.LogInformation("Slow endpoint called");
    
    // Simulate multiple processing steps
    using (var step1 = activitySource.StartActivity("ProcessingStep1"))
    {
        step1?.SetTag("step", 1);
        step1?.AddEvent(new ActivityEvent("Starting database query simulation"));
        await Task.Delay(500);
        step1?.AddEvent(new ActivityEvent("Database query completed"));
    }
    
    using (var step2 = activitySource.StartActivity("ProcessingStep2"))
    {
        step2?.SetTag("step", 2);
        step2?.AddEvent(new ActivityEvent("Starting data transformation"));
        await Task.Delay(800);
        step2?.AddEvent(new ActivityEvent("Data transformation completed"));
    }
    
    using (var step3 = activitySource.StartActivity("ProcessingStep3"))
    {
        step3?.SetTag("step", 3);
        step3?.AddEvent(new ActivityEvent("Starting cache update"));
        await Task.Delay(700);
        step3?.AddEvent(new ActivityEvent("Cache update completed"));
    }
    
    activity?.AddEvent(new ActivityEvent("All processing steps completed"));
    activity?.SetTag("total.steps", 3);
    
    stopwatch.Stop();
    processingTimeHistogram.Record(stopwatch.ElapsedMilliseconds, new KeyValuePair<string, object?>("endpoint", "/api/slow"));
    activeRequestsGauge.Add(-1);
    
    logger.LogInformation("Slow endpoint completed");
    return Results.Ok(new { message = "Slow operation completed", durationMs = activity?.Duration.TotalMilliseconds });
});

app.MapGet("/api/error", (ILogger<Program> logger) =>
{
    logger.LogError("Error endpoint called - throwing exception");
    throw new InvalidOperationException("This is a test error for OpenTelemetry tracing");
});

app.MapGet("/health", () => Results.Ok(new { status = "healthy", timestamp = DateTime.UtcNow }));

app.Run();

// Make Program class accessible for testing
public partial class Program { }
