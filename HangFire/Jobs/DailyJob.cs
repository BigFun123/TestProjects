using HangFire.Data;

namespace HangFire.Jobs;

public class DailyJob
{
    private readonly DatabaseService _databaseService;
    private readonly ILogger<DailyJob> _logger;

    public DailyJob(DatabaseService databaseService, ILogger<DailyJob> logger)
    {
        _databaseService = databaseService;
        _logger = logger;
    }

    public async Task RunDailyStoredProcedure()
    {
        _logger.LogInformation("Daily job started at {Time}", DateTime.UtcNow);

        try
        {
            // Execute your stored procedure
            await _databaseService.ExecuteStoredProcedureAsync("dbo.DailyMaintenanceProc");
            
            _logger.LogInformation("Daily job completed successfully at {Time}", DateTime.UtcNow);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Daily job failed at {Time}", DateTime.UtcNow);
            throw; // Re-throw to let Hangfire handle retry logic
        }
    }
}
