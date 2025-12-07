-- Demo: Insert and Update with Bloom Filter
-- The bloom column is automatically calculated by triggers

-- Insert sample data
-- The trigger will automatically calculate and set the bloom value
INSERT INTO bloom_names (name, bloom) VALUES 
    ('Alice', 0),
    ('Bob', 0),
    ('Charlie', 0),
    ('David', 0),
    ('Emma', 0),
    ('Frank', 0),
    ('Grace', 0),
    ('Henry', 0),
    ('Iris', 0),
    ('Jack', 0);

-- Insert more names for testing
INSERT INTO bloom_names (name, bloom) VALUES 
    ('Katherine', 0),
    ('Leo', 0),
    ('Maria', 0),
    ('Nathan', 0),
    ('Olivia', 0),
    ('Peter', 0),
    ('Quinn', 0),
    ('Rachel', 0),
    ('Sam', 0),
    ('Tina', 0);

-- Show the inserted data with bloom values
SELECT TOP 10 id, name, bloom, 
    CONVERT(VARCHAR(64), bloom, 2) as bloom_binary
FROM bloom_names 
ORDER BY id;

-- Example: Update a name - bloom will be recalculated automatically
UPDATE bloom_names SET name = 'Alexander' WHERE name = 'Alice';

-- Verify the bloom value changed
SELECT id, name, bloom, 
    CONVERT(VARCHAR(64), bloom, 2) as bloom_binary
FROM bloom_names 
WHERE name = 'Alexander';

-- Manual insertion with explicit bloom calculation (alternative approach)
INSERT INTO bloom_names (name, bloom) 
VALUES ('Zachary', dbo.calculate_bloom('Zachary'));

-- Bulk insert for performance testing (10,000 records)
IF OBJECT_ID('insert_test_data', 'P') IS NOT NULL
    DROP PROCEDURE insert_test_data;
GO

CREATE PROCEDURE insert_test_data
AS
BEGIN
    DECLARE @i INT = 1;
    DECLARE @test_name VARCHAR(64);
    
    WHILE @i <= 10000
    BEGIN
        -- Generate diverse test names
        SET @test_name = CONCAT(
            CHAR(65 + (@i % 26)),  -- A-Z
            CHAR(97 + ((@i * 7) % 26)),  -- a-z
            CHAR(97 + ((@i * 13) % 26)), -- a-z
            RIGHT('0000' + CAST(@i AS VARCHAR(4)), 4)  -- Numeric suffix with padding
        );
        
        INSERT INTO bloom_names (name, bloom) VALUES (@test_name, 0);
        SET @i = @i + 1;
    END;
END;
GO

-- Execute the procedure to insert test data
-- EXEC insert_test_data;

-- Display statistics
SELECT 
    COUNT(*) as total_records,
    COUNT(DISTINCT bloom) as unique_bloom_values,
    CAST(COUNT(*) AS FLOAT) / COUNT(DISTINCT bloom) as avg_collision_rate
FROM bloom_names;
