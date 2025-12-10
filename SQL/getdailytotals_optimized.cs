using Microsoft.EntityFrameworkCore;

namespace YourNamespace;

public class DailyTotalsQueryOptimized
{
    public class DailyTotalResult
    {
        public DateTime PeriodDate { get; set; }
        public decimal Balance { get; set; }
    }

    public static async Task<List<DailyTotalResult>> GetDailyTotalsAsync(
        DbContext context,
        string period,
        Guid modelId,
        DateTime startDate,
        DateTime endDate,
        int maxDataPoints = 800)
    {
        // Get all data points for the date range
        var allData = await context.Set<ModelDailyTotal>()
            .Where(m => m.ModelId == modelId && m.Date >= startDate && m.Date <= endDate)
            .OrderBy(m => m.Date)
            .ToListAsync();

        if (allData.Count == 0)
            return new List<DailyTotalResult>();

        // Group by period first
        var groupedData = allData
            .GroupBy(m => GetPeriodDate(m.Date, period))
            .Select(g => new DailyTotalResult
            {
                PeriodDate = g.Key,
                Balance = g.Max(x => x.Balance)
            })
            .OrderBy(r => r.PeriodDate)
            .ToList();

        // If we already have fewer points than max, return all
        if (groupedData.Count <= maxDataPoints)
            return groupedData;

        // Sample evenly spaced data points
        var sampledData = new List<DailyTotalResult>();
        double step = (double)groupedData.Count / maxDataPoints;

        for (int i = 0; i < maxDataPoints; i++)
        {
            int index = (int)Math.Floor(i * step);
            if (index < groupedData.Count)
            {
                sampledData.Add(groupedData[index]);
            }
        }

        return sampledData;
    }

    private static DateTime GetPeriodDate(DateTime date, string period)
    {
        return period.ToLower() switch
        {
            "daily" => date,
            "weekly" => date.AddDays(-(int)date.DayOfWeek),
            "monthly" => new DateTime(date.Year, date.Month, 1),
            "yearly" => new DateTime(date.Year, 1, 1),
            _ => date
        };
    }
}

// Model class - adjust namespace and properties as needed
public class ModelDailyTotal
{
    public DateTime Date { get; set; }
    public Guid ModelId { get; set; }
    public decimal Balance { get; set; }
}

// Example usage:
// var results = await DailyTotalsQueryOptimized.GetDailyTotalsAsync(
//     dbContext,
//     "daily",
//     Guid.Parse("00000000-0000-0000-0000-000000000000"),
//     new DateTime(2025, 1, 1),
//     new DateTime(2025, 12, 31),
//     800);
