-- =============================================
-- Distribution - Geographic Analysis
-- =============================================
-- For map visualizations and geographic pie charts

-- Transaction volume by country
SELECT 
    Country,
    COUNT(*) as TransactionCount,
    SUM(Amount) as TotalVolume,
    AVG(Amount) as AvgAmount,
    COUNT(DISTINCT AccountID) as UniqueCustomers,
    CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS DECIMAL(5,2)) as PercentOfTransactions
FROM Transactions
WHERE TransactionDate >= DATEADD(MONTH, -1, GETDATE())
    AND Status = 'Completed'
GROUP BY Country
ORDER BY TransactionCount DESC;

-- Transaction volume by state/region
SELECT 
    State,
    COUNT(*) as TransactionCount,
    SUM(Amount) as TotalVolume,
    AVG(Amount) as AvgAmount,
    COUNT(DISTINCT AccountID) as UniqueCustomers,
    CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS DECIMAL(5,2)) as PercentOfTransactions
FROM Transactions
WHERE TransactionDate >= DATEADD(MONTH, -1, GETDATE())
    AND Status = 'Completed'
    AND Country = 'USA'  -- or parameterized
GROUP BY State
ORDER BY TransactionCount DESC;

-- Transaction volume by city (top 20)
SELECT TOP 20
    City,
    State,
    COUNT(*) as TransactionCount,
    SUM(Amount) as TotalVolume,
    COUNT(DISTINCT AccountID) as UniqueCustomers,
    CAST(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Transactions 
                              WHERE TransactionDate >= DATEADD(MONTH, -1, GETDATE()) 
                              AND Status = 'Completed') AS DECIMAL(5,2)) as PercentOfTotal
FROM Transactions
WHERE TransactionDate >= DATEADD(MONTH, -1, GETDATE())
    AND Status = 'Completed'
GROUP BY City, State
ORDER BY TransactionCount DESC;

-- Account distribution by country
SELECT 
    Country,
    COUNT(*) as AccountCount,
    SUM(CurrentBalance) as TotalBalance,
    AVG(CurrentBalance) as AvgBalance,
    CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS DECIMAL(5,2)) as PercentOfAccounts
FROM Accounts
WHERE Status = 'Active'
GROUP BY Country
ORDER BY AccountCount DESC;

-- Cross-border transaction flow (source to destination)
SELECT 
    SourceCountry,
    DestinationCountry,
    COUNT(*) as TransactionCount,
    SUM(Amount) as TotalVolume,
    AVG(Amount) as AvgAmount
FROM InternationalTransfers
WHERE TransactionDate >= DATEADD(MONTH, -1, GETDATE())
    AND Status = 'Completed'
GROUP BY SourceCountry, DestinationCountry
ORDER BY TransactionCount DESC;
