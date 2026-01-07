using System;
using System.Net.Http;
using System.Threading.Tasks;
using Microsoft.Extensions.Configuration;

class Program
{
	static async Task Main(string[] args)
	{
		// Build configuration
		var config = new ConfigurationBuilder()
			.SetBasePath(AppContext.BaseDirectory)
			.AddJsonFile("appsettings.json", optional: false, reloadOnChange: true)
			.Build();

		string url = config["Settings:Url"];
		if (string.IsNullOrWhiteSpace(url))
		{
			Console.WriteLine("URL not found in settings.");
			return;
		}

		using var httpClient = new HttpClient();
		try
		{
			Console.WriteLine($"Sending GET request to: {url}");
			var response = await httpClient.GetAsync(url);
			response.EnsureSuccessStatusCode();
			string content = await response.Content.ReadAsStringAsync();
			Console.WriteLine("Response:");
			Console.WriteLine(content);
		}
		catch (Exception ex)
		{
			Console.WriteLine($"Error: {ex.Message}");
		}
	}
}
