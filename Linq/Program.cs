using LinqDemo.Data;
using LinqDemo.Models;
using Microsoft.EntityFrameworkCore;

namespace LinqDemo;

class Program
{
    static void Main(string[] args)
    {
        Console.WriteLine("=== LINQ Demo for Portfolio Management ===\n");

        // Initialize database with seed data
        using var context = new PortfolioDbContext();
        context.Database.EnsureCreated();

        // Run all demo methods
        Demo1_BasicSelection(context);
        Demo2_Filtering(context);
        Demo3_Projection(context);
        Demo4_Ordering(context);
        Demo5_Grouping(context);
        Demo6_Aggregation(context);
        Demo7_Joins(context);
        Demo8_NavigationProperties(context);
        Demo9_ComplexQueries(context);
        Demo10_TotalHoldingsOfModel(context);
        Demo11_PortfolioModelQueries(context);
        Demo12_PortfolioTotalValueWithModels(context);

        Console.WriteLine("\n=== Demo Complete ===");
    }

    /// <summary>
    /// Demo 1: Basic Selection - Retrieve all records from a table
    /// </summary>
    static void Demo1_BasicSelection(PortfolioDbContext context)
    {
        Console.WriteLine("--- Demo 1: Basic Selection ---");

        // Select all instruments using LINQ method syntax
        var allInstruments = context.Instruments.ToList();
        Console.WriteLine($"Total instruments: {allInstruments.Count}");

        // Select all instruments using LINQ query syntax
        var queryInstruments = (from i in context.Instruments
                                select i).ToList();
        Console.WriteLine($"Total instruments (query syntax): {queryInstruments.Count}");

        // Display first 3 instruments
        Console.WriteLine("\nFirst 3 Instruments:");
        foreach (var instrument in allInstruments.Take(3))
        {
            Console.WriteLine($"  {instrument.Symbol} - {instrument.Name} (${instrument.CurrentPrice})");
        }

        Console.WriteLine();
    }

    /// <summary>
    /// Demo 2: Filtering - Use Where clause to filter data
    /// </summary>
    static void Demo2_Filtering(PortfolioDbContext context)
    {
        Console.WriteLine("--- Demo 2: Filtering with Where ---");

        // Filter instruments by type (ETF only)
        var etfs = context.Instruments
            .Where(i => i.InstrumentType == "ETF")
            .ToList();
        
        Console.WriteLine($"ETFs found: {etfs.Count}");
        foreach (var etf in etfs)
        {
            Console.WriteLine($"  {etf.Symbol} - {etf.Name}");
        }

        // Filter instruments with price greater than $200
        var expensiveInstruments = context.Instruments
            .Where(i => i.CurrentPrice > 200)
            .ToList();
        
        Console.WriteLine($"\nInstruments priced over $200: {expensiveInstruments.Count}");
        foreach (var instrument in expensiveInstruments)
        {
            Console.WriteLine($"  {instrument.Symbol} - ${instrument.CurrentPrice}");
        }

        // Multiple filter conditions
        var techStocks = context.Instruments
            .Where(i => i.InstrumentType == "Stock" && i.CurrentPrice > 150)
            .ToList();
        
        Console.WriteLine($"\nTech stocks over $150: {techStocks.Count}");
        foreach (var stock in techStocks)
        {
            Console.WriteLine($"  {stock.Symbol} - ${stock.CurrentPrice}");
        }

        // Filter active portfolios
        var activePortfolios = context.Portfolios
            .Where(p => p.IsActive)
            .ToList();
        
        Console.WriteLine($"\nActive portfolios: {activePortfolios.Count}");

        Console.WriteLine();
    }

    /// <summary>
    /// Demo 3: Projection - Select specific properties or transform data
    /// </summary>
    static void Demo3_Projection(PortfolioDbContext context)
    {
        Console.WriteLine("--- Demo 3: Projection with Select ---");

        // Project to anonymous type with selected properties
        var instrumentSummary = context.Instruments
            .Select(i => new
            {
                i.Symbol,
                i.Name,
                Price = i.CurrentPrice,
                Type = i.InstrumentType
            })
            .ToList();

        Console.WriteLine("Instrument Summary (first 5):");
        foreach (var item in instrumentSummary.Take(5))
        {
            Console.WriteLine($"  {item.Symbol}: {item.Type} @ ${item.Price}");
        }

        // Project with calculation
        var portfolioValues = context.Portfolios
            .Where(p => p.IsActive)
            .Select(p => new
            {
                p.Name,
                p.OwnerName,
                p.CashBalance,
                AccountAge = DateTime.Now.Year - p.CreatedDate.Year
            })
            .ToList();

        Console.WriteLine("\nPortfolio Values:");
        foreach (var pv in portfolioValues)
        {
            Console.WriteLine($"  {pv.Name} ({pv.OwnerName}) - Cash: ${pv.CashBalance:N2}, Age: {pv.AccountAge} years");
        }

        // Project with SelectMany - flatten collections
        var allHoldingSymbols = context.Models
            .SelectMany(m => m.Holdings)
            .Select(h => h.Instrument.Symbol)
            .Distinct()
            .ToList();

        Console.WriteLine($"\nUnique instruments held across all models: {string.Join(", ", allHoldingSymbols)}");

        Console.WriteLine();
    }

    /// <summary>
    /// Demo 4: Ordering - Sort data using OrderBy, OrderByDescending, ThenBy
    /// </summary>
    static void Demo4_Ordering(PortfolioDbContext context)
    {
        Console.WriteLine("--- Demo 4: Ordering ---");

        // Order by price ascending
        var instrumentsByPrice = context.Instruments
            .OrderBy(i => i.CurrentPrice)
            .Select(i => new { i.Symbol, i.CurrentPrice })
            .ToList();

        Console.WriteLine("Instruments ordered by price (ascending):");
        foreach (var item in instrumentsByPrice.Take(5))
        {
            Console.WriteLine($"  {item.Symbol}: ${item.CurrentPrice}");
        }

        // Order by price descending
        var instrumentsByPriceDesc = context.Instruments
            .OrderByDescending(i => i.CurrentPrice)
            .Select(i => new { i.Symbol, i.CurrentPrice })
            .ToList();

        Console.WriteLine("\nInstruments ordered by price (descending, top 5):");
        foreach (var item in instrumentsByPriceDesc.Take(5))
        {
            Console.WriteLine($"  {item.Symbol}: ${item.CurrentPrice}");
        }

        // Multiple sorting criteria - OrderBy then ThenBy
        var portfoliosSorted = context.Portfolios
            .OrderBy(p => p.IsActive ? 0 : 1)  // Active first
            .ThenByDescending(p => p.CashBalance)
            .Select(p => new { p.Name, p.IsActive, p.CashBalance })
            .ToList();

        Console.WriteLine("\nPortfolios sorted by active status, then by cash balance:");
        foreach (var p in portfoliosSorted)
        {
            Console.WriteLine($"  {p.Name}: {(p.IsActive ? "Active" : "Inactive")} - ${p.CashBalance:N2}");
        }

        Console.WriteLine();
    }

    /// <summary>
    /// Demo 5: Grouping - Group data by a key using GroupBy
    /// </summary>
    static void Demo5_Grouping(PortfolioDbContext context)
    {
        Console.WriteLine("--- Demo 5: Grouping ---");

        // Group instruments by type
        var instrumentsByType = context.Instruments
            .GroupBy(i => i.InstrumentType)
            .Select(g => new
            {
                Type = g.Key,
                Count = g.Count(),
                AvgPrice = g.Average(i => i.CurrentPrice)
            })
            .ToList();

        Console.WriteLine("Instruments grouped by type:");
        foreach (var group in instrumentsByType)
        {
            Console.WriteLine($"  {group.Type}: {group.Count} instruments, Avg Price: ${group.AvgPrice:N2}");
        }

        // Group portfolios by model
        var portfoliosByModel = context.Portfolios
            .Where(p => p.IsActive)
            .GroupBy(p => p.Model.Name)
            .Select(g => new
            {
                ModelName = g.Key,
                PortfolioCount = g.Count(),
                TotalCash = g.Sum(p => p.CashBalance),
                AvgCash = g.Average(p => p.CashBalance)
            })
            .ToList();

        Console.WriteLine("\nActive portfolios grouped by model:");
        foreach (var group in portfoliosByModel)
        {
            Console.WriteLine($"  {group.ModelName}: {group.PortfolioCount} portfolios");
            Console.WriteLine($"    Total Cash: ${group.TotalCash:N2}, Avg: ${group.AvgCash:N2}");
        }

        // Group models by risk level (via ModelGroup)
        var modelsByRisk = context.Models
            .GroupBy(m => m.ModelGroup.RiskLevel)
            .Select(g => new
            {
                RiskLevel = g.Key,
                ModelCount = g.Count(),
                AvgEquityAllocation = g.Average(m => m.EquityAllocation)
            })
            .ToList();

        Console.WriteLine("\nModels grouped by risk level:");
        foreach (var group in modelsByRisk)
        {
            Console.WriteLine($"  {group.RiskLevel}: {group.ModelCount} models, Avg Equity: {group.AvgEquityAllocation:N1}%");
        }

        Console.WriteLine();
    }

    /// <summary>
    /// Demo 6: Aggregation - Calculate sum, average, min, max, count
    /// </summary>
    static void Demo6_Aggregation(PortfolioDbContext context)
    {
        Console.WriteLine("--- Demo 6: Aggregation Functions ---");

        // Count
        var totalInstruments = context.Instruments.Count();
        var etfCount = context.Instruments.Count(i => i.InstrumentType == "ETF");
        Console.WriteLine($"Total instruments: {totalInstruments}");
        Console.WriteLine($"ETF count: {etfCount}");

        // Sum
        var totalCash = context.Portfolios.Sum(p => p.CashBalance);
        var activeCash = context.Portfolios
            .Where(p => p.IsActive)
            .Sum(p => p.CashBalance);
        Console.WriteLine($"\nTotal cash across all portfolios: ${totalCash:N2}");
        Console.WriteLine($"Total cash in active portfolios: ${activeCash:N2}");

        // Average
        var avgInstrumentPrice = context.Instruments.Average(i => i.CurrentPrice);
        var avgStockPrice = context.Instruments
            .Where(i => i.InstrumentType == "Stock")
            .Average(i => i.CurrentPrice);
        Console.WriteLine($"\nAverage instrument price: ${avgInstrumentPrice:N2}");
        Console.WriteLine($"Average stock price: ${avgStockPrice:N2}");

        // Min and Max
        var cheapestInstrument = context.Instruments
            .OrderBy(i => i.CurrentPrice)
            .First();
        var mostExpensiveInstrument = context.Instruments
            .OrderByDescending(i => i.CurrentPrice)
            .First();
        
        Console.WriteLine($"\nCheapest instrument: {cheapestInstrument.Symbol} @ ${cheapestInstrument.CurrentPrice}");
        Console.WriteLine($"Most expensive instrument: {mostExpensiveInstrument.Symbol} @ ${mostExpensiveInstrument.CurrentPrice}");

        // Using Min/Max directly
        var minPrice = context.Instruments.Min(i => i.CurrentPrice);
        var maxPrice = context.Instruments.Max(i => i.CurrentPrice);
        Console.WriteLine($"Price range: ${minPrice} - ${maxPrice}");

        // Any and All
        var hasHighPriceStocks = context.Instruments
            .Any(i => i.InstrumentType == "Stock" && i.CurrentPrice > 300);
        var allInstrumentsHavePrice = context.Instruments
            .All(i => i.CurrentPrice > 0);
        
        Console.WriteLine($"\nAny stock over $300? {hasHighPriceStocks}");
        Console.WriteLine($"All instruments have positive price? {allInstrumentsHavePrice}");

        Console.WriteLine();
    }

    /// <summary>
    /// Demo 7: Joins - Combine data from multiple tables
    /// </summary>
    static void Demo7_Joins(PortfolioDbContext context)
    {
        Console.WriteLine("--- Demo 7: Joins ---");

        // Inner join - Portfolio with Model information
        var portfolioModelJoin = context.Portfolios
            .Join(
                context.Models,
                portfolio => portfolio.ModelId,
                model => model.Id,
                (portfolio, model) => new
                {
                    PortfolioName = portfolio.Name,
                    Owner = portfolio.OwnerName,
                    ModelName = model.Name,
                    EquityAllocation = model.EquityAllocation
                })
            .ToList();

        Console.WriteLine("Portfolio to Model join (first 5):");
        foreach (var item in portfolioModelJoin.Take(5))
        {
            Console.WriteLine($"  {item.PortfolioName} ({item.Owner}) uses {item.ModelName} - {item.EquityAllocation}% equity");
        }

        // Multiple joins - Portfolio -> Model -> ModelGroup
        var portfolioFullInfo = context.Portfolios
            .Join(
                context.Models,
                p => p.ModelId,
                m => m.Id,
                (p, m) => new { Portfolio = p, Model = m })
            .Join(
                context.ModelGroups,
                pm => pm.Model.ModelGroupId,
                mg => mg.Id,
                (pm, mg) => new
                {
                    PortfolioName = pm.Portfolio.Name,
                    ModelName = pm.Model.Name,
                    GroupName = mg.Name,
                    RiskLevel = mg.RiskLevel
                })
            .ToList();

        Console.WriteLine("\nPortfolio with full model and group info (first 3):");
        foreach (var item in portfolioFullInfo.Take(3))
        {
            Console.WriteLine($"  {item.PortfolioName} -> {item.ModelName} -> {item.GroupName} ({item.RiskLevel} risk)");
        }

        // Group join - Models with their holdings
        var modelsWithHoldings = context.Models
            .GroupJoin(
                context.Holdings,
                model => model.Id,
                holding => holding.ModelId,
                (model, holdings) => new
                {
                    ModelName = model.Name,
                    HoldingCount = holdings.Count()
                })
            .ToList();

        Console.WriteLine("\nModels with holding counts:");
        foreach (var item in modelsWithHoldings)
        {
            Console.WriteLine($"  {item.ModelName}: {item.HoldingCount} holdings");
        }

        Console.WriteLine();
    }

    /// <summary>
    /// Demo 8: Navigation Properties - Use EF Core navigation properties instead of joins
    /// </summary>
    static void Demo8_NavigationProperties(PortfolioDbContext context)
    {
        Console.WriteLine("--- Demo 8: Navigation Properties ---");

        // Access related data through navigation properties
        // Include() loads related data eagerly
        var portfoliosWithModels = context.Portfolios
            .Include(p => p.Model)
            .ThenInclude(m => m.ModelGroup)
            .Where(p => p.IsActive)
            .ToList();

        Console.WriteLine("Portfolios with navigation to Model and ModelGroup:");
        foreach (var portfolio in portfoliosWithModels.Take(3))
        {
            Console.WriteLine($"  {portfolio.Name}:");
            Console.WriteLine($"    Model: {portfolio.Model.Name}");
            Console.WriteLine($"    Group: {portfolio.Model.ModelGroup.Name} ({portfolio.Model.ModelGroup.RiskLevel})");
            Console.WriteLine($"    Allocation: {portfolio.Model.EquityAllocation}% equity / {portfolio.Model.FixedIncomeAllocation}% fixed income");
        }

        // Load models with their holdings and instruments
        var modelsWithHoldings = context.Models
            .Include(m => m.Holdings)
            .ThenInclude(h => h.Instrument)
            .ToList();

        Console.WriteLine("\nModels with their holdings:");
        foreach (var model in modelsWithHoldings.Take(2))
        {
            Console.WriteLine($"\n  {model.Name} ({model.Holdings.Count} holdings):");
            foreach (var holding in model.Holdings)
            {
                Console.WriteLine($"    - {holding.Instrument.Symbol}: {holding.Quantity} units @ ${holding.Instrument.CurrentPrice} " +
                                  $"(Target: {holding.TargetWeight}%)");
            }
        }

        Console.WriteLine();
    }

    /// <summary>
    /// Demo 9: Complex Queries - Combine multiple LINQ operations
    /// </summary>
    static void Demo9_ComplexQueries(PortfolioDbContext context)
    {
        Console.WriteLine("--- Demo 9: Complex Queries ---");

        // Find portfolios with high-risk models and cash > $10,000
        var highRiskWealthyPortfolios = context.Portfolios
            .Include(p => p.Model)
            .ThenInclude(m => m.ModelGroup)
            .Where(p => p.IsActive && 
                   p.CashBalance > 10000 && 
                   p.Model.ModelGroup.RiskLevel == "High")
            .OrderByDescending(p => p.CashBalance)
            .Select(p => new
            {
                p.Name,
                p.OwnerName,
                p.CashBalance,
                ModelName = p.Model.Name,
                RiskLevel = p.Model.ModelGroup.RiskLevel
            })
            .ToList();

        Console.WriteLine("High-risk portfolios with cash > $10,000:");
        foreach (var p in highRiskWealthyPortfolios)
        {
            Console.WriteLine($"  {p.Name} ({p.OwnerName}): ${p.CashBalance:N2} - {p.ModelName}");
        }

        // Find instruments that are held in multiple models
        var popularInstruments = context.Holdings
            .GroupBy(h => h.Instrument.Symbol)
            .Where(g => g.Count() > 2)
            .Select(g => new
            {
                Symbol = g.Key,
                ModelCount = g.Count(),
                TotalQuantity = g.Sum(h => h.Quantity),
                AvgTargetWeight = g.Average(h => h.TargetWeight)
            })
            .OrderByDescending(x => x.ModelCount)
            .ToList();

        Console.WriteLine("\nInstruments held in multiple models:");
        foreach (var inst in popularInstruments)
        {
            Console.WriteLine($"  {inst.Symbol}: In {inst.ModelCount} models, Total qty: {inst.TotalQuantity}, Avg weight: {inst.AvgTargetWeight:N1}%");
        }

        // Calculate portfolio age in years and group by decade
        var portfoliosByDecade = context.Portfolios
            .Where(p => p.IsActive)
            .Select(p => new
            {
                p.Name,
                p.CreatedDate,
                Age = DateTime.Now.Year - p.CreatedDate.Year
            })
            .AsEnumerable() // Switch to client-side evaluation for grouping calculation
            .GroupBy(p => (p.Age / 5) * 5) // Group by 5-year intervals
            .Select(g => new
            {
                AgeGroup = $"{g.Key}-{g.Key + 4} years",
                Count = g.Count()
            })
            .ToList();

        Console.WriteLine("\nActive portfolios by age group:");
        foreach (var group in portfoliosByDecade)
        {
            Console.WriteLine($"  {group.AgeGroup}: {group.Count} portfolios");
        }

        Console.WriteLine();
    }

    /// <summary>
    /// Demo 10: Total Holdings of a Model - Calculate the total market value of all instruments in a model
    /// This demonstrates joining Holdings with Instruments and performing calculations
    /// </summary>
    static void Demo10_TotalHoldingsOfModel(PortfolioDbContext context)
    {
        Console.WriteLine("--- Demo 10: Total Holdings Value by Model ---");

        // For each model, calculate the total market value of all its holdings
        var modelHoldingsValue = context.Models
            .Include(m => m.Holdings)
            .ThenInclude(h => h.Instrument)
            .Select(m => new
            {
                ModelName = m.Name,
                Holdings = m.Holdings.Select(h => new
                {
                    Symbol = h.Instrument.Symbol,
                    Quantity = h.Quantity,
                    CurrentPrice = h.Instrument.CurrentPrice,
                    MarketValue = h.Quantity * h.Instrument.CurrentPrice,
                    TargetWeight = h.TargetWeight,
                    CostBasis = h.CostBasis,
                    UnrealizedGainLoss = (h.Instrument.CurrentPrice - h.CostBasis) * h.Quantity
                }).ToList(),
                TotalMarketValue = m.Holdings.Sum(h => h.Quantity * h.Instrument.CurrentPrice),
                TotalCostBasis = m.Holdings.Sum(h => h.Quantity * h.CostBasis),
                HoldingCount = m.Holdings.Count
            })
            .ToList();

        Console.WriteLine("Total holdings value for each model:\n");
        
        foreach (var model in modelHoldingsValue)
        {
            Console.WriteLine($"Model: {model.ModelName}");
            Console.WriteLine($"  Total Holdings: {model.HoldingCount}");
            Console.WriteLine($"  Total Market Value: ${model.TotalMarketValue:N2}");
            Console.WriteLine($"  Total Cost Basis: ${model.TotalCostBasis:N2}");
            Console.WriteLine($"  Total Unrealized Gain/Loss: ${(model.TotalMarketValue - model.TotalCostBasis):N2}");
            Console.WriteLine($"  Return: {((model.TotalMarketValue - model.TotalCostBasis) / model.TotalCostBasis * 100):N2}%");
            Console.WriteLine("  Holdings breakdown:");
            
            foreach (var holding in model.Holdings.OrderByDescending(h => h.MarketValue))
            {
                var actualWeight = model.TotalMarketValue > 0 
                    ? (holding.MarketValue / model.TotalMarketValue * 100) 
                    : 0;
                
                Console.WriteLine($"    {holding.Symbol,-6} {holding.Quantity,8:N0} units @ ${holding.CurrentPrice,7:N2} = " +
                                  $"${holding.MarketValue,12:N2} " +
                                  $"({actualWeight,5:N1}% actual vs {holding.TargetWeight,5:N1}% target) " +
                                  $"[G/L: ${holding.UnrealizedGainLoss,10:N2}]");
            }
            Console.WriteLine();
        }

        // Find the model with the highest total value
        var topModel = modelHoldingsValue
            .OrderByDescending(m => m.TotalMarketValue)
            .First();
        
        Console.WriteLine($"Model with highest total value: {topModel.ModelName} at ${topModel.TotalMarketValue:N2}");

        // Calculate weighted average performance across all models
        var totalMarketValue = modelHoldingsValue.Sum(m => m.TotalMarketValue);
        var totalCostBasis = modelHoldingsValue.Sum(m => m.TotalCostBasis);
        var overallReturn = (totalMarketValue - totalCostBasis) / totalCostBasis * 100;
        
        Console.WriteLine($"\nOverall Statistics:");
        Console.WriteLine($"  Total Market Value (all models): ${totalMarketValue:N2}");
        Console.WriteLine($"  Total Cost Basis (all models): ${totalCostBasis:N2}");
        Console.WriteLine($"  Overall Return: {overallReturn:N2}%");

        Console.WriteLine();
    }

    /// <summary>
    /// Demo 11: Portfolio-Model Queries - Query portfolios directly via ModelId in Portfolio table
    /// This demonstrates the direct foreign key relationship between Portfolio and Model
    /// without needing to go through the Holdings table
    /// </summary>
    static void Demo11_PortfolioModelQueries(PortfolioDbContext context)
    {
        Console.WriteLine("--- Demo 11: Portfolio-Model Queries (ModelId in Portfolio Table) ---");

        // Find all portfolios using a specific model by name
        var targetModelName = "Balanced Growth";
        var portfoliosUsingModel = context.Portfolios
            .Where(p => p.Model.Name == targetModelName)
            .Select(p => new
            {
                p.Name,
                p.OwnerName,
                p.CashBalance,
                p.IsActive,
                ModelName = p.Model.Name
            })
            .ToList();

        Console.WriteLine($"Portfolios using '{targetModelName}' model:");
        foreach (var portfolio in portfoliosUsingModel)
        {
            Console.WriteLine($"  {portfolio.Name} ({portfolio.OwnerName}) - Cash: ${portfolio.CashBalance:N2}, Active: {portfolio.IsActive}");
        }

        // Find all portfolios in a specific model group (e.g., High risk)
        var riskLevel = "High";
        var highRiskPortfolios = context.Portfolios
            .Where(p => p.Model.ModelGroup.RiskLevel == riskLevel)
            .Select(p => new
            {
                p.Name,
                p.OwnerName,
                ModelName = p.Model.Name,
                GroupName = p.Model.ModelGroup.Name,
                EquityAllocation = p.Model.EquityAllocation
            })
            .ToList();

        Console.WriteLine($"\nPortfolios with {riskLevel} risk models:");
        foreach (var portfolio in highRiskPortfolios)
        {
            Console.WriteLine($"  {portfolio.Name}: {portfolio.ModelName} (Group: {portfolio.GroupName}, {portfolio.EquityAllocation}% equity)");
        }

        // Group portfolios by their model and calculate statistics
        var portfoliosByModel = context.Portfolios
            .GroupBy(p => new { p.ModelId, ModelName = p.Model.Name })
            .Select(g => new
            {
                ModelId = g.Key.ModelId,
                ModelName = g.Key.ModelName,
                TotalPortfolios = g.Count(),
                ActivePortfolios = g.Count(p => p.IsActive),
                TotalCashBalance = g.Sum(p => p.CashBalance),
                AverageCashBalance = g.Average(p => p.CashBalance),
                OldestPortfolioDate = g.Min(p => p.CreatedDate),
                NewestPortfolioDate = g.Max(p => p.CreatedDate)
            })
            .OrderByDescending(x => x.TotalPortfolios)
            .ToList();

        Console.WriteLine("\nPortfolio statistics grouped by model:");
        foreach (var stat in portfoliosByModel)
        {
            Console.WriteLine($"\n  Model: {stat.ModelName} (ID: {stat.ModelId})");
            Console.WriteLine($"    Total Portfolios: {stat.TotalPortfolios} ({stat.ActivePortfolios} active)");
            Console.WriteLine($"    Total Cash: ${stat.TotalCashBalance:N2}");
            Console.WriteLine($"    Average Cash: ${stat.AverageCashBalance:N2}");
            Console.WriteLine($"    Portfolio Age Range: {stat.OldestPortfolioDate:yyyy-MM-dd} to {stat.NewestPortfolioDate:yyyy-MM-dd}");
        }

        // Find portfolios with equity allocation above a threshold
        var equityThreshold = 80m;
        var aggressivePortfolios = context.Portfolios
            .Where(p => p.IsActive && p.Model.EquityAllocation >= equityThreshold)
            .OrderByDescending(p => p.Model.EquityAllocation)
            .ThenByDescending(p => p.CashBalance)
            .Select(p => new
            {
                p.Name,
                p.OwnerName,
                p.CashBalance,
                ModelName = p.Model.Name,
                EquityAllocation = p.Model.EquityAllocation,
                FixedIncomeAllocation = p.Model.FixedIncomeAllocation
            })
            .ToList();

        Console.WriteLine($"\nActive portfolios with {equityThreshold}%+ equity allocation:");
        foreach (var portfolio in aggressivePortfolios)
        {
            Console.WriteLine($"  {portfolio.Name} ({portfolio.OwnerName})");
            Console.WriteLine($"    Model: {portfolio.ModelName}");
            Console.WriteLine($"    Allocation: {portfolio.EquityAllocation}% equity / {portfolio.FixedIncomeAllocation}% fixed income");
            Console.WriteLine($"    Cash Balance: ${portfolio.CashBalance:N2}");
        }

        // Use Join explicitly to demonstrate the Portfolio -> Model relationship via ModelId
        var portfolioModelJoin = context.Portfolios
            .Join(
                context.Models,
                portfolio => portfolio.ModelId,  // Foreign key in Portfolio table
                model => model.Id,                // Primary key in Model table
                (portfolio, model) => new
                {
                    PortfolioId = portfolio.Id,
                    PortfolioName = portfolio.Name,
                    Owner = portfolio.OwnerName,
                    CashBalance = portfolio.CashBalance,
                    ModelId = model.Id,
                    ModelName = model.Name,
                    ModelEquityAllocation = model.EquityAllocation
                })
            .Where(x => x.CashBalance > 10000)
            .OrderBy(x => x.ModelName)
            .ThenByDescending(x => x.CashBalance)
            .ToList();

        Console.WriteLine($"\nExplicit join: Portfolios with cash > $10,000 joined to Models via ModelId:");
        foreach (var item in portfolioModelJoin)
        {
            Console.WriteLine($"  Portfolio '{item.PortfolioName}' (ID: {item.PortfolioId}) owned by {item.Owner}");
            Console.WriteLine($"    -> Uses Model '{item.ModelName}' (ID: {item.ModelId}) with {item.ModelEquityAllocation}% equity");
            Console.WriteLine($"    -> Cash: ${item.CashBalance:N2}");
        }

        // Find which models have the most portfolios
        var popularModels = context.Portfolios
            .GroupBy(p => p.Model.Name)
            .Select(g => new
            {
                ModelName = g.Key,
                PortfolioCount = g.Count(),
                TotalAssets = g.Sum(p => p.CashBalance)
            })
            .OrderByDescending(x => x.PortfolioCount)
            .ThenByDescending(x => x.TotalAssets)
            .ToList();

        Console.WriteLine("\nMost popular models (by portfolio count):");
        foreach (var model in popularModels)
        {
            Console.WriteLine($"  {model.ModelName}: {model.PortfolioCount} portfolios, ${model.TotalAssets:N2} total cash");
        }

        // Demonstrate that we can query portfolios without touching Holdings table
        // This is efficient because ModelId is directly in the Portfolio table
        var portfolioModelSummary = context.Portfolios
            .Select(p => new
            {
                p.Id,
                p.Name,
                p.ModelId,  // Direct foreign key in Portfolio table
                ModelName = p.Model.Name,
                GroupRiskLevel = p.Model.ModelGroup.RiskLevel
            })
            .ToList();

        Console.WriteLine($"\nDirect Portfolio -> Model relationship (via ModelId in Portfolio table):");
        Console.WriteLine($"Total portfolios queried: {portfolioModelSummary.Count}");
        Console.WriteLine("Sample data showing ModelId is in Portfolio table:");
        foreach (var item in portfolioModelSummary.Take(3))
        {
            Console.WriteLine($"  Portfolio ID {item.Id}: '{item.Name}' has ModelId={item.ModelId} ({item.ModelName}, {item.GroupRiskLevel} risk)");
        }

        Console.WriteLine();
    }

    /// <summary>
    /// Demo 12: Calculate total holdings using Portfolio.ModelId, Portfolio.TotalValue with Models and Instruments
    /// This demonstrates combining portfolio-level data with model holdings to analyze asset allocation
    /// and calculate various portfolio metrics
    /// </summary>
    static void Demo12_PortfolioTotalValueWithModels(PortfolioDbContext context)
    {
        Console.WriteLine("--- Demo 12: Portfolio Total Value with Models and Instruments ---");

        // Calculate total assets under management by model
        // Using Portfolio.ModelId and Portfolio.TotalValue
        var assetsUnderManagement = context.Portfolios
            .Where(p => p.IsActive)
            .GroupBy(p => new { p.ModelId, ModelName = p.Model.Name })
            .Select(g => new
            {
                ModelId = g.Key.ModelId,
                ModelName = g.Key.ModelName,
                PortfolioCount = g.Count(),
                TotalAUM = g.Sum(p => p.TotalValue),
                TotalCash = g.Sum(p => p.CashBalance),
                AveragePortfolioSize = g.Average(p => p.TotalValue),
                InvestedAmount = g.Sum(p => p.TotalValue - p.CashBalance),
                CashPercentage = g.Sum(p => p.CashBalance) / g.Sum(p => p.TotalValue) * 100
            })
            .OrderByDescending(x => x.TotalAUM)
            .ToList();

        Console.WriteLine("Assets Under Management by Model (using Portfolio.TotalValue):");
        var grandTotalAUM = 0m;
        foreach (var aum in assetsUnderManagement)
        {
            Console.WriteLine($"\n  Model: {aum.ModelName} (ID: {aum.ModelId})");
            Console.WriteLine($"    Portfolios: {aum.PortfolioCount}");
            Console.WriteLine($"    Total AUM: ${aum.TotalAUM:N2}");
            Console.WriteLine($"    Total Cash: ${aum.TotalCash:N2}");
            Console.WriteLine($"    Invested: ${aum.InvestedAmount:N2}");
            Console.WriteLine($"    Avg Portfolio Size: ${aum.AveragePortfolioSize:N2}");
            Console.WriteLine($"    Cash %: {aum.CashPercentage:N2}%");
            grandTotalAUM += aum.TotalAUM;
        }
        Console.WriteLine($"\n  GRAND TOTAL AUM: ${grandTotalAUM:N2}");

        // Calculate expected instrument allocation per portfolio based on model holdings
        // Combines Portfolio.TotalValue, Portfolio.ModelId with Model -> Holdings -> Instruments
        var portfolioInstrumentAllocation = context.Portfolios
            .Where(p => p.IsActive && p.TotalValue > 0)
            .Include(p => p.Model)
            .ThenInclude(m => m.Holdings)
            .ThenInclude(h => h.Instrument)
            .Select(p => new
            {
                PortfolioId = p.Id,
                PortfolioName = p.Name,
                OwnerName = p.OwnerName,
                TotalValue = p.TotalValue,
                CashBalance = p.CashBalance,
                InvestedAmount = p.TotalValue - p.CashBalance,
                ModelName = p.Model.Name,
                // Calculate expected dollar amount per instrument based on model target weights
                ExpectedAllocations = p.Model.Holdings.Select(h => new
                {
                    Symbol = h.Instrument.Symbol,
                    InstrumentName = h.Instrument.Name,
                    TargetWeight = h.TargetWeight,
                    ExpectedValue = (p.TotalValue - p.CashBalance) * h.TargetWeight / 100,
                    CurrentPrice = h.Instrument.CurrentPrice,
                    ExpectedShares = ((p.TotalValue - p.CashBalance) * h.TargetWeight / 100) / h.Instrument.CurrentPrice
                }).ToList()
            })
            .ToList();

        Console.WriteLine("\nExpected Portfolio Allocations (using Portfolio.TotalValue + Model Holdings):");
        foreach (var portfolio in portfolioInstrumentAllocation.Take(3))
        {
            Console.WriteLine($"\n  Portfolio: {portfolio.PortfolioName} (Owner: {portfolio.OwnerName})");
            Console.WriteLine($"    Model: {portfolio.ModelName}");
            Console.WriteLine($"    Total Value: ${portfolio.TotalValue:N2}");
            Console.WriteLine($"    Cash Balance: ${portfolio.CashBalance:N2}");
            Console.WriteLine($"    Invested Amount: ${portfolio.InvestedAmount:N2}");
            Console.WriteLine("    Expected Instrument Allocations:");
            
            foreach (var allocation in portfolio.ExpectedAllocations)
            {
                Console.WriteLine($"      {allocation.Symbol,-6} ({allocation.TargetWeight,5:N1}%) -> ${allocation.ExpectedValue,12:N2} " +
                                  $"(~{allocation.ExpectedShares,8:N0} shares @ ${allocation.CurrentPrice:N2})");
            }
        }

        // Find portfolios with highest invested percentage (lowest cash percentage)
        var investmentRatios = context.Portfolios
            .Where(p => p.IsActive && p.TotalValue > 0)
            .Select(p => new
            {
                p.Name,
                p.OwnerName,
                p.TotalValue,
                p.CashBalance,
                InvestedAmount = p.TotalValue - p.CashBalance,
                InvestedPercentage = (p.TotalValue - p.CashBalance) / p.TotalValue * 100,
                CashPercentage = p.CashBalance / p.TotalValue * 100,
                ModelName = p.Model.Name
            })
            .OrderByDescending(x => x.InvestedPercentage)
            .ToList();

        Console.WriteLine("\nPortfolios by Investment Ratio (highest invested % first):");
        foreach (var ratio in investmentRatios)
        {
            Console.WriteLine($"  {ratio.Name} ({ratio.OwnerName}) - {ratio.ModelName}");
            Console.WriteLine($"    Total: ${ratio.TotalValue:N2} | Invested: ${ratio.InvestedAmount:N2} ({ratio.InvestedPercentage:N1}%) | " +
                              $"Cash: ${ratio.CashBalance:N2} ({ratio.CashPercentage:N1}%)");
        }

        // Calculate aggregate instrument exposure across all portfolios
        // This shows total dollars allocated to each instrument across all active portfolios
        var aggregateInstrumentExposure = context.Portfolios
            .Where(p => p.IsActive && p.TotalValue > 0)
            .SelectMany(p => p.Model.Holdings.Select(h => new
            {
                Symbol = h.Instrument.Symbol,
                InstrumentName = h.Instrument.Name,
                InstrumentType = h.Instrument.InstrumentType,
                PortfolioInvestedAmount = p.TotalValue - p.CashBalance,
                TargetWeight = h.TargetWeight,
                ExposureAmount = (p.TotalValue - p.CashBalance) * h.TargetWeight / 100
            }))
            .GroupBy(x => new { x.Symbol, x.InstrumentName, x.InstrumentType })
            .Select(g => new
            {
                Symbol = g.Key.Symbol,
                InstrumentName = g.Key.InstrumentName,
                InstrumentType = g.Key.InstrumentType,
                TotalExposure = g.Sum(x => x.ExposureAmount),
                PortfolioCount = g.Count()
            })
            .OrderByDescending(x => x.TotalExposure)
            .ToList();

        Console.WriteLine("\nAggregate Instrument Exposure Across All Portfolios:");
        Console.WriteLine("(Total dollars allocated to each instrument based on Portfolio.TotalValue and Model target weights)");
        
        var totalExposure = aggregateInstrumentExposure.Sum(x => x.TotalExposure);
        foreach (var exposure in aggregateInstrumentExposure)
        {
            var percentOfTotal = (exposure.TotalExposure / totalExposure * 100);
            Console.WriteLine($"  {exposure.Symbol,-6} {exposure.InstrumentType,-6} ${exposure.TotalExposure,12:N2} " +
                              $"({percentOfTotal,5:N2}% of total, {exposure.PortfolioCount} portfolios)");
            Console.WriteLine($"         {exposure.InstrumentName}");
        }
        Console.WriteLine($"\n  TOTAL EXPOSURE: ${totalExposure:N2}");

        // Compare model equity allocation targets vs actual portfolio distribution
        var modelAllocationAnalysis = context.Portfolios
            .Where(p => p.IsActive)
            .Include(p => p.Model)
            .ThenInclude(m => m.ModelGroup)
            .Select(p => new
            {
                PortfolioName = p.Name,
                OwnerName = p.OwnerName,
                TotalValue = p.TotalValue,
                ModelName = p.Model.Name,
                ModelEquityTarget = p.Model.EquityAllocation,
                ModelFixedIncomeTarget = p.Model.FixedIncomeAllocation,
                RiskLevel = p.Model.ModelGroup.RiskLevel,
                CashPercentage = p.CashBalance / p.TotalValue * 100
            })
            .OrderBy(x => x.RiskLevel)
            .ThenByDescending(x => x.TotalValue)
            .ToList();

        Console.WriteLine("\nModel Allocation Analysis (Target vs Portfolio Values):");
        foreach (var analysis in modelAllocationAnalysis)
        {
            Console.WriteLine($"\n  {analysis.PortfolioName} ({analysis.OwnerName}) - Total: ${analysis.TotalValue:N2}");
            Console.WriteLine($"    Model: {analysis.ModelName} ({analysis.RiskLevel} risk)");
            Console.WriteLine($"    Target Allocation: {analysis.ModelEquityTarget:N1}% equity / {analysis.ModelFixedIncomeTarget:N1}% fixed income");
            Console.WriteLine($"    Actual Cash Position: {analysis.CashPercentage:N2}%");
            Console.WriteLine($"    Invested Position: {(100 - analysis.CashPercentage):N2}%");
        }

        // Summary statistics using Portfolio.TotalValue
        var summaryStats = context.Portfolios
            .Where(p => p.IsActive)
            .GroupBy(p => 1) // Group all into one for aggregate stats
            .Select(g => new
            {
                TotalPortfolios = g.Count(),
                TotalValue = g.Sum(p => p.TotalValue),
                TotalCash = g.Sum(p => p.CashBalance),
                TotalInvested = g.Sum(p => p.TotalValue - p.CashBalance),
                AveragePortfolioValue = g.Average(p => p.TotalValue),
                MedianCashBalance = g.OrderBy(p => p.CashBalance).Skip(g.Count() / 2).First().CashBalance,
                LargestPortfolio = g.Max(p => p.TotalValue),
                SmallestPortfolio = g.Min(p => p.TotalValue),
                OverallCashPercentage = g.Sum(p => p.CashBalance) / g.Sum(p => p.TotalValue) * 100,
                OverallInvestedPercentage = g.Sum(p => p.TotalValue - p.CashBalance) / g.Sum(p => p.TotalValue) * 100
            })
            .FirstOrDefault();

        Console.WriteLine("\n=== Portfolio Summary Statistics ===");
        if (summaryStats != null)
        {
            Console.WriteLine($"Total Active Portfolios: {summaryStats.TotalPortfolios}");
            Console.WriteLine($"Total Portfolio Value: ${summaryStats.TotalValue:N2}");
            Console.WriteLine($"Total Cash Balance: ${summaryStats.TotalCash:N2} ({summaryStats.OverallCashPercentage:N2}%)");
            Console.WriteLine($"Total Invested Amount: ${summaryStats.TotalInvested:N2} ({summaryStats.OverallInvestedPercentage:N2}%)");
            Console.WriteLine($"Average Portfolio Value: ${summaryStats.AveragePortfolioValue:N2}");
            Console.WriteLine($"Portfolio Size Range: ${summaryStats.SmallestPortfolio:N2} - ${summaryStats.LargestPortfolio:N2}");
        }

        Console.WriteLine();
    }
}
