-- Query to retrieve historical values for all models (useful for comparison graphs)
-- Server: money
-- Parameters: @StartDate (optional), @EndDate (optional)

DECLARE @StartDate DATE = DATEADD(DAY, -30, GETDATE()); -- Default: last 30 days
DECLARE @EndDate DATE = GETDATE(); -- Default: today

-- Get historical values for all models
SELECT 
    mvh.ModelId,
    mvh.ValueDate,
    mvh.TotalValue,
    mvh.CreatedAt,
    -- Optional: Include model name if Model table has a Name column
    -- m.ModelName,
    COUNT(*) OVER (PARTITION BY mvh.ModelId) as DataPointCount
FROM 
    ModelValueHistory mvh
    -- INNER JOIN Model m ON mvh.ModelId = m.ModelId
WHERE 
    mvh.ValueDate BETWEEN @StartDate AND @EndDate
ORDER BY 
    mvh.ModelId, mvh.ValueDate ASC;
