-- =============================================
-- Customer Cohort Analysis
-- =============================================
-- Analyze customer behavior patterns by cohort

-- Cohort retention analysis (monthly)
WITH Cohorts AS (
    SELECT 
        AccountID,
        DATEFROMPARTS(DATEPART(YEAR, AccountOpenDate), DATEPART(MONTH, AccountOpenDate), 1) as CohortMonth
    FROM Accounts
),
CohortActivity AS (
    SELECT 
        c.CohortMonth,
        DATEDIFF(MONTH, c.CohortMonth, DATEFROMPARTS(DATEPART(YEAR, t.TransactionDate), DATEPART(MONTH, t.TransactionDate), 1)) as MonthNumber,
        COUNT(DISTINCT c.AccountID) as ActiveCustomers
    FROM Cohorts c
    LEFT JOIN Transactions t ON c.AccountID = t.AccountID AND t.Status = 'Completed'
    WHERE c.CohortMonth >= DATEADD(MONTH, -12, GETDATE())
    GROUP BY c.CohortMonth, DATEDIFF(MONTH, c.CohortMonth, DATEFROMPARTS(DATEPART(YEAR, t.TransactionDate), DATEPART(MONTH, t.TransactionDate), 1))
),
CohortSize AS (
    SELECT 
        CohortMonth,
        COUNT(*) as TotalCustomers
    FROM Cohorts
    WHERE CohortMonth >= DATEADD(MONTH, -12, GETDATE())
    GROUP BY CohortMonth
)
SELECT 
    ca.CohortMonth,
    cs.TotalCustomers as CohortSize,
    ca.MonthNumber,
    ca.ActiveCustomers,
    CAST(ca.ActiveCustomers * 100.0 / cs.TotalCustomers AS DECIMAL(5,2)) as RetentionRate
FROM CohortActivity ca
INNER JOIN CohortSize cs ON ca.CohortMonth = cs.CohortMonth
WHERE ca.MonthNumber IS NOT NULL
ORDER BY ca.CohortMonth DESC, ca.MonthNumber;

-- Revenue cohort analysis
SELECT 
    DATEFROMPARTS(DATEPART(YEAR, a.AccountOpenDate), DATEPART(MONTH, a.AccountOpenDate), 1) as CohortMonth,
    DATEDIFF(MONTH, a.AccountOpenDate, t.TransactionDate) as MonthsSinceOpen,
    COUNT(DISTINCT a.AccountID) as ActiveCustomers,
    SUM(t.ProcessingFee) as Revenue,
    AVG(t.ProcessingFee) as AvgRevenuePerTransaction,
    SUM(SUM(t.ProcessingFee)) OVER (PARTITION BY DATEFROMPARTS(DATEPART(YEAR, a.AccountOpenDate), DATEPART(MONTH, a.AccountOpenDate), 1) 
                                     ORDER BY DATEDIFF(MONTH, a.AccountOpenDate, t.TransactionDate)) as CumulativeRevenue
FROM Accounts a
INNER JOIN Transactions t ON a.AccountID = t.AccountID AND t.Status = 'Completed'
WHERE a.AccountOpenDate >= DATEADD(MONTH, -12, GETDATE())
GROUP BY DATEFROMPARTS(DATEPART(YEAR, a.AccountOpenDate), DATEPART(MONTH, a.AccountOpenDate), 1),
         DATEDIFF(MONTH, a.AccountOpenDate, t.TransactionDate)
ORDER BY CohortMonth DESC, MonthsSinceOpen;

-- Cohort behavior comparison
WITH CohortStats AS (
    SELECT 
        DATEFROMPARTS(DATEPART(YEAR, a.AccountOpenDate), DATEPART(MONTH, a.AccountOpenDate), 1) as CohortMonth,
        a.AccountID,
        COUNT(t.TransactionID) as TotalTransactions,
        SUM(t.Amount) as TotalVolume,
        SUM(t.ProcessingFee) as TotalRevenue,
        AVG(t.Amount) as AvgTransactionSize,
        COUNT(DISTINCT t.PaymentMethod) as PaymentMethodsUsed,
        MAX(t.TransactionDate) as LastTransaction
    FROM Accounts a
    LEFT JOIN Transactions t ON a.AccountID = t.AccountID AND t.Status = 'Completed'
    WHERE a.AccountOpenDate >= DATEADD(MONTH, -12, GETDATE())
    GROUP BY DATEFROMPARTS(DATEPART(YEAR, a.AccountOpenDate), DATEPART(MONTH, a.AccountOpenDate), 1), a.AccountID
)
SELECT 
    CohortMonth,
    COUNT(*) as CohortSize,
    AVG(TotalTransactions) as AvgTransactionsPerCustomer,
    AVG(TotalVolume) as AvgVolumePerCustomer,
    AVG(TotalRevenue) as AvgRevenuePerCustomer,
    AVG(AvgTransactionSize) as AvgTransactionSize,
    AVG(PaymentMethodsUsed) as AvgPaymentMethodsUsed,
    SUM(CASE WHEN DATEDIFF(DAY, LastTransaction, GETDATE()) <= 30 THEN 1 ELSE 0 END) as ActiveLast30Days,
    CAST(SUM(CASE WHEN DATEDIFF(DAY, LastTransaction, GETDATE()) <= 30 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) as ActiveRate
FROM CohortStats
GROUP BY CohortMonth
ORDER BY CohortMonth DESC;

-- Customer acquisition quality by cohort
SELECT 
    DATEFROMPARTS(DATEPART(YEAR, a.AccountOpenDate), DATEPART(MONTH, a.AccountOpenDate), 1) as CohortMonth,
    a.AcquisitionChannel,
    COUNT(*) as CustomersAcquired,
    SUM(lifetime.TotalRevenue) as TotalLifetimeRevenue,
    AVG(lifetime.TotalRevenue) as AvgCLV,
    AVG(DATEDIFF(DAY, a.AccountOpenDate, lifetime.FirstTransaction)) as AvgDaysToFirstTransaction,
    SUM(CASE WHEN a.Status = 'Active' THEN 1 ELSE 0 END) as StillActive,
    CAST(SUM(CASE WHEN a.Status = 'Active' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) as RetentionRate,
    CAST(SUM(lifetime.TotalRevenue) / COUNT(*) AS DECIMAL(18,2)) as RevenuePerAcquisition
FROM Accounts a
LEFT JOIN (
    SELECT 
        AccountID,
        SUM(ProcessingFee) as TotalRevenue,
        MIN(TransactionDate) as FirstTransaction
    FROM Transactions
    WHERE Status = 'Completed'
    GROUP BY AccountID
) lifetime ON a.AccountID = lifetime.AccountID
WHERE a.AccountOpenDate >= DATEADD(MONTH, -12, GETDATE())
GROUP BY DATEFROMPARTS(DATEPART(YEAR, a.AccountOpenDate), DATEPART(MONTH, a.AccountOpenDate), 1), 
         a.AcquisitionChannel
ORDER BY CohortMonth DESC, TotalLifetimeRevenue DESC;

-- Transaction frequency evolution by cohort
SELECT 
    DATEFROMPARTS(DATEPART(YEAR, a.AccountOpenDate), DATEPART(MONTH, a.AccountOpenDate), 1) as CohortMonth,
    CASE 
        WHEN DATEDIFF(MONTH, a.AccountOpenDate, GETDATE()) = 0 THEN 'Month 0 (Current)'
        WHEN DATEDIFF(MONTH, a.AccountOpenDate, GETDATE()) = 1 THEN 'Month 1'
        WHEN DATEDIFF(MONTH, a.AccountOpenDate, GETDATE()) <= 3 THEN 'Months 2-3'
        WHEN DATEDIFF(MONTH, a.AccountOpenDate, GETDATE()) <= 6 THEN 'Months 4-6'
        WHEN DATEDIFF(MONTH, a.AccountOpenDate, GETDATE()) <= 12 THEN 'Months 7-12'
        ELSE 'Year 1+'
    END as AgeGroup,
    COUNT(DISTINCT a.AccountID) as Customers,
    COUNT(t.TransactionID) as TotalTransactions,
    CAST(COUNT(t.TransactionID) * 1.0 / COUNT(DISTINCT a.AccountID) AS DECIMAL(10,2)) as AvgTransactionsPerCustomer,
    AVG(t.Amount) as AvgTransactionAmount,
    SUM(t.ProcessingFee) as Revenue
FROM Accounts a
LEFT JOIN Transactions t ON a.AccountID = t.AccountID 
    AND t.Status = 'Completed'
    AND t.TransactionDate >= DATEADD(MONTH, -1, GETDATE())
WHERE a.AccountOpenDate >= DATEADD(MONTH, -12, GETDATE())
GROUP BY DATEFROMPARTS(DATEPART(YEAR, a.AccountOpenDate), DATEPART(MONTH, a.AccountOpenDate), 1),
         CASE 
            WHEN DATEDIFF(MONTH, a.AccountOpenDate, GETDATE()) = 0 THEN 'Month 0 (Current)'
            WHEN DATEDIFF(MONTH, a.AccountOpenDate, GETDATE()) = 1 THEN 'Month 1'
            WHEN DATEDIFF(MONTH, a.AccountOpenDate, GETDATE()) <= 3 THEN 'Months 2-3'
            WHEN DATEDIFF(MONTH, a.AccountOpenDate, GETDATE()) <= 6 THEN 'Months 4-6'
            WHEN DATEDIFF(MONTH, a.AccountOpenDate, GETDATE()) <= 12 THEN 'Months 7-12'
            ELSE 'Year 1+'
         END
ORDER BY CohortMonth DESC, 
         CASE AgeGroup
            WHEN 'Month 0 (Current)' THEN 1
            WHEN 'Month 1' THEN 2
            WHEN 'Months 2-3' THEN 3
            WHEN 'Months 4-6' THEN 4
            WHEN 'Months 7-12' THEN 5
            ELSE 6
         END;
