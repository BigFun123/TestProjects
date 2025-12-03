using Castle.DynamicProxy;
using System.Diagnostics;

namespace Interceptor.Interceptors;

public class PerformanceInterceptor : IInterceptor
{
    public void Intercept(IInvocation invocation)
    {
        var methodName = invocation.Method.Name;
        var stopwatch = Stopwatch.StartNew();
        
        try
        {
            // Call the actual method
            invocation.Proceed();
        }
        finally
        {
            stopwatch.Stop();
            var color = stopwatch.ElapsedMilliseconds > 1000 ? ConsoleColor.Red : ConsoleColor.Green;
            Console.ForegroundColor = color;
            Console.WriteLine($"[PERF] Method {methodName} executed in {stopwatch.ElapsedMilliseconds}ms");
            Console.ResetColor();
        }
    }
}
