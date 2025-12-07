-- =============================================
-- Histogram - Transaction Frequency Distribution
-- =============================================
-- For histograms showing how often customers transact

-- Customer transaction frequency distribution (last 30 days)
WITH CustomerFrequency AS (
    SELECT 
        AccountID,
        COUNT(*) as TransactionCount
    FROM Transactions
    WHERE TransactionDate >= DATEADD(DAY, -30, GETDATE())
        AND Status = 'Completed'
    GROUP BY AccountID
)
SELECT 
    CASE 
        WHEN TransactionCount = 1 THEN '1'
        WHEN TransactionCount = 2 THEN '2'
        WHEN TransactionCount = 3 THEN '3'
        WHEN TransactionCount BETWEEN 4 AND 5 THEN '4-5'
        WHEN TransactionCount BETWEEN 6 AND 10 THEN '6-10'
        WHEN TransactionCount BETWEEN 11 AND 20 THEN '11-20'
        WHEN TransactionCount BETWEEN 21 AND 50 THEN '21-50'
        ELSE '50+'
    END as TransactionRange,
    COUNT(*) as CustomerCount,
    AVG(TransactionCount) as AvgTransactions,
    CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS DECIMAL(5,2)) as Percentage
FROM CustomerFrequency
GROUP BY 
    CASE 
        WHEN TransactionCount = 1 THEN '1'
        WHEN TransactionCount = 2 THEN '2'
        WHEN TransactionCount = 3 THEN '3'
        WHEN TransactionCount BETWEEN 4 AND 5 THEN '4-5'
        WHEN TransactionCount BETWEEN 6 AND 10 THEN '6-10'
        WHEN TransactionCount BETWEEN 11 AND 20 THEN '11-20'
        WHEN TransactionCount BETWEEN 21 AND 50 THEN '21-50'
        ELSE '50+'
    END
ORDER BY 
    CASE 
        WHEN TransactionRange = '1' THEN 1
        WHEN TransactionRange = '2' THEN 2
        WHEN TransactionRange = '3' THEN 3
        WHEN TransactionRange = '4-5' THEN 4
        WHEN TransactionRange = '6-10' THEN 5
        WHEN TransactionRange = '11-20' THEN 6
        WHEN TransactionRange = '21-50' THEN 7
        ELSE 8
    END;

-- Days since last transaction distribution
SELECT 
    CASE 
        WHEN DATEDIFF(DAY, LastTransactionDate, GETDATE()) <= 7 THEN '0-7 days'
        WHEN DATEDIFF(DAY, LastTransactionDate, GETDATE()) <= 14 THEN '8-14 days'
        WHEN DATEDIFF(DAY, LastTransactionDate, GETDATE()) <= 30 THEN '15-30 days'
        WHEN DATEDIFF(DAY, LastTransactionDate, GETDATE()) <= 60 THEN '31-60 days'
        WHEN DATEDIFF(DAY, LastTransactionDate, GETDATE()) <= 90 THEN '61-90 days'
        WHEN DATEDIFF(DAY, LastTransactionDate, GETDATE()) <= 180 THEN '91-180 days'
        ELSE '180+ days'
    END as RecencyRange,
    COUNT(*) as AccountCount,
    AVG(DATEDIFF(DAY, LastTransactionDate, GETDATE())) as AvgDays,
    CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS DECIMAL(5,2)) as Percentage
FROM Accounts
WHERE Status = 'Active'
    AND LastTransactionDate IS NOT NULL
GROUP BY 
    CASE 
        WHEN DATEDIFF(DAY, LastTransactionDate, GETDATE()) <= 7 THEN '0-7 days'
        WHEN DATEDIFF(DAY, LastTransactionDate, GETDATE()) <= 14 THEN '8-14 days'
        WHEN DATEDIFF(DAY, LastTransactionDate, GETDATE()) <= 30 THEN '15-30 days'
        WHEN DATEDIFF(DAY, LastTransactionDate, GETDATE()) <= 60 THEN '31-60 days'
        WHEN DATEDIFF(DAY, LastTransactionDate, GETDATE()) <= 90 THEN '61-90 days'
        WHEN DATEDIFF(DAY, LastTransactionDate, GETDATE()) <= 180 THEN '91-180 days'
        ELSE '180+ days'
    END
ORDER BY 
    CASE RecencyRange
        WHEN '0-7 days' THEN 1
        WHEN '8-14 days' THEN 2
        WHEN '15-30 days' THEN 3
        WHEN '31-60 days' THEN 4
        WHEN '61-90 days' THEN 5
        WHEN '91-180 days' THEN 6
        ELSE 7
    END;

-- Transaction count per day of week
SELECT 
    DATEPART(WEEKDAY, TransactionDate) as DayOfWeek,
    DATENAME(WEEKDAY, TransactionDate) as DayName,
    COUNT(*) as TransactionCount,
    SUM(Amount) as TotalVolume,
    AVG(Amount) as AvgAmount,
    CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS DECIMAL(5,2)) as Percentage
FROM Transactions
WHERE TransactionDate >= DATEADD(DAY, -90, GETDATE())
    AND Status = 'Completed'
GROUP BY DATEPART(WEEKDAY, TransactionDate), DATENAME(WEEKDAY, TransactionDate)
ORDER BY DayOfWeek;

-- Average transactions per customer by account age
SELECT 
    CASE 
        WHEN DATEDIFF(MONTH, a.AccountOpenDate, GETDATE()) < 3 THEN '0-3 months'
        WHEN DATEDIFF(MONTH, a.AccountOpenDate, GETDATE()) < 6 THEN '3-6 months'
        WHEN DATEDIFF(MONTH, a.AccountOpenDate, GETDATE()) < 12 THEN '6-12 months'
        WHEN DATEDIFF(MONTH, a.AccountOpenDate, GETDATE()) < 24 THEN '1-2 years'
        ELSE '2+ years'
    END as AccountAge,
    COUNT(DISTINCT a.AccountID) as Customers,
    COUNT(t.TransactionID) as TotalTransactions,
    CAST(COUNT(t.TransactionID) * 1.0 / COUNT(DISTINCT a.AccountID) AS DECIMAL(10,2)) as AvgTransactionsPerCustomer,
    AVG(t.Amount) as AvgTransactionAmount
FROM Accounts a
LEFT JOIN Transactions t ON a.AccountID = t.AccountID 
    AND t.Status = 'Completed'
    AND t.TransactionDate >= DATEADD(MONTH, -1, GETDATE())
WHERE a.Status = 'Active'
GROUP BY 
    CASE 
        WHEN DATEDIFF(MONTH, a.AccountOpenDate, GETDATE()) < 3 THEN '0-3 months'
        WHEN DATEDIFF(MONTH, a.AccountOpenDate, GETDATE()) < 6 THEN '3-6 months'
        WHEN DATEDIFF(MONTH, a.AccountOpenDate, GETDATE()) < 12 THEN '6-12 months'
        WHEN DATEDIFF(MONTH, a.AccountOpenDate, GETDATE()) < 24 THEN '1-2 years'
        ELSE '2+ years'
    END
ORDER BY 
    CASE AccountAge
        WHEN '0-3 months' THEN 1
        WHEN '3-6 months' THEN 2
        WHEN '6-12 months' THEN 3
        WHEN '1-2 years' THEN 4
        ELSE 5
    END;
