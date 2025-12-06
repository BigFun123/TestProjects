-- =============================================
-- Account Aging and Lifecycle Analysis
-- =============================================
-- Analyzes account lifecycle, tenure, and aging patterns

-- Account age distribution
SELECT 
    CASE 
        WHEN DATEDIFF(MONTH, AccountOpenDate, GETDATE()) < 3 THEN '0-3 months (New)'
        WHEN DATEDIFF(MONTH, AccountOpenDate, GETDATE()) < 6 THEN '3-6 months'
        WHEN DATEDIFF(MONTH, AccountOpenDate, GETDATE()) < 12 THEN '6-12 months'
        WHEN DATEDIFF(MONTH, AccountOpenDate, GETDATE()) < 24 THEN '1-2 years'
        WHEN DATEDIFF(MONTH, AccountOpenDate, GETDATE()) < 36 THEN '2-3 years'
        WHEN DATEDIFF(MONTH, AccountOpenDate, GETDATE()) < 60 THEN '3-5 years'
        ELSE '5+ years (Mature)'
    END as AccountAgeRange,
    COUNT(*) as AccountCount,
    SUM(CurrentBalance) as TotalBalance,
    AVG(CurrentBalance) as AvgBalance,
    SUM(CASE WHEN Status = 'Active' THEN 1 ELSE 0 END) as ActiveCount,
    SUM(CASE WHEN Status = 'Inactive' THEN 1 ELSE 0 END) as InactiveCount,
    CAST(SUM(CASE WHEN Status = 'Active' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) as ActivePercentage
FROM Accounts
GROUP BY 
    CASE 
        WHEN DATEDIFF(MONTH, AccountOpenDate, GETDATE()) < 3 THEN '0-3 months (New)'
        WHEN DATEDIFF(MONTH, AccountOpenDate, GETDATE()) < 6 THEN '3-6 months'
        WHEN DATEDIFF(MONTH, AccountOpenDate, GETDATE()) < 12 THEN '6-12 months'
        WHEN DATEDIFF(MONTH, AccountOpenDate, GETDATE()) < 24 THEN '1-2 years'
        WHEN DATEDIFF(MONTH, AccountOpenDate, GETDATE()) < 36 THEN '2-3 years'
        WHEN DATEDIFF(MONTH, AccountOpenDate, GETDATE()) < 60 THEN '3-5 years'
        ELSE '5+ years (Mature)'
    END
ORDER BY 
    CASE 
        WHEN AccountAgeRange = '0-3 months (New)' THEN 1
        WHEN AccountAgeRange = '3-6 months' THEN 2
        WHEN AccountAgeRange = '6-12 months' THEN 3
        WHEN AccountAgeRange = '1-2 years' THEN 4
        WHEN AccountAgeRange = '2-3 years' THEN 5
        WHEN AccountAgeRange = '3-5 years' THEN 6
        ELSE 7
    END;

-- Account activity lifecycle
SELECT 
    a.AccountID,
    a.CustomerName,
    a.AccountType,
    a.AccountOpenDate,
    DATEDIFF(MONTH, a.AccountOpenDate, GETDATE()) as AccountAgeMonths,
    a.CurrentBalance,
    a.LastTransactionDate,
    t.FirstTransactionDate,
    t.TotalTransactions,
    t.AvgMonthlyTransactions,
    t.TotalVolume,
    CASE 
        WHEN t.TotalTransactions = 0 THEN 'Never Used'
        WHEN DATEDIFF(DAY, a.LastTransactionDate, GETDATE()) > 180 THEN 'Dormant'
        WHEN t.AvgMonthlyTransactions >= 10 THEN 'Highly Active'
        WHEN t.AvgMonthlyTransactions >= 3 THEN 'Active'
        ELSE 'Low Activity'
    END as ActivityLevel
FROM Accounts a
LEFT JOIN (
    SELECT 
        AccountID,
        MIN(TransactionDate) as FirstTransactionDate,
        COUNT(*) as TotalTransactions,
        CAST(COUNT(*) AS FLOAT) / NULLIF(DATEDIFF(MONTH, MIN(TransactionDate), GETDATE()), 0) as AvgMonthlyTransactions,
        SUM(Amount) as TotalVolume
    FROM Transactions
    WHERE Status = 'Completed'
    GROUP BY AccountID
) t ON a.AccountID = t.AccountID
WHERE a.Status = 'Active'
ORDER BY t.TotalVolume DESC;

-- New account onboarding success rate
SELECT 
    CAST(AccountOpenDate AS DATE) as OpenDate,
    COUNT(*) as NewAccounts,
    SUM(CASE WHEN FirstTransactionDate IS NOT NULL THEN 1 ELSE 0 END) as AccountsWithActivity,
    SUM(CASE WHEN FirstTransactionDate <= DATEADD(DAY, 7, AccountOpenDate) THEN 1 ELSE 0 END) as ActiveWithin7Days,
    SUM(CASE WHEN FirstTransactionDate <= DATEADD(DAY, 30, AccountOpenDate) THEN 1 ELSE 0 END) as ActiveWithin30Days,
    CAST(SUM(CASE WHEN FirstTransactionDate IS NOT NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) as ActivationRate,
    CAST(SUM(CASE WHEN FirstTransactionDate <= DATEADD(DAY, 7, AccountOpenDate) THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) as Week1ActivationRate
FROM (
    SELECT 
        a.AccountID,
        a.AccountOpenDate,
        (SELECT MIN(TransactionDate) FROM Transactions WHERE AccountID = a.AccountID) as FirstTransactionDate
    FROM Accounts a
    WHERE a.AccountOpenDate >= DATEADD(MONTH, -6, GETDATE())
) AccountActivation
GROUP BY CAST(AccountOpenDate AS DATE)
ORDER BY OpenDate DESC;

-- Account closure analysis
SELECT 
    CAST(ClosureDate AS DATE) as ClosureDate,
    COUNT(*) as AccountsClosed,
    AVG(DATEDIFF(MONTH, AccountOpenDate, ClosureDate)) as AvgAccountLifespanMonths,
    SUM(FinalBalance) as TotalFinalBalance,
    ClosureReason,
    COUNT(CASE WHEN DATEDIFF(MONTH, AccountOpenDate, ClosureDate) < 3 THEN 1 END) as ClosedUnder3Months
FROM AccountClosures
WHERE ClosureDate >= DATEADD(MONTH, -12, GETDATE())
GROUP BY CAST(ClosureDate AS DATE), ClosureReason
ORDER BY ClosureDate DESC;

-- Retention rate by cohort
SELECT 
    DATEPART(YEAR, AccountOpenDate) as CohortYear,
    DATEPART(QUARTER, AccountOpenDate) as CohortQuarter,
    COUNT(*) as TotalAccountsOpened,
    SUM(CASE WHEN Status = 'Active' THEN 1 ELSE 0 END) as StillActive,
    SUM(CASE WHEN Status = 'Closed' THEN 1 ELSE 0 END) as Closed,
    CAST(SUM(CASE WHEN Status = 'Active' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) as RetentionRate,
    AVG(CASE WHEN Status = 'Active' THEN CurrentBalance ELSE NULL END) as AvgBalanceActive
FROM Accounts
WHERE AccountOpenDate >= DATEADD(YEAR, -3, GETDATE())
GROUP BY DATEPART(YEAR, AccountOpenDate), DATEPART(QUARTER, AccountOpenDate)
ORDER BY CohortYear DESC, CohortQuarter DESC;
