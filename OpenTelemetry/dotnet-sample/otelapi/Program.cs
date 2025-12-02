using otelapi.Controllers;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddControllers();

// Conditionally register tracing for TestController
var enableTracingTest = builder.Configuration.GetValue<bool>("Features:EnableTracingTest", false);
if (enableTracingTest)
{
    builder.Services.AddScoped<TestController>();
    builder.Services.AddScoped<ITestService, TracingTestController>();
}
else
{
    builder.Services.AddScoped<ITestService, TestController>();
}

// Conditionally register tracing for Test2Controller
var enableTracingTest2 = builder.Configuration.GetValue<bool>("Features:EnableTracingTest2", false);
if (enableTracingTest2)
{
    builder.Services.AddScoped<Test2Controller>();
    builder.Services.AddScoped<ITest2Service, TracingTest2Controller>();
}
else
{
    builder.Services.AddScoped<ITest2Service, Test2Controller>();
}

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.MapControllers();

app.Run();

