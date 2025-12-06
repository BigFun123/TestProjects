-- for a financial graph
-- from a table named 'ModelDailyTotal' with columns 'Date' (Date), ModelId, and 'Balance' (decimal) 
-- that has daily total Balance records for a financial model
-- get the daily total Balances for a specific ModelId within a given Date range
-- and return the results ordered by Date
-- the function should return data based on an input parameter for ModelId, and daily, weekly, monthly, or yearly totals
-- @Period parameter values: 'daily', 'weekly', 'monthly', 'yearly'

DECLARE @Period NVARCHAR(10) = 'daily'; -- Change this to 'daily', 'weekly', 'monthly', or 'yearly'
DECLARE @ModelId UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000000'; -- Replace with your ModelId
DECLARE @StartDate DATE = '2025-01-01'; -- Replace with your start date
DECLARE @EndDate DATE = '2025-12-31'; -- Replace with your end date

SELECT 
    CASE 
        WHEN @Period = 'daily' THEN [Date]
        WHEN @Period = 'weekly' THEN DateADD(day, -(DatePART(weekday, [Date]) - 1), [Date])
        WHEN @Period = 'monthly' THEN DateFROMPARTS(YEAR([Date]), MONTH([Date]), 1)
        WHEN @Period = 'yearly' THEN DateFROMPARTS(YEAR([Date]), 1, 1)
    END AS [period_Date],
    SUM([Balance]) AS [Balance]
FROM 
    ModelDailyTotal
WHERE 
    ModelId = @ModelId
    AND [Date] BETWEEN @StartDate AND @EndDate
GROUP BY 
    CASE 
        WHEN @Period = 'daily' THEN [Date]
        WHEN @Period = 'weekly' THEN DateADD(day, -(DatePART(weekday, [Date]) - 1), [Date])
        WHEN @Period = 'monthly' THEN DateFROMPARTS(YEAR([Date]), MONTH([Date]), 1)
        WHEN @Period = 'yearly' THEN DateFROMPARTS(YEAR([Date]), 1, 1)
    END
ORDER BY 
    [period_Date] ASC;