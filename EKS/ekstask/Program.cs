using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Configuration;
using ekstask;

var builder = Host.CreateApplicationBuilder(args);

// Add configuration
builder.Configuration.AddJsonFile("appsettings.json", optional: false, reloadOnChange: true);

// Configure settings
builder.Services.Configure<ScheduledTaskConfiguration>(
    builder.Configuration.GetSection("ScheduledTask"));

// Add HttpClient with default configuration
builder.Services.AddHttpClient("ScheduledTaskClient", client =>
{
    client.Timeout = TimeSpan.FromSeconds(30);
});

// Add the background service
builder.Services.AddHostedService<ScheduledTaskService>();

var host = builder.Build();
await host.RunAsync();
