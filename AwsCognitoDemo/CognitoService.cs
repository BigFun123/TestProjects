using Amazon.CognitoIdentityProvider;
using Amazon.CognitoIdentityProvider.Model;
using System.Threading.Tasks;

namespace AwsCognitoDemo
{
    public class CognitoService
    {
        private readonly AmazonCognitoIdentityProviderClient _client;
        public CognitoService(AmazonCognitoIdentityProviderClient client)
        {
            _client = client;
        }

        public async Task<ListUserPoolsResponse> ListUserPoolsAsync(int maxResults = 10)
        {
            var request = new ListUserPoolsRequest { MaxResults = maxResults };
            return await _client.ListUserPoolsAsync(request);
        }
    }
}
