-- =============================================
-- Time Series - Transaction Volume Over Time
-- =============================================
-- For line charts showing transaction counts over time

-- Daily transaction volume (last 90 days)
SELECT 
    CAST(TransactionDate AS DATE) as Date,
    COUNT(*) as TransactionCount,
    SUM(Amount) as TotalVolume,
    AVG(Amount) as AvgAmount
FROM Transactions
WHERE TransactionDate >= DATEADD(DAY, -90, GETDATE())
    AND Status = 'Completed'
GROUP BY CAST(TransactionDate AS DATE)
ORDER BY Date;

-- Hourly transaction pattern (24-hour view)
SELECT 
    DATEPART(HOUR, TransactionDate) as Hour,
    COUNT(*) as TransactionCount,
    AVG(Amount) as AvgAmount,
    SUM(Amount) as TotalVolume
FROM Transactions
WHERE TransactionDate >= DATEADD(DAY, -30, GETDATE())
    AND Status = 'Completed'
GROUP BY DATEPART(HOUR, TransactionDate)
ORDER BY Hour;

-- Weekly transaction trend (last 26 weeks)
SELECT 
    DATEPART(YEAR, TransactionDate) as Year,
    DATEPART(WEEK, TransactionDate) as WeekNumber,
    MIN(CAST(TransactionDate AS DATE)) as WeekStartDate,
    COUNT(*) as TransactionCount,
    SUM(Amount) as TotalVolume,
    AVG(Amount) as AvgAmount
FROM Transactions
WHERE TransactionDate >= DATEADD(WEEK, -26, GETDATE())
    AND Status = 'Completed'
GROUP BY DATEPART(YEAR, TransactionDate), DATEPART(WEEK, TransactionDate)
ORDER BY Year, WeekNumber;

-- Monthly transaction trend (last 24 months)
SELECT 
    DATEFROMPARTS(DATEPART(YEAR, TransactionDate), DATEPART(MONTH, TransactionDate), 1) as Month,
    COUNT(*) as TransactionCount,
    SUM(Amount) as TotalVolume,
    AVG(Amount) as AvgAmount,
    COUNT(DISTINCT AccountID) as UniqueCustomers
FROM Transactions
WHERE TransactionDate >= DATEADD(MONTH, -24, GETDATE())
    AND Status = 'Completed'
GROUP BY DATEFROMPARTS(DATEPART(YEAR, TransactionDate), DATEPART(MONTH, TransactionDate), 1)
ORDER BY Month;

-- Quarterly comparison
SELECT 
    DATEPART(YEAR, TransactionDate) as Year,
    DATEPART(QUARTER, TransactionDate) as Quarter,
    COUNT(*) as TransactionCount,
    SUM(Amount) as TotalVolume,
    AVG(Amount) as AvgAmount,
    COUNT(DISTINCT AccountID) as UniqueCustomers,
    SUM(ProcessingFee) as Revenue
FROM Transactions
WHERE TransactionDate >= DATEADD(YEAR, -2, GETDATE())
    AND Status = 'Completed'
GROUP BY DATEPART(YEAR, TransactionDate), DATEPART(QUARTER, TransactionDate)
ORDER BY Year, Quarter;
