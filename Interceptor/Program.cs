using Castle.DynamicProxy;
using Interceptor;
using Interceptor.Interceptors;

var builder = WebApplication.CreateBuilder(args);

// Add controllers
builder.Services.AddControllers();

// Register Calculator with interceptors
var proxyGenerator = new ProxyGenerator();

// Read interceptor settings from configuration
var enablePerformanceInterceptor = builder.Configuration.GetValue<bool>("Interceptors:EnablePerformanceInterceptor", true);
var enableLoggingInterceptor = builder.Configuration.GetValue<bool>("Interceptors:EnableLoggingInterceptor", true);

// Build interceptor list based on configuration
var interceptors = new List<IInterceptor>();
if (enableLoggingInterceptor)
{
    interceptors.Add(new LoggingInterceptor());
    Console.WriteLine("✓ LoggingInterceptor enabled");
}
if (enablePerformanceInterceptor)
{
    interceptors.Add(new PerformanceInterceptor());
    Console.WriteLine("✓ PerformanceInterceptor enabled");
}

// Create calculator with configured interceptors
var calculator = proxyGenerator.CreateInterfaceProxyWithTarget<ICalculator>(
    new Calculator(),
    interceptors.ToArray()
);
builder.Services.AddSingleton<ICalculator>(calculator);

var app = builder.Build();

app.MapControllers();

app.Run();


