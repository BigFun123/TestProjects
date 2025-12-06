-- =============================================
-- Audit Trail and Transaction History
-- =============================================
-- Comprehensive audit queries for compliance and investigation

-- Complete transaction audit trail
SELECT 
    t.TransactionID,
    t.AccountID,
    a.CustomerName,
    t.TransactionDate,
    t.TransactionType,
    t.Amount,
    t.Status,
    t.CreatedBy,
    t.CreatedDate,
    t.ModifiedBy,
    t.ModifiedDate,
    t.ApprovedBy,
    t.ApprovalDate,
    t.IPAddress,
    t.DeviceID,
    t.UserAgent,
    t.Location,
    CASE 
        WHEN t.ModifiedBy IS NOT NULL THEN 'Modified'
        WHEN t.Status = 'Reversed' THEN 'Reversed'
        ELSE 'Original'
    END as AuditStatus
FROM Transactions t
INNER JOIN Accounts a ON t.AccountID = a.AccountID
WHERE t.AccountID = @AccountID  -- Parameter
    AND t.TransactionDate >= @StartDate  -- Parameter
    AND t.TransactionDate <= @EndDate  -- Parameter
ORDER BY t.TransactionDate DESC;

-- Account modification history
SELECT 
    ah.AuditID,
    ah.AccountID,
    a.CustomerName,
    ah.ChangeDate,
    ah.ChangedBy,
    ah.ChangeType,  -- 'Update', 'StatusChange', 'LimitChange'
    ah.FieldName,
    ah.OldValue,
    ah.NewValue,
    ah.Reason,
    ah.IPAddress,
    ah.ApprovalRequired,
    ah.ApprovedBy,
    ah.ApprovalDate
FROM AccountAuditHistory ah
INNER JOIN Accounts a ON ah.AccountID = a.AccountID
WHERE ah.ChangeDate >= DATEADD(DAY, -30, GETDATE())
ORDER BY ah.ChangeDate DESC;

-- User access audit log
SELECT 
    l.LogID,
    l.UserID,
    u.UserName,
    l.LoginDate,
    l.LogoutDate,
    DATEDIFF(MINUTE, l.LoginDate, l.LogoutDate) as SessionDurationMinutes,
    l.IPAddress,
    l.Location,
    l.DeviceType,
    l.ActionsTaken,
    l.AccountsAccessed,
    CASE 
        WHEN l.IPAddress NOT IN (SELECT AllowedIP FROM UserAllowedIPs WHERE UserID = l.UserID) THEN 'Unusual IP'
        WHEN DATEPART(HOUR, l.LoginDate) NOT BETWEEN 6 AND 22 THEN 'Off-Hours Access'
        WHEN l.FailedLoginAttempts >= 3 THEN 'Multiple Failed Attempts'
        ELSE 'Normal'
    END as SecurityFlag
FROM AccessLogs l
INNER JOIN Users u ON l.UserID = u.UserID
WHERE l.LoginDate >= DATEADD(DAY, -7, GETDATE())
ORDER BY l.LoginDate DESC;

-- Transaction reversal audit
SELECT 
    r.ReversalID,
    r.OriginalTransactionID,
    ot.Amount as OriginalAmount,
    ot.TransactionDate as OriginalDate,
    r.ReversalTransactionID,
    rt.TransactionDate as ReversalDate,
    DATEDIFF(DAY, ot.TransactionDate, rt.TransactionDate) as DaysToReversal,
    r.ReversalReason,
    r.RequestedBy,
    r.ApprovedBy,
    r.ApprovalDate,
    CASE 
        WHEN DATEDIFF(DAY, ot.TransactionDate, rt.TransactionDate) = 0 THEN 'Same Day'
        WHEN DATEDIFF(DAY, ot.TransactionDate, rt.TransactionDate) <= 3 THEN 'Within 3 Days'
        WHEN DATEDIFF(DAY, ot.TransactionDate, rt.TransactionDate) <= 30 THEN 'Within 30 Days'
        ELSE 'Over 30 Days'
    END as ReversalTiming
FROM TransactionReversals r
INNER JOIN Transactions ot ON r.OriginalTransactionID = ot.TransactionID
INNER JOIN Transactions rt ON r.ReversalTransactionID = rt.TransactionID
WHERE rt.TransactionDate >= DATEADD(DAY, -30, GETDATE())
ORDER BY rt.TransactionDate DESC;

-- Permission changes audit
SELECT 
    pc.ChangeID,
    pc.UserID,
    u.UserName,
    pc.ChangeDate,
    pc.ChangedBy,
    cb.UserName as ChangedByName,
    pc.PermissionType,
    pc.OldPermission,
    pc.NewPermission,
    pc.Reason,
    pc.ApprovedBy,
    CASE 
        WHEN pc.NewPermission LIKE '%Admin%' THEN 'Elevated Privileges'
        WHEN pc.NewPermission LIKE '%Approve%' THEN 'Approval Rights'
        ELSE 'Standard'
    END as PrivilegeLevel
FROM PermissionChanges pc
INNER JOIN Users u ON pc.UserID = u.UserID
INNER JOIN Users cb ON pc.ChangedBy = cb.UserID
WHERE pc.ChangeDate >= DATEADD(DAY, -90, GETDATE())
ORDER BY pc.ChangeDate DESC;

-- Data export audit trail
SELECT 
    e.ExportID,
    e.ExportDate,
    e.ExportedBy,
    u.UserName,
    u.Department,
    e.DataType,  -- 'Transactions', 'CustomerData', 'Reports'
    e.RecordCount,
    e.DateRangeStart,
    e.DateRangeEnd,
    e.ExportFormat,  -- 'CSV', 'Excel', 'PDF'
    e.Purpose,
    e.ApprovedBy,
    CASE 
        WHEN e.RecordCount >= 10000 THEN 'Large Export'
        WHEN e.DataType = 'CustomerData' THEN 'Sensitive Data'
        WHEN u.Department NOT IN ('Compliance', 'Finance', 'Audit') THEN 'Review Required'
        ELSE 'Normal'
    END as SecurityLevel
FROM DataExports e
INNER JOIN Users u ON e.ExportedBy = u.UserID
WHERE e.ExportDate >= DATEADD(DAY, -30, GETDATE())
ORDER BY e.ExportDate DESC;

-- Account status change timeline
SELECT 
    sc.ChangeID,
    sc.AccountID,
    a.CustomerName,
    sc.ChangeDate,
    sc.OldStatus,
    sc.NewStatus,
    sc.Reason,
    sc.ChangedBy,
    u.UserName,
    sc.AutomatedChange,
    CASE 
        WHEN sc.NewStatus = 'Suspended' THEN 'Risk Management Action'
        WHEN sc.NewStatus = 'Closed' THEN 'Account Closure'
        WHEN sc.NewStatus = 'Frozen' THEN 'Security Hold'
        WHEN sc.NewStatus = 'Active' AND sc.OldStatus IN ('Suspended', 'Frozen') THEN 'Reactivation'
        ELSE 'Standard Change'
    END as ChangeCategory
FROM AccountStatusChanges sc
INNER JOIN Accounts a ON sc.AccountID = a.AccountID
LEFT JOIN Users u ON sc.ChangedBy = u.UserID
WHERE sc.ChangeDate >= DATEADD(MONTH, -3, GETDATE())
ORDER BY sc.ChangeDate DESC;
