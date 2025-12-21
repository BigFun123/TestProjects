var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.MapGet("/", () => new
{
    message = "Hello World from AWS!",
    environment = Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT") ?? "Production",
    machineName = Environment.MachineName,
    timestamp = DateTime.UtcNow
})
.WithName("HelloWorld")
.WithOpenApi();

app.MapGet("/health", () => Results.Ok(new { status = "healthy" }))
.WithName("HealthCheck")
.WithOpenApi();

app.Run();
