using Prometheus;

var builder = WebApplication.CreateBuilder(args);

// Configure Kestrel to listen on port 5000
builder.WebHost.ConfigureKestrel(options =>
{
    options.ListenAnyIP(5000);
});

var app = builder.Build();

// Enable Prometheus metrics middleware
app.UseRouting();
app.UseHttpMetrics(); // Automatically tracks HTTP metrics

// Map Prometheus metrics endpoint
app.MapMetrics();

// Custom metrics
var orderCounter = Metrics.CreateCounter("orders_processed_total", "Total number of orders processed");
var orderValue = Metrics.CreateHistogram("order_value_dollars", "Order value in dollars",
    new HistogramConfiguration
    {
        Buckets = Histogram.LinearBuckets(start: 10, width: 10, count: 10)
    });
var activeOrders = Metrics.CreateGauge("active_orders", "Number of currently active orders");

// Simple home endpoint
app.MapGet("/", () => 
{
    return Results.Ok(new 
    { 
        message = "Prometheus Sample App", 
        endpoints = new[] 
        { 
            "/", 
            "/weather",
            "/order",
            "/metrics" 
        } 
    });
});

// Weather endpoint
app.MapGet("/weather", () =>
{
    var forecasts = Enumerable.Range(1, 5).Select(index =>
        new WeatherForecast
        (
            DateOnly.FromDateTime(DateTime.Now.AddDays(index)),
            Random.Shared.Next(-20, 55),
            new[] { "Freezing", "Bracing", "Chilly", "Cool", "Mild", "Warm", "Balmy", "Hot", "Sweltering", "Scorching" }[Random.Shared.Next(10)]
        ))
        .ToArray();
    return forecasts;
});

// Order endpoint to demonstrate custom metrics
app.MapPost("/order", () =>
{
    // Simulate order processing
    var value = Random.Shared.Next(10, 100);
    
    orderCounter.Inc();
    orderValue.Observe(value);
    activeOrders.Inc();
    
    // Simulate processing time
    Thread.Sleep(Random.Shared.Next(10, 100));
    
    activeOrders.Dec();
    
    return Results.Ok(new { orderId = Guid.NewGuid(), value, status = "processed" });
});

Console.WriteLine("Starting Prometheus Sample App on http://localhost:5000");
Console.WriteLine("Metrics available at http://localhost:5000/metrics");

app.Run();

record WeatherForecast(DateOnly Date, int TemperatureC, string? Summary)
{
    public int TemperatureF => 32 + (int)(TemperatureC / 0.5556);
}
