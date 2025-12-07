-- =============================================
-- Pagination with Date Ranges and Time Periods
-- =============================================
-- These queries demonstrate pagination combined with date filtering
-- Common in reporting, analytics, and time-based data retrieval

-- =============================================
-- Example 1: Pagination with Simple Date Range
-- =============================================

DECLARE @PageNumber INT = 1;
DECLARE @PageSize INT = 10;
DECLARE @StartDate DATE = '2024-01-01';
DECLARE @EndDate DATE = '2024-12-31';

SELECT 
    OrderID,
    CustomerID,
    OrderDate,
    TotalAmount,
    Status,
    COUNT(*) OVER() AS TotalRecords
FROM Orders
WHERE OrderDate >= @StartDate 
    AND OrderDate < DATEADD(DAY, 1, @EndDate) -- Include entire end date
ORDER BY OrderDate DESC, OrderID DESC
OFFSET (@PageNumber - 1) * @PageSize ROWS
FETCH NEXT @PageSize ROWS ONLY;

GO

-- =============================================
-- Example 2: Pagination for Current Month
-- =============================================

DECLARE @PageNumber INT = 1;
DECLARE @PageSize INT = 25;

SELECT 
    TransactionID,
    AccountID,
    TransactionDate,
    Amount,
    TransactionType,
    COUNT(*) OVER() AS TotalRecords
FROM Transactions
WHERE TransactionDate >= DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1) -- First day of current month
    AND TransactionDate < DATEFROMPARTS(YEAR(DATEADD(MONTH, 1, GETDATE())), MONTH(DATEADD(MONTH, 1, GETDATE())), 1) -- First day of next month
ORDER BY TransactionDate DESC
OFFSET (@PageNumber - 1) * @PageSize ROWS
FETCH NEXT @PageSize ROWS ONLY;

GO

-- =============================================
-- Example 3: Pagination for Last N Days
-- =============================================

DECLARE @PageNumber INT = 1;
DECLARE @PageSize INT = 20;
DECLARE @DaysBack INT = 30;

SELECT 
    OrderID,
    CustomerID,
    OrderDate,
    TotalAmount,
    COUNT(*) OVER() AS TotalRecords
FROM Orders
WHERE OrderDate >= DATEADD(DAY, -@DaysBack, CAST(GETDATE() AS DATE))
    AND OrderDate < DATEADD(DAY, 1, CAST(GETDATE() AS DATE))
ORDER BY OrderDate DESC
OFFSET (@PageNumber - 1) * @PageSize ROWS
FETCH NEXT @PageSize ROWS ONLY;

GO

-- =============================================
-- Example 4: Pagination by Year and Month
-- =============================================

CREATE OR ALTER PROCEDURE sp_GetOrdersByYearMonth
    @Year INT,
    @Month INT,
    @PageNumber INT = 1,
    @PageSize INT = 10
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validate parameters
    IF @Month < 1 OR @Month > 12
    BEGIN
        RAISERROR('Month must be between 1 and 12', 16, 1);
        RETURN;
    END
    
    DECLARE @StartDate DATE = DATEFROMPARTS(@Year, @Month, 1);
    DECLARE @EndDate DATE = DATEADD(MONTH, 1, @StartDate);
    
    SELECT 
        OrderID,
        CustomerID,
        OrderDate,
        TotalAmount,
        Status,
        COUNT(*) OVER() AS TotalRecords,
        SUM(TotalAmount) OVER() AS MonthTotal
    FROM Orders
    WHERE OrderDate >= @StartDate 
        AND OrderDate < @EndDate
    ORDER BY OrderDate DESC
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END;
GO

-- Test the procedure
EXEC sp_GetOrdersByYearMonth @Year = 2024, @Month = 6, @PageNumber = 1, @PageSize = 15;
GO

-- =============================================
-- Example 5: Pagination with Quarter Filter
-- =============================================

DECLARE @PageNumber INT = 1;
DECLARE @PageSize INT = 25;
DECLARE @Year INT = 2024;
DECLARE @Quarter INT = 2; -- Q2

DECLARE @StartDate DATE = DATEFROMPARTS(@Year, (@Quarter - 1) * 3 + 1, 1);
DECLARE @EndDate DATE = DATEADD(QUARTER, 1, @StartDate);

SELECT 
    SaleID,
    ProductID,
    SaleDate,
    Quantity,
    Revenue,
    COUNT(*) OVER() AS TotalRecords,
    SUM(Revenue) OVER() AS QuarterRevenue
FROM Sales
WHERE SaleDate >= @StartDate 
    AND SaleDate < @EndDate
ORDER BY SaleDate DESC
OFFSET (@PageNumber - 1) * @PageSize ROWS
FETCH NEXT @PageSize ROWS ONLY;

GO

-- =============================================
-- Example 6: Pagination with Date Range and Time
-- =============================================

DECLARE @PageNumber INT = 1;
DECLARE @PageSize INT = 50;
DECLARE @StartDateTime DATETIME = '2024-06-01 08:00:00';
DECLARE @EndDateTime DATETIME = '2024-06-01 17:00:00';

SELECT 
    LogID,
    UserID,
    Action,
    LogTimestamp,
    Details,
    COUNT(*) OVER() AS TotalRecords
FROM ActivityLogs
WHERE LogTimestamp >= @StartDateTime 
    AND LogTimestamp <= @EndDateTime
ORDER BY LogTimestamp DESC
OFFSET (@PageNumber - 1) * @PageSize ROWS
FETCH NEXT @PageSize ROWS ONLY;

GO

-- =============================================
-- Example 7: Pagination with Relative Date Ranges
-- =============================================

CREATE OR ALTER PROCEDURE sp_GetTransactionsByPeriod
    @Period NVARCHAR(20), -- 'TODAY', 'YESTERDAY', 'THIS_WEEK', 'LAST_WEEK', 'THIS_MONTH', 'LAST_MONTH'
    @PageNumber INT = 1,
    @PageSize INT = 10
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @StartDate DATETIME;
    DECLARE @EndDate DATETIME;
    
    -- Calculate date range based on period
    IF @Period = 'TODAY'
    BEGIN
        SET @StartDate = CAST(GETDATE() AS DATE);
        SET @EndDate = DATEADD(DAY, 1, @StartDate);
    END
    ELSE IF @Period = 'YESTERDAY'
    BEGIN
        SET @StartDate = DATEADD(DAY, -1, CAST(GETDATE() AS DATE));
        SET @EndDate = CAST(GETDATE() AS DATE);
    END
    ELSE IF @Period = 'THIS_WEEK'
    BEGIN
        SET @StartDate = DATEADD(DAY, 1 - DATEPART(WEEKDAY, GETDATE()), CAST(GETDATE() AS DATE));
        SET @EndDate = DATEADD(DAY, 1, CAST(GETDATE() AS DATE));
    END
    ELSE IF @Period = 'LAST_WEEK'
    BEGIN
        SET @StartDate = DATEADD(DAY, 1 - DATEPART(WEEKDAY, GETDATE()) - 7, CAST(GETDATE() AS DATE));
        SET @EndDate = DATEADD(DAY, 7, @StartDate);
    END
    ELSE IF @Period = 'THIS_MONTH'
    BEGIN
        SET @StartDate = DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1);
        SET @EndDate = DATEADD(DAY, 1, CAST(GETDATE() AS DATE));
    END
    ELSE IF @Period = 'LAST_MONTH'
    BEGIN
        SET @StartDate = DATEADD(MONTH, -1, DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1));
        SET @EndDate = DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1);
    END
    ELSE
    BEGIN
        RAISERROR('Invalid period. Valid values: TODAY, YESTERDAY, THIS_WEEK, LAST_WEEK, THIS_MONTH, LAST_MONTH', 16, 1);
        RETURN;
    END
    
    SELECT 
        TransactionID,
        AccountID,
        TransactionDate,
        Amount,
        TransactionType,
        Description,
        COUNT(*) OVER() AS TotalRecords,
        @Period AS Period,
        @StartDate AS PeriodStart,
        @EndDate AS PeriodEnd
    FROM Transactions
    WHERE TransactionDate >= @StartDate 
        AND TransactionDate < @EndDate
    ORDER BY TransactionDate DESC
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END;
GO

-- Test the procedure
EXEC sp_GetTransactionsByPeriod @Period = 'THIS_MONTH', @PageNumber = 1, @PageSize = 20;
GO

-- =============================================
-- Example 8: Pagination with Date Bucketing
-- =============================================
-- Group data by date periods while paginating

DECLARE @PageNumber INT = 1;
DECLARE @PageSize INT = 10;
DECLARE @StartDate DATE = '2024-01-01';
DECLARE @EndDate DATE = '2024-12-31';

WITH DailyAggregates AS (
    SELECT 
        CAST(OrderDate AS DATE) AS OrderDay,
        COUNT(*) AS OrderCount,
        SUM(TotalAmount) AS DailyRevenue,
        AVG(TotalAmount) AS AvgOrderValue
    FROM Orders
    WHERE OrderDate >= @StartDate 
        AND OrderDate < DATEADD(DAY, 1, @EndDate)
    GROUP BY CAST(OrderDate AS DATE)
)
SELECT 
    OrderDay,
    OrderCount,
    DailyRevenue,
    AvgOrderValue,
    COUNT(*) OVER() AS TotalDays
FROM DailyAggregates
ORDER BY OrderDay DESC
OFFSET (@PageNumber - 1) * @PageSize ROWS
FETCH NEXT @PageSize ROWS ONLY;

GO

-- =============================================
-- Example 9: Pagination with Business Days Only
-- =============================================

DECLARE @PageNumber INT = 1;
DECLARE @PageSize INT = 15;
DECLARE @StartDate DATE = '2024-01-01';
DECLARE @EndDate DATE = '2024-12-31';

SELECT 
    TransactionID,
    TransactionDate,
    Amount,
    COUNT(*) OVER() AS TotalRecords
FROM Transactions
WHERE TransactionDate >= @StartDate 
    AND TransactionDate < DATEADD(DAY, 1, @EndDate)
    AND DATEPART(WEEKDAY, TransactionDate) NOT IN (1, 7) -- Exclude Sunday(1) and Saturday(7)
ORDER BY TransactionDate DESC
OFFSET (@PageNumber - 1) * @PageSize ROWS
FETCH NEXT @PageSize ROWS ONLY;

GO
