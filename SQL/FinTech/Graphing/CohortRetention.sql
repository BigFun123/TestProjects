-- =============================================
-- Cohort - Retention Curve Analysis
-- =============================================
-- For line charts showing retention rates over time by cohort

-- Monthly cohort retention curve
WITH Cohorts AS (
    SELECT 
        AccountID,
        DATEFROMPARTS(DATEPART(YEAR, AccountOpenDate), DATEPART(MONTH, AccountOpenDate), 1) as CohortMonth
    FROM Accounts
    WHERE AccountOpenDate >= DATEADD(MONTH, -12, GETDATE())
),
CohortActivity AS (
    SELECT 
        c.CohortMonth,
        DATEDIFF(MONTH, c.CohortMonth, DATEFROMPARTS(DATEPART(YEAR, t.TransactionDate), DATEPART(MONTH, t.TransactionDate), 1)) as MonthNumber,
        COUNT(DISTINCT c.AccountID) as ActiveCustomers
    FROM Cohorts c
    LEFT JOIN Transactions t ON c.AccountID = t.AccountID AND t.Status = 'Completed'
    GROUP BY c.CohortMonth, DATEDIFF(MONTH, c.CohortMonth, DATEFROMPARTS(DATEPART(YEAR, t.TransactionDate), DATEPART(MONTH, t.TransactionDate), 1))
),
CohortSize AS (
    SELECT 
        CohortMonth,
        COUNT(*) as TotalCustomers
    FROM Cohorts
    GROUP BY CohortMonth
)
SELECT 
    ca.CohortMonth,
    ca.MonthNumber,
    cs.TotalCustomers as CohortSize,
    ca.ActiveCustomers,
    CAST(ca.ActiveCustomers * 100.0 / cs.TotalCustomers AS DECIMAL(5,2)) as RetentionRate
FROM CohortActivity ca
INNER JOIN CohortSize cs ON ca.CohortMonth = cs.CohortMonth
WHERE ca.MonthNumber IS NOT NULL AND ca.MonthNumber >= 0
ORDER BY ca.CohortMonth, ca.MonthNumber;

-- Average retention rate by month (across all cohorts)
WITH Cohorts AS (
    SELECT 
        AccountID,
        DATEFROMPARTS(DATEPART(YEAR, AccountOpenDate), DATEPART(MONTH, AccountOpenDate), 1) as CohortMonth
    FROM Accounts
    WHERE AccountOpenDate >= DATEADD(MONTH, -12, GETDATE())
),
CohortActivity AS (
    SELECT 
        c.CohortMonth,
        DATEDIFF(MONTH, c.CohortMonth, DATEFROMPARTS(DATEPART(YEAR, t.TransactionDate), DATEPART(MONTH, t.TransactionDate), 1)) as MonthNumber,
        COUNT(DISTINCT c.AccountID) as ActiveCustomers,
        (SELECT COUNT(*) FROM Cohorts WHERE CohortMonth = c.CohortMonth) as CohortSize
    FROM Cohorts c
    LEFT JOIN Transactions t ON c.AccountID = t.AccountID AND t.Status = 'Completed'
    GROUP BY c.CohortMonth, DATEDIFF(MONTH, c.CohortMonth, DATEFROMPARTS(DATEPART(YEAR, t.TransactionDate), DATEPART(MONTH, t.TransactionDate), 1))
)
SELECT 
    MonthNumber,
    AVG(CAST(ActiveCustomers * 100.0 / CohortSize AS DECIMAL(5,2))) as AvgRetentionRate,
    MIN(CAST(ActiveCustomers * 100.0 / CohortSize AS DECIMAL(5,2))) as MinRetentionRate,
    MAX(CAST(ActiveCustomers * 100.0 / CohortSize AS DECIMAL(5,2))) as MaxRetentionRate,
    COUNT(DISTINCT CohortMonth) as CohortsIncluded
FROM CohortActivity
WHERE MonthNumber IS NOT NULL AND MonthNumber BETWEEN 0 AND 12
GROUP BY MonthNumber
ORDER BY MonthNumber;

-- Weekly retention curve (first 12 weeks)
WITH Cohorts AS (
    SELECT 
        AccountID,
        DATEADD(WEEK, DATEDIFF(WEEK, 0, AccountOpenDate), 0) as CohortWeek
    FROM Accounts
    WHERE AccountOpenDate >= DATEADD(WEEK, -12, GETDATE())
),
CohortActivity AS (
    SELECT 
        c.CohortWeek,
        DATEDIFF(WEEK, c.CohortWeek, DATEADD(WEEK, DATEDIFF(WEEK, 0, t.TransactionDate), 0)) as WeekNumber,
        COUNT(DISTINCT c.AccountID) as ActiveCustomers
    FROM Cohorts c
    LEFT JOIN Transactions t ON c.AccountID = t.AccountID AND t.Status = 'Completed'
    GROUP BY c.CohortWeek, DATEDIFF(WEEK, c.CohortWeek, DATEADD(WEEK, DATEDIFF(WEEK, 0, t.TransactionDate), 0))
),
CohortSize AS (
    SELECT 
        CohortWeek,
        COUNT(*) as TotalCustomers
    FROM Cohorts
    GROUP BY CohortWeek
)
SELECT 
    ca.CohortWeek,
    ca.WeekNumber,
    cs.TotalCustomers as CohortSize,
    ca.ActiveCustomers,
    CAST(ca.ActiveCustomers * 100.0 / cs.TotalCustomers AS DECIMAL(5,2)) as RetentionRate
FROM CohortActivity ca
INNER JOIN CohortSize cs ON ca.CohortWeek = cs.CohortWeek
WHERE ca.WeekNumber IS NOT NULL AND ca.WeekNumber BETWEEN 0 AND 12
ORDER BY ca.CohortWeek, ca.WeekNumber;
