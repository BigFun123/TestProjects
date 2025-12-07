-- =============================================
-- Histogram - Transaction Amount Distribution
-- =============================================
-- For histograms showing the distribution of transaction amounts

-- Transaction amount distribution (binned)
WITH AmountBins AS (
    SELECT 
        Amount,
        FLOOR(Amount / 100) * 100 as BinStart,  -- $100 bins
        FLOOR(Amount / 100) * 100 + 100 as BinEnd
    FROM Transactions
    WHERE TransactionDate >= DATEADD(MONTH, -1, GETDATE())
        AND Status = 'Completed'
        AND Amount <= 5000  -- Focus on typical range
)
SELECT 
    BinStart,
    BinEnd,
    CAST(BinStart AS VARCHAR) + ' - ' + CAST(BinEnd AS VARCHAR) as BinRange,
    COUNT(*) as TransactionCount,
    AVG(Amount) as AvgAmount,
    CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS DECIMAL(5,2)) as Percentage
FROM AmountBins
GROUP BY BinStart, BinEnd
ORDER BY BinStart;

-- Transaction amount distribution with percentiles
SELECT 
    PERCENTILE_CONT(0.10) WITHIN GROUP (ORDER BY Amount) OVER () as P10,
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Amount) OVER () as P25,
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY Amount) OVER () as P50_Median,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Amount) OVER () as P75,
    PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY Amount) OVER () as P90,
    PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY Amount) OVER () as P95,
    PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY Amount) OVER () as P99,
    MIN(Amount) as MinAmount,
    MAX(Amount) as MaxAmount,
    AVG(Amount) as AvgAmount,
    STDEV(Amount) as StdDevAmount
FROM Transactions
WHERE TransactionDate >= DATEADD(MONTH, -1, GETDATE())
    AND Status = 'Completed';

-- Log-scale amount distribution (for wide range)
SELECT 
    CASE 
        WHEN Amount < 1 THEN '< $1'
        WHEN Amount < 10 THEN '$1 - $10'
        WHEN Amount < 100 THEN '$10 - $100'
        WHEN Amount < 1000 THEN '$100 - $1K'
        WHEN Amount < 10000 THEN '$1K - $10K'
        WHEN Amount < 100000 THEN '$10K - $100K'
        ELSE '$100K+'
    END as AmountRange,
    COUNT(*) as TransactionCount,
    SUM(Amount) as TotalVolume,
    AVG(Amount) as AvgAmount,
    MIN(Amount) as MinAmount,
    MAX(Amount) as MaxAmount
FROM Transactions
WHERE TransactionDate >= DATEADD(MONTH, -1, GETDATE())
    AND Status = 'Completed'
GROUP BY 
    CASE 
        WHEN Amount < 1 THEN '< $1'
        WHEN Amount < 10 THEN '$1 - $10'
        WHEN Amount < 100 THEN '$10 - $100'
        WHEN Amount < 1000 THEN '$100 - $1K'
        WHEN Amount < 10000 THEN '$1K - $10K'
        WHEN Amount < 100000 THEN '$10K - $100K'
        ELSE '$100K+'
    END
ORDER BY MIN(Amount);

-- Amount distribution by transaction type
WITH AmountBins AS (
    SELECT 
        TransactionType,
        Amount,
        FLOOR(Amount / 50) * 50 as BinStart
    FROM Transactions
    WHERE TransactionDate >= DATEADD(MONTH, -1, GETDATE())
        AND Status = 'Completed'
        AND Amount <= 2000
)
SELECT 
    TransactionType,
    BinStart,
    BinStart + 50 as BinEnd,
    COUNT(*) as TransactionCount,
    AVG(Amount) as AvgAmount
FROM AmountBins
GROUP BY TransactionType, BinStart
ORDER BY TransactionType, BinStart;
