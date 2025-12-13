using Microsoft.AspNetCore.Mvc;

namespace ekswebapi.Controllers;

[ApiController]
[Route("api")]
public class HelloController : ControllerBase
{
    private readonly ILogger<HelloController> _logger;

    public HelloController(ILogger<HelloController> logger)
    {
        _logger = logger;
    }

    [HttpGet("hello")]
    public IActionResult GetHello()
    {
        _logger.LogInformation("Hello endpoint called at {time}", DateTime.UtcNow);
        return Ok(new { message = "Hello World!", timestamp = DateTime.UtcNow });
    }
}
