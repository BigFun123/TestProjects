using System;
using System.Diagnostics;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;

namespace TimingSensitiveDemo
{
    class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("===========================================================\n");
            Console.WriteLine("=== Timing-Based Password Comparison Vulnerability Demo ===\n");

            string correctPassword = "MySecurePassword123!";

            Console.WriteLine($"Correct Password: {correctPassword}\n");
            
            // Test passwords with varying degrees of correctness
            string[] testPasswords = new string[]
            {
                "IgnoreMeJustSettling",               // Completely wrong
                "WrongPassword123",               // Completely wrong
                "X",                          // First char wrong
                "XX",                          // First char wrong
                "XXX",                          // First char wrong
                "XXXX",                          // First char wrong
                "XXXXX",                          // First char wrong
                "XXXXXX",                          // First char wrong
                "XXXXXXXXXXXXXXXXXXXX",       // Correct length
                "XXXXXXXXXXXXXXXXXXXXX",       // Incorrect length
                "XXXXXXXXXXXXXXXXXXXXXXXXXXX",       // Completely incorrect
                "M",                          // First char correct
                "MyS",                        // First 3 chars correct
                "MySecure",                   // First 8 chars correct
                "MySecurePassword",           // First 16 chars correct
                "MaSecurePassworn132!",       // somewhat incorrect
                "MySecurePassworz132!",       // somewhat incorrect
                "MySecurePassword132!",       // somewhat incorrect
                "MySecurePassword123!",       // Completely correct
                "WrongPassword"               // Completely wrong
            };

            Console.WriteLine("--- INSECURE: Character-by-character comparison ---");
            Console.WriteLine("(Notice timing differences based on how many characters match)\n");
            
            foreach (var password in testPasswords)
            {
                long elapsedTicks = MeasureInsecureComparison(correctPassword, password);
                Console.WriteLine($"Password: {password,-35} Time: {elapsedTicks,8} ticks");
            }
            Console.WriteLine("\n");
            
            Console.WriteLine("Built In methods:\n");
            foreach (var password in testPasswords)
            {
                long elapsedTicks = MeasureInsecureComparison2(correctPassword, password);
                Console.WriteLine($"Password: {password,-35} Time: {elapsedTicks,8} ticks");
            }

            Console.WriteLine("\n--- SECURE: Constant-time comparison ---");
            Console.WriteLine("(Notice consistent timing regardless of match quality)\n");

            foreach (var password in testPasswords)
            {
                long elapsedTicks = MeasureSecureComparison(correctPassword, password);
                Console.WriteLine($"Password: {password,-35} Time: {elapsedTicks,8} ticks");
            }

            Console.WriteLine("\n--- SECURE: Delay-time comparison ---");
            foreach (var password in testPasswords)
            {
                long elapsedTicks = MeasureSecureComparisonDelay(correctPassword, password).GetAwaiter().GetResult();
                Console.WriteLine($"Password: {password,-35} Time: {elapsedTicks,8} ticks");
            }

            Console.WriteLine("\n=== Explanation ===");
            Console.WriteLine("The insecure method exits early when it finds a mismatch,");
            Console.WriteLine("allowing attackers to use timing attacks to deduce the password");
            Console.WriteLine("character by character.");
            Console.WriteLine("\nThe secure method always compares all bytes, making timing");
            Console.WriteLine("attacks infeasible.");

            Console.WriteLine("\nPress any key to exit...");
            Console.ReadKey();
        }

       
        

        /// <summary>
        /// Measures the execution time of insecure password comparison.
        /// </summary>
        static long MeasureInsecureComparison(string correct, string test)
        {
            Stopwatch sw = Stopwatch.StartNew();
            
            // Run multiple iterations to get measurable timing
            for (int i = 0; i < 10000; i++)
            {
                PasswordComparer.InsecurePasswordCompare(correct, test);
            }
            
            sw.Stop();
            return sw.ElapsedTicks;
        }

         static long MeasureInsecureComparison2(string correct, string test)
        {
            Stopwatch sw = Stopwatch.StartNew();
            
            // Run multiple iterations to get measurable timing
            for (int i = 0; i < 10000; i++)
            {
                PasswordComparer.InsecurePasswordCompare(correct, test);
            }
            
            sw.Stop();
            return sw.ElapsedTicks;
        }

        /// <summary>
        /// Measures the execution time of secure password comparison.
        /// </summary>
        static long MeasureSecureComparison(string correct, string test)
        {
            Stopwatch sw = Stopwatch.StartNew();
            
            // Run multiple iterations to get measurable timing
            for (int i = 0; i < 10000; i++)
            {
                PasswordComparer.SecurePasswordCompare(correct, test);
            }
            
            sw.Stop();
            return sw.ElapsedTicks;
        }

        /// <summary>
        /// Measures the execution time of secure password comparison with delay.
        /// </summary>
        static async Task<long> MeasureSecureComparisonDelay(string correct, string test)
        {
            Stopwatch sw = Stopwatch.StartNew();
            
            // Run multiple iterations to get measurable timing
            for (int i = 0; i < 10000; i++)
            {
                PasswordComparer.SecurePasswordCompare(correct, test);
                await PasswordComparer.DelayMicroseconds(10); // Add fixed delay to mitigate timing attacks
            }
            
            sw.Stop();
            return sw.ElapsedTicks;
        }
    }
}
