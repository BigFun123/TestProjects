-- =============================================
-- Payment Settlement and Reconciliation
-- =============================================
-- Tracks payment settlement status and reconciliation

-- Daily settlement summary
SELECT 
    CAST(SettlementDate AS DATE) as Date,
    PaymentProcessor,
    COUNT(*) as TotalPayments,
    SUM(Amount) as TotalAmount,
    SUM(ProcessingFee) as TotalFees,
    SUM(Amount - ProcessingFee) as NetSettlement,
    SUM(CASE WHEN SettlementStatus = 'Settled' THEN 1 ELSE 0 END) as SettledCount,
    SUM(CASE WHEN SettlementStatus = 'Pending' THEN 1 ELSE 0 END) as PendingCount,
    SUM(CASE WHEN SettlementStatus = 'Failed' THEN 1 ELSE 0 END) as FailedCount,
    CAST(SUM(CASE WHEN SettlementStatus = 'Settled' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) as SettlementRate
FROM Payments
WHERE SettlementDate >= DATEADD(DAY, -30, GETDATE())
GROUP BY CAST(SettlementDate AS DATE), PaymentProcessor
ORDER BY Date DESC, PaymentProcessor;

-- Unsettled payments requiring attention
SELECT 
    p.PaymentID,
    p.TransactionID,
    p.AccountID,
    p.Amount,
    p.ProcessingFee,
    p.PaymentProcessor,
    p.PaymentDate,
    p.ExpectedSettlementDate,
    DATEDIFF(DAY, p.ExpectedSettlementDate, GETDATE()) as DaysOverdue,
    p.SettlementStatus,
    p.FailureReason,
    CASE 
        WHEN DATEDIFF(DAY, p.ExpectedSettlementDate, GETDATE()) >= 7 THEN 'Critical - Escalate'
        WHEN DATEDIFF(DAY, p.ExpectedSettlementDate, GETDATE()) >= 3 THEN 'High Priority'
        WHEN DATEDIFF(DAY, p.ExpectedSettlementDate, GETDATE()) >= 1 THEN 'Review Required'
        ELSE 'Monitor'
    END as ActionRequired
FROM Payments p
WHERE p.SettlementStatus IN ('Pending', 'Failed')
    AND p.ExpectedSettlementDate < GETDATE()
ORDER BY DaysOverdue DESC, p.Amount DESC;

-- Settlement reconciliation by processor
SELECT 
    p.PaymentProcessor,
    COUNT(*) as TotalPayments,
    SUM(p.Amount) as ExpectedAmount,
    COALESCE(s.SettledAmount, 0) as ActualSettledAmount,
    SUM(p.Amount) - COALESCE(s.SettledAmount, 0) as Discrepancy,
    SUM(p.ProcessingFee) as TotalFeesCharged,
    COALESCE(s.ActualFees, 0) as ActualFeesDeducted,
    SUM(p.ProcessingFee) - COALESCE(s.ActualFees, 0) as FeeDiscrepancy
FROM Payments p
LEFT JOIN (
    SELECT 
        PaymentProcessor,
        SUM(SettledAmount) as SettledAmount,
        SUM(FeeAmount) as ActualFees
    FROM SettlementRecords
    WHERE SettlementDate = CAST(GETDATE() AS DATE)
    GROUP BY PaymentProcessor
) s ON p.PaymentProcessor = s.PaymentProcessor
WHERE CAST(p.PaymentDate AS DATE) = CAST(GETDATE() AS DATE)
GROUP BY p.PaymentProcessor, s.SettledAmount, s.ActualFees
HAVING ABS(SUM(p.Amount) - COALESCE(s.SettledAmount, 0)) > 0.01  -- Flag discrepancies
ORDER BY ABS(Discrepancy) DESC;

-- Settlement velocity analysis
SELECT 
    PaymentProcessor,
    AVG(DATEDIFF(HOUR, PaymentDate, ActualSettlementDate)) as AvgSettlementHours,
    MIN(DATEDIFF(HOUR, PaymentDate, ActualSettlementDate)) as FastestSettlementHours,
    MAX(DATEDIFF(HOUR, PaymentDate, ActualSettlementDate)) as SlowestSettlementHours,
    STDEV(DATEDIFF(HOUR, PaymentDate, ActualSettlementDate)) as StdDevHours,
    COUNT(*) as TotalSettled
FROM Payments
WHERE SettlementStatus = 'Settled'
    AND PaymentDate >= DATEADD(DAY, -30, GETDATE())
GROUP BY PaymentProcessor
ORDER BY AvgSettlementHours;
