-- =============================================
-- Distribution - Transaction Amount Ranges
-- =============================================
-- For pie charts and bar charts showing transaction amount distribution

-- Transaction size distribution
SELECT 
    CASE 
        WHEN Amount < 10 THEN '< $10'
        WHEN Amount < 50 THEN '$10 - $50'
        WHEN Amount < 100 THEN '$50 - $100'
        WHEN Amount < 500 THEN '$100 - $500'
        WHEN Amount < 1000 THEN '$500 - $1K'
        WHEN Amount < 5000 THEN '$1K - $5K'
        WHEN Amount < 10000 THEN '$5K - $10K'
        ELSE '$10K+'
    END as AmountRange,
    COUNT(*) as TransactionCount,
    SUM(Amount) as TotalVolume,
    AVG(Amount) as AvgAmount,
    CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS DECIMAL(5,2)) as PercentOfTransactions,
    CAST(SUM(Amount) * 100.0 / SUM(SUM(Amount)) OVER () AS DECIMAL(5,2)) as PercentOfVolume
FROM Transactions
WHERE TransactionDate >= DATEADD(MONTH, -1, GETDATE())
    AND Status = 'Completed'
GROUP BY 
    CASE 
        WHEN Amount < 10 THEN '< $10'
        WHEN Amount < 50 THEN '$10 - $50'
        WHEN Amount < 100 THEN '$50 - $100'
        WHEN Amount < 500 THEN '$100 - $500'
        WHEN Amount < 1000 THEN '$500 - $1K'
        WHEN Amount < 5000 THEN '$1K - $5K'
        WHEN Amount < 10000 THEN '$5K - $10K'
        ELSE '$10K+'
    END
ORDER BY 
    CASE 
        WHEN AmountRange = '< $10' THEN 1
        WHEN AmountRange = '$10 - $50' THEN 2
        WHEN AmountRange = '$50 - $100' THEN 3
        WHEN AmountRange = '$100 - $500' THEN 4
        WHEN AmountRange = '$500 - $1K' THEN 5
        WHEN AmountRange = '$1K - $5K' THEN 6
        WHEN AmountRange = '$5K - $10K' THEN 7
        ELSE 8
    END;

-- Account balance distribution
SELECT 
    CASE 
        WHEN CurrentBalance < 0 THEN 'Negative'
        WHEN CurrentBalance = 0 THEN 'Zero'
        WHEN CurrentBalance < 1000 THEN '< $1K'
        WHEN CurrentBalance < 10000 THEN '$1K - $10K'
        WHEN CurrentBalance < 50000 THEN '$10K - $50K'
        WHEN CurrentBalance < 100000 THEN '$50K - $100K'
        ELSE '$100K+'
    END as BalanceRange,
    COUNT(*) as AccountCount,
    SUM(CurrentBalance) as TotalBalance,
    AVG(CurrentBalance) as AvgBalance,
    CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS DECIMAL(5,2)) as PercentOfAccounts
FROM Accounts
WHERE Status = 'Active'
GROUP BY 
    CASE 
        WHEN CurrentBalance < 0 THEN 'Negative'
        WHEN CurrentBalance = 0 THEN 'Zero'
        WHEN CurrentBalance < 1000 THEN '< $1K'
        WHEN CurrentBalance < 10000 THEN '$1K - $10K'
        WHEN CurrentBalance < 50000 THEN '$10K - $50K'
        WHEN CurrentBalance < 100000 THEN '$50K - $100K'
        ELSE '$100K+'
    END
ORDER BY 
    CASE 
        WHEN BalanceRange = 'Negative' THEN 1
        WHEN BalanceRange = 'Zero' THEN 2
        WHEN BalanceRange = '< $1K' THEN 3
        WHEN BalanceRange = '$1K - $10K' THEN 4
        WHEN BalanceRange = '$10K - $50K' THEN 5
        WHEN BalanceRange = '$50K - $100K' THEN 6
        ELSE 7
    END;

-- Failure reason distribution
SELECT 
    FailureReason,
    COUNT(*) as FailureCount,
    SUM(Amount) as FailedVolume,
    CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS DECIMAL(5,2)) as PercentOfFailures
FROM Transactions
WHERE Status = 'Failed'
    AND TransactionDate >= DATEADD(MONTH, -1, GETDATE())
GROUP BY FailureReason
ORDER BY FailureCount DESC;

-- Account type distribution
SELECT 
    AccountType,
    COUNT(*) as AccountCount,
    SUM(CurrentBalance) as TotalBalance,
    AVG(CurrentBalance) as AvgBalance,
    CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS DECIMAL(5,2)) as PercentOfAccounts
FROM Accounts
WHERE Status = 'Active'
GROUP BY AccountType
ORDER BY AccountCount DESC;
