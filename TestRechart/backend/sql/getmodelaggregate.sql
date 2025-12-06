USE [scratch]
GO
/****** Object:  StoredProcedure [dbo].[GetDailyTotals]    Script Date: 2025/12/06 19:55:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Stored procedure version of getdailytotals.sql
-- For a financial graph
-- From a table named 'ModelDailyTotal' with columns 'Date' (Date), ModelId, and 'Balance' (decimal) 
-- that has daily total Balance records for a financial model
-- Get the daily total Balances for a specific ModelId within a given Date range
-- and return the results ordered by Date
-- @Period parameter values: 'daily', 'weekly', 'monthly', 'yearly'

ALTER   PROCEDURE [dbo].[GetDailyTotals]
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
        MAX([Balance]) AS [Balance]
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
