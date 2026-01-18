using Amazon.Lambda.Core;

// Assembly attribute to enable the Lambda function's JSON input to be converted into a .NET class.
[assembly: LambdaSerializer(typeof(Amazon.Lambda.Serialization.SystemTextJson.DefaultLambdaJsonSerializer))]

namespace ScheduledLambda;

public class Function
{
    
    /// <summary>
    /// A simple function that takes an object and does a HTTP GET request to a URL specified in environment variable FETCH_URL.
    /// </summary>
    /// <param name="input">The event for the Lambda function handler to process.</param>
    /// <param name="context">The ILambdaContext that provides methods for logging and describing the Lambda environment.</param>
    /// <returns></returns>
    /// public void FunctionHandler(CloudWatchEvent<dynamic> evnt, ILambdaContext context)

    public async Task<string> FunctionHandler(object input, ILambdaContext context)
    {
        var url = Environment.GetEnvironmentVariable("FETCH_URL");
        if (string.IsNullOrEmpty(url))
        {
            context.Logger.LogLine("FETCH_URL environment variable is not set.");
            return "FETCH_URL environment variable is not set.";
        }

        // get APIKey from secrets manager
        var secretsService = new SecretsManagerService();
        var apiKeySecret = await secretsService.GetSecretValueAsync("APIKey");
        if (string.IsNullOrEmpty(apiKeySecret))
        {
            context.Logger.LogLine("APIKey secret not found or empty.");
        } else {
            context.Logger.LogLine($"Retrieved APIKey secret.{apiKeySecret}");
        }

        try
        {
            using var httpClient = new HttpClient();
            var response = await httpClient.GetAsync(url);
            var content = await response.Content.ReadAsStringAsync();
            context.Logger.LogLine($"Fetched from {url}: {content}");
            return content;
        }
        catch (Exception ex)
        {
            context.Logger.LogLine($"Error fetching from {url}: {ex.Message}");
            return $"Error: {ex.Message}";
        }
    }
}
