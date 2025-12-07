-- =============================================
-- Time Series - Success and Failure Rates
-- =============================================
-- For line charts tracking transaction success/failure rates over time

-- Daily success rate trend
SELECT 
    CAST(TransactionDate AS DATE) as Date,
    COUNT(*) as TotalTransactions,
    SUM(CASE WHEN Status = 'Completed' THEN 1 ELSE 0 END) as Successful,
    SUM(CASE WHEN Status = 'Failed' THEN 1 ELSE 0 END) as Failed,
    SUM(CASE WHEN Status = 'Pending' THEN 1 ELSE 0 END) as Pending,
    CAST(SUM(CASE WHEN Status = 'Completed' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) as SuccessRate,
    CAST(SUM(CASE WHEN Status = 'Failed' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) as FailureRate
FROM Transactions
WHERE TransactionDate >= DATEADD(DAY, -90, GETDATE())
GROUP BY CAST(TransactionDate AS DATE)
ORDER BY Date;

-- Hourly success rate pattern (for heatmap or line chart)
SELECT 
    DATEPART(HOUR, TransactionDate) as Hour,
    DATEPART(WEEKDAY, TransactionDate) as DayOfWeek,
    COUNT(*) as TotalTransactions,
    CAST(SUM(CASE WHEN Status = 'Completed' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) as SuccessRate
FROM Transactions
WHERE TransactionDate >= DATEADD(DAY, -30, GETDATE())
GROUP BY DATEPART(HOUR, TransactionDate), DATEPART(WEEKDAY, TransactionDate)
ORDER BY DayOfWeek, Hour;

-- Weekly failure rate by payment method
SELECT 
    DATEPART(YEAR, TransactionDate) as Year,
    DATEPART(WEEK, TransactionDate) as WeekNumber,
    MIN(CAST(TransactionDate AS DATE)) as WeekStartDate,
    PaymentMethod,
    COUNT(*) as TotalTransactions,
    SUM(CASE WHEN Status = 'Failed' THEN 1 ELSE 0 END) as Failed,
    CAST(SUM(CASE WHEN Status = 'Failed' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) as FailureRate
FROM Transactions
WHERE TransactionDate >= DATEADD(WEEK, -12, GETDATE())
GROUP BY DATEPART(YEAR, TransactionDate), DATEPART(WEEK, TransactionDate), PaymentMethod
ORDER BY Year, WeekNumber, PaymentMethod;

-- Transaction status distribution over time (stacked bar chart)
SELECT 
    DATEFROMPARTS(DATEPART(YEAR, TransactionDate), DATEPART(MONTH, TransactionDate), 1) as Month,
    Status,
    COUNT(*) as TransactionCount,
    SUM(Amount) as TotalVolume
FROM Transactions
WHERE TransactionDate >= DATEADD(MONTH, -12, GETDATE())
GROUP BY DATEFROMPARTS(DATEPART(YEAR, TransactionDate), DATEPART(MONTH, TransactionDate), 1), Status
ORDER BY Month, Status;
