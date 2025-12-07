-- =============================================
-- Histogram - Processing Time Distribution
-- =============================================
-- For histograms showing transaction processing time distributions

-- Processing time distribution (in seconds)
WITH ProcessingTimes AS (
    SELECT 
        DATEDIFF(SECOND, TransactionInitiatedDate, TransactionCompletedDate) as ProcessingSeconds,
        FLOOR(DATEDIFF(SECOND, TransactionInitiatedDate, TransactionCompletedDate) / 5) * 5 as BinStart  -- 5-second bins
    FROM Transactions
    WHERE Status = 'Completed'
        AND TransactionDate >= DATEADD(DAY, -7, GETDATE())
        AND TransactionCompletedDate IS NOT NULL
        AND DATEDIFF(SECOND, TransactionInitiatedDate, TransactionCompletedDate) <= 120  -- Focus on 0-120 seconds
)
SELECT 
    BinStart,
    BinStart + 5 as BinEnd,
    CAST(BinStart AS VARCHAR) + '-' + CAST(BinStart + 5 AS VARCHAR) + 's' as TimeRange,
    COUNT(*) as TransactionCount,
    AVG(ProcessingSeconds) as AvgSeconds,
    CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS DECIMAL(5,2)) as Percentage
FROM ProcessingTimes
GROUP BY BinStart
ORDER BY BinStart;

-- Processing time percentiles
SELECT 
    PaymentMethod,
    COUNT(*) as Transactions,
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY DATEDIFF(SECOND, TransactionInitiatedDate, TransactionCompletedDate)) 
        OVER (PARTITION BY PaymentMethod) as P50_Median,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY DATEDIFF(SECOND, TransactionInitiatedDate, TransactionCompletedDate)) 
        OVER (PARTITION BY PaymentMethod) as P75,
    PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY DATEDIFF(SECOND, TransactionInitiatedDate, TransactionCompletedDate)) 
        OVER (PARTITION BY PaymentMethod) as P90,
    PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY DATEDIFF(SECOND, TransactionInitiatedDate, TransactionCompletedDate)) 
        OVER (PARTITION BY PaymentMethod) as P95,
    AVG(DATEDIFF(SECOND, TransactionInitiatedDate, TransactionCompletedDate)) as AvgSeconds,
    MIN(DATEDIFF(SECOND, TransactionInitiatedDate, TransactionCompletedDate)) as MinSeconds,
    MAX(DATEDIFF(SECOND, TransactionInitiatedDate, TransactionCompletedDate)) as MaxSeconds
FROM Transactions
WHERE Status = 'Completed'
    AND TransactionDate >= DATEADD(DAY, -7, GETDATE())
    AND TransactionCompletedDate IS NOT NULL
GROUP BY PaymentMethod
ORDER BY AvgSeconds;

-- Settlement time distribution (hours)
WITH SettlementTimes AS (
    SELECT 
        DATEDIFF(HOUR, PaymentDate, ActualSettlementDate) as SettlementHours,
        FLOOR(DATEDIFF(HOUR, PaymentDate, ActualSettlementDate) / 6) * 6 as BinStart  -- 6-hour bins
    FROM Payments
    WHERE SettlementStatus = 'Settled'
        AND PaymentDate >= DATEADD(DAY, -30, GETDATE())
        AND DATEDIFF(HOUR, PaymentDate, ActualSettlementDate) <= 168  -- Focus on 0-7 days
)
SELECT 
    BinStart,
    BinStart + 6 as BinEnd,
    CAST(BinStart AS VARCHAR) + '-' + CAST(BinStart + 6 AS VARCHAR) + 'h' as TimeRange,
    COUNT(*) as PaymentCount,
    AVG(SettlementHours) as AvgHours,
    CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS DECIMAL(5,2)) as Percentage
FROM SettlementTimes
GROUP BY BinStart
ORDER BY BinStart;

-- Response time distribution by hour of day
SELECT 
    DATEPART(HOUR, TransactionInitiatedDate) as HourOfDay,
    COUNT(*) as Transactions,
    AVG(DATEDIFF(MILLISECOND, TransactionInitiatedDate, TransactionCompletedDate)) as AvgMilliseconds,
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY DATEDIFF(MILLISECOND, TransactionInitiatedDate, TransactionCompletedDate)) 
        OVER (PARTITION BY DATEPART(HOUR, TransactionInitiatedDate)) as MedianMilliseconds,
    PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY DATEDIFF(MILLISECOND, TransactionInitiatedDate, TransactionCompletedDate)) 
        OVER (PARTITION BY DATEPART(HOUR, TransactionInitiatedDate)) as P95Milliseconds
FROM Transactions
WHERE Status = 'Completed'
    AND TransactionDate >= DATEADD(DAY, -7, GETDATE())
    AND TransactionCompletedDate IS NOT NULL
GROUP BY DATEPART(HOUR, TransactionInitiatedDate)
ORDER BY HourOfDay;
