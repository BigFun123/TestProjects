-- =============================================
-- Regulatory Reporting Queries
-- =============================================
-- Generate reports for regulatory compliance requirements

-- Currency Transaction Report (CTR) - Transactions over $10,000
SELECT 
    t.TransactionID,
    t.TransactionDate,
    t.AccountID,
    a.CustomerName,
    a.TaxID,
    a.Address,
    a.City,
    a.State,
    a.ZipCode,
    t.Amount,
    t.TransactionType,
    t.PaymentMethod,
    CASE 
        WHEN t.PaymentMethod = 'Cash' THEN 'Cash In'
        WHEN t.TransactionType = 'Withdrawal' AND t.PaymentMethod = 'Cash' THEN 'Cash Out'
        ELSE 'Non-Cash'
    END as CTRType,
    t.Location,
    t.ProcessedBy
FROM Transactions t
INNER JOIN Accounts a ON t.AccountID = a.AccountID
WHERE t.Amount > 10000
    AND t.TransactionDate >= DATEADD(DAY, -1, GETDATE())
    AND t.Status = 'Completed'
ORDER BY t.Amount DESC;

-- Suspicious Activity Report (SAR) - Potential filing candidates
SELECT 
    sar.SARID,
    sar.AccountID,
    a.CustomerName,
    sar.SuspiciousActivityType,
    sar.DetectionDate,
    sar.TotalAmountInvolved,
    sar.NumberOfTransactions,
    sar.Description,
    sar.FilingStatus,
    sar.AssignedTo,
    DATEDIFF(DAY, sar.DetectionDate, GETDATE()) as DaysSinceDetection,
    CASE 
        WHEN sar.FilingStatus = 'Pending Review' AND DATEDIFF(DAY, sar.DetectionDate, GETDATE()) > 30 THEN 'URGENT - 30 Day Deadline Approaching'
        WHEN sar.FilingStatus = 'Pending Review' AND DATEDIFF(DAY, sar.DetectionDate, GETDATE()) > 15 THEN 'HIGH PRIORITY'
        WHEN sar.FilingStatus = 'Under Investigation' THEN 'In Progress'
        WHEN sar.FilingStatus = 'Filed' THEN 'Complete'
        ELSE 'Review Required'
    END as ActionStatus
FROM SuspiciousActivityReports sar
INNER JOIN Accounts a ON sar.AccountID = a.AccountID
WHERE sar.FilingStatus IN ('Pending Review', 'Under Investigation')
ORDER BY DaysSinceDetection DESC;

-- Know Your Customer (KYC) Review Due
SELECT 
    a.AccountID,
    a.CustomerName,
    a.Email,
    a.AccountType,
    a.AccountOpenDate,
    k.LastKYCReviewDate,
    k.KYCRiskLevel,
    DATEDIFF(MONTH, k.LastKYCReviewDate, GETDATE()) as MonthsSinceReview,
    CASE 
        WHEN k.KYCRiskLevel = 'High' THEN 12  -- Annual for high risk
        WHEN k.KYCRiskLevel = 'Medium' THEN 24  -- Every 2 years for medium
        ELSE 36  -- Every 3 years for low risk
    END as ReviewFrequencyMonths,
    CASE 
        WHEN DATEDIFF(MONTH, k.LastKYCReviewDate, GETDATE()) >= 
             CASE WHEN k.KYCRiskLevel = 'High' THEN 12 WHEN k.KYCRiskLevel = 'Medium' THEN 24 ELSE 36 END
        THEN 'OVERDUE'
        WHEN DATEDIFF(MONTH, k.LastKYCReviewDate, GETDATE()) >= 
             CASE WHEN k.KYCRiskLevel = 'High' THEN 10 WHEN k.KYCRiskLevel = 'Medium' THEN 22 ELSE 34 END
        THEN 'DUE SOON'
        ELSE 'CURRENT'
    END as ReviewStatus
FROM Accounts a
INNER JOIN KYCRecords k ON a.AccountID = k.AccountID
WHERE a.Status = 'Active'
    AND DATEDIFF(MONTH, k.LastKYCReviewDate, GETDATE()) >= 
        CASE 
            WHEN k.KYCRiskLevel = 'High' THEN 10
            WHEN k.KYCRiskLevel = 'Medium' THEN 22
            ELSE 34
        END
ORDER BY MonthsSinceReview DESC;

-- Large Value Transfer Report (International Wires)
SELECT 
    t.TransactionID,
    t.TransactionDate,
    t.AccountID,
    a.CustomerName,
    t.Amount,
    t.Currency,
    t.BeneficiaryName,
    t.BeneficiaryBank,
    t.BeneficiaryCountry,
    t.Purpose,
    t.SourceOfFunds,
    CASE 
        WHEN t.Amount >= 50000 THEN 'Enhanced Due Diligence Required'
        WHEN t.Amount >= 25000 THEN 'Standard Review'
        ELSE 'Monitor'
    END as ReviewLevel
FROM Transactions t
INNER JOIN Accounts a ON t.AccountID = a.AccountID
WHERE t.TransactionType = 'International Wire'
    AND t.Amount >= 10000
    AND t.TransactionDate >= DATEADD(MONTH, -1, GETDATE())
    AND t.Status = 'Completed'
ORDER BY t.Amount DESC;

-- Office of Foreign Assets Control (OFAC) Screening Results
SELECT 
    s.ScreeningID,
    s.ScreeningDate,
    s.EntityType,  -- 'Customer' or 'Transaction'
    s.EntityID,
    s.EntityName,
    s.MatchType,  -- 'Exact', 'Fuzzy', 'Partial'
    s.MatchScore,
    s.ListType,  -- 'SDN', 'Sectoral', 'Non-SDN'
    s.ReviewStatus,
    s.FalsePositive,
    s.ReviewedBy,
    s.ReviewDate,
    DATEDIFF(HOUR, s.ScreeningDate, COALESCE(s.ReviewDate, GETDATE())) as HoursToReview
FROM OFACScreenings s
WHERE s.ReviewStatus IN ('Pending', 'Under Review')
    OR (s.ReviewStatus = 'Potential Match' AND s.FalsePositive IS NULL)
ORDER BY s.MatchScore DESC, s.ScreeningDate;

-- Aggregate Transaction Report by Customer (Monthly)
SELECT 
    a.AccountID,
    a.CustomerName,
    a.TaxID,
    DATEPART(YEAR, t.TransactionDate) as Year,
    DATEPART(MONTH, t.TransactionDate) as Month,
    COUNT(*) as TransactionCount,
    SUM(CASE WHEN t.TransactionType IN ('Credit', 'Deposit') THEN t.Amount ELSE 0 END) as TotalCredits,
    SUM(CASE WHEN t.TransactionType IN ('Debit', 'Withdrawal') THEN t.Amount ELSE 0 END) as TotalDebits,
    SUM(t.Amount) as NetAmount,
    MAX(t.Amount) as LargestTransaction
FROM Transactions t
INNER JOIN Accounts a ON t.AccountID = a.AccountID
WHERE t.Status = 'Completed'
    AND t.TransactionDate >= DATEADD(MONTH, -3, GETDATE())
GROUP BY a.AccountID, a.CustomerName, a.TaxID, 
         DATEPART(YEAR, t.TransactionDate), DATEPART(MONTH, t.TransactionDate)
HAVING SUM(t.Amount) >= 50000  -- Report threshold
ORDER BY Year DESC, Month DESC, NetAmount DESC;
