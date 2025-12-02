using Microsoft.AspNetCore.Mvc;
using System.Diagnostics;

namespace otelapi.Controllers;

[ApiController]
[Route("test")]
public class TracingTestController : ControllerBase, ITestService
{
    private readonly TestController _testController;
    private static readonly ActivitySource ActivitySource = new ActivitySource("TracingTestController");

    public TracingTestController(TestController testController)
    {
        _testController = testController;
    }

    [HttpGet]
    public string Get()
    {
        using var activity = ActivitySource.StartActivity("TracingTest");
        activity?.SetTag("operation", "test");
        
        Console.WriteLine("Starting tracing activity");
        var result = _testController.Get();
        
        activity?.SetTag("inner.result", result);
        
        return "tracing test successful";
    }
}