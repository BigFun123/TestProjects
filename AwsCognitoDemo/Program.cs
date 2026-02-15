using Amazon;
using Amazon.CognitoIdentityProvider;
using System;
using System.Threading.Tasks;

namespace AwsCognitoDemo
{
	// This demo shows how to connect to AWS Cognito using the AWS SDK for .NET.
	// Cognito is a fully managed authentication, authorization, and user management service for web and mobile apps.
	// It allows you to create and manage user pools, handle sign-up/sign-in, and integrate with social identity providers.
	internal class Program
	{
		static async Task Main(string[] args)
		{
			Console.WriteLine("AWS Cognito Demo (.NET 8)");
			Console.WriteLine("--------------------------\n");
			Console.WriteLine("Cognito provides user authentication, authorization, and user management for your applications.\n");
			Console.WriteLine("This demo lists all Cognito User Pools in your AWS account.\n");

			var client = new AmazonCognitoIdentityProviderClient(RegionEndpoint.USEast1);
			var service = new CognitoService(client);

			var userPools = await service.ListUserPoolsAsync();
			if (userPools.UserPools.Count == 0)
			{
				Console.WriteLine("No Cognito User Pools found in this region.");
			}
			else
			{
				Console.WriteLine("User Pools:");
				foreach (var pool in userPools.UserPools)
				{
					Console.WriteLine($"- {pool.Name} (ID: {pool.Id})");
				}
			}

			Console.WriteLine("\nYou can use Cognito for:");
			Console.WriteLine("- User sign-up and sign-in");
			Console.WriteLine("- Multi-factor authentication (MFA)");
			Console.WriteLine("- Social login (Google, Facebook, etc.)");
			Console.WriteLine("- User directory management");
			Console.WriteLine("- Secure access for your apps\n");

			// --- Cognito Login Demo ---
			Console.WriteLine("\nCognito Client Credentials Login Demo: Get JWT Token");
			Console.Write("Enter Cognito App Client ID: ");
			var clientId = Console.ReadLine();
			Console.Write("Enter Cognito App Client Secret: ");
			var clientSecret = ReadPassword();
			Console.Write("Enter Cognito User Pool Domain (e.g. myapp.auth.us-east-1.amazoncognito.com): ");
			var userPoolDomain = Console.ReadLine();

			var authService = new CognitoAuthService(client);
			try
			{
				var accessToken = await authService.GetTokenWithClientCredentialsAsync(clientId, clientSecret, userPoolDomain);
				Console.WriteLine("\nLogin successful! JWT Access Token:");
				Console.WriteLine(accessToken);
			}
			catch (Exception ex)
			{
				Console.WriteLine($"Login failed: {ex.Message}");
			}
		}

		// Helper to read password without echoing
		private static string ReadPassword()
		{
			var pwd = string.Empty;
			ConsoleKey key;
			do
			{
				var keyInfo = Console.ReadKey(intercept: true);
				key = keyInfo.Key;
				if (key == ConsoleKey.Backspace && pwd.Length > 0)
				{
					pwd = pwd[..^1];
					Console.Write("\b \b");
				}
				else if (!char.IsControl(keyInfo.KeyChar))
				{
					pwd += keyInfo.KeyChar;
					Console.Write("*");
				}
			} while (key != ConsoleKey.Enter);
			Console.WriteLine();
			return pwd;
		}
	}
}
