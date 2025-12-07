-- =============================================
-- Segmentation - Revenue Breakdown
-- =============================================
-- For waterfall charts, treemaps, and stacked bar charts

-- Revenue by customer segment
SELECT 
    a.AccountType as Segment,
    COUNT(DISTINCT a.AccountID) as Customers,
    SUM(t.ProcessingFee) as Revenue,
    AVG(t.ProcessingFee) as AvgRevenuePerTransaction,
    COUNT(t.TransactionID) as TotalTransactions,
    CAST(SUM(t.ProcessingFee) * 100.0 / SUM(SUM(t.ProcessingFee)) OVER () AS DECIMAL(5,2)) as PercentOfRevenue
FROM Accounts a
INNER JOIN Transactions t ON a.AccountID = t.AccountID
WHERE t.TransactionDate >= DATEADD(MONTH, -1, GETDATE())
    AND t.Status = 'Completed'
GROUP BY a.AccountType
ORDER BY Revenue DESC;

-- Revenue by payment method
SELECT 
    PaymentMethod,
    COUNT(*) as Transactions,
    SUM(ProcessingFee) as Revenue,
    AVG(ProcessingFee) as AvgFee,
    SUM(Amount) as Volume,
    CAST(SUM(ProcessingFee) * 100.0 / SUM(SUM(ProcessingFee)) OVER () AS DECIMAL(5,2)) as PercentOfRevenue,
    CAST(SUM(ProcessingFee) * 100.0 / SUM(Amount) AS DECIMAL(5,2)) as EffectiveFeeRate
FROM Transactions
WHERE TransactionDate >= DATEADD(MONTH, -1, GETDATE())
    AND Status = 'Completed'
GROUP BY PaymentMethod
ORDER BY Revenue DESC;

-- Revenue by transaction type
SELECT 
    TransactionType,
    COUNT(*) as Transactions,
    SUM(ProcessingFee) as Revenue,
    SUM(Amount) as Volume,
    AVG(ProcessingFee) as AvgFee,
    CAST(SUM(ProcessingFee) * 100.0 / SUM(SUM(ProcessingFee)) OVER () AS DECIMAL(5,2)) as PercentOfRevenue
FROM Transactions
WHERE TransactionDate >= DATEADD(MONTH, -1, GETDATE())
    AND Status = 'Completed'
GROUP BY TransactionType
ORDER BY Revenue DESC;

-- Top revenue-generating customers (for treemap)
SELECT TOP 50
    a.AccountID,
    a.CustomerName,
    a.AccountType,
    COUNT(t.TransactionID) as Transactions,
    SUM(t.ProcessingFee) as Revenue,
    SUM(t.Amount) as Volume,
    CAST(SUM(t.ProcessingFee) * 100.0 / (SELECT SUM(ProcessingFee) FROM Transactions 
                                          WHERE TransactionDate >= DATEADD(MONTH, -1, GETDATE()) 
                                          AND Status = 'Completed') AS DECIMAL(5,2)) as PercentOfTotalRevenue
FROM Accounts a
INNER JOIN Transactions t ON a.AccountID = t.AccountID
WHERE t.TransactionDate >= DATEADD(MONTH, -1, GETDATE())
    AND t.Status = 'Completed'
GROUP BY a.AccountID, a.CustomerName, a.AccountType
ORDER BY Revenue DESC;

-- Revenue contribution by top 10% customers (Pareto analysis)
WITH CustomerRevenue AS (
    SELECT 
        a.AccountID,
        SUM(t.ProcessingFee) as Revenue,
        NTILE(10) OVER (ORDER BY SUM(t.ProcessingFee) DESC) as Decile
    FROM Accounts a
    INNER JOIN Transactions t ON a.AccountID = t.AccountID
    WHERE t.TransactionDate >= DATEADD(MONTH, -1, GETDATE())
        AND t.Status = 'Completed'
    GROUP BY a.AccountID
)
SELECT 
    Decile,
    COUNT(*) as Customers,
    SUM(Revenue) as Revenue,
    CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS DECIMAL(5,2)) as PercentOfCustomers,
    CAST(SUM(Revenue) * 100.0 / SUM(SUM(Revenue)) OVER () AS DECIMAL(5,2)) as PercentOfRevenue,
    CAST(SUM(SUM(Revenue)) OVER (ORDER BY Decile) * 100.0 / SUM(SUM(Revenue)) OVER () AS DECIMAL(5,2)) as CumulativePercent
FROM CustomerRevenue
GROUP BY Decile
ORDER BY Decile;
