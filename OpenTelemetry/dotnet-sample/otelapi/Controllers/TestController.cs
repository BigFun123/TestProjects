using Microsoft.AspNetCore.Mvc;

namespace otelapi.Controllers;

[ApiController]
[Route("[controller]")]
public class TestController : ControllerBase, ITestService
{
    [HttpGet]
    public string Get()
    {
        return "hello world";
    }
}
