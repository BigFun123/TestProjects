
using System;
using Serilog;
using Serilog.Sinks.Graylog;
using Serilog.Sinks.Graylog.Core.Transport;

class Program
{
    static void Main(string[] args)
    {
        Log.Logger = new LoggerConfiguration()
            .WriteTo.Graylog(new GraylogSinkOptions
            {
                HostnameOrAddress = "127.0.0.1",
                Port = 12201,
                Facility = "dotnet8-serilog",
                TransportType = TransportType.Udp
            })
            .CreateLogger();

        // Use a minimal message and add a custom property to ensure GELF compliance
        Log.Information("hello from dotnet 8 serilog {host}", Environment.MachineName);
        Log.CloseAndFlush();
        Console.WriteLine("Message sent to Graylog via Serilog.");
    }
}
