-- =============================================
-- Customer Churn Analysis and Prediction
-- =============================================
-- Identify customers at risk of churning and analyze churn patterns

-- Active customers at risk of churning
WITH CustomerActivity AS (
    SELECT 
        a.AccountID,
        a.CustomerName,
        a.AccountType,
        a.CurrentBalance,
        a.LastTransactionDate,
        DATEDIFF(DAY, a.LastTransactionDate, GETDATE()) as DaysSinceLastTransaction,
        COUNT(t.TransactionID) as HistoricalTransactionCount,
        AVG(t.Amount) as AvgHistoricalAmount,
        SUM(t.ProcessingFee) as LifetimeRevenue,
        COUNT(DISTINCT CAST(t.TransactionDate AS DATE)) as ActiveDays,
        DATEDIFF(DAY, a.AccountOpenDate, GETDATE()) as AccountAgeDays
    FROM Accounts a
    LEFT JOIN Transactions t ON a.AccountID = t.AccountID AND t.Status = 'Completed'
    WHERE a.Status = 'Active'
    GROUP BY a.AccountID, a.CustomerName, a.AccountType, a.CurrentBalance, 
             a.LastTransactionDate, a.AccountOpenDate
)
SELECT 
    AccountID,
    CustomerName,
    AccountType,
    CurrentBalance,
    LastTransactionDate,
    DaysSinceLastTransaction,
    HistoricalTransactionCount,
    AvgHistoricalAmount,
    LifetimeRevenue,
    CAST(ActiveDays * 100.0 / NULLIF(AccountAgeDays, 0) AS DECIMAL(5,2)) as ActivityRate,
    CASE 
        WHEN DaysSinceLastTransaction >= 180 THEN 'Critical - Likely Churned'
        WHEN DaysSinceLastTransaction >= 120 THEN 'High Risk'
        WHEN DaysSinceLastTransaction >= 90 THEN 'Medium Risk'
        WHEN DaysSinceLastTransaction >= 60 THEN 'Low Risk'
        ELSE 'Active'
    END as ChurnRisk,
    CASE 
        WHEN LifetimeRevenue >= 5000 AND DaysSinceLastTransaction >= 90 THEN 'Immediate Outreach - High Value'
        WHEN LifetimeRevenue >= 1000 AND DaysSinceLastTransaction >= 120 THEN 'Retention Campaign'
        WHEN DaysSinceLastTransaction >= 180 THEN 'Win-Back Campaign'
        WHEN DaysSinceLastTransaction >= 60 THEN 'Engagement Email'
        ELSE 'Monitor'
    END as RecommendedAction
FROM CustomerActivity
WHERE DaysSinceLastTransaction >= 60
ORDER BY LifetimeRevenue DESC, DaysSinceLastTransaction DESC;

-- Churn rate by cohort
SELECT 
    DATEPART(YEAR, AccountOpenDate) as CohortYear,
    DATEPART(QUARTER, AccountOpenDate) as CohortQuarter,
    COUNT(*) as TotalCustomers,
    SUM(CASE WHEN Status = 'Closed' THEN 1 ELSE 0 END) as ChurnedCustomers,
    SUM(CASE WHEN Status = 'Active' THEN 1 ELSE 0 END) as ActiveCustomers,
    CAST(SUM(CASE WHEN Status = 'Closed' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) as ChurnRate,
    AVG(CASE WHEN Status = 'Closed' THEN DATEDIFF(MONTH, AccountOpenDate, ClosureDate) ELSE NULL END) as AvgMonthsToChurn
FROM Accounts
WHERE AccountOpenDate >= DATEADD(YEAR, -3, GETDATE())
GROUP BY DATEPART(YEAR, AccountOpenDate), DATEPART(QUARTER, AccountOpenDate)
ORDER BY CohortYear DESC, CohortQuarter DESC;

-- Monthly churn analysis
SELECT 
    DATEPART(YEAR, ClosureDate) as Year,
    DATEPART(MONTH, ClosureDate) as Month,
    COUNT(*) as ChurnedAccounts,
    AVG(DATEDIFF(MONTH, AccountOpenDate, ClosureDate)) as AvgTenureMonths,
    SUM(FinalBalance) as LostBalance,
    STRING_AGG(ClosureReason, '; ') as TopReasons,
    COUNT(CASE WHEN DATEDIFF(MONTH, AccountOpenDate, ClosureDate) < 3 THEN 1 END) as ChurnedUnder3Months,
    CAST(COUNT(CASE WHEN DATEDIFF(MONTH, AccountOpenDate, ClosureDate) < 3 THEN 1 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) as EarlyChurnRate
FROM AccountClosures
WHERE ClosureDate >= DATEADD(MONTH, -12, GETDATE())
GROUP BY DATEPART(YEAR, ClosureDate), DATEPART(MONTH, ClosureDate)
ORDER BY Year DESC, Month DESC;

-- Churn reasons analysis
SELECT 
    ClosureReason,
    COUNT(*) as Count,
    AVG(DATEDIFF(MONTH, AccountOpenDate, ClosureDate)) as AvgTenureMonths,
    SUM(FinalBalance) as TotalLostBalance,
    CAST(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM AccountClosures WHERE ClosureDate >= DATEADD(MONTH, -12, GETDATE())) AS DECIMAL(5,2)) as PercentOfChurn,
    CASE 
        WHEN ClosureReason LIKE '%fee%' OR ClosureReason LIKE '%cost%' THEN 'Price Sensitivity'
        WHEN ClosureReason LIKE '%service%' OR ClosureReason LIKE '%support%' THEN 'Service Quality'
        WHEN ClosureReason LIKE '%feature%' OR ClosureReason LIKE '%functionality%' THEN 'Product Issues'
        WHEN ClosureReason LIKE '%competitor%' THEN 'Competitive Loss'
        ELSE 'Other'
    END as ChurnCategory
FROM AccountClosures
WHERE ClosureDate >= DATEADD(MONTH, -12, GETDATE())
GROUP BY ClosureReason
ORDER BY Count DESC;

-- Predictive churn indicators (engagement decline)
WITH MonthlyActivity AS (
    SELECT 
        AccountID,
        DATEPART(YEAR, TransactionDate) as Year,
        DATEPART(MONTH, TransactionDate) as Month,
        COUNT(*) as MonthlyTransactions,
        SUM(Amount) as MonthlyVolume
    FROM Transactions
    WHERE Status = 'Completed'
        AND TransactionDate >= DATEADD(MONTH, -6, GETDATE())
    GROUP BY AccountID, DATEPART(YEAR, TransactionDate), DATEPART(MONTH, TransactionDate)
),
ActivityTrend AS (
    SELECT 
        m1.AccountID,
        AVG(m1.MonthlyTransactions) as Recent3MonthAvg,
        AVG(m2.MonthlyTransactions) as Previous3MonthAvg
    FROM MonthlyActivity m1
    LEFT JOIN MonthlyActivity m2 ON m1.AccountID = m2.AccountID
        AND ((m2.Year = m1.Year AND m2.Month < m1.Month) OR m2.Year < m1.Year)
    WHERE m1.Year = DATEPART(YEAR, GETDATE()) 
        AND m1.Month >= DATEPART(MONTH, DATEADD(MONTH, -3, GETDATE()))
    GROUP BY m1.AccountID
)
SELECT 
    a.AccountID,
    a.CustomerName,
    a.AccountType,
    at.Recent3MonthAvg,
    at.Previous3MonthAvg,
    CAST((at.Recent3MonthAvg - at.Previous3MonthAvg) / NULLIF(at.Previous3MonthAvg, 0) * 100 AS DECIMAL(10,2)) as PercentChange,
    CASE 
        WHEN at.Recent3MonthAvg < at.Previous3MonthAvg * 0.5 THEN 'High Churn Risk - 50%+ decline'
        WHEN at.Recent3MonthAvg < at.Previous3MonthAvg * 0.7 THEN 'Medium Churn Risk - 30%+ decline'
        WHEN at.Recent3MonthAvg < at.Previous3MonthAvg * 0.9 THEN 'Low Churn Risk - Minor decline'
        ELSE 'Stable/Growing'
    END as RiskLevel
FROM Accounts a
INNER JOIN ActivityTrend at ON a.AccountID = at.AccountID
WHERE a.Status = 'Active'
    AND at.Previous3MonthAvg > 0
    AND at.Recent3MonthAvg < at.Previous3MonthAvg
ORDER BY PercentChange;

-- Successful retention interventions
SELECT 
    ri.InterventionID,
    ri.AccountID,
    a.CustomerName,
    ri.InterventionType,  -- 'Email', 'Call', 'Offer', 'Survey'
    ri.InterventionDate,
    ri.ChurnRiskBefore,
    COUNT(t.TransactionID) as TransactionsAfter,
    SUM(t.Amount) as VolumeAfter,
    MAX(t.TransactionDate) as LastTransaction,
    DATEDIFF(DAY, ri.InterventionDate, MAX(t.TransactionDate)) as DaysActive,
    CASE 
        WHEN COUNT(t.TransactionID) >= 5 THEN 'Highly Successful'
        WHEN COUNT(t.TransactionID) >= 2 THEN 'Moderately Successful'
        WHEN COUNT(t.TransactionID) >= 1 THEN 'Partially Successful'
        ELSE 'Unsuccessful'
    END as InterventionSuccess
FROM RetentionInterventions ri
INNER JOIN Accounts a ON ri.AccountID = a.AccountID
LEFT JOIN Transactions t ON ri.AccountID = t.AccountID 
    AND t.TransactionDate > ri.InterventionDate
    AND t.Status = 'Completed'
WHERE ri.InterventionDate >= DATEADD(MONTH, -6, GETDATE())
GROUP BY ri.InterventionID, ri.AccountID, a.CustomerName, ri.InterventionType, 
         ri.InterventionDate, ri.ChurnRiskBefore
ORDER BY InterventionDate DESC;
