using System;
using System.Net.Http;
using System.Threading.Tasks;

class Program
{
	static async Task Main(string[] args)
	{
		Console.WriteLine("Hello from AWS Cron!");
		using var client = new HttpClient();
		try
		{
			var request = new HttpRequestMessage(HttpMethod.Get, "https://usermetrics.net");
			// Replace YOUR_TOKEN_HERE with your actual Bearer token
			request.Headers.Authorization = new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", "YOUR_TOKEN_HERE");
			var response = await client.SendAsync(request);
			var content = await response.Content.ReadAsStringAsync();
			Console.WriteLine($"Response: {content.Substring(0, Math.Min(100, content.Length))}...");
		}
		catch (Exception ex)
		{
			Console.WriteLine($"Error: {ex.Message}");
		}
	}
}
