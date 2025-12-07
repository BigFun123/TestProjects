-- =============================================
-- Distribution - Payment Method Analysis
-- =============================================
-- For pie charts and donut charts showing payment method distribution

-- Payment method distribution (current month)
SELECT 
    PaymentMethod,
    COUNT(*) as TransactionCount,
    SUM(Amount) as TotalVolume,
    CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS DECIMAL(5,2)) as PercentOfTransactions,
    CAST(SUM(Amount) * 100.0 / SUM(SUM(Amount)) OVER () AS DECIMAL(5,2)) as PercentOfVolume
FROM Transactions
WHERE TransactionDate >= DATEADD(MONTH, -1, GETDATE())
    AND Status = 'Completed'
GROUP BY PaymentMethod
ORDER BY TransactionCount DESC;

-- Payment method usage by customer segment
SELECT 
    a.AccountType,
    t.PaymentMethod,
    COUNT(*) as TransactionCount,
    SUM(t.Amount) as TotalVolume,
    CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY a.AccountType) AS DECIMAL(5,2)) as PercentWithinSegment
FROM Transactions t
INNER JOIN Accounts a ON t.AccountID = a.AccountID
WHERE t.TransactionDate >= DATEADD(MONTH, -1, GETDATE())
    AND t.Status = 'Completed'
GROUP BY a.AccountType, t.PaymentMethod
ORDER BY a.AccountType, TransactionCount DESC;

-- Transaction type distribution
SELECT 
    TransactionType,
    COUNT(*) as TransactionCount,
    SUM(Amount) as TotalVolume,
    AVG(Amount) as AvgAmount,
    CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS DECIMAL(5,2)) as Percentage
FROM Transactions
WHERE TransactionDate >= DATEADD(MONTH, -1, GETDATE())
    AND Status = 'Completed'
GROUP BY TransactionType
ORDER BY TransactionCount DESC;

-- Transaction status breakdown
SELECT 
    Status,
    COUNT(*) as TransactionCount,
    SUM(Amount) as TotalVolume,
    CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS DECIMAL(5,2)) as Percentage
FROM Transactions
WHERE TransactionDate >= DATEADD(DAY, -30, GETDATE())
GROUP BY Status
ORDER BY TransactionCount DESC;

-- Currency distribution
SELECT 
    Currency,
    COUNT(*) as TransactionCount,
    SUM(Amount) as TotalVolume,
    CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS DECIMAL(5,2)) as PercentOfTransactions,
    COUNT(DISTINCT AccountID) as UniqueCustomers
FROM Transactions
WHERE TransactionDate >= DATEADD(MONTH, -1, GETDATE())
    AND Status = 'Completed'
GROUP BY Currency
ORDER BY TransactionCount DESC;
