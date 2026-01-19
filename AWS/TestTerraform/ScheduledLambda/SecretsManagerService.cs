using Amazon.SecretsManager;
using Amazon.SecretsManager.Model;

namespace ScheduledLambda;

public class SecretsManagerService
{
    private readonly IAmazonSecretsManager _secretsManager;

    public SecretsManagerService(IAmazonSecretsManager? secretsManager = null)
    {
        _secretsManager = secretsManager ?? new AmazonSecretsManagerClient();
    }

    public async Task<string?> GetSecretValueAsync(string secretName)
    {
        try
        {
            var request = new GetSecretValueRequest
            {
                SecretId = secretName
            };
            var response = await _secretsManager.GetSecretValueAsync(request);
            return response.SecretString;
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error retrieving secret {secretName}: {ex.Message}");
            // Log or handle exception as needed
            return null;
        }
    }
}
