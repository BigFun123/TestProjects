using System;
using System.Threading;

namespace HelloCompose
{
    class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("Hello from Docker Compose!");
            Console.WriteLine($"Starting at: {DateTime.Now}");
            Console.WriteLine("Application is running...");
            Console.WriteLine("Press Ctrl+C to exit");
            
            int counter = 0;
            while (true)
            {
                counter++;
                Console.WriteLine($"[{DateTime.Now:HH:mm:ss}] Heartbeat #{counter}");
                Thread.Sleep(5000); // Wait 5 seconds
            }
        }
    }
}
