using Microsoft.AspNetCore.Mvc;

namespace Interceptor.Controllers;

[ApiController]
[Route("api/[controller]")]
public class CalculatorController : ControllerBase
{
    private readonly ICalculator _calculator;

    public CalculatorController(ICalculator calculator)
    {
        _calculator = calculator;
    }

    [HttpGet]
    public IActionResult GetInfo()
    {
        return Ok(new
        {
            title = "Castle Interceptor Demo",
            endpoints = new[]
            {
                "GET /api/calculator/add/{a}/{b} - Add two numbers",
                "GET /api/calculator/subtract/{a}/{b} - Subtract two numbers",
                "GET /api/calculator/multiply/{a}/{b} - Multiply two numbers",
                "GET /api/calculator/divide/{a}/{b} - Divide two numbers",
                "GET /api/calculator/slow-operation - Demonstrates performance monitoring"
            }
        });
    }

    [HttpGet("add/{a}/{b}")]
    public IActionResult Add(int a, int b)
    {
        var result = _calculator.Add(a, b);
        return Ok(new { operation = "add", a, b, result });
    }

    [HttpGet("subtract/{a}/{b}")]
    public IActionResult Subtract(int a, int b)
    {
        var result = _calculator.Subtract(a, b);
        return Ok(new { operation = "subtract", a, b, result });
    }

    [HttpGet("multiply/{a}/{b}")]
    public IActionResult Multiply(int a, int b)
    {
        var result = _calculator.Multiply(a, b);
        return Ok(new { operation = "multiply", a, b, result });
    }

    [HttpGet("divide/{a}/{b}")]
    public IActionResult Divide(int a, int b)
    {
        try
        {
            var result = _calculator.Divide(a, b);
            return Ok(new { operation = "divide", a, b, result });
        }
        catch (DivideByZeroException ex)
        {
            return BadRequest(new { error = ex.Message });
        }
    }

    [HttpGet("slow-operation")]
    public IActionResult SlowOperation()
    {
        var result = _calculator.SlowOperation();
        return Ok(new { operation = "slow-operation", result });
    }
}
