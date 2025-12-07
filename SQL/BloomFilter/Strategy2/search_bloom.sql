-- Search using Bloom Filter with bitwise operations
-- This demonstrates fast lookups using the bloom column

-- Function to search for a name using bloom filter
-- Returns candidate records that might match (with possible false positives)
DELIMITER $$

DROP PROCEDURE IF EXISTS search_by_bloom$$

CREATE PROCEDURE search_by_bloom(IN search_name VARCHAR(64))
BEGIN
    DECLARE search_bloom BIGINT UNSIGNED;
    
    -- Calculate bloom filter for the search term
    SET search_bloom = calculate_bloom(search_name);
    
    -- First pass: Use bloom filter to quickly eliminate non-matches
    -- If (bloom & search_bloom) == search_bloom, then the record is a candidate
    -- This uses bitwise AND to check if all bits in search_bloom are set in bloom
    SELECT 
        id, 
        name, 
        bloom,
        search_bloom as search_bloom_value,
        (bloom & search_bloom) as bitwise_and_result,
        CASE 
            WHEN (bloom & search_bloom) = search_bloom THEN 'CANDIDATE'
            ELSE 'ELIMINATED'
        END as bloom_filter_result
    FROM bloom_names
    WHERE (bloom & search_bloom) = search_bloom;
    
    -- Second pass: Verify exact match from candidates
    SELECT 
        id,
        name,
        bloom,
        'EXACT MATCH' as match_type
    FROM bloom_names
    WHERE (bloom & search_bloom) = search_bloom
    AND name = search_name;
END$$

DELIMITER ;

-- Example searches
CALL search_by_bloom('Alice');
CALL search_by_bloom('Bob');
CALL search_by_bloom('Charlie');

-- Direct query approach using bloom filter
-- Search for names that might match 'David'
SET @search_bloom = calculate_bloom('David');

SELECT 
    id,
    name,
    bloom,
    @search_bloom as search_bloom,
    (bloom & @search_bloom) as and_result,
    CASE 
        WHEN (bloom & @search_bloom) = @search_bloom THEN 'Candidate'
        ELSE 'Not a match'
    END as bloom_status
FROM bloom_names
WHERE (bloom & @search_bloom) = @search_bloom;

-- Verify exact matches from candidates
SELECT id, name, bloom
FROM bloom_names
WHERE (bloom & @search_bloom) = @search_bloom
AND name = 'David';

-- Batch search example: Search for multiple names
-- This demonstrates the efficiency of bloom filter for multiple lookups
DROP PROCEDURE IF EXISTS batch_search_by_bloom$$

DELIMITER $$

CREATE PROCEDURE batch_search_by_bloom()
BEGIN
    DECLARE search_names VARCHAR(1000) DEFAULT 'Alice,Bob,Charlie,David,Emma';
    DECLARE search_name VARCHAR(64);
    DECLARE search_bloom BIGINT UNSIGNED;
    DECLARE combined_bloom BIGINT UNSIGNED DEFAULT 0;
    
    -- For demonstration: Search for 'Bob'
    SET search_name = 'Bob';
    SET search_bloom = calculate_bloom(search_name);
    
    SELECT 
        COUNT(*) as total_candidates,
        SUM(CASE WHEN name = search_name THEN 1 ELSE 0 END) as exact_matches,
        COUNT(*) - SUM(CASE WHEN name = search_name THEN 1 ELSE 0 END) as false_positives
    FROM bloom_names
    WHERE (bloom & search_bloom) = search_bloom;
END$$

DELIMITER ;

-- Show bloom filter effectiveness
-- Compare the number of records that pass bloom filter vs actual matches
SET @target_name = 'Henry';
SET @target_bloom = calculate_bloom(@target_name);

SELECT 
    'Bloom Filter Candidates' as stage,
    COUNT(*) as record_count
FROM bloom_names
WHERE (bloom & @target_bloom) = @target_bloom

UNION ALL

SELECT 
    'Exact Matches' as stage,
    COUNT(*) as record_count
FROM bloom_names
WHERE (bloom & @target_bloom) = @target_bloom
AND name = @target_name;

-- Search with pattern matching combined with bloom filter
-- This shows how bloom filter can be used as a pre-filter for LIKE queries
SET @pattern_bloom = calculate_bloom('Mar');

SELECT id, name, bloom
FROM bloom_names
WHERE (bloom & @pattern_bloom) = @pattern_bloom
AND name LIKE 'Mar%';
