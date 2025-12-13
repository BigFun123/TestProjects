namespace ekstask;

public class ScheduledTaskConfiguration
{
    public string ApiBaseUrl { get; set; } = string.Empty;
    public string Endpoint { get; set; } = string.Empty;
    public string CronExpression { get; set; } = "0 0 * * *"; // Default: daily at midnight
    public string TimeZone { get; set; } = "UTC";
}
