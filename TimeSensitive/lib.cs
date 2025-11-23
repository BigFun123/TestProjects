using System;
using System.Diagnostics;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;

namespace TimingSensitiveDemo
{

    public class PasswordComparer
    {

        static Random random = new Random(1234);


        /// <summary>
        /// INSECURE: Compares passwords character-by-character and returns early on mismatch.
        /// This creates a timing vulnerability.
        /// </summary>
        public static bool InsecurePasswordCompare(string password1, string password2)
        {
            // VULNERABILITY: Early exit reveals information through timing
            if (password1.Length != password2.Length)
            {
                return false;
            }

            // simulate some processing delay
            for (int i = 0; i < 1000; i++)
            {
                // no-op
                int p = i * i;
            }

            for (int i = 0; i < password1.Length; i++)
            {
                if (password1[i] != password2[i])
                    return false; // Early exit = timing leak!
            }

            // simulate some processing delay
            for (int i = 0; i < 1000; i++)
            {
                // no-op
                int p = i * i;
            }

            return true;
        }

        public static bool InsecurePasswordCompare2(string password1, string password2)
        {
            // VULNERABILITY: Early exit reveals information through timing
            if (password1.Length != password2.Length)
            {
                return false;
            }

            if (String.Compare(password1, password2) != 0)
            {
                return false; // Early exit = timing leak!
            }

            return true;
        }

        /// <summary>
        /// Alternative secure implementation if CryptographicOperations is not available.
        /// </summary>
        public static bool SecurePasswordCompareManual(string password1, string password2)
        {
            byte[] bytes1 = Encoding.UTF8.GetBytes(password1);
            byte[] bytes2 = Encoding.UTF8.GetBytes(password2);

            // Constant-time comparison using bitwise operations
            int diff = bytes1.Length ^ bytes2.Length;
            int length = Math.Max(bytes1.Length, bytes2.Length);            

            for (int i = 0; i < length; i++)
            {
                int b2 = i < bytes2.Length ? bytes2[i] : 0;
                int b1 = i < bytes1.Length ? bytes1[i] : 0;                
                diff |= b1 ^ b2;
            }

            return diff == 0;
        }

        /// <summary>
        /// SECURE: Uses constant-time comparison to prevent timing attacks.
        /// </summary>
        public static bool SecurePasswordCompare(string password1, string password2)
        {
            byte[] bytes1 = Encoding.UTF8.GetBytes(password1);
            byte[] bytes2 = Encoding.UTF8.GetBytes(password2);

            // Use CryptographicOperations.FixedTimeEquals for constant-time comparison
            // Available in .NET Core 2.1+ and .NET Standard 2.1+
            return CryptographicOperations.FixedTimeEquals(bytes1, bytes2);
        }

        /// <summary>
        /// Introduces a precise delay in microseconds to mitigate timing attacks.
        /// Adds a small amount of random jitter to prevent optimization.
        /// </summary>
        public static async Task DelayMicroseconds(double microseconds)
        {

            microseconds += random.NextDouble() * 40; // Add small random jitter to prevent optimization            
            Stopwatch stopwatch = Stopwatch.StartNew();
            double targetTicks = microseconds * TimeSpan.TicksPerMillisecond / 1000.0;

            while (stopwatch.ElapsedTicks < targetTicks)
            {
                // Busy wait for precise timing
                await Task.Yield(); // Allow other tasks to run
            }
        }

    }
}