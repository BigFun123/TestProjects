using Microsoft.AspNetCore.Mvc;
using System.Diagnostics;

namespace otelapi.Controllers;

[ApiController]
[Route("test2")]
public class TracingTest2Controller : ControllerBase, ITest2Service
{
    private readonly Test2Controller _test2Controller;
    private static readonly ActivitySource ActivitySource = new ActivitySource("TracingTest2Controller");

    public TracingTest2Controller(Test2Controller test2Controller)
    {
        _test2Controller = test2Controller;
    }

    [HttpGet]
    public string Get()
    {
        using var activity = ActivitySource.StartActivity("TracingTest2");
        activity?.SetTag("operation", "test2");
        
        Console.WriteLine("Starting tracing activity for test2");
        var result = _test2Controller.Get();
        
        activity?.SetTag("inner.result", result);
        
        return "tracing test2 successful";
    }
}
