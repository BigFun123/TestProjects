-- =============================================
-- Customer Lifetime Value (CLV) Analysis
-- =============================================
-- Calculate and analyze customer lifetime value metrics

-- Customer Lifetime Value Calculation
WITH CustomerMetrics AS (
    SELECT 
        a.AccountID,
        a.CustomerName,
        a.AccountType,
        a.AccountOpenDate,
        DATEDIFF(MONTH, a.AccountOpenDate, GETDATE()) as TenureMonths,
        COUNT(t.TransactionID) as TotalTransactions,
        SUM(t.Amount) as TotalVolume,
        SUM(t.ProcessingFee) as TotalFeesGenerated,
        AVG(t.Amount) as AvgTransactionAmount,
        MAX(t.TransactionDate) as LastTransactionDate,
        DATEDIFF(DAY, MAX(t.TransactionDate), GETDATE()) as DaysSinceLastTransaction,
        COUNT(DISTINCT CAST(t.TransactionDate AS DATE)) as ActiveDays
    FROM Accounts a
    LEFT JOIN Transactions t ON a.AccountID = t.AccountID AND t.Status = 'Completed'
    WHERE a.AccountOpenDate <= DATEADD(MONTH, -1, GETDATE())  -- At least 1 month old
    GROUP BY a.AccountID, a.CustomerName, a.AccountType, a.AccountOpenDate
)
SELECT 
    AccountID,
    CustomerName,
    AccountType,
    TenureMonths,
    TotalTransactions,
    TotalVolume,
    TotalFeesGenerated as LifetimeValue,
    CAST(TotalFeesGenerated / NULLIF(TenureMonths, 0) AS DECIMAL(18,2)) as MonthlyValue,
    CAST(TotalTransactions / NULLIF(TenureMonths, 0) AS DECIMAL(10,2)) as AvgMonthlyTransactions,
    AvgTransactionAmount,
    ActiveDays,
    LastTransactionDate,
    DaysSinceLastTransaction,
    CASE 
        WHEN TotalFeesGenerated >= 10000 THEN 'VIP'
        WHEN TotalFeesGenerated >= 5000 THEN 'High Value'
        WHEN TotalFeesGenerated >= 1000 THEN 'Medium Value'
        WHEN TotalFeesGenerated >= 100 THEN 'Standard'
        ELSE 'Low Value'
    END as CustomerTier,
    CASE 
        WHEN DaysSinceLastTransaction > 180 THEN 'At Risk'
        WHEN DaysSinceLastTransaction > 90 THEN 'Declining'
        WHEN CAST(TotalTransactions / NULLIF(TenureMonths, 0) AS DECIMAL(10,2)) > 10 THEN 'Highly Active'
        ELSE 'Active'
    END as ActivityStatus
FROM CustomerMetrics
ORDER BY LifetimeValue DESC;

-- CLV Cohort Analysis
SELECT 
    DATEPART(YEAR, a.AccountOpenDate) as CohortYear,
    DATEPART(QUARTER, a.AccountOpenDate) as CohortQuarter,
    COUNT(DISTINCT a.AccountID) as CustomerCount,
    SUM(t.ProcessingFee) as TotalRevenue,
    AVG(t.ProcessingFee) as AvgRevenuePerCustomer,
    SUM(CASE WHEN a.Status = 'Active' THEN 1 ELSE 0 END) as StillActive,
    CAST(SUM(CASE WHEN a.Status = 'Active' THEN 1 ELSE 0 END) * 100.0 / COUNT(DISTINCT a.AccountID) AS DECIMAL(5,2)) as RetentionRate,
    AVG(DATEDIFF(MONTH, a.AccountOpenDate, GETDATE())) as AvgTenureMonths
FROM Accounts a
LEFT JOIN Transactions t ON a.AccountID = t.AccountID AND t.Status = 'Completed'
WHERE a.AccountOpenDate >= DATEADD(YEAR, -3, GETDATE())
GROUP BY DATEPART(YEAR, a.AccountOpenDate), DATEPART(QUARTER, a.AccountOpenDate)
ORDER BY CohortYear DESC, CohortQuarter DESC;

-- Top revenue-generating customers
SELECT TOP 100
    a.AccountID,
    a.CustomerName,
    a.AccountType,
    a.AccountOpenDate,
    DATEDIFF(MONTH, a.AccountOpenDate, GETDATE()) as TenureMonths,
    COUNT(t.TransactionID) as TransactionCount,
    SUM(t.Amount) as TotalVolume,
    SUM(t.ProcessingFee) as TotalRevenue,
    CAST(SUM(t.ProcessingFee) / NULLIF(DATEDIFF(MONTH, a.AccountOpenDate, GETDATE()), 0) AS DECIMAL(18,2)) as MonthlyRevenue,
    MAX(t.TransactionDate) as LastTransaction,
    a.CurrentBalance
FROM Accounts a
INNER JOIN Transactions t ON a.AccountID = t.AccountID AND t.Status = 'Completed'
WHERE a.Status = 'Active'
GROUP BY a.AccountID, a.CustomerName, a.AccountType, a.AccountOpenDate, a.CurrentBalance
ORDER BY TotalRevenue DESC;

-- Customer value segmentation
WITH CustomerValue AS (
    SELECT 
        a.AccountID,
        a.CustomerName,
        SUM(t.ProcessingFee) as TotalRevenue,
        COUNT(t.TransactionID) as TransactionCount,
        DATEDIFF(MONTH, a.AccountOpenDate, GETDATE()) as TenureMonths,
        MAX(t.TransactionDate) as LastTransaction
    FROM Accounts a
    LEFT JOIN Transactions t ON a.AccountID = t.AccountID AND t.Status = 'Completed'
    WHERE a.Status = 'Active'
    GROUP BY a.AccountID, a.CustomerName, a.AccountOpenDate
)
SELECT 
    CASE 
        WHEN TotalRevenue >= 10000 THEN 'Tier 1 - VIP'
        WHEN TotalRevenue >= 5000 THEN 'Tier 2 - High Value'
        WHEN TotalRevenue >= 1000 THEN 'Tier 3 - Medium Value'
        WHEN TotalRevenue >= 100 THEN 'Tier 4 - Standard'
        ELSE 'Tier 5 - Low Value'
    END as CustomerTier,
    COUNT(*) as CustomerCount,
    SUM(TotalRevenue) as TotalSegmentRevenue,
    AVG(TotalRevenue) as AvgCustomerRevenue,
    SUM(TransactionCount) as TotalTransactions,
    AVG(CAST(TotalRevenue / NULLIF(TenureMonths, 0) AS DECIMAL(18,2))) as AvgMonthlyRevenue,
    CAST(SUM(TotalRevenue) * 100.0 / (SELECT SUM(TotalRevenue) FROM CustomerValue) AS DECIMAL(5,2)) as PercentOfTotalRevenue
FROM CustomerValue
GROUP BY 
    CASE 
        WHEN TotalRevenue >= 10000 THEN 'Tier 1 - VIP'
        WHEN TotalRevenue >= 5000 THEN 'Tier 2 - High Value'
        WHEN TotalRevenue >= 1000 THEN 'Tier 3 - Medium Value'
        WHEN TotalRevenue >= 100 THEN 'Tier 4 - Standard'
        ELSE 'Tier 5 - Low Value'
    END
ORDER BY 
    CASE CustomerTier
        WHEN 'Tier 1 - VIP' THEN 1
        WHEN 'Tier 2 - High Value' THEN 2
        WHEN 'Tier 3 - Medium Value' THEN 3
        WHEN 'Tier 4 - Standard' THEN 4
        ELSE 5
    END;

-- Predictive CLV (based on early behavior)
SELECT 
    a.AccountID,
    a.CustomerName,
    a.AccountOpenDate,
    DATEDIFF(DAY, a.AccountOpenDate, GETDATE()) as DaysSinceOpen,
    first30.TransactionCount as First30DayTransactions,
    first30.TotalVolume as First30DayVolume,
    first30.FeesGenerated as First30DayRevenue,
    lifetime.TotalRevenue as ActualLifetimeRevenue,
    CAST(first30.FeesGenerated * (DATEDIFF(DAY, a.AccountOpenDate, GETDATE()) / 30.0) AS DECIMAL(18,2)) as ProjectedCLV,
    CASE 
        WHEN first30.TransactionCount >= 10 THEN 'High Potential'
        WHEN first30.TransactionCount >= 5 THEN 'Medium Potential'
        WHEN first30.TransactionCount >= 1 THEN 'Low Potential'
        ELSE 'Inactive'
    END as PotentialTier
FROM Accounts a
LEFT JOIN (
    SELECT 
        AccountID,
        COUNT(*) as TransactionCount,
        SUM(Amount) as TotalVolume,
        SUM(ProcessingFee) as FeesGenerated
    FROM Transactions
    WHERE TransactionDate <= DATEADD(DAY, 30, (SELECT AccountOpenDate FROM Accounts WHERE AccountID = Transactions.AccountID))
        AND Status = 'Completed'
    GROUP BY AccountID
) first30 ON a.AccountID = first30.AccountID
LEFT JOIN (
    SELECT 
        AccountID,
        SUM(ProcessingFee) as TotalRevenue
    FROM Transactions
    WHERE Status = 'Completed'
    GROUP BY AccountID
) lifetime ON a.AccountID = lifetime.AccountID
WHERE a.AccountOpenDate >= DATEADD(MONTH, -6, GETDATE())
    AND a.AccountOpenDate <= DATEADD(DAY, -30, GETDATE())
ORDER BY First30DayRevenue DESC;
