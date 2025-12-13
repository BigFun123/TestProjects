# Model Value History Queries

This folder contains SQL queries for tracking and graphing total model holdings over time in a financial application.

## Overview

The system calculates the total value of a model by:
1. Getting all portfolios associated with the model via the model group
2. Applying portfolio weights (which sum to 1.0)
3. Summing instrument values from each portfolio
4. Storing daily snapshots for historical tracking

## Architecture

- **Server "money"**: Contains model, model group, and portfolio tables
- **Server "ios"**: Contains portfolio-instrument mappings and instrument values
- **Linked Server**: The queries use a linked server connection from "money" to "ios"

## Setup Instructions

### 1. Create History Table
Run `create_history_table.sql` once to create the `ModelValueHistory` table on the "money" server.

### 2. Set Up Daily Job
Run `setup_scheduled_job.sql` to create a SQL Server Agent job that runs daily at 6 PM. 
- Update `@database_name` with your actual database name
- Adjust the schedule time if needed

### 3. Configure Linked Server (if not already set up)
```sql
-- Example linked server setup
EXEC sp_addlinkedserver 
    @server='ios',
    @srvproduct='',
    @provider='SQLNCLI', 
    @datasrc='ios_server_name';
```

## Query Files

### Core Queries

- **`create_history_table.sql`**: Creates the table to store daily model value snapshots
- **`calculate_daily_model_values.sql`**: Daily query to calculate and store current model values
- **`calculate_current_model_value.sql`**: Ad-hoc query to get current value without storing

### Graphing Queries

- **`get_model_history_for_graph.sql`**: Retrieves historical values for a specific model
- **`get_all_models_history.sql`**: Retrieves historical values for all models (comparison graphs)

### Automation

- **`setup_scheduled_job.sql`**: Creates SQL Server Agent job for daily execution

## Usage Examples

### Getting Data for a Single Model Graph
```sql
-- Get last 90 days for model #5
DECLARE @ModelId INT = 5;
DECLARE @StartDate DATE = DATEADD(DAY, -90, GETDATE());
DECLARE @EndDate DATE = GETDATE();

SELECT ValueDate, TotalValue
FROM ModelValueHistory
WHERE ModelId = @ModelId
  AND ValueDate BETWEEN @StartDate AND @EndDate
ORDER BY ValueDate ASC;
```

### Checking Today's Values
```sql
SELECT ModelId, TotalValue, CreatedAt
FROM ModelValueHistory
WHERE ValueDate = CAST(GETDATE() AS DATE)
ORDER BY ModelId;
```

### Manual Daily Run (Testing)
Execute `calculate_daily_model_values.sql` to manually run today's calculation.

## Data Model

### ModelValueHistory Table
| Column | Type | Description |
|--------|------|-------------|
| HistoryId | INT IDENTITY | Primary key |
| ModelId | INT | Reference to Model table |
| ValueDate | DATE | Date of the snapshot |
| TotalValue | DECIMAL(18,2) | Total model value |
| CreatedAt | DATETIME2 | Timestamp of when record was created |

### Calculation Logic
```
TotalModelValue = SUM(PortfolioWeight × InstrumentValue)
```
For each model:
- Join through ModelGroup to get all portfolios and their weights
- For each portfolio, sum all instrument values from the "ios" server
- Multiply by the portfolio weight
- Sum across all portfolios

## Notes

- Portfolio weights should add up to 1.0 for each model
- The system prevents duplicate entries for the same model and date
- Historical data enables trend analysis and performance tracking
- Indexes are created for efficient querying by model and date range
