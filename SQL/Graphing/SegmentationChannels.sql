-- =============================================
-- Segmentation - Channel and Device Analysis
-- =============================================
-- For pie charts and bar charts showing channel performance

-- Transaction volume by channel
SELECT 
    Channel,
    COUNT(*) as TransactionCount,
    SUM(Amount) as TotalVolume,
    AVG(Amount) as AvgAmount,
    COUNT(DISTINCT AccountID) as UniqueCustomers,
    CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS DECIMAL(5,2)) as PercentOfTransactions,
    CAST(SUM(CASE WHEN Status = 'Completed' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) as SuccessRate
FROM Transactions
WHERE TransactionDate >= DATEADD(MONTH, -1, GETDATE())
GROUP BY Channel
ORDER BY TransactionCount DESC;

-- Device type distribution
SELECT 
    DeviceType,
    COUNT(*) as TransactionCount,
    SUM(Amount) as TotalVolume,
    COUNT(DISTINCT AccountID) as UniqueUsers,
    CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS DECIMAL(5,2)) as PercentOfTransactions,
    AVG(DATEDIFF(SECOND, TransactionInitiatedDate, TransactionCompletedDate)) as AvgCompletionSeconds
FROM Transactions
WHERE TransactionDate >= DATEADD(MONTH, -1, GETDATE())
    AND Status = 'Completed'
GROUP BY DeviceType
ORDER BY TransactionCount DESC;

-- Operating system distribution
SELECT 
    OperatingSystem,
    COUNT(*) as TransactionCount,
    COUNT(DISTINCT AccountID) as UniqueUsers,
    CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS DECIMAL(5,2)) as PercentOfTransactions
FROM Transactions
WHERE TransactionDate >= DATEADD(MONTH, -1, GETDATE())
GROUP BY OperatingSystem
ORDER BY TransactionCount DESC;

-- Browser distribution
SELECT 
    Browser,
    COUNT(*) as TransactionCount,
    COUNT(DISTINCT AccountID) as UniqueUsers,
    CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS DECIMAL(5,2)) as PercentOfTransactions,
    CAST(SUM(CASE WHEN Status = 'Failed' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) as FailureRate
FROM Transactions
WHERE TransactionDate >= DATEADD(MONTH, -1, GETDATE())
    AND Channel = 'Web'
GROUP BY Browser
ORDER BY TransactionCount DESC;

-- Acquisition channel performance
SELECT 
    a.AcquisitionChannel,
    COUNT(DISTINCT a.AccountID) as Customers,
    SUM(t.ProcessingFee) as Revenue,
    AVG(t.ProcessingFee) as AvgRevenuePerTransaction,
    COUNT(t.TransactionID) as TotalTransactions,
    CAST(COUNT(DISTINCT a.AccountID) * 100.0 / SUM(COUNT(DISTINCT a.AccountID)) OVER () AS DECIMAL(5,2)) as PercentOfCustomers
FROM Accounts a
LEFT JOIN Transactions t ON a.AccountID = t.AccountID 
    AND t.Status = 'Completed'
    AND t.TransactionDate >= DATEADD(MONTH, -1, GETDATE())
WHERE a.Status = 'Active'
GROUP BY a.AcquisitionChannel
ORDER BY Customers DESC;
