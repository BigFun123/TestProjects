-- =============================================
-- Cohort - Revenue Performance Over Time
-- =============================================
-- For line charts and area charts showing cohort revenue trends

-- Cumulative revenue by cohort
SELECT 
    DATEFROMPARTS(DATEPART(YEAR, a.AccountOpenDate), DATEPART(MONTH, a.AccountOpenDate), 1) as CohortMonth,
    DATEDIFF(MONTH, a.AccountOpenDate, t.TransactionDate) as MonthsSinceOpen,
    COUNT(DISTINCT a.AccountID) as ActiveCustomers,
    SUM(t.ProcessingFee) as MonthlyRevenue,
    SUM(SUM(t.ProcessingFee)) OVER (PARTITION BY DATEFROMPARTS(DATEPART(YEAR, a.AccountOpenDate), DATEPART(MONTH, a.AccountOpenDate), 1) 
                                     ORDER BY DATEDIFF(MONTH, a.AccountOpenDate, t.TransactionDate)) as CumulativeRevenue,
    CAST(SUM(t.ProcessingFee) / COUNT(DISTINCT a.AccountID) AS DECIMAL(18,2)) as RevenuePerCustomer
FROM Accounts a
INNER JOIN Transactions t ON a.AccountID = t.AccountID AND t.Status = 'Completed'
WHERE a.AccountOpenDate >= DATEADD(MONTH, -12, GETDATE())
GROUP BY DATEFROMPARTS(DATEPART(YEAR, a.AccountOpenDate), DATEPART(MONTH, a.AccountOpenDate), 1),
         DATEDIFF(MONTH, a.AccountOpenDate, t.TransactionDate)
ORDER BY CohortMonth, MonthsSinceOpen;

-- Average revenue per customer by cohort age
WITH CohortRevenue AS (
    SELECT 
        DATEFROMPARTS(DATEPART(YEAR, a.AccountOpenDate), DATEPART(MONTH, a.AccountOpenDate), 1) as CohortMonth,
        a.AccountID,
        DATEDIFF(MONTH, a.AccountOpenDate, t.TransactionDate) as MonthsSinceOpen,
        SUM(t.ProcessingFee) as Revenue
    FROM Accounts a
    INNER JOIN Transactions t ON a.AccountID = t.AccountID AND t.Status = 'Completed'
    WHERE a.AccountOpenDate >= DATEADD(MONTH, -12, GETDATE())
    GROUP BY DATEFROMPARTS(DATEPART(YEAR, a.AccountOpenDate), DATEPART(MONTH, a.AccountOpenDate), 1),
             a.AccountID,
             DATEDIFF(MONTH, a.AccountOpenDate, t.TransactionDate)
)
SELECT 
    MonthsSinceOpen,
    COUNT(DISTINCT AccountID) as TotalCustomers,
    AVG(Revenue) as AvgRevenuePerCustomer,
    SUM(Revenue) as TotalRevenue,
    MIN(Revenue) as MinRevenue,
    MAX(Revenue) as MaxRevenue
FROM CohortRevenue
WHERE MonthsSinceOpen BETWEEN 0 AND 12
GROUP BY MonthsSinceOpen
ORDER BY MonthsSinceOpen;

-- Cohort LTV projection (first 6 months)
SELECT 
    DATEFROMPARTS(DATEPART(YEAR, a.AccountOpenDate), DATEPART(MONTH, a.AccountOpenDate), 1) as CohortMonth,
    COUNT(DISTINCT a.AccountID) as CohortSize,
    SUM(CASE WHEN DATEDIFF(MONTH, a.AccountOpenDate, t.TransactionDate) <= 6 THEN t.ProcessingFee ELSE 0 END) as First6MonthsRevenue,
    CAST(SUM(CASE WHEN DATEDIFF(MONTH, a.AccountOpenDate, t.TransactionDate) <= 6 THEN t.ProcessingFee ELSE 0 END) / 
         COUNT(DISTINCT a.AccountID) AS DECIMAL(18,2)) as AvgFirst6MonthsLTV,
    SUM(t.ProcessingFee) as TotalLifetimeRevenue,
    CAST(SUM(t.ProcessingFee) / COUNT(DISTINCT a.AccountID) AS DECIMAL(18,2)) as CurrentLTV
FROM Accounts a
LEFT JOIN Transactions t ON a.AccountID = t.AccountID AND t.Status = 'Completed'
WHERE a.AccountOpenDate >= DATEADD(MONTH, -12, GETDATE())
GROUP BY DATEFROMPARTS(DATEPART(YEAR, a.AccountOpenDate), DATEPART(MONTH, a.AccountOpenDate), 1)
ORDER BY CohortMonth;

-- Transaction frequency by cohort over time
SELECT 
    DATEFROMPARTS(DATEPART(YEAR, a.AccountOpenDate), DATEPART(MONTH, a.AccountOpenDate), 1) as CohortMonth,
    DATEDIFF(MONTH, a.AccountOpenDate, t.TransactionDate) as MonthsSinceOpen,
    COUNT(DISTINCT a.AccountID) as ActiveCustomers,
    COUNT(t.TransactionID) as TotalTransactions,
    CAST(COUNT(t.TransactionID) * 1.0 / COUNT(DISTINCT a.AccountID) AS DECIMAL(10,2)) as AvgTransactionsPerCustomer
FROM Accounts a
INNER JOIN Transactions t ON a.AccountID = t.AccountID AND t.Status = 'Completed'
WHERE a.AccountOpenDate >= DATEADD(MONTH, -12, GETDATE())
GROUP BY DATEFROMPARTS(DATEPART(YEAR, a.AccountOpenDate), DATEPART(MONTH, a.AccountOpenDate), 1),
         DATEDIFF(MONTH, a.AccountOpenDate, t.TransactionDate)
ORDER BY CohortMonth, MonthsSinceOpen;
