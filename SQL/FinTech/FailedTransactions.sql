-- =============================================
-- Failed Transaction Analysis
-- =============================================
-- Analyzes failed transactions to identify patterns and issues

-- Failed transaction summary
SELECT 
    CAST(TransactionDate AS DATE) as Date,
    FailureReason,
    COUNT(*) as FailureCount,
    SUM(Amount) as FailedVolume,
    AVG(Amount) as AvgFailedAmount,
    CAST(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Transactions WHERE CAST(TransactionDate AS DATE) = CAST(t.TransactionDate AS DATE)) AS DECIMAL(5,2)) as FailureRate
FROM Transactions t
WHERE Status = 'Failed'
    AND TransactionDate >= DATEADD(DAY, -30, GETDATE())
GROUP BY CAST(TransactionDate AS DATE), FailureReason
ORDER BY Date DESC, FailureCount DESC;

-- Failed transactions by category
SELECT 
    FailureReason,
    COUNT(*) as TotalFailures,
    SUM(Amount) as TotalFailedAmount,
    COUNT(DISTINCT AccountID) as AffectedAccounts,
    MIN(TransactionDate) as FirstOccurrence,
    MAX(TransactionDate) as LastOccurrence,
    CASE 
        WHEN FailureReason LIKE '%insufficient%' THEN 'Customer Issue - Low Balance'
        WHEN FailureReason LIKE '%expired%' THEN 'Customer Issue - Expired Card'
        WHEN FailureReason LIKE '%declined%' THEN 'Issuer Issue'
        WHEN FailureReason LIKE '%timeout%' OR FailureReason LIKE '%connection%' THEN 'Technical Issue'
        WHEN FailureReason LIKE '%fraud%' THEN 'Security Issue'
        ELSE 'Other'
    END as IssueCategory
FROM Transactions
WHERE Status = 'Failed'
    AND TransactionDate >= DATEADD(DAY, -30, GETDATE())
GROUP BY FailureReason
ORDER BY TotalFailures DESC;

-- Accounts with high failure rates
SELECT 
    t.AccountID,
    a.CustomerName,
    a.AccountType,
    COUNT(*) as TotalTransactions,
    SUM(CASE WHEN t.Status = 'Failed' THEN 1 ELSE 0 END) as FailedTransactions,
    SUM(CASE WHEN t.Status = 'Completed' THEN 1 ELSE 0 END) as SuccessfulTransactions,
    CAST(SUM(CASE WHEN t.Status = 'Failed' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) as FailureRate,
    STRING_AGG(DISTINCT t.FailureReason, '; ') as FailureReasons
FROM Transactions t
INNER JOIN Accounts a ON t.AccountID = a.AccountID
WHERE t.TransactionDate >= DATEADD(DAY, -30, GETDATE())
GROUP BY t.AccountID, a.CustomerName, a.AccountType
HAVING SUM(CASE WHEN t.Status = 'Failed' THEN 1 ELSE 0 END) >= 3
    AND CAST(SUM(CASE WHEN t.Status = 'Failed' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) >= 20
ORDER BY FailureRate DESC, FailedTransactions DESC;

-- Retry analysis for failed transactions
SELECT 
    t1.TransactionID as OriginalTransactionID,
    t1.AccountID,
    t1.Amount,
    t1.TransactionDate as FirstAttempt,
    t1.FailureReason,
    COUNT(t2.TransactionID) as RetryCount,
    MAX(t2.TransactionDate) as LastRetryAttempt,
    MAX(CASE WHEN t2.Status = 'Completed' THEN 'Success' ELSE 'Failed' END) as FinalStatus,
    DATEDIFF(MINUTE, t1.TransactionDate, MAX(t2.TransactionDate)) as MinutesToResolution
FROM Transactions t1
LEFT JOIN Transactions t2 ON t1.AccountID = t2.AccountID
    AND t2.TransactionDate > t1.TransactionDate
    AND t2.Amount = t1.Amount
    AND t2.TransactionDate <= DATEADD(HOUR, 24, t1.TransactionDate)
WHERE t1.Status = 'Failed'
    AND t1.TransactionDate >= DATEADD(DAY, -7, GETDATE())
GROUP BY t1.TransactionID, t1.AccountID, t1.Amount, t1.TransactionDate, t1.FailureReason
ORDER BY t1.TransactionDate DESC;

-- Failure rate by payment method
SELECT 
    PaymentMethod,
    COUNT(*) as TotalTransactions,
    SUM(CASE WHEN Status = 'Failed' THEN 1 ELSE 0 END) as Failed,
    SUM(CASE WHEN Status = 'Completed' THEN 1 ELSE 0 END) as Successful,
    CAST(SUM(CASE WHEN Status = 'Failed' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) as FailureRate,
    SUM(CASE WHEN Status = 'Failed' THEN Amount ELSE 0 END) as FailedVolume
FROM Transactions
WHERE TransactionDate >= DATEADD(DAY, -30, GETDATE())
GROUP BY PaymentMethod
ORDER BY FailureRate DESC;
