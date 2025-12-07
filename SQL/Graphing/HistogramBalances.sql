-- =============================================
-- Histogram - Account Balance Distribution
-- =============================================
-- For histograms showing account balance distributions

-- Current balance distribution
WITH BalanceBins AS (
    SELECT 
        CurrentBalance,
        FLOOR(CurrentBalance / 1000) * 1000 as BinStart  -- $1,000 bins
    FROM Accounts
    WHERE Status = 'Active'
        AND CurrentBalance >= 0
        AND CurrentBalance <= 50000  -- Focus on typical range
)
SELECT 
    BinStart,
    BinStart + 1000 as BinEnd,
    '$' + CAST(BinStart AS VARCHAR) + ' - $' + CAST(BinStart + 1000 AS VARCHAR) as BalanceRange,
    COUNT(*) as AccountCount,
    AVG(CurrentBalance) as AvgBalance,
    CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS DECIMAL(5,2)) as Percentage
FROM BalanceBins
GROUP BY BinStart
ORDER BY BinStart;

-- Balance distribution with statistical summary
SELECT 
    'Current Balances' as Category,
    COUNT(*) as TotalAccounts,
    MIN(CurrentBalance) as MinBalance,
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY CurrentBalance) OVER () as Q1,
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY CurrentBalance) OVER () as Median,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY CurrentBalance) OVER () as Q3,
    MAX(CurrentBalance) as MaxBalance,
    AVG(CurrentBalance) as MeanBalance,
    STDEV(CurrentBalance) as StdDev,
    PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY CurrentBalance) OVER () as P90,
    PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY CurrentBalance) OVER () as P95,
    PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY CurrentBalance) OVER () as P99
FROM Accounts
WHERE Status = 'Active';

-- Balance distribution by account type
WITH BalanceBins AS (
    SELECT 
        AccountType,
        CurrentBalance,
        FLOOR(CurrentBalance / 2000) * 2000 as BinStart  -- $2,000 bins
    FROM Accounts
    WHERE Status = 'Active'
        AND CurrentBalance >= 0
        AND CurrentBalance <= 100000
)
SELECT 
    AccountType,
    BinStart,
    BinStart + 2000 as BinEnd,
    COUNT(*) as AccountCount,
    AVG(CurrentBalance) as AvgBalance,
    CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY AccountType) AS DECIMAL(5,2)) as PercentWithinType
FROM BalanceBins
GROUP BY AccountType, BinStart
ORDER BY AccountType, BinStart;

-- Available credit distribution (for credit accounts)
WITH CreditBins AS (
    SELECT 
        (CreditLimit - CurrentBalance) as AvailableCredit,
        FLOOR((CreditLimit - CurrentBalance) / 500) * 500 as BinStart  -- $500 bins
    FROM Accounts
    WHERE Status = 'Active'
        AND AccountType = 'Credit'
        AND CreditLimit > 0
        AND (CreditLimit - CurrentBalance) >= 0
        AND (CreditLimit - CurrentBalance) <= 10000
)
SELECT 
    BinStart,
    BinStart + 500 as BinEnd,
    '$' + CAST(BinStart AS VARCHAR) + ' - $' + CAST(BinStart + 500 AS VARCHAR) as CreditRange,
    COUNT(*) as AccountCount,
    AVG(AvailableCredit) as AvgAvailableCredit,
    CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS DECIMAL(5,2)) as Percentage
FROM CreditBins
GROUP BY BinStart
ORDER BY BinStart;

-- Credit utilization distribution
SELECT 
    CASE 
        WHEN (CurrentBalance * 100.0 / NULLIF(CreditLimit, 0)) < 10 THEN '0-10%'
        WHEN (CurrentBalance * 100.0 / NULLIF(CreditLimit, 0)) < 20 THEN '10-20%'
        WHEN (CurrentBalance * 100.0 / NULLIF(CreditLimit, 0)) < 30 THEN '20-30%'
        WHEN (CurrentBalance * 100.0 / NULLIF(CreditLimit, 0)) < 50 THEN '30-50%'
        WHEN (CurrentBalance * 100.0 / NULLIF(CreditLimit, 0)) < 70 THEN '50-70%'
        WHEN (CurrentBalance * 100.0 / NULLIF(CreditLimit, 0)) < 90 THEN '70-90%'
        ELSE '90-100%'
    END as UtilizationRange,
    COUNT(*) as AccountCount,
    AVG(CurrentBalance * 100.0 / NULLIF(CreditLimit, 0)) as AvgUtilization,
    CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS DECIMAL(5,2)) as Percentage
FROM Accounts
WHERE Status = 'Active'
    AND AccountType = 'Credit'
    AND CreditLimit > 0
GROUP BY 
    CASE 
        WHEN (CurrentBalance * 100.0 / NULLIF(CreditLimit, 0)) < 10 THEN '0-10%'
        WHEN (CurrentBalance * 100.0 / NULLIF(CreditLimit, 0)) < 20 THEN '10-20%'
        WHEN (CurrentBalance * 100.0 / NULLIF(CreditLimit, 0)) < 30 THEN '20-30%'
        WHEN (CurrentBalance * 100.0 / NULLIF(CreditLimit, 0)) < 50 THEN '30-50%'
        WHEN (CurrentBalance * 100.0 / NULLIF(CreditLimit, 0)) < 70 THEN '50-70%'
        WHEN (CurrentBalance * 100.0 / NULLIF(CreditLimit, 0)) < 90 THEN '70-90%'
        ELSE '90-100%'
    END
ORDER BY 
    CASE UtilizationRange
        WHEN '0-10%' THEN 1
        WHEN '10-20%' THEN 2
        WHEN '20-30%' THEN 3
        WHEN '30-50%' THEN 4
        WHEN '50-70%' THEN 5
        WHEN '70-90%' THEN 6
        ELSE 7
    END;
