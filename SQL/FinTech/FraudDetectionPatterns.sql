-- =============================================
-- Fraud Detection Pattern Analysis
-- =============================================
-- Identifies suspicious transaction patterns that may indicate fraud

-- Multiple transactions from same account in short time window
SELECT 
    AccountID,
    COUNT(*) as TransactionCount,
    SUM(Amount) as TotalAmount,
    MIN(TransactionDate) as FirstTransaction,
    MAX(TransactionDate) as LastTransaction,
    DATEDIFF(MINUTE, MIN(TransactionDate), MAX(TransactionDate)) as TimeWindowMinutes
FROM Transactions
WHERE TransactionDate >= DATEADD(HOUR, -1, GETDATE())
GROUP BY AccountID
HAVING COUNT(*) >= 5  -- 5 or more transactions in 1 hour
ORDER BY TransactionCount DESC;

-- Unusual transaction amounts (3+ standard deviations from user's average)
WITH UserStats AS (
    SELECT 
        AccountID,
        AVG(Amount) as AvgAmount,
        STDEV(Amount) as StdDevAmount
    FROM Transactions
    WHERE TransactionDate >= DATEADD(DAY, -90, GETDATE())
        AND Status = 'Completed'
    GROUP BY AccountID
    HAVING COUNT(*) >= 10  -- Users with at least 10 transactions
)
SELECT 
    t.TransactionID,
    t.AccountID,
    t.Amount,
    t.TransactionDate,
    us.AvgAmount as UserAvgAmount,
    us.StdDevAmount as UserStdDev,
    CAST((t.Amount - us.AvgAmount) / NULLIF(us.StdDevAmount, 0) AS DECIMAL(10,2)) as StandardDeviations
FROM Transactions t
INNER JOIN UserStats us ON t.AccountID = us.AccountID
WHERE t.TransactionDate >= DATEADD(DAY, -1, GETDATE())
    AND ABS(t.Amount - us.AvgAmount) > (3 * us.StdDevAmount)
ORDER BY StandardDeviations DESC;

-- Transactions from unusual locations or devices
SELECT 
    t.TransactionID,
    t.AccountID,
    t.Amount,
    t.TransactionDate,
    t.IPAddress,
    t.DeviceID,
    t.Location,
    COUNT(DISTINCT prev.Location) as HistoricalLocations,
    COUNT(DISTINCT prev.DeviceID) as HistoricalDevices
FROM Transactions t
LEFT JOIN Transactions prev ON prev.AccountID = t.AccountID 
    AND prev.TransactionDate < t.TransactionDate
    AND prev.TransactionDate >= DATEADD(DAY, -90, GETDATE())
WHERE t.TransactionDate >= DATEADD(DAY, -1, GETDATE())
    AND NOT EXISTS (
        SELECT 1 FROM Transactions hist
        WHERE hist.AccountID = t.AccountID
            AND hist.Location = t.Location
            AND hist.TransactionDate < t.TransactionDate
            AND hist.TransactionDate >= DATEADD(DAY, -30, GETDATE())
    )
GROUP BY t.TransactionID, t.AccountID, t.Amount, t.TransactionDate, 
         t.IPAddress, t.DeviceID, t.Location
HAVING COUNT(DISTINCT prev.Location) >= 1  -- User has transaction history
ORDER BY t.TransactionDate DESC;

-- Round-amount transactions (common in money laundering)
SELECT 
    TransactionID,
    AccountID,
    Amount,
    TransactionDate,
    PaymentMethod
FROM Transactions
WHERE TransactionDate >= DATEADD(DAY, -7, GETDATE())
    AND (Amount % 100 = 0 OR Amount % 1000 = 0)  -- Round amounts
    AND Amount >= 1000
ORDER BY Amount DESC;
