# Castle DynamicProxy Interceptor Demo

This demo shows how **Castle DynamicProxy** interceptors work in .NET.

## What Are Interceptors?

Interceptors allow you to **intercept method calls** and add cross-cutting concerns like:
- Logging
- Performance monitoring
- Caching
- Authorization
- Exception handling

## How It Works

1. **Define an interface** (`ICalculator`) with methods to intercept
2. **Create an implementation** (`Calculator`) with business logic
3. **Create interceptors** that implement `IInterceptor`:
   - `LoggingInterceptor` - logs method calls and results
   - `PerformanceInterceptor` - measures execution time
4. **Use ProxyGenerator** to create a proxy that wraps the original object
5. All method calls go through the interceptors first!

## Running the Demo

```bash
dotnet restore
dotnet run
```

Visit http://localhost:5000 to see available endpoints.

## Test the Endpoints

```bash
# Add two numbers
curl http://localhost:5000/add/10/5

# Subtract
curl http://localhost:5000/subtract/10/5

# Multiply
curl http://localhost:5000/multiply/10/5

# Divide
curl http://localhost:5000/divide/10/5

# Test slow operation (shows performance monitoring)
curl http://localhost:5000/slow-operation

# Test error handling
curl http://localhost:5000/divide/10/0
```

## Console Output Example

When you call `/add/10/5`, you'll see in the console:

```
[LOG] Calling method: Add(10, 5)
[LOG] Method Add returned: 15
[PERF] Method Add executed in 0ms
```

When you call `/slow-operation`:

```
[LOG] Calling method: SlowOperation()
[LOG] Method SlowOperation returned: Operation completed after 2 seconds
[PERF] Method SlowOperation executed in 2001ms
```

## Key Concepts

### Multiple Interceptors
Multiple interceptors are chained together. They execute in order:
```csharp
proxyGenerator.CreateInterfaceProxyWithTarget<ICalculator>(
    new Calculator(),
    new LoggingInterceptor(),      // Runs first
    new PerformanceInterceptor()   // Runs second
);
```

### IInvocation Object
The `IInvocation` object provides:
- `Method` - method being called
- `Arguments` - method parameters
- `ReturnValue` - method result (after `Proceed()`)
- `Proceed()` - calls the next interceptor or actual method

### Use Cases
- **Logging**: Track all method calls automatically
- **Performance**: Monitor slow operations
- **Caching**: Cache results based on parameters
- **Security**: Check authorization before method execution
- **Retry Logic**: Automatically retry failed operations
- **Transaction Management**: Wrap methods in transactions
