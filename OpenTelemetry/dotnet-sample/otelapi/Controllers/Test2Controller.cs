using Microsoft.AspNetCore.Mvc;

namespace otelapi.Controllers;

[ApiController]
[Route("[controller]")]
public class Test2Controller : ControllerBase, ITest2Service
{
    [HttpGet]
    public string Get()
    {
        return "hello from test2";
    }
}
