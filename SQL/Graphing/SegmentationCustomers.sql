-- =============================================
-- Segmentation - Customer Value Tiers
-- =============================================
-- For bar charts and pie charts showing customer segmentation by value

-- Customer tier distribution (by lifetime value)
WITH CustomerValue AS (
    SELECT 
        a.AccountID,
        a.CustomerName,
        SUM(t.ProcessingFee) as LifetimeValue,
        CASE 
            WHEN SUM(t.ProcessingFee) >= 10000 THEN 'VIP'
            WHEN SUM(t.ProcessingFee) >= 5000 THEN 'High Value'
            WHEN SUM(t.ProcessingFee) >= 1000 THEN 'Medium Value'
            WHEN SUM(t.ProcessingFee) >= 100 THEN 'Standard'
            ELSE 'Low Value'
        END as Tier
    FROM Accounts a
    LEFT JOIN Transactions t ON a.AccountID = t.AccountID AND t.Status = 'Completed'
    WHERE a.Status = 'Active'
    GROUP BY a.AccountID, a.CustomerName
)
SELECT 
    Tier,
    COUNT(*) as CustomerCount,
    SUM(LifetimeValue) as TotalRevenue,
    AVG(LifetimeValue) as AvgRevenue,
    CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS DECIMAL(5,2)) as PercentOfCustomers,
    CAST(SUM(LifetimeValue) * 100.0 / SUM(SUM(LifetimeValue)) OVER () AS DECIMAL(5,2)) as PercentOfRevenue
FROM CustomerValue
GROUP BY Tier
ORDER BY 
    CASE Tier
        WHEN 'VIP' THEN 1
        WHEN 'High Value' THEN 2
        WHEN 'Medium Value' THEN 3
        WHEN 'Standard' THEN 4
        ELSE 5
    END;

-- Customer segmentation by transaction frequency
SELECT 
    CASE 
        WHEN TransactionCount >= 50 THEN 'Power Users (50+)'
        WHEN TransactionCount >= 20 THEN 'Heavy Users (20-49)'
        WHEN TransactionCount >= 10 THEN 'Regular Users (10-19)'
        WHEN TransactionCount >= 5 THEN 'Moderate Users (5-9)'
        WHEN TransactionCount >= 1 THEN 'Light Users (1-4)'
        ELSE 'Inactive'
    END as Segment,
    COUNT(*) as CustomerCount,
    AVG(TransactionCount) as AvgTransactions,
    SUM(TotalVolume) as TotalVolume,
    CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS DECIMAL(5,2)) as PercentOfCustomers
FROM (
    SELECT 
        a.AccountID,
        COUNT(t.TransactionID) as TransactionCount,
        SUM(t.Amount) as TotalVolume
    FROM Accounts a
    LEFT JOIN Transactions t ON a.AccountID = t.AccountID 
        AND t.Status = 'Completed'
        AND t.TransactionDate >= DATEADD(MONTH, -3, GETDATE())
    WHERE a.Status = 'Active'
    GROUP BY a.AccountID
) CustomerActivity
GROUP BY 
    CASE 
        WHEN TransactionCount >= 50 THEN 'Power Users (50+)'
        WHEN TransactionCount >= 20 THEN 'Heavy Users (20-49)'
        WHEN TransactionCount >= 10 THEN 'Regular Users (10-19)'
        WHEN TransactionCount >= 5 THEN 'Moderate Users (5-9)'
        WHEN TransactionCount >= 1 THEN 'Light Users (1-4)'
        ELSE 'Inactive'
    END
ORDER BY 
    CASE Segment
        WHEN 'Power Users (50+)' THEN 1
        WHEN 'Heavy Users (20-49)' THEN 2
        WHEN 'Regular Users (10-19)' THEN 3
        WHEN 'Moderate Users (5-9)' THEN 4
        WHEN 'Light Users (1-4)' THEN 5
        ELSE 6
    END;

-- Account age segmentation
SELECT 
    CASE 
        WHEN DATEDIFF(MONTH, AccountOpenDate, GETDATE()) < 1 THEN '< 1 month'
        WHEN DATEDIFF(MONTH, AccountOpenDate, GETDATE()) < 3 THEN '1-3 months'
        WHEN DATEDIFF(MONTH, AccountOpenDate, GETDATE()) < 6 THEN '3-6 months'
        WHEN DATEDIFF(MONTH, AccountOpenDate, GETDATE()) < 12 THEN '6-12 months'
        WHEN DATEDIFF(MONTH, AccountOpenDate, GETDATE()) < 24 THEN '1-2 years'
        ELSE '2+ years'
    END as AgeSegment,
    COUNT(*) as CustomerCount,
    AVG(CurrentBalance) as AvgBalance,
    SUM(CurrentBalance) as TotalBalance,
    CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS DECIMAL(5,2)) as PercentOfCustomers
FROM Accounts
WHERE Status = 'Active'
GROUP BY 
    CASE 
        WHEN DATEDIFF(MONTH, AccountOpenDate, GETDATE()) < 1 THEN '< 1 month'
        WHEN DATEDIFF(MONTH, AccountOpenDate, GETDATE()) < 3 THEN '1-3 months'
        WHEN DATEDIFF(MONTH, AccountOpenDate, GETDATE()) < 6 THEN '3-6 months'
        WHEN DATEDIFF(MONTH, AccountOpenDate, GETDATE()) < 12 THEN '6-12 months'
        WHEN DATEDIFF(MONTH, AccountOpenDate, GETDATE()) < 24 THEN '1-2 years'
        ELSE '2+ years'
    END
ORDER BY 
    CASE AgeSegment
        WHEN '< 1 month' THEN 1
        WHEN '1-3 months' THEN 2
        WHEN '3-6 months' THEN 3
        WHEN '6-12 months' THEN 4
        WHEN '1-2 years' THEN 5
        ELSE 6
    END;

-- RFM Segmentation (Recency, Frequency, Monetary)
WITH RFMScores AS (
    SELECT 
        a.AccountID,
        a.CustomerName,
        DATEDIFF(DAY, MAX(t.TransactionDate), GETDATE()) as Recency,
        COUNT(t.TransactionID) as Frequency,
        SUM(t.Amount) as Monetary,
        NTILE(5) OVER (ORDER BY DATEDIFF(DAY, MAX(t.TransactionDate), GETDATE())) as R_Score,
        NTILE(5) OVER (ORDER BY COUNT(t.TransactionID) DESC) as F_Score,
        NTILE(5) OVER (ORDER BY SUM(t.Amount) DESC) as M_Score
    FROM Accounts a
    LEFT JOIN Transactions t ON a.AccountID = t.AccountID AND t.Status = 'Completed'
    WHERE a.Status = 'Active'
        AND t.TransactionDate >= DATEADD(MONTH, -6, GETDATE())
    GROUP BY a.AccountID, a.CustomerName
)
SELECT 
    CASE 
        WHEN R_Score >= 4 AND F_Score >= 4 AND M_Score >= 4 THEN 'Champions'
        WHEN R_Score >= 3 AND F_Score >= 3 AND M_Score >= 3 THEN 'Loyal Customers'
        WHEN R_Score >= 4 AND F_Score <= 2 THEN 'Recent Customers'
        WHEN R_Score <= 2 AND F_Score >= 4 THEN 'At Risk'
        WHEN R_Score <= 2 AND F_Score <= 2 THEN 'Lost'
        ELSE 'Potential'
    END as Segment,
    COUNT(*) as CustomerCount,
    AVG(Frequency) as AvgFrequency,
    AVG(Monetary) as AvgMonetary,
    CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS DECIMAL(5,2)) as Percentage
FROM RFMScores
GROUP BY 
    CASE 
        WHEN R_Score >= 4 AND F_Score >= 4 AND M_Score >= 4 THEN 'Champions'
        WHEN R_Score >= 3 AND F_Score >= 3 AND M_Score >= 3 THEN 'Loyal Customers'
        WHEN R_Score >= 4 AND F_Score <= 2 THEN 'Recent Customers'
        WHEN R_Score <= 2 AND F_Score >= 4 THEN 'At Risk'
        WHEN R_Score <= 2 AND F_Score <= 2 THEN 'Lost'
        ELSE 'Potential'
    END
ORDER BY CustomerCount DESC;
