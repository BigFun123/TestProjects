using Castle.DynamicProxy;

namespace Interceptor.Interceptors;

public class LoggingInterceptor : IInterceptor
{
    public void Intercept(IInvocation invocation)
    {
        var methodName = invocation.Method.Name;
        var parameters = string.Join(", ", invocation.Arguments.Select(a => a?.ToString() ?? "null"));
        
        Console.WriteLine($"[LOG] Calling method: {methodName}({parameters})");
        
        try
        {
            // Call the actual method
            invocation.Proceed();
            
            Console.WriteLine($"[LOG] Method {methodName} returned: {invocation.ReturnValue}");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[LOG] Method {methodName} threw exception: {ex.Message}");
            throw;
        }
    }
}
