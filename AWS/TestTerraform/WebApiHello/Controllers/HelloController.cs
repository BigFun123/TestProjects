using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;

namespace WebApiHello.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class HelloController : ControllerBase
    {
        private readonly IConfiguration _configuration;

        public HelloController(IConfiguration configuration)
        {
            _configuration = configuration;
        }

        [HttpGet]
        public IActionResult Get()
        {
            var name = _configuration["GreetingName"] ?? "World";
            var another = _configuration["AnotherOne"] ?? "here";
            return Ok($"Hello {name} {another}!");
        }
    }
}
