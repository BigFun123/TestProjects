using System;

namespace DecoratorsDemo
{
    [CustomAuth("Admin")]
    public class ApiController
    {
        [CustomAuth("User")]
        public void GetData(string user)
        {
            Console.WriteLine($"Data returned for user: {user}");
        }
    }
}
