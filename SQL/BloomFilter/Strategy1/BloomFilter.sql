-- =============================================
-- Bloom Filter Demo - Usage Examples
-- =============================================
-- This script demonstrates how to use the Bloom filter
-- to efficiently check if emails exist before querying the main table

USE BloomFilterDemo;
GO

PRINT '========================================';
PRINT 'BLOOM FILTER DEMONSTRATION';
PRINT '========================================';
PRINT '';

-- =============================================
-- Step 1: View Current Data
-- =============================================
PRINT '1. Current Accounts in Database:';
PRINT '----------------------------------------';
SELECT AccountID, CustomerName, Email, Balance, Status
FROM dbo.Accounts
ORDER BY AccountID;
GO

-- =============================================
-- Step 2: Populate Bloom Filter
-- =============================================
PRINT '';
PRINT '2. Populating Bloom Filter with existing emails...';
PRINT '----------------------------------------';

-- Add all existing emails to the Bloom filter
DECLARE @Email NVARCHAR(255);
DECLARE email_cursor CURSOR FOR
    SELECT Email FROM dbo.Accounts;

OPEN email_cursor;
FETCH NEXT FROM email_cursor INTO @Email;

WHILE @@FETCH_STATUS = 0
BEGIN
    EXEC dbo.sp_AddToBloomFilter @Email;
    PRINT 'Added: ' + @Email;
    FETCH NEXT FROM email_cursor INTO @Email;
END

CLOSE email_cursor;
DEALLOCATE email_cursor;

PRINT 'Bloom filter populated!';
GO

-- =============================================
-- Step 3: Check Bloom Filter Statistics
-- =============================================
PRINT '';
PRINT '3. Bloom Filter Statistics:';
PRINT '----------------------------------------';

SELECT 
    COUNT(*) as TotalBits,
    SUM(CAST(BitValue AS INT)) as BitsSet,
    CAST(SUM(CAST(BitValue AS INT)) * 100.0 / COUNT(*) AS DECIMAL(5,2)) as PercentageFilled
FROM dbo.BloomFilterBits;
GO

-- =============================================
-- Step 4: Test Bloom Filter - Positive Cases
-- =============================================
PRINT '';
PRINT '4. Testing Bloom Filter - Emails that EXIST:';
PRINT '----------------------------------------';

-- Test with existing emails
DECLARE @TestEmail NVARCHAR(255);
DECLARE @Exists BIT;

-- Test 1: john.smith@email.com (EXISTS)
SET @TestEmail = 'john.smith@email.com';
EXEC dbo.sp_CheckBloomFilter @TestEmail, @Exists OUTPUT;

PRINT 'Email: ' + @TestEmail;
PRINT 'Bloom Filter Says: ' + CASE WHEN @Exists = 1 THEN 'POSSIBLY EXISTS' ELSE 'DEFINITELY DOES NOT EXIST' END;

-- Verify in actual table
IF EXISTS (SELECT 1 FROM dbo.Accounts WHERE Email = @TestEmail)
    PRINT 'Actual Result: EXISTS (True Positive)';
ELSE
    PRINT 'Actual Result: DOES NOT EXIST (False Positive!)';
PRINT '';

-- Test 2: diana.prince@email.com (EXISTS)
SET @TestEmail = 'diana.prince@email.com';
EXEC dbo.sp_CheckBloomFilter @TestEmail, @Exists OUTPUT;

PRINT 'Email: ' + @TestEmail;
PRINT 'Bloom Filter Says: ' + CASE WHEN @Exists = 1 THEN 'POSSIBLY EXISTS' ELSE 'DEFINITELY DOES NOT EXIST' END;

IF EXISTS (SELECT 1 FROM dbo.Accounts WHERE Email = @TestEmail)
    PRINT 'Actual Result: EXISTS (True Positive)';
ELSE
    PRINT 'Actual Result: DOES NOT EXIST (False Positive!)';
PRINT '';

-- =============================================
-- Step 5: Test Bloom Filter - Negative Cases
-- =============================================
PRINT '';
PRINT '5. Testing Bloom Filter - Emails that DO NOT EXIST:';
PRINT '----------------------------------------';

-- Test 3: newuser@email.com (DOES NOT EXIST)
SET @TestEmail = 'newuser@email.com';
EXEC dbo.sp_CheckBloomFilter @TestEmail, @Exists OUTPUT;

PRINT 'Email: ' + @TestEmail;
PRINT 'Bloom Filter Says: ' + CASE WHEN @Exists = 1 THEN 'POSSIBLY EXISTS (False Positive!)' ELSE 'DEFINITELY DOES NOT EXIST' END;

IF EXISTS (SELECT 1 FROM dbo.Accounts WHERE Email = @TestEmail)
    PRINT 'Actual Result: EXISTS';
ELSE
    PRINT 'Actual Result: DOES NOT EXIST (True Negative)';
PRINT '';

-- Test 4: random.person@email.com (DOES NOT EXIST)
SET @TestEmail = 'random.person@email.com';
EXEC dbo.sp_CheckBloomFilter @TestEmail, @Exists OUTPUT;

PRINT 'Email: ' + @TestEmail;
PRINT 'Bloom Filter Says: ' + CASE WHEN @Exists = 1 THEN 'POSSIBLY EXISTS (False Positive!)' ELSE 'DEFINITELY DOES NOT EXIST' END;

IF EXISTS (SELECT 1 FROM dbo.Accounts WHERE Email = @TestEmail)
    PRINT 'Actual Result: EXISTS';
ELSE
    PRINT 'Actual Result: DOES NOT EXIST (True Negative)';
PRINT '';

-- =============================================
-- Step 6: Practical Use Case - Query Optimization
-- =============================================
PRINT '';
PRINT '6. Practical Use Case - Query Optimization:';
PRINT '----------------------------------------';
PRINT 'Using Bloom Filter to avoid expensive queries...';
PRINT '';

-- Function to demonstrate query optimization
DECLARE @SearchEmails TABLE (Email NVARCHAR(255));
INSERT INTO @SearchEmails VALUES 
    ('john.smith@email.com'),      -- EXISTS
    ('fake.user@email.com'),       -- DOES NOT EXIST
    ('jane.doe@email.com'),        -- EXISTS
    ('notreal@email.com'),         -- DOES NOT EXIST
    ('alice.williams@email.com');  -- EXISTS

DECLARE @CurrentEmail NVARCHAR(255);
DECLARE @MightExist BIT;
DECLARE @QueriesAvoided INT = 0;
DECLARE @QueriesMade INT = 0;

DECLARE search_cursor CURSOR FOR
    SELECT Email FROM @SearchEmails;

OPEN search_cursor;
FETCH NEXT FROM search_cursor INTO @CurrentEmail;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- First check Bloom filter
    EXEC dbo.sp_CheckBloomFilter @CurrentEmail, @MightExist OUTPUT;
    
    IF @MightExist = 0
    BEGIN
        -- Bloom filter says it definitely doesn't exist
        -- Skip the expensive database query!
        PRINT 'Email: ' + @CurrentEmail + ' - SKIPPED (Bloom filter: definitely not exists)';
        SET @QueriesAvoided = @QueriesAvoided + 1;
    END
    ELSE
    BEGIN
        -- Bloom filter says it might exist, so we need to check
        PRINT 'Email: ' + @CurrentEmail + ' - CHECKING (Bloom filter: might exist)';
        SET @QueriesMade = @QueriesMade + 1;
        
        -- Now query the actual table
        IF EXISTS (SELECT 1 FROM dbo.Accounts WHERE Email = @CurrentEmail)
        BEGIN
            SELECT 'FOUND:', AccountID, CustomerName, Balance, Status
            FROM dbo.Accounts
            WHERE Email = @CurrentEmail;
        END
        ELSE
        BEGIN
            PRINT '  Result: Not found (False Positive)';
        END
    END
    
    FETCH NEXT FROM search_cursor INTO @CurrentEmail;
END

CLOSE search_cursor;
DEALLOCATE search_cursor;

PRINT '';
PRINT 'Performance Summary:';
PRINT 'Queries Avoided: ' + CAST(@QueriesAvoided AS NVARCHAR(10));
PRINT 'Queries Made: ' + CAST(@QueriesMade AS NVARCHAR(10));
PRINT 'Efficiency: Avoided ' + CAST(@QueriesAvoided * 100 / 5 AS NVARCHAR(10)) + '% of unnecessary queries';
GO

-- =============================================
-- Step 7: Batch Query Demonstration
-- =============================================
PRINT '';
PRINT '7. Batch Query with Bloom Filter Optimization:';
PRINT '----------------------------------------';

-- Create a function that returns filtered results
SELECT 
    s.Email as SearchEmail,
    CASE 
        WHEN a.Email IS NOT NULL THEN 'FOUND'
        ELSE 'NOT FOUND'
    END as Status,
    a.AccountID,
    a.CustomerName,
    a.Balance
FROM (
    VALUES 
        ('john.smith@email.com'),
        ('nonexistent1@email.com'),
        ('jane.doe@email.com'),
        ('nonexistent2@email.com'),
        ('diana.prince@email.com')
) AS s(Email)
LEFT JOIN dbo.Accounts a ON s.Email = a.Email
ORDER BY 
    CASE WHEN a.Email IS NOT NULL THEN 0 ELSE 1 END,
    s.Email;
GO

-- =============================================
-- Step 8: View Hash Distribution
-- =============================================
PRINT '';
PRINT '8. Hash Distribution Analysis:';
PRINT '----------------------------------------';
PRINT 'Showing how emails map to different bit positions...';
PRINT '';

SELECT TOP 10
    a.Email,
    c.HashFunctionID,
    c.Description,
    dbo.fn_ComputeHash(a.Email, c.HashSeed, 10000) as BitPosition
FROM dbo.Accounts a
CROSS JOIN dbo.BloomFilterConfig c
ORDER BY a.Email, c.HashFunctionID;
GO

-- =============================================
-- Key Takeaways
-- =============================================
PRINT '';
PRINT '========================================';
PRINT 'KEY TAKEAWAYS:';
PRINT '========================================';
PRINT '1. Bloom filters can quickly tell you if something DEFINITELY does not exist';
PRINT '2. If Bloom filter says "might exist", you still need to check the actual data';
PRINT '3. False positives are possible, but false negatives are NOT';
PRINT '4. Great for avoiding expensive queries when data likely doesn''t exist';
PRINT '5. Trade-off: Small memory footprint vs. some false positive rate';
PRINT '';
PRINT 'Use Cases:';
PRINT '- Checking if email exists before sending verification';
PRINT '- Avoiding disk reads for non-existent cache keys';
PRINT '- Filtering out definitely-not-matching records before joins';
PRINT '- Duplicate detection in streaming data';
PRINT '========================================';
GO
