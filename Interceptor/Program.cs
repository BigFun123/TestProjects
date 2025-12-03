using Castle.DynamicProxy;
using Interceptor;
using Interceptor.Interceptors;

var builder = WebApplication.CreateBuilder(args);

// Add controllers
builder.Services.AddControllers();

// Register Calculator with interceptors
var proxyGenerator = new ProxyGenerator();
var calculator = proxyGenerator.CreateInterfaceProxyWithTarget<ICalculator>(
    new Calculator(),
    new LoggingInterceptor(),
    new PerformanceInterceptor()
);
builder.Services.AddSingleton<ICalculator>(calculator);

var app = builder.Build();

app.MapControllers();

app.Run();


