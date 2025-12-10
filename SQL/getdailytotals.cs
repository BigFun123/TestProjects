using Microsoft.EntityFrameworkCore;

namespace YourNamespace;

public class DailyTotalsQuery
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
        DateTime endDate)
    {
        var query = context.Set<ModelDailyTotal>()
            .Where(m => m.ModelId == modelId && m.Date >= startDate && m.Date <= endDate)
            .AsEnumerable()
            .GroupBy(m => GetPeriodDate(m.Date, period))
            .Select(g => new DailyTotalResult
            {
                PeriodDate = g.Key,
                Balance = g.Max(x => x.Balance)
            })
            .OrderBy(r => r.PeriodDate)
            .ToList();

        return await Task.FromResult(query);
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
// var results = await DailyTotalsQuery.GetDailyTotalsAsync(
//     dbContext,
//     "daily",
//     Guid.Parse("00000000-0000-0000-0000-000000000000"),
//     new DateTime(2025, 1, 1),
//     new DateTime(2025, 12, 31));
