using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Configuration;

public class ApiSchedulerService : BackgroundService
{
    private readonly IHttpClientFactory _httpClientFactory;
    private readonly ILogger<ApiSchedulerService> _logger;
    private readonly IConfiguration _configuration;

    public ApiSchedulerService(
        IHttpClientFactory httpClientFactory,
        ILogger<ApiSchedulerService> logger,
        IConfiguration configuration)
    {
        _httpClientFactory = httpClientFactory;
        _logger = logger;
        _configuration = configuration;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation("API Scheduler Service started at: {time}", DateTimeOffset.Now);

        try
        {
            var endpoint = _configuration["ApiSettings:Endpoint"] ?? "/api/hello";
            var httpClient = _httpClientFactory.CreateClient("ApiClient");

            _logger.LogInformation("Calling API endpoint: {endpoint}", httpClient.BaseAddress + endpoint);

            var response = await httpClient.GetAsync(endpoint, stoppingToken);
            
            if (response.IsSuccessStatusCode)
            {
                var content = await response.Content.ReadAsStringAsync(stoppingToken);
                _logger.LogInformation("API call successful. Response: {response}", content);
            }
            else
            {
                _logger.LogError("API call failed with status code: {statusCode}", response.StatusCode);
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error occurred while calling API");
            throw; // Exit with error code for Kubernetes to detect failure
        }

        _logger.LogInformation("API Scheduler Service completed at: {time}", DateTimeOffset.Now);
    }
}
