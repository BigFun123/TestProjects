# LINQ Demo Project - Portfolio Management System

A comprehensive .NET 8 demonstration project showcasing common LINQ operations using Entity Framework Core with an in-memory database. This training project demonstrates LINQ queries in the context of a financial portfolio management system.

## Project Structure

```
Linq/
├── LinqDemo.csproj          # Project file with EF Core dependencies
├── Program.cs               # Main program with 10 LINQ demonstration methods
├── Models/                  # Domain model classes
│   ├── Instrument.cs        # Financial instruments (stocks, bonds, ETFs)
│   ├── ModelGroup.cs        # Investment model groups (Conservative, Moderate, Aggressive)
│   ├── Model.cs             # Investment models with allocation strategies
│   ├── Holding.cs           # Holdings (instruments within models)
│   └── Portfolio.cs         # Customer portfolios
└── Data/
    └── PortfolioDbContext.cs # EF Core DbContext with seed data
```

## Domain Model

The project models a financial portfolio management system:

- **Instruments**: Financial securities (AAPL, MSFT, SPY, AGG, etc.)
- **Model Groups**: Risk-based groupings (Conservative, Moderate, Aggressive)
- **Models**: Investment strategies with specific asset allocations
- **Holdings**: Positions (instruments) within each model with quantities and weights
- **Portfolios**: Customer accounts that follow specific models

### Relationships

```
ModelGroup (1) ─────< (M) Model
                           │
                           ├───< (M) Holding >──── (M) Instrument
                           │
                           └───< (M) Portfolio
```

## LINQ Operations Demonstrated

### Demo 1: Basic Selection
- Retrieve all records from a table
- Method syntax vs. Query syntax
- Using `ToList()` to execute queries

### Demo 2: Filtering
- `Where()` clause with single and multiple conditions
- Boolean operators (`&&`, `||`)
- Filtering by different data types

### Demo 3: Projection
- `Select()` to transform data
- Creating anonymous types
- Calculated properties
- `SelectMany()` to flatten collections
- `Distinct()` for unique values

### Demo 4: Ordering
- `OrderBy()` and `OrderByDescending()`
- `ThenBy()` and `ThenByDescending()` for secondary sorting
- Multi-level sorting criteria

### Demo 5: Grouping
- `GroupBy()` to group records by key
- Aggregating within groups
- Multiple grouping scenarios

### Demo 6: Aggregation Functions
- `Count()` and conditional count
- `Sum()` for totals
- `Average()` for means
- `Min()` and `Max()` for extremes
- `Any()` and `All()` for existence checks
- `First()` and `FirstOrDefault()`

### Demo 7: Joins
- `Join()` for inner joins
- Multiple table joins
- `GroupJoin()` for left outer joins
- Joining on foreign keys

### Demo 8: Navigation Properties
- Using EF Core navigation properties
- `Include()` and `ThenInclude()` for eager loading
- Accessing related data without explicit joins

### Demo 9: Complex Queries
- Combining multiple LINQ operations
- Nested queries
- Client-side vs. server-side evaluation
- Multi-step transformations

### Demo 10: Total Holdings of a Model
- **Primary Use Case**: Calculate total market value of all instruments in a model
- Demonstrates:
  - Joining Holdings with Instruments
  - Calculating market values (`Quantity * CurrentPrice`)
  - Computing unrealized gains/losses
  - Calculating actual vs. target weights
  - Aggregating values across holdings
  - Finding top performers

### Demo 11: Portfolio-Model Queries
- **Primary Use Case**: Query portfolios directly via ModelId foreign key in Portfolio table
- Demonstrates:
  - Direct Portfolio -> Model relationship without going through Holdings
  - Filtering portfolios by model name or attributes
  - Grouping portfolios by model with statistics
  - Finding portfolios by model group risk level
  - Explicit joins showing the ModelId foreign key relationship
  - Calculating portfolio counts per model
  - Efficiently querying portfolio-model data without touching Holdings table

### Demo 12: Portfolio Total Value with Models and Instruments
- **Primary Use Case**: Calculate holdings and analytics using Portfolio.ModelId and Portfolio.TotalValue
- Demonstrates:
  - Assets under management (AUM) calculations by model
  - Expected portfolio allocations based on model target weights
  - Investment ratios (invested vs. cash percentages)
  - Aggregate instrument exposure across all portfolios
  - Combining Portfolio.TotalValue with Model.Holdings and Instruments
  - Real-world portfolio analytics and reporting
  - Summary statistics using portfolio-level data

## Key LINQ Concepts Illustrated

### Query Execution
- **Deferred Execution**: Queries are not executed until enumerated
- **Immediate Execution**: Using `ToList()`, `Count()`, `First()`, etc.

### Method Syntax vs. Query Syntax
```csharp
// Method syntax (used primarily in this demo)
var results = context.Instruments
    .Where(i => i.CurrentPrice > 100)
    .OrderBy(i => i.Symbol)
    .ToList();

// Query syntax (equivalent)
var results = (from i in context.Instruments
               where i.CurrentPrice > 100
               orderby i.Symbol
               select i).ToList();
```

### Projection Types
- **Anonymous Types**: `new { Name = x.Name, Price = x.Price }`
- **Named Types**: `new InstrumentDto { ... }`
- **Identity Projection**: `select i` (returns the entity as-is)

### Aggregation Patterns
```csharp
// Sum of all values
var total = items.Sum(i => i.Value);

// Average with filter
var avg = items.Where(i => i.IsActive).Average(i => i.Value);

// Group and aggregate
var grouped = items
    .GroupBy(i => i.Category)
    .Select(g => new { Category = g.Key, Total = g.Sum(x => x.Value) });
```

## Running the Demo

### Prerequisites
- .NET 8 SDK

### Steps

1. Navigate to the Linq directory:
   ```cmd
   cd d:\dev\TestProjects\Linq
   ```

2. Restore dependencies:
   ```cmd
   dotnet restore
   ```

3. Run the project:
   ```cmd
   dotnet run
   ```

### Expected Output

The program will execute all 12 demonstrations in sequence, showing:
- Record counts and summaries
- Filtered results
- Projected data transformations
- Sorted results
- Grouped data with aggregates
- Aggregation calculations
- Join results
- Navigation property usage
- Complex query results
- **Total holdings calculations with market values and performance metrics**
- **Portfolio-to-Model queries using the direct foreign key relationship**
- **Portfolio analytics using TotalValue field with models and instruments**

## Sample Seed Data

The in-memory database is seeded with:
- **10 Instruments**: AAPL, MSFT, GOOGL, SPY, AGG, VTI, BND, TSLA, JPM, GLD
- **3 Model Groups**: Conservative, Moderate, Aggressive
- **5 Models**: Various investment strategies from conservative to aggressive
- **21 Holdings**: Instrument allocations across the model with TotalValue ranging from $165K to $250Ks
- **7 Portfolios**: Customer accounts (6 active, 1 closed)

## Learning Points

### LINQ Benefits
- **Type Safety**: Compile-time checking of queries
- **IntelliSense**: Full IDE support for query composition
- **Composability**: Chain operations to build complex queries
- **Readability**: Declarative syntax that expresses intent clearly

### Entity Framework Core Features
- **In-Memory Database**: Perfect for demos and testing
- **Navigation Properties**: Simplify related data access
- **Lazy vs. Eager Loading**: Control when related data is loaded
- **LINQ Provider**: Translates LINQ to SQL (or in-memory operations)

### Common Patterns
1. **Filter-Project-Sort**: `Where() -> Select() -> OrderBy()`
2. **Group-Aggregate**: `GroupBy() -> Select(g => new { Count, Sum, Avg })`
3. **Master-Detail**: `Include() -> ThenInclude()` for related data
4. **Calculated Fields**: Use `Select()` to add computed properties
5. **Financial Calculations**: Sum holdings, calculate returns, weight distributions

## Advanced LINQ Topics (Not Covered)

- `Let` clause in query syntax
- `Zip()` for combining sequences
- `Aggregate()` for custom accumulations
- `SkipWhile()` and `TakeWhile()`
- Custom LINQ operators (extension methods)
- Async LINQ operations (`ToListAsync()`, etc.)
- Compiled queries for performance

## Next Steps

To extend your learning:

1. **Add More Queries**: Try writing queries for:
   - Finding portfolios with highest returns
   - Calculating asset allocation across all portfolios
   - Finding over/under-weighted holdings
   - Ranking instruments by popularity

2. **Add Business Logic**: Implement methods for:
   - Rebalancing portfolios to target weights
   - Risk scoring based on allocations
   - Performance attribution

3. **Switch to SQL Server**: Replace the in-memory provider with SQL Server and observe the SQL generated

4. **Add Async Operations**: Convert synchronous LINQ to async (`ToListAsync()`, etc.)

5. **Implement Repository Pattern**: Abstract data access behind repositories

## Resources

- [LINQ Documentation](https://learn.microsoft.com/en-us/dotnet/csharp/linq/)
- [Entity Framework Core Documentation](https://learn.microsoft.com/en-us/ef/core/)
- [101 LINQ Samples](https://learn.microsoft.com/en-us/samples/dotnet/try-samples/101-linq-samples/)

## License

This is a training/demo project for educational purposes.
