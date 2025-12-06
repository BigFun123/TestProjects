using Microsoft.Data.SqlClient;
using System.Text.Json;

var builder = WebApplication.CreateBuilder(args);

// Add CORS
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFrontend",
        policy =>
        {
            policy.WithOrigins("http://localhost:5173", "http://localhost:3000")
                  .AllowAnyHeader()
                  .AllowAnyMethod();
        });
});

var app = builder.Build();

app.UseCors("AllowFrontend");

app.MapGet("/api/chartdata", async (string? connectionString, string period = "daily") =>
{
    // Use provided connection string or default
    var connStr = connectionString ?? builder.Configuration.GetConnectionString("DefaultConnection")
        ?? "Server=DESKTOP-8BH3O0K\\LOCALDB#034CB5D0;Database=scratch;Trusted_Connection=True;";

    var data = new List<ChartDataPoint>();

    try
    {
        using var connection = new SqlConnection(connStr);
        await connection.OpenAsync();

        // Call the stored procedure
        using var command = new SqlCommand("dbo.GetDailyTotals", connection);
        command.CommandType = System.Data.CommandType.StoredProcedure;
        
        // Add parameters
        command.Parameters.AddWithValue("@Period", period == "alltime" ? "daily" : period);
        command.Parameters.AddWithValue("@ModelId", Guid.Parse("3923C450-098A-447A-A060-E176D926BFDE"));
        command.Parameters.AddWithValue("@StartDate", new DateTime(2023, 1, 1));
        command.Parameters.AddWithValue("@EndDate", new DateTime(2025, 12, 31));

        using var reader = await command.ExecuteReaderAsync();

        while (await reader.ReadAsync())
        {
            data.Add(new ChartDataPoint
            {
                Date = reader.GetDateTime(0),
                Value = reader.GetDecimal(1)
            });
        }
    }
    catch (Exception ex)
    {
        // Return sample data if database connection fails
        Console.WriteLine($"Database error: {ex.Message}");
        //data = GetSampleData();
    }

    return Results.Ok(data);
});

app.MapGet("/api/sampledata", () =>
{
    return Results.Ok(GetSampleData());
});

app.MapGet("/", () => "TestRechart Backend API is running. Try /api/chartdata or /api/sampledata");

app.Run();

List<ChartDataPoint> GetSampleData()
{
    return new List<ChartDataPoint>
    {
      new ChartDataPoint { Date = new DateTime(2023, 1, 1), Value = 10 },
      new ChartDataPoint { Date = new DateTime(2023, 1, 2), Value = 15 },
      new ChartDataPoint { Date = new DateTime(2023, 1, 3), Value = 8 },
      new ChartDataPoint { Date = new DateTime(2023, 1, 4), Value = 20 },
      new ChartDataPoint { Date = new DateTime(2023, 1, 5), Value = 12 },   
    };
}

record ChartDataPoint
{
    public DateTime Date { get; set; } = DateTime.Now;
    public decimal Value { get; set; }
}
