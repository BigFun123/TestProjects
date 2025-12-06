-- Stored procedure version of getdailytotals.sql
-- For a financial graph
-- From a table named 'ModelDailyTotal' with columns 'Date' (Date), ModelId, and 'Balance' (decimal) 
-- that has daily total Balance records for a financial model
-- Get the daily total Balances for a specific ModelId within a given Date range
-- and return the results ordered by Date
-- @Period parameter values: 'daily', 'weekly', 'monthly', 'yearly'

--TODO: A more accurate way is to take the pixel width of the graph and divide the date range by that to get the number of data points needed

CREATE OR ALTER PROCEDURE dbo.GetDailyTotals
    @Period NVARCHAR(10),
    @ModelId UNIQUEIDENTIFIER,
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        CASE 
            WHEN @Period = 'daily' THEN [Date]
            WHEN @Period = 'weekly' THEN DateADD(day, -(DatePART(weekday, [Date]) - 1), [Date])
            WHEN @Period = 'monthly' THEN DateFROMPARTS(YEAR([Date]), MONTH([Date]), 1)
            WHEN @Period = 'yearly' THEN DateFROMPARTS(YEAR([Date]), 1, 1)
        END AS [period_Date],
        MAX([Balance]) AS [Balance] -- MAX, AVG, MIN, depending on requirements. MAX gives consistent graphs
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
END;
GO

-- Example usage:
-- EXEC dbo.GetDailyTotals 
--     @Period = 'daily', 
--     @ModelId = '00000000-0000-0000-0000-000000000000', 
--     @StartDate = '2025-01-01', 
--     @EndDate = '2025-12-31';
