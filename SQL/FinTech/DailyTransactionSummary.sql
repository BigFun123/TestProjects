-- =============================================
-- Daily Transaction Summary Report
-- =============================================
-- Provides comprehensive daily transaction metrics including
-- volume, amounts, and status breakdown

SELECT 
    CAST(TransactionDate AS DATE) as Date,
    COUNT(*) as TotalTransactions,
    SUM(CASE WHEN Status = 'Completed' THEN 1 ELSE 0 END) as CompletedCount,
    SUM(CASE WHEN Status = 'Failed' THEN 1 ELSE 0 END) as FailedCount,
    SUM(CASE WHEN Status = 'Pending' THEN 1 ELSE 0 END) as PendingCount,
    SUM(Amount) as TotalVolume,
    AVG(Amount) as AvgTransactionAmount,
    MIN(Amount) as MinAmount,
    MAX(Amount) as MaxAmount,
    STDEV(Amount) as StdDevAmount,
    SUM(CASE WHEN Status = 'Completed' THEN Amount ELSE 0 END) as CompletedVolume,
    CAST(SUM(CASE WHEN Status = 'Failed' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) as FailureRate
FROM Transactions
WHERE TransactionDate >= DATEADD(DAY, -30, GETDATE())
GROUP BY CAST(TransactionDate AS DATE)
ORDER BY Date DESC;

-- Hourly breakdown for today
SELECT 
    DATEPART(HOUR, TransactionDate) as Hour,
    COUNT(*) as TransactionCount,
    SUM(Amount) as TotalAmount,
    AVG(Amount) as AvgAmount
FROM Transactions
WHERE CAST(TransactionDate AS DATE) = CAST(GETDATE() AS DATE)
GROUP BY DATEPART(HOUR, TransactionDate)
ORDER BY Hour;
