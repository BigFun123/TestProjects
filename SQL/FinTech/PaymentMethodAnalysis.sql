-- =============================================
-- Payment Method Performance Analysis
-- =============================================
-- Analyzes transaction performance across different payment methods

-- Payment method usage and success rates
SELECT 
    PaymentMethod,
    COUNT(*) as TotalTransactions,
    SUM(Amount) as TotalVolume,
    AVG(Amount) as AvgTransactionAmount,
    SUM(CASE WHEN Status = 'Completed' THEN 1 ELSE 0 END) as SuccessfulCount,
    SUM(CASE WHEN Status = 'Failed' THEN 1 ELSE 0 END) as FailedCount,
    SUM(CASE WHEN Status = 'Pending' THEN 1 ELSE 0 END) as PendingCount,
    CAST(SUM(CASE WHEN Status = 'Completed' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) as SuccessRate,
    COUNT(DISTINCT AccountID) as UniqueUsers,
    SUM(ProcessingFee) as TotalFees,
    CAST(SUM(ProcessingFee) * 100.0 / SUM(Amount) AS DECIMAL(5,2)) as AvgFeePercentage
FROM Transactions
WHERE TransactionDate >= DATEADD(DAY, -30, GETDATE())
GROUP BY PaymentMethod
ORDER BY TotalVolume DESC;

-- Payment method adoption trends
SELECT 
    DATEPART(YEAR, TransactionDate) as Year,
    DATEPART(MONTH, TransactionDate) as Month,
    PaymentMethod,
    COUNT(*) as TransactionCount,
    SUM(Amount) as Volume,
    COUNT(DISTINCT AccountID) as UniqueUsers
FROM Transactions
WHERE TransactionDate >= DATEADD(MONTH, -12, GETDATE())
    AND Status = 'Completed'
GROUP BY DATEPART(YEAR, TransactionDate), DATEPART(MONTH, TransactionDate), PaymentMethod
ORDER BY Year DESC, Month DESC, Volume DESC;

-- Payment method by transaction size
SELECT 
    PaymentMethod,
    CASE 
        WHEN Amount < 10 THEN 'Micro (<$10)'
        WHEN Amount < 50 THEN 'Small ($10-$50)'
        WHEN Amount < 200 THEN 'Medium ($50-$200)'
        WHEN Amount < 1000 THEN 'Large ($200-$1K)'
        ELSE 'Very Large ($1K+)'
    END as TransactionSize,
    COUNT(*) as TransactionCount,
    SUM(Amount) as TotalVolume,
    AVG(Amount) as AvgAmount,
    CAST(SUM(CASE WHEN Status = 'Completed' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) as SuccessRate
FROM Transactions
WHERE TransactionDate >= DATEADD(DAY, -30, GETDATE())
GROUP BY PaymentMethod,
    CASE 
        WHEN Amount < 10 THEN 'Micro (<$10)'
        WHEN Amount < 50 THEN 'Small ($10-$50)'
        WHEN Amount < 200 THEN 'Medium ($50-$200)'
        WHEN Amount < 1000 THEN 'Large ($200-$1K)'
        ELSE 'Very Large ($1K+)'
    END
ORDER BY PaymentMethod, 
    CASE TransactionSize
        WHEN 'Micro (<$10)' THEN 1
        WHEN 'Small ($10-$50)' THEN 2
        WHEN 'Medium ($50-$200)' THEN 3
        WHEN 'Large ($200-$1K)' THEN 4
        ELSE 5
    END;

-- Payment method processing time analysis
SELECT 
    PaymentMethod,
    COUNT(*) as TransactionCount,
    AVG(DATEDIFF(SECOND, TransactionInitiatedDate, TransactionCompletedDate)) as AvgProcessingSeconds,
    MIN(DATEDIFF(SECOND, TransactionInitiatedDate, TransactionCompletedDate)) as MinProcessingSeconds,
    MAX(DATEDIFF(SECOND, TransactionInitiatedDate, TransactionCompletedDate)) as MaxProcessingSeconds,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY DATEDIFF(SECOND, TransactionInitiatedDate, TransactionCompletedDate)) 
        OVER (PARTITION BY PaymentMethod) as MedianProcessingSeconds,
    PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY DATEDIFF(SECOND, TransactionInitiatedDate, TransactionCompletedDate)) 
        OVER (PARTITION BY PaymentMethod) as P95ProcessingSeconds
FROM Transactions
WHERE Status = 'Completed'
    AND TransactionDate >= DATEADD(DAY, -30, GETDATE())
    AND TransactionCompletedDate IS NOT NULL
GROUP BY PaymentMethod
ORDER BY AvgProcessingSeconds;

-- Cost analysis by payment method
SELECT 
    PaymentMethod,
    COUNT(*) as TransactionCount,
    SUM(Amount) as TotalVolume,
    SUM(ProcessingFee) as TotalFees,
    AVG(ProcessingFee) as AvgFeePerTransaction,
    CAST(SUM(ProcessingFee) * 100.0 / SUM(Amount) AS DECIMAL(5,2)) as EffectiveFeeRate,
    SUM(Amount - ProcessingFee) as NetRevenue,
    CASE 
        WHEN CAST(SUM(ProcessingFee) * 100.0 / SUM(Amount) AS DECIMAL(5,2)) < 1.5 THEN 'Low Cost'
        WHEN CAST(SUM(ProcessingFee) * 100.0 / SUM(Amount) AS DECIMAL(5,2)) < 3.0 THEN 'Medium Cost'
        ELSE 'High Cost'
    END as CostCategory
FROM Transactions
WHERE Status = 'Completed'
    AND TransactionDate >= DATEADD(DAY, -30, GETDATE())
GROUP BY PaymentMethod
ORDER BY EffectiveFeeRate;

-- Customer preference analysis
SELECT 
    a.AccountType,
    t.PaymentMethod,
    COUNT(*) as TransactionCount,
    COUNT(DISTINCT t.AccountID) as UniqueCustomers,
    SUM(t.Amount) as TotalVolume,
    CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY a.AccountType) AS DECIMAL(5,2)) as PercentOfAccountType
FROM Transactions t
INNER JOIN Accounts a ON t.AccountID = a.AccountID
WHERE t.TransactionDate >= DATEADD(DAY, -30, GETDATE())
    AND t.Status = 'Completed'
GROUP BY a.AccountType, t.PaymentMethod
ORDER BY a.AccountType, TransactionCount DESC;
