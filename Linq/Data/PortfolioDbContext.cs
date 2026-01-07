using Microsoft.EntityFrameworkCore;
using LinqDemo.Models;

namespace LinqDemo.Data;

/// <summary>
/// Database context for the portfolio management system
/// </summary>
public class PortfolioDbContext : DbContext
{
    /// <summary>
    /// Collection of instruments (stocks, bonds, ETFs)
    /// </summary>
    public DbSet<Instrument> Instruments { get; set; } = null!;

    /// <summary>
    /// Collection of model groups
    /// </summary>
    public DbSet<ModelGroup> ModelGroups { get; set; } = null!;

    /// <summary>
    /// Collection of investment models
    /// </summary>
    public DbSet<Model> Models { get; set; } = null!;

    /// <summary>
    /// Collection of holdings (instrument positions within models)
    /// </summary>
    public DbSet<Holding> Holdings { get; set; } = null!;

    /// <summary>
    /// Collection of portfolios
    /// </summary>
    public DbSet<Portfolio> Portfolios { get; set; } = null!;

    /// <summary>
    /// Configure the database to use in-memory database for this demo
    /// </summary>
    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
    {
        // Using InMemory database for demo purposes - no need for actual SQL Server
        optionsBuilder.UseInMemoryDatabase("PortfolioDB");
    }

    /// <summary>
    /// Configure entity relationships and seed initial data
    /// </summary>
    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Configure decimal precision for financial calculations
        modelBuilder.Entity<Instrument>()
            .Property(i => i.CurrentPrice)
            .HasPrecision(18, 4);

        modelBuilder.Entity<Holding>()
            .Property(h => h.Quantity)
            .HasPrecision(18, 4);

        modelBuilder.Entity<Holding>()
            .Property(h => h.TargetWeight)
            .HasPrecision(5, 2);

        modelBuilder.Entity<Holding>()
            .Property(h => h.CostBasis)
            .HasPrecision(18, 4);

        modelBuilder.Entity<Portfolio>()
            .Property(p => p.CashBalance)
            .HasPrecision(18, 2);

        modelBuilder.Entity<Portfolio>()
            .Property(p => p.TotalValue)
            .HasPrecision(18, 2);

        // Configure relationships
        modelBuilder.Entity<Model>()
            .HasOne(m => m.ModelGroup)
            .WithMany(mg => mg.Models)
            .HasForeignKey(m => m.ModelGroupId);

        modelBuilder.Entity<Holding>()
            .HasOne(h => h.Model)
            .WithMany(m => m.Holdings)
            .HasForeignKey(h => h.ModelId);

        modelBuilder.Entity<Holding>()
            .HasOne(h => h.Instrument)
            .WithMany(i => i.Holdings)
            .HasForeignKey(h => h.InstrumentId);

        modelBuilder.Entity<Portfolio>()
            .HasOne(p => p.Model)
            .WithMany(m => m.Portfolios)
            .HasForeignKey(p => p.ModelId);

        // Seed data - Instruments
        modelBuilder.Entity<Instrument>().HasData(
            new Instrument { Id = 1, Symbol = "AAPL", Name = "Apple Inc.", InstrumentType = "Stock", CurrentPrice = 175.50m, Currency = "USD" },
            new Instrument { Id = 2, Symbol = "MSFT", Name = "Microsoft Corporation", InstrumentType = "Stock", CurrentPrice = 378.25m, Currency = "USD" },
            new Instrument { Id = 3, Symbol = "GOOGL", Name = "Alphabet Inc.", InstrumentType = "Stock", CurrentPrice = 140.75m, Currency = "USD" },
            new Instrument { Id = 4, Symbol = "SPY", Name = "SPDR S&P 500 ETF", InstrumentType = "ETF", CurrentPrice = 450.00m, Currency = "USD" },
            new Instrument { Id = 5, Symbol = "AGG", Name = "iShares Core US Aggregate Bond ETF", InstrumentType = "ETF", CurrentPrice = 103.50m, Currency = "USD" },
            new Instrument { Id = 6, Symbol = "VTI", Name = "Vanguard Total Stock Market ETF", InstrumentType = "ETF", CurrentPrice = 235.80m, Currency = "USD" },
            new Instrument { Id = 7, Symbol = "BND", Name = "Vanguard Total Bond Market ETF", InstrumentType = "ETF", CurrentPrice = 76.25m, Currency = "USD" },
            new Instrument { Id = 8, Symbol = "TSLA", Name = "Tesla Inc.", InstrumentType = "Stock", CurrentPrice = 242.50m, Currency = "USD" },
            new Instrument { Id = 9, Symbol = "JPM", Name = "JPMorgan Chase & Co.", InstrumentType = "Stock", CurrentPrice = 158.75m, Currency = "USD" },
            new Instrument { Id = 10, Symbol = "GLD", Name = "SPDR Gold Trust", InstrumentType = "ETF", CurrentPrice = 188.90m, Currency = "USD" }
        );

        // Seed data - Model Groups
        modelBuilder.Entity<ModelGroup>().HasData(
            new ModelGroup { Id = 1, Name = "Conservative", Description = "Low-risk, income-focused strategies", RiskLevel = "Low" },
            new ModelGroup { Id = 2, Name = "Moderate", Description = "Balanced growth and income", RiskLevel = "Medium" },
            new ModelGroup { Id = 3, Name = "Aggressive", Description = "High-growth, equity-focused strategies", RiskLevel = "High" }
        );

        // Seed data - Models
        modelBuilder.Entity<Model>().HasData(
            new Model { Id = 1, Name = "Conservative Income", Description = "70% bonds, 30% equities", EquityAllocation = 30m, FixedIncomeAllocation = 70m, ModelGroupId = 1 },
            new Model { Id = 2, Name = "Balanced Growth", Description = "60% equities, 40% bonds", EquityAllocation = 60m, FixedIncomeAllocation = 40m, ModelGroupId = 2 },
            new Model { Id = 3, Name = "Growth Portfolio", Description = "80% equities, 20% bonds", EquityAllocation = 80m, FixedIncomeAllocation = 20m, ModelGroupId = 2 },
            new Model { Id = 4, Name = "Aggressive Growth", Description = "95% equities, 5% bonds", EquityAllocation = 95m, FixedIncomeAllocation = 5m, ModelGroupId = 3 },
            new Model { Id = 5, Name = "Tech-Focused Growth", Description = "100% technology stocks", EquityAllocation = 100m, FixedIncomeAllocation = 0m, ModelGroupId = 3 }
        );

        // Seed data - Holdings (Model 1: Conservative Income)
        modelBuilder.Entity<Holding>().HasData(
            new Holding { Id = 1, ModelId = 1, InstrumentId = 5, Quantity = 500m, TargetWeight = 50m, CostBasis = 102.00m }, // AGG
            new Holding { Id = 2, ModelId = 1, InstrumentId = 7, Quantity = 300m, TargetWeight = 20m, CostBasis = 75.50m },  // BND
            new Holding { Id = 3, ModelId = 1, InstrumentId = 4, Quantity = 150m, TargetWeight = 20m, CostBasis = 445.00m }, // SPY
            new Holding { Id = 4, ModelId = 1, InstrumentId = 10, Quantity = 50m, TargetWeight = 10m, CostBasis = 185.00m }  // GLD
        );

        // Seed data - Holdings (Model 2: Balanced Growth)
        modelBuilder.Entity<Holding>().HasData(
            new Holding { Id = 5, ModelId = 2, InstrumentId = 6, Quantity = 400m, TargetWeight = 40m, CostBasis = 230.00m },  // VTI
            new Holding { Id = 6, ModelId = 2, InstrumentId = 4, Quantity = 200m, TargetWeight = 20m, CostBasis = 440.00m },  // SPY
            new Holding { Id = 7, ModelId = 2, InstrumentId = 5, Quantity = 300m, TargetWeight = 30m, CostBasis = 101.50m },  // AGG
            new Holding { Id = 8, ModelId = 2, InstrumentId = 7, Quantity = 150m, TargetWeight = 10m, CostBasis = 76.00m }    // BND
        );

        // Seed data - Holdings (Model 3: Growth Portfolio)
        modelBuilder.Entity<Holding>().HasData(
            new Holding { Id = 9, ModelId = 3, InstrumentId = 6, Quantity = 500m, TargetWeight = 50m, CostBasis = 228.00m },  // VTI
            new Holding { Id = 10, ModelId = 3, InstrumentId = 1, Quantity = 200m, TargetWeight = 20m, CostBasis = 165.00m }, // AAPL
            new Holding { Id = 11, ModelId = 3, InstrumentId = 2, Quantity = 50m, TargetWeight = 10m, CostBasis = 360.00m },  // MSFT
            new Holding { Id = 12, ModelId = 3, InstrumentId = 5, Quantity = 200m, TargetWeight = 20m, CostBasis = 102.50m }  // AGG
        );

        // Seed data - Holdings (Model 4: Aggressive Growth)
        modelBuilder.Entity<Holding>().HasData(
            new Holding { Id = 13, ModelId = 4, InstrumentId = 1, Quantity = 400m, TargetWeight = 30m, CostBasis = 160.00m }, // AAPL
            new Holding { Id = 14, ModelId = 4, InstrumentId = 2, Quantity = 200m, TargetWeight = 30m, CostBasis = 355.00m }, // MSFT
            new Holding { Id = 15, ModelId = 4, InstrumentId = 8, Quantity = 300m, TargetWeight = 30m, CostBasis = 220.00m }, // TSLA
            new Holding { Id = 16, ModelId = 4, InstrumentId = 7, Quantity = 100m, TargetWeight = 5m, CostBasis = 76.50m },   // BND
            new Holding { Id = 17, ModelId = 4, InstrumentId = 3, Quantity = 50m, TargetWeight = 5m, CostBasis = 135.00m }    // GOOGL
        );

        // Seed data - Holdings (Model 5: Tech-Focused Growth)
        modelBuilder.Entity<Holding>().HasData(
            new Holding { Id = 18, ModelId = 5, InstrumentId = 1, Quantity = 300m, TargetWeight = 25m, CostBasis = 162.00m }, // AAPL
            new Holding { Id = 19, ModelId = 5, InstrumentId = 2, Quantity = 150m, TargetWeight = 25m, CostBasis = 358.00m }, // MSFT
            new Holding { Id = 20, ModelId = 5, InstrumentId = 3, Quantity = 200m, TargetWeight = 25m, CostBasis = 138.00m }, // GOOGL
            new Holding { Id = 21, ModelId = 5, InstrumentId = 8, Quantity = 250m, TargetWeight = 25m, CostBasis = 225.00m }  // TSLA
        );

        // Seed data - Portfolios
        modelBuilder.Entity<Portfolio>().HasData(
            new Portfolio { Id = 1, Name = "John's Retirement", OwnerName = "John Smith", CreatedDate = new DateTime(2020, 1, 15), CashBalance = 15000m, TotalValue = 165000m, ModelId = 1, IsActive = true },
            new Portfolio { Id = 2, Name = "Sarah's 401k", OwnerName = "Sarah Johnson", CreatedDate = new DateTime(2019, 6, 1), CashBalance = 25000m, TotalValue = 250000m, ModelId = 2, IsActive = true },
            new Portfolio { Id = 3, Name = "Mike's Investment", OwnerName = "Mike Williams", CreatedDate = new DateTime(2021, 3, 10), CashBalance = 8000m, TotalValue = 200000m, ModelId = 3, IsActive = true },
            new Portfolio { Id = 4, Name = "Emily's Growth", OwnerName = "Emily Brown", CreatedDate = new DateTime(2022, 7, 20), CashBalance = 5000m, TotalValue = 238000m, ModelId = 4, IsActive = true },
            new Portfolio { Id = 5, Name = "Tech Portfolio", OwnerName = "David Lee", CreatedDate = new DateTime(2023, 1, 5), CashBalance = 12000m, TotalValue = 210000m, ModelId = 5, IsActive = true },
            new Portfolio { Id = 6, Name = "Jane's Savings", OwnerName = "Jane Davis", CreatedDate = new DateTime(2018, 11, 12), CashBalance = 20000m, TotalValue = 171000m, ModelId = 1, IsActive = true },
            new Portfolio { Id = 7, Name = "Closed Account", OwnerName = "Bob Wilson", CreatedDate = new DateTime(2015, 5, 1), CashBalance = 0m, TotalValue = 0m, ModelId = 2, IsActive = false }
        );
    }
}
