-- =============================================
-- Time Series - Revenue and Growth Trends
-- =============================================
-- For line and area charts showing revenue over time with growth rates

-- Daily revenue with moving average
SELECT 
    CAST(TransactionDate AS DATE) as Date,
    SUM(ProcessingFee) as DailyRevenue,
    COUNT(*) as TransactionCount,
    AVG(SUM(ProcessingFee)) OVER (ORDER BY CAST(TransactionDate AS DATE) 
                                   ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as MA7Revenue,
    AVG(SUM(ProcessingFee)) OVER (ORDER BY CAST(TransactionDate AS DATE) 
                                   ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) as MA30Revenue
FROM Transactions
WHERE TransactionDate >= DATEADD(DAY, -90, GETDATE())
    AND Status = 'Completed'
GROUP BY CAST(TransactionDate AS DATE)
ORDER BY Date;

-- Monthly revenue with year-over-year comparison
SELECT 
    DATEFROMPARTS(DATEPART(YEAR, TransactionDate), DATEPART(MONTH, TransactionDate), 1) as Month,
    SUM(ProcessingFee) as Revenue,
    COUNT(*) as TransactionCount,
    COUNT(DISTINCT AccountID) as UniqueCustomers,
    LAG(SUM(ProcessingFee), 12) OVER (ORDER BY DATEFROMPARTS(DATEPART(YEAR, TransactionDate), DATEPART(MONTH, TransactionDate), 1)) as SameMonthLastYear,
    CAST((SUM(ProcessingFee) - LAG(SUM(ProcessingFee), 12) OVER (ORDER BY DATEFROMPARTS(DATEPART(YEAR, TransactionDate), DATEPART(MONTH, TransactionDate), 1))) * 100.0 / 
         NULLIF(LAG(SUM(ProcessingFee), 12) OVER (ORDER BY DATEFROMPARTS(DATEPART(YEAR, TransactionDate), DATEPART(MONTH, TransactionDate), 1)), 0) AS DECIMAL(10,2)) as YoYGrowthPercent
FROM Transactions
WHERE TransactionDate >= DATEADD(MONTH, -24, GETDATE())
    AND Status = 'Completed'
GROUP BY DATEFROMPARTS(DATEPART(YEAR, TransactionDate), DATEPART(MONTH, TransactionDate), 1)
ORDER BY Month;

-- Month-over-month growth rate
SELECT 
    DATEFROMPARTS(DATEPART(YEAR, TransactionDate), DATEPART(MONTH, TransactionDate), 1) as Month,
    SUM(ProcessingFee) as Revenue,
    LAG(SUM(ProcessingFee)) OVER (ORDER BY DATEFROMPARTS(DATEPART(YEAR, TransactionDate), DATEPART(MONTH, TransactionDate), 1)) as PreviousMonthRevenue,
    CAST((SUM(ProcessingFee) - LAG(SUM(ProcessingFee)) OVER (ORDER BY DATEFROMPARTS(DATEPART(YEAR, TransactionDate), DATEPART(MONTH, TransactionDate), 1))) * 100.0 / 
         NULLIF(LAG(SUM(ProcessingFee)) OVER (ORDER BY DATEFROMPARTS(DATEPART(YEAR, TransactionDate), DATEPART(MONTH, TransactionDate), 1)), 0) AS DECIMAL(10,2)) as MoMGrowthPercent
FROM Transactions
WHERE TransactionDate >= DATEADD(MONTH, -12, GETDATE())
    AND Status = 'Completed'
GROUP BY DATEFROMPARTS(DATEPART(YEAR, TransactionDate), DATEPART(MONTH, TransactionDate), 1)
ORDER BY Month;

-- Cumulative revenue over time
SELECT 
    CAST(TransactionDate AS DATE) as Date,
    SUM(ProcessingFee) as DailyRevenue,
    SUM(SUM(ProcessingFee)) OVER (ORDER BY CAST(TransactionDate AS DATE)) as CumulativeRevenue
FROM Transactions
WHERE TransactionDate >= DATEADD(MONTH, -12, GETDATE())
    AND Status = 'Completed'
GROUP BY CAST(TransactionDate AS DATE)
ORDER BY Date;

-- Revenue by transaction type over time (stacked area chart)
SELECT 
    CAST(TransactionDate AS DATE) as Date,
    TransactionType,
    SUM(ProcessingFee) as Revenue,
    COUNT(*) as TransactionCount
FROM Transactions
WHERE TransactionDate >= DATEADD(DAY, -90, GETDATE())
    AND Status = 'Completed'
GROUP BY CAST(TransactionDate AS DATE), TransactionType
ORDER BY Date, TransactionType;
