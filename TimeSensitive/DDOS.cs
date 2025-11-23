using System;
using System.Diagnostics;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;
using TimingSensitiveDemo;

namespace DDOSDemo
{
    class Program
    {
        static void Main(string[] args)
        {
            CompleteTest();
        }
        static void CompleteTest()
        {
            Console.WriteLine("=== DDOS Timing Attack Simulation ===\n");
            
            var correctPassword = "MyPassword123!";
            string[] passwords = new string[] { "ignoreme", 
            "x", "xx", "xxx", "xxxx", "xxxxx", "xxxxxx", "xxxxxxx", "xxxxxxxx", 
            "xxxxxxxxx", "xxxxxxxxxx", "xxxxxxxxxxx", "xxxxxxxxxxxx", "xxxxxxxxxxxxxx","xxxxxxxxxxxxxxx" };
            long longest = 0;
            var longestPwd = "";
            var index = 0;
            
            foreach (var pwd in passwords)
            {
                index = index + 1;
                long elapsedTicks = MeasureInsecureComparison(correctPassword, pwd, 100);
                if (elapsedTicks > longest)
                {
                    longest = elapsedTicks;
                    longestPwd = pwd;
                }
                Console.WriteLine($"Password: {pwd,-35} Time: {elapsedTicks,8} ticks");
            }
            Console.WriteLine($"\nLongest Password: {longestPwd} Time: {longest,8} ticks, Index: {index}");


            Hackit("test!", 5);
        }

        static long MeasureInsecureComparison(string correct, string test, int num = 10000)
        {
            Stopwatch sw = Stopwatch.StartNew();
            
            for (int i = 0; i < num; i++)
            {
                PasswordComparer.InsecurePasswordCompare(correct, test);
            }
            
            sw.Stop();
            return sw.ElapsedTicks;
        }

        static void Hackit(string correctPassword, int length = 8) {
            // Brute force attack - try every possible combination
            Console.WriteLine($"\n=== Brute Force Attack to Guess Password ===\n{length} characters long\n");
            var chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()";            
            var guess = new char[length];
            var totalAttempts = 0;
            
            // Initialize all positions to first character
            for (int i = 0; i < length; i++) {
                guess[i] = chars[0];
            }
            
            bool found = false;
            var sw = Stopwatch.StartNew();
            
            // Brute force loop - increment through all combinations
            while (!found) {
                totalAttempts++;
                string testPassword = new string(guess);
                
                // Check if this password matches
                if (testPassword == correctPassword) {
                    found = true;
                    sw.Stop();
                    Console.WriteLine($"\n=== PASSWORD FOUND! ===");
                    Console.WriteLine($"Password: {testPassword}");
                    Console.WriteLine($"Total Attempts: {totalAttempts:N0}");
                    Console.WriteLine($"Time Elapsed: {sw.Elapsed}");
                    break;
                }
                
                // Show progress every 1 million attempts
                if (totalAttempts % 1000000 == 0) {
                    Console.WriteLine($"Attempts: {totalAttempts:N0} - Current: {testPassword}");
                }
                
                // Increment to next combination (like odometer)
                int position = length - 1;
                while (position >= 0) {
                    int currentCharIndex = chars.IndexOf(guess[position]);
                    
                    if (currentCharIndex < chars.Length - 1) {
                        // Increment this position
                        guess[position] = chars[currentCharIndex + 1];
                        break;
                    } else {
                        // Roll over to first char and carry to next position
                        guess[position] = chars[0];
                        position--;
                    }
                }
                
                // If we've rolled over all positions, we've tried everything
                if (position < 0) {
                    Console.WriteLine($"\n=== PASSWORD NOT FOUND ===");
                    Console.WriteLine($"Total Attempts: {totalAttempts:N0}");
                    Console.WriteLine($"All combinations exhausted.");
                    break;
                }
            }
        }
    }
}