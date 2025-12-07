-- Performance Testing: Bloom Filter vs Regular SELECT
-- This script compares the performance of bloom filter searches vs regular name searches

-- First, ensure we have test data
-- Run insert_demo.sql and execute: EXEC insert_test_data;

-- Declare all variables at the beginning
DECLARE @test_name VARCHAR(64);
DECLARE @start_time DATETIME2;
DECLARE @end_time DATETIME2;
DECLARE @regular_select_time BIGINT;
DECLARE @bloom_filter_time BIGINT;
DECLARE @search_bloom BIGINT;
DECLARE @regular_multi_time BIGINT;
DECLARE @bloom_multi_time BIGINT;
DECLARE @regular_like_time BIGINT;
DECLARE @bloom_like_time BIGINT;
DECLARE @pattern_bloom BIGINT;
DECLARE @full_scan_time BIGINT;
DECLARE @bloom_scan_time BIGINT;
DECLARE @regular_notfound_time BIGINT;
DECLARE @bloom_notfound_time BIGINT;
DECLARE @notfound_bloom BIGINT;

-- Test Setup: Display current record count
SELECT COUNT(*) as total_records FROM bloom_names;

-- ====================================================================
-- TEST 1: Single Name Lookup Performance
-- ====================================================================

-- Test 1a: Regular SELECT with name index
SET @test_name = 'Charlie';
SET @start_time = SYSDATETIME();

SELECT id, name FROM bloom_names WHERE name = @test_name;

SET @end_time = SYSDATETIME();
SET @regular_select_time = DATEDIFF(MICROSECOND, @start_time, @end_time);

-- Test 1b: Bloom filter approach
SET @start_time = SYSDATETIME();
SET @search_bloom = dbo.calculate_bloom(@test_name);

SELECT id, name 
FROM bloom_names 
WHERE (bloom & @search_bloom) = @search_bloom
AND name = @test_name;

SET @end_time = SYSDATETIME();
SET @bloom_filter_time = DATEDIFF(MICROSECOND, @start_time, @end_time);

-- Display Test 1 Results
SELECT 
    'Single Name Lookup' as test_type,
    @regular_select_time as regular_select_microseconds,
    @bloom_filter_time as bloom_filter_microseconds,
    @regular_select_time - @bloom_filter_time as time_difference,
    ROUND(CAST(@regular_select_time AS FLOAT) / NULLIF(@bloom_filter_time, 0), 2) as performance_ratio;

-- ====================================================================
-- TEST 2: Multiple Name Lookups
-- ====================================================================

-- Test 2a: Regular SELECT for multiple names (without bloom)
SET @start_time = SYSDATETIME();

SELECT id, name FROM bloom_names WHERE name IN ('Alice', 'Bob', 'Charlie', 'David', 'Emma');

SET @end_time = SYSDATETIME();
SET @regular_multi_time = DATEDIFF(MICROSECOND, @start_time, @end_time);

-- Test 2b: Bloom filter approach for multiple names
SET @start_time = SYSDATETIME();

SELECT id, name 
FROM bloom_names 
WHERE (
    (bloom & dbo.calculate_bloom('Alice')) = dbo.calculate_bloom('Alice') OR
    (bloom & dbo.calculate_bloom('Bob')) = dbo.calculate_bloom('Bob') OR
    (bloom & dbo.calculate_bloom('Charlie')) = dbo.calculate_bloom('Charlie') OR
    (bloom & dbo.calculate_bloom('David')) = dbo.calculate_bloom('David') OR
    (bloom & dbo.calculate_bloom('Emma')) = dbo.calculate_bloom('Emma')
) AND name IN ('Alice', 'Bob', 'Charlie', 'David', 'Emma');

SET @end_time = SYSDATETIME();
SET @bloom_multi_time = DATEDIFF(MICROSECOND, @start_time, @end_time);

-- Display Test 2 Results
SELECT 
    'Multiple Name Lookup (5 names)' as test_type,
    @regular_multi_time as regular_select_microseconds,
    @bloom_multi_time as bloom_filter_microseconds,
    @regular_multi_time - @bloom_multi_time as time_difference,
    ROUND(CAST(@regular_multi_time AS FLOAT) / NULLIF(@bloom_multi_time, 0), 2) as performance_ratio;

-- ====================================================================
-- TEST 3: Pattern Matching with LIKE
-- ====================================================================

-- Test 3a: Regular LIKE query (must scan many records)
SET @start_time = SYSDATETIME();

SELECT id, name FROM bloom_names WHERE name LIKE 'Mar%';

SET @end_time = SYSDATETIME();
SET @regular_like_time = DATEDIFF(MICROSECOND, @start_time, @end_time);

-- Test 3b: Bloom filter pre-filtering with LIKE
SET @start_time = SYSDATETIME();
SET @pattern_bloom = dbo.calculate_bloom('Mar');

SELECT id, name 
FROM bloom_names 
WHERE (bloom & @pattern_bloom) = @pattern_bloom
AND name LIKE 'Mar%';

SET @end_time = SYSDATETIME();
SET @bloom_like_time = DATEDIFF(MICROSECOND, @start_time, @end_time);

-- Display Test 3 Results
SELECT 
    'Pattern Matching (LIKE)' as test_type,
    @regular_like_time as regular_like_microseconds,
    @bloom_like_time as bloom_prefilter_microseconds,
    @regular_like_time - @bloom_like_time as time_difference,
    ROUND(CAST(@regular_like_time AS FLOAT) / NULLIF(@bloom_like_time, 0), 2) as performance_ratio;

-- ====================================================================
-- TEST 4: Full Table Scan vs Bloom Filter Scan
-- ====================================================================

-- Test 4a: Count all names starting with specific characters (full scan)
SET @start_time = SYSDATETIME();

SELECT COUNT(*) FROM bloom_names WHERE name LIKE 'A%' OR name LIKE 'B%';

SET @end_time = SYSDATETIME();
SET @full_scan_time = DATEDIFF(MICROSECOND, @start_time, @end_time);

-- Test 4b: Bloom filter approach
SET @start_time = SYSDATETIME();

SELECT COUNT(*) 
FROM bloom_names 
WHERE (
    (bloom & dbo.calculate_bloom('A')) = dbo.calculate_bloom('A') OR
    (bloom & dbo.calculate_bloom('B')) = dbo.calculate_bloom('B')
) AND (name LIKE 'A%' OR name LIKE 'B%');

SET @end_time = SYSDATETIME();
SET @bloom_scan_time = DATEDIFF(MICROSECOND, @start_time, @end_time);

-- Display Test 4 Results
SELECT 
    'Full Table Scan (A% or B%)' as test_type,
    @full_scan_time as full_scan_microseconds,
    @bloom_scan_time as bloom_scan_microseconds,
    @full_scan_time - @bloom_scan_time as time_difference,
    ROUND(CAST(@full_scan_time AS FLOAT) / NULLIF(@bloom_scan_time, 0), 2) as performance_ratio;

-- ====================================================================
-- TEST 5: Non-existent Name Lookup (Bloom Filter Advantage)
-- ====================================================================

-- Test 5a: Regular SELECT for non-existent name
SET @start_time = SYSDATETIME();

SELECT id, name FROM bloom_names WHERE name = 'NonExistentName12345';

SET @end_time = SYSDATETIME();
SET @regular_notfound_time = DATEDIFF(MICROSECOND, @start_time, @end_time);

-- Test 5b: Bloom filter approach for non-existent name
SET @start_time = SYSDATETIME();
SET @notfound_bloom = dbo.calculate_bloom('NonExistentName12345');

SELECT id, name 
FROM bloom_names 
WHERE (bloom & @notfound_bloom) = @notfound_bloom
AND name = 'NonExistentName12345';

SET @end_time = SYSDATETIME();
SET @bloom_notfound_time = DATEDIFF(MICROSECOND, @start_time, @end_time);

-- Display Test 5 Results
SELECT 
    'Non-existent Name Lookup' as test_type,
    @regular_notfound_time as regular_select_microseconds,
    @bloom_notfound_time as bloom_filter_microseconds,
    @regular_notfound_time - @bloom_notfound_time as time_difference,
    ROUND(CAST(@regular_notfound_time AS FLOAT) / NULLIF(@bloom_notfound_time, 0), 2) as performance_ratio;

-- ====================================================================
-- COMPREHENSIVE PERFORMANCE SUMMARY
-- ====================================================================

SELECT 
    'PERFORMANCE SUMMARY' as title,
    '' as test_type,
    '' as winner,
    '' as notes
    
UNION ALL

SELECT 
    '---' as title,
    'Single Name Lookup' as test_type,
    CASE 
        WHEN @regular_select_time < @bloom_filter_time THEN 'Regular SELECT'
        ELSE 'Bloom Filter'
    END as winner,
    CONCAT('Ratio: ', ROUND(CAST(@regular_select_time AS FLOAT) / NULLIF(@bloom_filter_time, 0), 2), 'x') as notes

UNION ALL

SELECT 
    '---' as title,
    'Multiple Name Lookup' as test_type,
    CASE 
        WHEN @regular_multi_time < @bloom_multi_time THEN 'Regular SELECT'
        ELSE 'Bloom Filter'
    END as winner,
    CONCAT('Ratio: ', ROUND(CAST(@regular_multi_time AS FLOAT) / NULLIF(@bloom_multi_time, 0), 2), 'x') as notes

UNION ALL

SELECT 
    '---' as title,
    'Pattern Matching' as test_type,
    CASE 
        WHEN @regular_like_time < @bloom_like_time THEN 'Regular LIKE'
        ELSE 'Bloom Filter'
    END as winner,
    CONCAT('Ratio: ', ROUND(CAST(@regular_like_time AS FLOAT) / NULLIF(@bloom_like_time, 0), 2), 'x') as notes

UNION ALL

SELECT 
    '---' as title,
    'Full Table Scan' as test_type,
    CASE 
        WHEN @full_scan_time < @bloom_scan_time THEN 'Regular Scan'
        ELSE 'Bloom Filter'
    END as winner,
    CONCAT('Ratio: ', ROUND(CAST(@full_scan_time AS FLOAT) / NULLIF(@bloom_scan_time, 0), 2), 'x') as notes

UNION ALL

SELECT 
    '---' as title,
    'Non-existent Name' as test_type,
    CASE 
        WHEN @regular_notfound_time < @bloom_notfound_time THEN 'Regular SELECT'
        ELSE 'Bloom Filter'
    END as winner,
    CONCAT('Ratio: ', ROUND(CAST(@regular_notfound_time AS FLOAT) / NULLIF(@bloom_notfound_time, 0), 2), 'x') as notes;

-- ====================================================================
-- ADDITIONAL STATISTICS
-- ====================================================================

-- Analyze bloom filter efficiency
SELECT 
    'Bloom Filter Statistics' as metric_type,
    COUNT(*) as value,
    'Total Records' as description
FROM bloom_names

UNION ALL

SELECT 
    'Bloom Filter Statistics' as metric_type,
    COUNT(DISTINCT bloom) as value,
    'Unique Bloom Values' as description
FROM bloom_names

UNION ALL

SELECT 
    'Bloom Filter Statistics' as metric_type,
    CAST(COUNT(*) AS FLOAT) / NULLIF(COUNT(DISTINCT bloom), 0) as value,
    'Average Collision Rate' as description
FROM bloom_names;

-- Show index information
EXEC sp_helpindex 'bloom_names';
