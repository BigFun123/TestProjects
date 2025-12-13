-- Query to retrieve historical model values for graphing
-- Server: money
-- Parameters: @ModelId, @StartDate (optional), @EndDate (optional)

DECLARE @ModelId INT = 1; -- Replace with actual ModelId
DECLARE @StartDate DATE = DATEADD(DAY, -30, GETDATE()); -- Default: last 30 days
DECLARE @EndDate DATE = GETDATE(); -- Default: today

-- Get historical values for a specific model
SELECT 
    ModelId,
    ValueDate,
    TotalValue,
    CreatedAt
FROM 
    ModelValueHistory
WHERE 
    ModelId = @ModelId
    AND ValueDate BETWEEN @StartDate AND @EndDate
ORDER BY 
    ValueDate ASC;
