-- =============================================
-- Account Balance History and Tracking
-- =============================================
-- Tracks balance changes over time with audit trail

-- Current account balances with change indicators
SELECT 
    a.AccountID,
    a.CustomerName,
    a.AccountType,
    a.CurrentBalance,
    a.AvailableBalance,
    a.CreditLimit,
    a.LastTransactionDate,
    DATEDIFF(DAY, a.LastTransactionDate, GETDATE()) as DaysSinceLastTransaction,
    (SELECT SUM(Amount) FROM Transactions 
     WHERE AccountID = a.AccountID 
     AND TransactionDate >= DATEADD(DAY, -30, GETDATE())
     AND Status = 'Completed') as Last30DaysActivity,
    (SELECT SUM(Amount) FROM Transactions 
     WHERE AccountID = a.AccountID 
     AND TransactionDate >= DATEADD(DAY, -7, GETDATE())
     AND Status = 'Completed') as Last7DaysActivity,
    CASE 
        WHEN a.CurrentBalance < 0 THEN 'Overdrawn'
        WHEN a.AvailableBalance < (a.CreditLimit * 0.1) THEN 'Low Balance'
        WHEN a.CurrentBalance >= 100000 THEN 'High Balance'
        ELSE 'Normal'
    END as BalanceStatus
FROM Accounts a
WHERE a.Status = 'Active'
ORDER BY a.CurrentBalance DESC;

-- Balance history over time (requires BalanceHistory table)
SELECT 
    AccountID,
    BalanceDate,
    OpeningBalance,
    Credits,
    Debits,
    ClosingBalance,
    (ClosingBalance - OpeningBalance) as NetChange,
    CAST((ClosingBalance - OpeningBalance) * 100.0 / NULLIF(OpeningBalance, 0) AS DECIMAL(10,2)) as PercentChange
FROM BalanceHistory
WHERE AccountID = @AccountID  -- Parameter
    AND BalanceDate >= DATEADD(MONTH, -6, GETDATE())
ORDER BY BalanceDate DESC;

-- Accounts with significant balance changes
SELECT 
    a.AccountID,
    a.CustomerName,
    a.CurrentBalance,
    prev.Balance as PreviousBalance,
    (a.CurrentBalance - prev.Balance) as BalanceChange,
    CAST((a.CurrentBalance - prev.Balance) * 100.0 / NULLIF(prev.Balance, 0) AS DECIMAL(10,2)) as PercentChange
FROM Accounts a
INNER JOIN (
    SELECT AccountID, Balance, SnapshotDate
    FROM AccountBalanceSnapshots
    WHERE SnapshotDate = (
        SELECT MAX(SnapshotDate) 
        FROM AccountBalanceSnapshots 
        WHERE SnapshotDate < DATEADD(DAY, -30, GETDATE())
    )
) prev ON a.AccountID = prev.AccountID
WHERE ABS(a.CurrentBalance - prev.Balance) >= 10000  -- Significant change threshold
    OR ABS((a.CurrentBalance - prev.Balance) * 100.0 / NULLIF(prev.Balance, 0)) >= 50  -- Or 50% change
ORDER BY ABS(a.CurrentBalance - prev.Balance) DESC;

-- Account balance reconciliation
SELECT 
    a.AccountID,
    a.CustomerName,
    a.CurrentBalance as ReportedBalance,
    COALESCE(a.OpeningBalance, 0) + 
    COALESCE((SELECT SUM(CASE WHEN TransactionType IN ('Credit', 'Deposit') THEN Amount ELSE -Amount END)
              FROM Transactions 
              WHERE AccountID = a.AccountID 
              AND Status = 'Completed'), 0) as CalculatedBalance,
    a.CurrentBalance - (COALESCE(a.OpeningBalance, 0) + 
    COALESCE((SELECT SUM(CASE WHEN TransactionType IN ('Credit', 'Deposit') THEN Amount ELSE -Amount END)
              FROM Transactions 
              WHERE AccountID = a.AccountID 
              AND Status = 'Completed'), 0)) as Discrepancy
FROM Accounts a
WHERE a.Status = 'Active'
HAVING ABS(Discrepancy) > 0.01  -- Flag any discrepancy
ORDER BY ABS(Discrepancy) DESC;
