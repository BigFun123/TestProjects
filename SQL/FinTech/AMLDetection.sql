-- =============================================
-- Anti-Money Laundering (AML) Detection
-- =============================================
-- Identifies suspicious activities that may indicate money laundering

-- Structuring Detection (Breaking up large amounts into smaller transactions)
SELECT 
    t.AccountID,
    a.CustomerName,
    CAST(t.TransactionDate AS DATE) as Date,
    COUNT(*) as TransactionCount,
    SUM(t.Amount) as TotalAmount,
    AVG(t.Amount) as AvgAmount,
    MIN(t.Amount) as MinAmount,
    MAX(t.Amount) as MaxAmount,
    DATEDIFF(MINUTE, MIN(t.TransactionDate), MAX(t.TransactionDate)) as TimeWindowMinutes,
    'Potential Structuring - Multiple transactions just below reporting threshold' as SuspiciousActivity
FROM Transactions t
INNER JOIN Accounts a ON t.AccountID = a.AccountID
WHERE t.TransactionDate >= DATEADD(DAY, -7, GETDATE())
    AND t.Status = 'Completed'
    AND t.Amount BETWEEN 9000 AND 9999  -- Just below $10K reporting threshold
GROUP BY t.AccountID, a.CustomerName, CAST(t.TransactionDate AS DATE)
HAVING COUNT(*) >= 3
    AND SUM(t.Amount) >= 20000
ORDER BY TotalAmount DESC;

-- Rapid Movement of Funds (Layering)
WITH RapidTransfers AS (
    SELECT 
        t1.AccountID as SourceAccount,
        t1.TransactionID as OutgoingTxn,
        t1.Amount as OutgoingAmount,
        t1.TransactionDate as OutgoingDate,
        t2.TransactionID as IncomingTxn,
        t2.Amount as IncomingAmount,
        t2.TransactionDate as IncomingDate,
        DATEDIFF(MINUTE, t2.TransactionDate, t1.TransactionDate) as MinutesBetween
    FROM Transactions t1
    INNER JOIN Transactions t2 ON t1.AccountID = t2.AccountID
    WHERE t1.TransactionType = 'Debit'
        AND t2.TransactionType = 'Credit'
        AND t2.TransactionDate < t1.TransactionDate
        AND t2.TransactionDate >= DATEADD(HOUR, -24, t1.TransactionDate)
        AND t1.Amount > 5000
        AND ABS(t1.Amount - t2.Amount) / t2.Amount < 0.1  -- Similar amounts
)
SELECT 
    rt.SourceAccount,
    a.CustomerName,
    COUNT(*) as RapidTransferCount,
    SUM(rt.OutgoingAmount) as TotalOutgoing,
    AVG(rt.MinutesBetween) as AvgMinutesBetweenTransfers,
    'Potential Layering - Rapid movement of similar amounts' as SuspiciousActivity
FROM RapidTransfers rt
INNER JOIN Accounts a ON rt.SourceAccount = a.AccountID
GROUP BY rt.SourceAccount, a.CustomerName
HAVING COUNT(*) >= 3
ORDER BY RapidTransferCount DESC;

-- Unusual Cash Transactions
SELECT 
    t.TransactionID,
    t.AccountID,
    a.CustomerName,
    t.Amount,
    t.TransactionDate,
    t.TransactionType,
    t.Location,
    CASE 
        WHEN t.Amount >= 10000 THEN 'CTR Required (>=$10K)'
        WHEN t.Amount >= 5000 THEN 'Enhanced Due Diligence'
        ELSE 'Monitor'
    END as ComplianceAction,
    'Large Cash Transaction' as SuspiciousActivity
FROM Transactions t
INNER JOIN Accounts a ON t.AccountID = a.AccountID
WHERE t.PaymentMethod = 'Cash'
    AND t.Amount >= 5000
    AND t.TransactionDate >= DATEADD(DAY, -30, GETDATE())
ORDER BY t.Amount DESC;

-- Cross-Border Transactions to High-Risk Countries
SELECT 
    t.TransactionID,
    t.AccountID,
    a.CustomerName,
    t.Amount,
    t.TransactionDate,
    t.BeneficiaryCountry,
    t.BeneficiaryName,
    hr.RiskLevel,
    hr.RiskReason,
    'Cross-Border to High-Risk Jurisdiction' as SuspiciousActivity
FROM Transactions t
INNER JOIN Accounts a ON t.AccountID = a.AccountID
INNER JOIN HighRiskCountries hr ON t.BeneficiaryCountry = hr.CountryCode
WHERE t.TransactionDate >= DATEADD(DAY, -30, GETDATE())
    AND t.TransactionType = 'International Wire'
ORDER BY t.Amount DESC;

-- Suspicious Round-Number Patterns
SELECT 
    t.AccountID,
    a.CustomerName,
    COUNT(*) as RoundAmountCount,
    SUM(t.Amount) as TotalRoundAmount,
    STRING_AGG(CAST(t.Amount AS VARCHAR), ', ') as Amounts,
    MIN(t.TransactionDate) as FirstTransaction,
    MAX(t.TransactionDate) as LastTransaction,
    'Frequent Round Amount Transactions' as SuspiciousActivity
FROM Transactions t
INNER JOIN Accounts a ON t.AccountID = a.AccountID
WHERE (t.Amount % 1000 = 0 OR t.Amount % 5000 = 0)
    AND t.Amount >= 5000
    AND t.TransactionDate >= DATEADD(DAY, -30, GETDATE())
    AND t.Status = 'Completed'
GROUP BY t.AccountID, a.CustomerName
HAVING COUNT(*) >= 5
ORDER BY TotalRoundAmount DESC;

-- Sudden Increase in Account Activity
WITH AccountBaseline AS (
    SELECT 
        AccountID,
        AVG(DailyTransactionCount) as BaselineAvgCount,
        AVG(DailyVolume) as BaselineAvgVolume,
        STDEV(DailyTransactionCount) as StdDevCount,
        STDEV(DailyVolume) as StdDevVolume
    FROM (
        SELECT 
            AccountID,
            CAST(TransactionDate AS DATE) as Date,
            COUNT(*) as DailyTransactionCount,
            SUM(Amount) as DailyVolume
        FROM Transactions
        WHERE TransactionDate BETWEEN DATEADD(DAY, -90, GETDATE()) AND DATEADD(DAY, -30, GETDATE())
            AND Status = 'Completed'
        GROUP BY AccountID, CAST(TransactionDate AS DATE)
    ) Historical
    GROUP BY AccountID
),
RecentActivity AS (
    SELECT 
        AccountID,
        COUNT(*) as RecentCount,
        SUM(Amount) as RecentVolume
    FROM Transactions
    WHERE TransactionDate >= DATEADD(DAY, -7, GETDATE())
        AND Status = 'Completed'
    GROUP BY AccountID
)
SELECT 
    ra.AccountID,
    a.CustomerName,
    ab.BaselineAvgCount,
    ra.RecentCount,
    CAST((ra.RecentCount - ab.BaselineAvgCount * 7) / NULLIF(ab.StdDevCount, 0) AS DECIMAL(10,2)) as CountStdDevs,
    ab.BaselineAvgVolume,
    ra.RecentVolume,
    CAST((ra.RecentVolume - ab.BaselineAvgVolume * 7) / NULLIF(ab.StdDevVolume, 0) AS DECIMAL(10,2)) as VolumeStdDevs,
    'Sudden Spike in Activity' as SuspiciousActivity
FROM RecentActivity ra
INNER JOIN AccountBaseline ab ON ra.AccountID = ab.AccountID
INNER JOIN Accounts a ON ra.AccountID = a.AccountID
WHERE ra.RecentCount > ab.BaselineAvgCount * 7 * 3  -- 3x baseline
    OR ra.RecentVolume > ab.BaselineAvgVolume * 7 * 3
ORDER BY VolumeStdDevs DESC;
