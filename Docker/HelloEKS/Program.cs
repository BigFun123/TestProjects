using System;
using System.Net.Http;
using System.Threading;
using System.Threading.Tasks;

class Program
{
    private static readonly HttpClient client = new HttpClient();
    
    static async Task Main(string[] args)
    {
        Console.WriteLine("Hello World from EKS!");
        Console.WriteLine("Starting HTTP request timer...");
        
        // Get the URL and interval from environment variables or use defaults
        string targetUrl = Environment.GetEnvironmentVariable("TARGET_URL") ?? "https://httpbin.org/get";
        int intervalSeconds = int.TryParse(Environment.GetEnvironmentVariable("INTERVAL_SECONDS"), out int val) ? val : 30;
        
        Console.WriteLine($"Target URL: {targetUrl}");
        Console.WriteLine($"Interval: {intervalSeconds} seconds");
        Console.WriteLine();
        
        using var cts = new CancellationTokenSource();
        
        // Handle graceful shutdown
        Console.CancelKeyPress += (sender, eventArgs) =>
        {
            Console.WriteLine("\nShutting down gracefully...");
            cts.Cancel();
            eventArgs.Cancel = true;
        };
        
        await RunHttpRequestLoop(targetUrl, intervalSeconds, cts.Token);
    }
    
    static async Task RunHttpRequestLoop(string url, int intervalSeconds, CancellationToken cancellationToken)
    {
        int requestCount = 0;
        
        while (!cancellationToken.IsCancellationRequested)
        {
            try
            {
                requestCount++;
                DateTime startTime = DateTime.UtcNow;
                
                Console.WriteLine($"[{DateTime.UtcNow:yyyy-MM-dd HH:mm:ss}] Request #{requestCount}");
                
                HttpResponseMessage response = await client.GetAsync(url, cancellationToken);
                
                DateTime endTime = DateTime.UtcNow;
                TimeSpan duration = endTime - startTime;
                
                string content = await response.Content.ReadAsStringAsync(cancellationToken);
                
                Console.WriteLine($"  Status: {(int)response.StatusCode} {response.StatusCode}");
                Console.WriteLine($"  Duration: {duration.TotalMilliseconds:F2}ms");
                Console.WriteLine($"  Content Length: {content.Length} bytes");
                Console.WriteLine();
                
                // Wait for the specified interval
                await Task.Delay(TimeSpan.FromSeconds(intervalSeconds), cancellationToken);
            }
            catch (OperationCanceledException)
            {
                Console.WriteLine("Operation cancelled.");
                break;
            }
            catch (HttpRequestException ex)
            {
                Console.WriteLine($"  HTTP Error: {ex.Message}");
                Console.WriteLine();
                
                // Wait before retrying
                try
                {
                    await Task.Delay(TimeSpan.FromSeconds(intervalSeconds), cancellationToken);
                }
                catch (OperationCanceledException)
                {
                    break;
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"  Unexpected Error: {ex.Message}");
                Console.WriteLine();
                
                // Wait before retrying
                try
                {
                    await Task.Delay(TimeSpan.FromSeconds(intervalSeconds), cancellationToken);
                }
                catch (OperationCanceledException)
                {
                    break;
                }
            }
        }
        
        Console.WriteLine("HTTP request loop stopped.");
    }
}
