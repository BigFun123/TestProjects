using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using NCrontab;

namespace ekstask;

public class ScheduledTaskService : BackgroundService
{
    private readonly ILogger<ScheduledTaskService> _logger;
    private readonly IHttpClientFactory _httpClientFactory;
    private readonly ScheduledTaskConfiguration _config;
    private CrontabSchedule _schedule;
    private DateTime _nextRun;
    private readonly TimeZoneInfo _timeZone;

    public ScheduledTaskService(
        ILogger<ScheduledTaskService> logger,
        IHttpClientFactory httpClientFactory,
        IOptions<ScheduledTaskConfiguration> config)
    {
        _logger = logger;
        _httpClientFactory = httpClientFactory;
        _config = config.Value;

        try
        {
            _schedule = CrontabSchedule.Parse(_config.CronExpression);
            _timeZone = TimeZoneInfo.FindSystemTimeZoneById(_config.TimeZone);
            _nextRun = _schedule.GetNextOccurrence(TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, _timeZone));
            _logger.LogInformation("Scheduled task initialized. Next run: {NextRun} {TimeZone}", _nextRun, _config.TimeZone);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to initialize scheduled task with cron expression: {CronExpression}", _config.CronExpression);
            throw;
        }
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation("Scheduled Task Service is starting");

        while (!stoppingToken.IsCancellationRequested)
        {
            var now = TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, _timeZone);
            var delay = _nextRun - now;

            if (delay.TotalMilliseconds > 0)
            {
                _logger.LogInformation("Next task execution scheduled for {NextRun} {TimeZone} (in {Delay})", 
                    _nextRun, _config.TimeZone, delay);
                
                await Task.Delay(delay, stoppingToken);
            }

            if (!stoppingToken.IsCancellationRequested)
            {
                await ExecuteTaskAsync(stoppingToken);
                
                // Calculate next run
                _nextRun = _schedule.GetNextOccurrence(TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, _timeZone));
            }
        }

        _logger.LogInformation("Scheduled Task Service is stopping");
    }

    private async Task ExecuteTaskAsync(CancellationToken stoppingToken)
    {
        try
        {
            _logger.LogInformation("Executing scheduled task: Calling {Endpoint}", _config.Endpoint);

            var httpClient = _httpClientFactory.CreateClient("ScheduledTaskClient");
            var url = $"{_config.ApiBaseUrl.TrimEnd('/')}/{_config.Endpoint.TrimStart('/')}";

            var response = await httpClient.PostAsync(url, null, stoppingToken);

            if (response.IsSuccessStatusCode)
            {
                var content = await response.Content.ReadAsStringAsync(stoppingToken);
                _logger.LogInformation("API call successful. Status: {StatusCode}, Response: {Response}", 
                    response.StatusCode, content);
            }
            else
            {
                var errorContent = await response.Content.ReadAsStringAsync(stoppingToken);
                _logger.LogWarning("API call returned non-success status. Status: {StatusCode}, Response: {Response}", 
                    response.StatusCode, errorContent);
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error executing scheduled task");
        }
    }
}
