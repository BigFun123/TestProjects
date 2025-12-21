using System;
using System.Net.Http;
using System.Threading.Tasks;

class Program
{
    private static readonly HttpClient client = new HttpClient();
    
    static async Task Main(string[] args)
    {
        Console.WriteLine("===========================================");
        Console.WriteLine("HelloTask - Scheduled ECS Task");
        Console.WriteLine($"Execution Time: {DateTime.UtcNow:yyyy-MM-dd HH:mm:ss} UTC");
        Console.WriteLine("===========================================");
        Console.WriteLine();
        
        // Get configuration from environment variables
        string taskName = Environment.GetEnvironmentVariable("TASK_NAME") ?? "HelloTask";
        string targetUrl = Environment.GetEnvironmentVariable("TARGET_URL") ?? "https://httpbin.org/get";
        
        Console.WriteLine($"Task Name: {taskName}");
        Console.WriteLine($"Target URL: {targetUrl}");
        Console.WriteLine();
        
        try
        {
            // Perform the scheduled work
            await PerformScheduledWork(targetUrl);
            
            Console.WriteLine();
            Console.WriteLine("===========================================");
            Console.WriteLine("Task completed successfully!");
            Console.WriteLine($"Completion Time: {DateTime.UtcNow:yyyy-MM-dd HH:mm:ss} UTC");
            Console.WriteLine("===========================================");
            
            Environment.Exit(0);
        }
        catch (Exception ex)
        {
            Console.WriteLine();
            Console.WriteLine("===========================================");
            Console.WriteLine($"ERROR: Task failed with exception");
            Console.WriteLine($"Message: {ex.Message}");
            Console.WriteLine($"Stack Trace: {ex.StackTrace}");
            Console.WriteLine("===========================================");
            
            Environment.Exit(1);
        }
    }
    
    static async Task PerformScheduledWork(string url)
    {
        Console.WriteLine("Starting scheduled work...");
        Console.WriteLine();
        
        // Example: Make an HTTP request
        Console.WriteLine($"Sending HTTP GET request to: {url}");
        DateTime startTime = DateTime.UtcNow;
        
        HttpResponseMessage response = await client.GetAsync(url);
        
        DateTime endTime = DateTime.UtcNow;
        TimeSpan duration = endTime - startTime;
        
        string content = await response.Content.ReadAsStringAsync();
        
        Console.WriteLine($"Response Status: {(int)response.StatusCode} {response.StatusCode}");
        Console.WriteLine($"Response Time: {duration.TotalMilliseconds:F2}ms");
        Console.WriteLine($"Response Length: {content.Length} bytes");
        
        response.EnsureSuccessStatusCode();
        
        // Additional work can be added here:
        // - Database operations
        // - File processing
        // - Data synchronization
        // - Report generation
        // - Cleanup tasks
        // etc.
        
        Console.WriteLine();
        Console.WriteLine("Scheduled work completed successfully.");
    }
}
