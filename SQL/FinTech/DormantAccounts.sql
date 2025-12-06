-- =============================================
-- Dormant and Inactive Account Analysis
-- =============================================
-- Identifies accounts with no activity for extended periods

-- Dormant accounts (no activity for 90+ days)
SELECT 
    a.AccountID,
    a.CustomerName,
    a.Email,
    a.PhoneNumber,
    a.AccountType,
    a.CurrentBalance,
    a.LastTransactionDate,
    DATEDIFF(DAY, a.LastTransactionDate, GETDATE()) as DaysSinceLastActivity,
    a.AccountOpenDate,
    DATEDIFF(MONTH, a.AccountOpenDate, GETDATE()) as AccountAgeMonths,
    CASE 
        WHEN DATEDIFF(DAY, a.LastTransactionDate, GETDATE()) >= 365 THEN 'Severely Dormant (1+ year)'
        WHEN DATEDIFF(DAY, a.LastTransactionDate, GETDATE()) >= 180 THEN 'Highly Dormant (6+ months)'
        WHEN DATEDIFF(DAY, a.LastTransactionDate, GETDATE()) >= 90 THEN 'Dormant (3+ months)'
        ELSE 'Active'
    END as DormancyLevel
FROM Accounts a
WHERE a.Status = 'Active'
    AND (a.LastTransactionDate IS NULL 
         OR a.LastTransactionDate < DATEADD(DAY, -90, GETDATE()))
ORDER BY DaysSinceLastActivity DESC;

-- Dormant accounts with balances requiring action
SELECT 
    a.AccountID,
    a.CustomerName,
    a.AccountType,
    a.CurrentBalance,
    a.LastTransactionDate,
    DATEDIFF(DAY, a.LastTransactionDate, GETDATE()) as DaysSinceLastActivity,
    CASE 
        WHEN a.CurrentBalance >= 10000 THEN 'High Priority - Large Balance'
        WHEN a.CurrentBalance >= 1000 THEN 'Medium Priority'
        WHEN a.CurrentBalance > 0 THEN 'Low Priority'
        WHEN a.CurrentBalance < 0 THEN 'Negative Balance - Collection Required'
        ELSE 'Zero Balance'
    END as ActionPriority,
    CASE 
        WHEN DATEDIFF(DAY, a.LastTransactionDate, GETDATE()) >= 365 THEN 'Eligible for escheatment review'
        WHEN DATEDIFF(DAY, a.LastTransactionDate, GETDATE()) >= 180 THEN 'Send reactivation notice'
        WHEN DATEDIFF(DAY, a.LastTransactionDate, GETDATE()) >= 90 THEN 'Send activity reminder'
        ELSE 'Monitor'
    END as RecommendedAction
FROM Accounts a
WHERE a.Status = 'Active'
    AND a.LastTransactionDate < DATEADD(DAY, -90, GETDATE())
    AND a.CurrentBalance <> 0
ORDER BY a.CurrentBalance DESC, DaysSinceLastActivity DESC;

-- Reactivation opportunities (dormant but valuable accounts)
SELECT 
    a.AccountID,
    a.CustomerName,
    a.Email,
    a.CurrentBalance,
    DATEDIFF(DAY, a.LastTransactionDate, GETDATE()) as DaysSinceLastActivity,
    hist.HistoricalAvgBalance,
    hist.TotalLifetimeTransactions,
    hist.TotalLifetimeVolume,
    CASE 
        WHEN hist.HistoricalAvgBalance >= 50000 THEN 'VIP Account'
        WHEN hist.TotalLifetimeVolume >= 100000 THEN 'High Value Customer'
        WHEN hist.TotalLifetimeTransactions >= 100 THEN 'Active User History'
        ELSE 'Standard'
    END as CustomerValue
FROM Accounts a
INNER JOIN (
    SELECT 
        AccountID,
        AVG(Balance) as HistoricalAvgBalance,
        COUNT(*) as TotalLifetimeTransactions,
        SUM(Amount) as TotalLifetimeVolume
    FROM TransactionHistory
    GROUP BY AccountID
) hist ON a.AccountID = hist.AccountID
WHERE a.Status = 'Active'
    AND DATEDIFF(DAY, a.LastTransactionDate, GETDATE()) BETWEEN 90 AND 365
    AND (hist.HistoricalAvgBalance >= 10000 
         OR hist.TotalLifetimeVolume >= 50000
         OR hist.TotalLifetimeTransactions >= 50)
ORDER BY hist.HistoricalAvgBalance DESC;

-- Dormancy trend analysis
SELECT 
    DATEPART(YEAR, LastTransactionDate) as Year,
    DATEPART(MONTH, LastTransactionDate) as Month,
    COUNT(*) as AccountsBecameDormant,
    SUM(CurrentBalance) as TotalDormantBalance,
    AVG(CurrentBalance) as AvgDormantBalance
FROM Accounts
WHERE Status = 'Active'
    AND LastTransactionDate < DATEADD(DAY, -90, GETDATE())
    AND LastTransactionDate >= DATEADD(YEAR, -2, GETDATE())
GROUP BY DATEPART(YEAR, LastTransactionDate), DATEPART(MONTH, LastTransactionDate)
ORDER BY Year DESC, Month DESC;
