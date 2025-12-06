-- =============================================
-- High Value Transaction Monitoring
-- =============================================
-- Tracks and analyzes high-value transactions for compliance
-- and risk management purposes

-- Transactions above threshold
DECLARE @HighValueThreshold DECIMAL(18,2) = 10000.00;

SELECT 
    t.TransactionID,
    t.AccountID,
    a.CustomerName,
    a.AccountType,
    t.Amount,
    t.TransactionType,
    t.TransactionDate,
    t.Status,
    t.PaymentMethod,
    t.Merchant,
    t.Description,
    CASE 
        WHEN t.Amount >= 50000 THEN 'Critical'
        WHEN t.Amount >= 25000 THEN 'High'
        WHEN t.Amount >= 10000 THEN 'Medium'
        ELSE 'Standard'
    END as RiskLevel
FROM Transactions t
INNER JOIN Accounts a ON t.AccountID = a.AccountID
WHERE t.Amount >= @HighValueThreshold
    AND t.TransactionDate >= DATEADD(DAY, -7, GETDATE())
ORDER BY t.Amount DESC, t.TransactionDate DESC;

-- Daily high-value transaction summary
SELECT 
    CAST(TransactionDate AS DATE) as Date,
    COUNT(*) as HighValueCount,
    SUM(Amount) as TotalHighValueVolume,
    AVG(Amount) as AvgHighValueAmount,
    MAX(Amount) as LargestTransaction,
    COUNT(DISTINCT AccountID) as UniqueAccounts
FROM Transactions
WHERE Amount >= @HighValueThreshold
    AND TransactionDate >= DATEADD(DAY, -30, GETDATE())
GROUP BY CAST(TransactionDate AS DATE)
ORDER BY Date DESC;

-- Accounts with multiple high-value transactions
SELECT 
    t.AccountID,
    a.CustomerName,
    a.AccountType,
    COUNT(*) as HighValueTransactionCount,
    SUM(t.Amount) as TotalHighValueVolume,
    MIN(t.TransactionDate) as FirstHighValueTxn,
    MAX(t.TransactionDate) as LastHighValueTxn,
    AVG(t.Amount) as AvgHighValueAmount
FROM Transactions t
INNER JOIN Accounts a ON t.AccountID = a.AccountID
WHERE t.Amount >= @HighValueThreshold
    AND t.TransactionDate >= DATEADD(DAY, -30, GETDATE())
GROUP BY t.AccountID, a.CustomerName, a.AccountType
HAVING COUNT(*) >= 3
ORDER BY TotalHighValueVolume DESC;

-- High-value transactions requiring additional review
SELECT 
    t.TransactionID,
    t.AccountID,
    a.CustomerName,
    t.Amount,
    t.TransactionDate,
    t.Status,
    CASE 
        WHEN t.Amount >= 50000 THEN 'Requires executive approval'
        WHEN t.Amount >= 25000 THEN 'Requires manager approval'
        WHEN t.Amount >= 10000 THEN 'Requires compliance review'
    END as ReviewLevel,
    CASE 
        WHEN t.Status = 'Pending' THEN 'Awaiting approval'
        WHEN t.Status = 'Completed' AND t.ReviewedBy IS NULL THEN 'Needs post-transaction review'
        WHEN t.Status = 'Completed' AND t.ReviewedBy IS NOT NULL THEN 'Reviewed'
        ELSE 'Check status'
    END as ReviewStatus
FROM Transactions t
INNER JOIN Accounts a ON t.AccountID = a.AccountID
WHERE t.Amount >= @HighValueThreshold
    AND t.TransactionDate >= DATEADD(DAY, -7, GETDATE())
    AND (t.Status = 'Pending' OR t.ReviewedBy IS NULL)
ORDER BY t.Amount DESC;
