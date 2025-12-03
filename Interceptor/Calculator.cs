namespace Interceptor;

public class Calculator : ICalculator
{
    public int Add(int a, int b)
    {
        return a + b;
    }

    public int Subtract(int a, int b)
    {
        return a - b;
    }

    public int Multiply(int a, int b)
    {
        return a * b;
    }

    public double Divide(int a, int b)
    {
        if (b == 0)
            throw new DivideByZeroException("Cannot divide by zero!");
        return (double)a / b;
    }

    public string SlowOperation()
    {
        // Simulate a slow operation
        Thread.Sleep(2000);
        return "Operation completed after 2 seconds";
    }
}
