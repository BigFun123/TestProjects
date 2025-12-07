-- =============================================
-- Cohort - Churn Rate Trends
-- =============================================
-- For line charts showing churn rates over time

-- Monthly churn rate trend
SELECT 
    DATEFROMPARTS(DATEPART(YEAR, ClosureDate), DATEPART(MONTH, ClosureDate), 1) as Month,
    COUNT(*) as ChurnedAccounts,
    (SELECT COUNT(*) FROM Accounts WHERE Status = 'Active' 
     AND AccountOpenDate < DATEFROMPARTS(DATEPART(YEAR, ac.ClosureDate), DATEPART(MONTH, ac.ClosureDate), 1)) as ActiveAccountsAtStart,
    CAST(COUNT(*) * 100.0 / 
         (SELECT COUNT(*) FROM Accounts WHERE Status = 'Active' 
          AND AccountOpenDate < DATEFROMPARTS(DATEPART(YEAR, ac.ClosureDate), DATEPART(MONTH, ac.ClosureDate), 1)) 
         AS DECIMAL(5,2)) as ChurnRate
FROM AccountClosures ac
WHERE ClosureDate >= DATEADD(MONTH, -12, GETDATE())
GROUP BY DATEFROMPARTS(DATEPART(YEAR, ClosureDate), DATEPART(MONTH, ClosureDate), 1)
ORDER BY Month;

-- Churn rate by cohort
SELECT 
    DATEFROMPARTS(DATEPART(YEAR, AccountOpenDate), DATEPART(MONTH, AccountOpenDate), 1) as CohortMonth,
    COUNT(*) as TotalAccounts,
    SUM(CASE WHEN Status = 'Closed' THEN 1 ELSE 0 END) as ChurnedAccounts,
    SUM(CASE WHEN Status = 'Active' THEN 1 ELSE 0 END) as ActiveAccounts,
    CAST(SUM(CASE WHEN Status = 'Closed' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) as ChurnRate,
    AVG(CASE WHEN Status = 'Closed' THEN DATEDIFF(MONTH, AccountOpenDate, ClosureDate) END) as AvgMonthsToChurn
FROM Accounts
WHERE AccountOpenDate >= DATEADD(MONTH, -12, GETDATE())
GROUP BY DATEFROMPARTS(DATEPART(YEAR, AccountOpenDate), DATEPART(MONTH, AccountOpenDate), 1)
ORDER BY CohortMonth;

-- Survival curve (percentage of cohort still active over time)
WITH Cohorts AS (
    SELECT 
        AccountID,
        DATEFROMPARTS(DATEPART(YEAR, AccountOpenDate), DATEPART(MONTH, AccountOpenDate), 1) as CohortMonth,
        Status,
        CASE WHEN Status = 'Closed' THEN DATEDIFF(MONTH, AccountOpenDate, ClosureDate) ELSE NULL END as MonthsToChurn
    FROM Accounts
    WHERE AccountOpenDate >= DATEADD(MONTH, -12, GETDATE())
),
SurvivalData AS (
    SELECT 
        CohortMonth,
        MonthNumber,
        COUNT(*) as CohortSize,
        SUM(CASE WHEN MonthsToChurn IS NULL OR MonthsToChurn >= MonthNumber THEN 1 ELSE 0 END) as StillActive
    FROM Cohorts
    CROSS JOIN (SELECT TOP 13 ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 as MonthNumber FROM sys.objects) Months
    GROUP BY CohortMonth, MonthNumber
)
SELECT 
    CohortMonth,
    MonthNumber,
    CohortSize,
    StillActive,
    CAST(StillActive * 100.0 / CohortSize AS DECIMAL(5,2)) as SurvivalRate,
    CAST((CohortSize - StillActive) * 100.0 / CohortSize AS DECIMAL(5,2)) as ChurnRate
FROM SurvivalData
WHERE MonthNumber <= 12
ORDER BY CohortMonth, MonthNumber;

-- Churn risk score trend (customers at risk)
SELECT 
    CAST(GETDATE() - DATEPART(DAY, GETDATE()) + 1 AS DATE) as Month,
    COUNT(*) as TotalActiveCustomers,
    SUM(CASE WHEN DATEDIFF(DAY, LastTransactionDate, GETDATE()) >= 180 THEN 1 ELSE 0 END) as CriticalRisk,
    SUM(CASE WHEN DATEDIFF(DAY, LastTransactionDate, GETDATE()) BETWEEN 120 AND 179 THEN 1 ELSE 0 END) as HighRisk,
    SUM(CASE WHEN DATEDIFF(DAY, LastTransactionDate, GETDATE()) BETWEEN 90 AND 119 THEN 1 ELSE 0 END) as MediumRisk,
    SUM(CASE WHEN DATEDIFF(DAY, LastTransactionDate, GETDATE()) BETWEEN 60 AND 89 THEN 1 ELSE 0 END) as LowRisk,
    CAST(SUM(CASE WHEN DATEDIFF(DAY, LastTransactionDate, GETDATE()) >= 90 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) as AtRiskPercentage
FROM Accounts
WHERE Status = 'Active'
UNION ALL
SELECT 
    DATEADD(MONTH, -1, CAST(GETDATE() - DATEPART(DAY, GETDATE()) + 1 AS DATE)),
    COUNT(*),
    SUM(CASE WHEN DATEDIFF(DAY, LastTransactionDate, DATEADD(MONTH, -1, GETDATE())) >= 180 THEN 1 ELSE 0 END),
    SUM(CASE WHEN DATEDIFF(DAY, LastTransactionDate, DATEADD(MONTH, -1, GETDATE())) BETWEEN 120 AND 179 THEN 1 ELSE 0 END),
    SUM(CASE WHEN DATEDIFF(DAY, LastTransactionDate, DATEADD(MONTH, -1, GETDATE())) BETWEEN 90 AND 119 THEN 1 ELSE 0 END),
    SUM(CASE WHEN DATEDIFF(DAY, LastTransactionDate, DATEADD(MONTH, -1, GETDATE())) BETWEEN 60 AND 89 THEN 1 ELSE 0 END),
    CAST(SUM(CASE WHEN DATEDIFF(DAY, LastTransactionDate, DATEADD(MONTH, -1, GETDATE())) >= 90 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2))
FROM Accounts
WHERE Status = 'Active'
ORDER BY Month DESC;
