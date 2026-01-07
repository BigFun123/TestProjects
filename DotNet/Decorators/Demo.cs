using System;

namespace DecoratorsDemo
{
    public class Demo
    {
        public static void Run()
        {
            // CustomAuth attribute demo
            Console.WriteLine("--- CustomAuth Attribute Demo ---");
            var api = new ApiController();
            AuthProcessor.ProcessRequest(api, "GetData", "User"); // Allowed
            AuthProcessor.ProcessRequest(api, "GetData", "Guest"); // Denied
        }
    }
}
