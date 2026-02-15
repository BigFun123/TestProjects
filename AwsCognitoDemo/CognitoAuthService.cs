using Amazon.CognitoIdentityProvider;
using Amazon.CognitoIdentityProvider.Model;
using System.Threading.Tasks;

namespace AwsCognitoDemo
{
    public class CognitoAuthService
    {
        private readonly AmazonCognitoIdentityProviderClient _client;
        public CognitoAuthService(AmazonCognitoIdentityProviderClient client)
        {
            _client = client;
        }

        public async Task<string> GetTokenWithClientCredentialsAsync(string clientId, string clientSecret, string userPoolDomain)
        {
            // Calls the Cognito OAuth2 token endpoint for client credentials grant
            var tokenEndpoint = $"https://{userPoolDomain}/oauth2/token";
            using var http = new System.Net.Http.HttpClient();
            var request = new System.Net.Http.HttpRequestMessage(System.Net.Http.HttpMethod.Post, tokenEndpoint);
            var authHeader = System.Convert.ToBase64String(System.Text.Encoding.UTF8.GetBytes($"{clientId}:{clientSecret}"));
            request.Headers.Add("Authorization", $"Basic {authHeader}");
            request.Content = new System.Net.Http.FormUrlEncodedContent(new[]
            {
                new System.Collections.Generic.KeyValuePair<string, string>("grant_type", "client_credentials")
            });
            var response = await http.SendAsync(request);
            var content = await response.Content.ReadAsStringAsync();
            if (!response.IsSuccessStatusCode)
                throw new System.Exception($"OAuth2 error: {content}");
            // Parse access_token from JSON
            var json = System.Text.Json.JsonDocument.Parse(content);
            return json.RootElement.GetProperty("access_token").GetString();
        }
    }
}
