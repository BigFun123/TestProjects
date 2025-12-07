-- Create table with Bloom filter column
-- The bloom column stores a BIGINT (64-bit) representing a Bloom filter bitmap
-- Each bit in the bitmap represents a hash position for the name string

IF OBJECT_ID('bloom_names', 'U') IS NOT NULL
    DROP TABLE bloom_names;
GO

CREATE TABLE bloom_names (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(64) NOT NULL,
    bloom BIGINT NOT NULL,
    INDEX idx_bloom (bloom),
    INDEX idx_name (name)
);
GO

-- Helper function to get bit value at position (2^n)
-- SQL Server doesn't support bit shift in scalar functions, so we use POWER with proper overflow handling
IF OBJECT_ID('get_bit_value', 'FN') IS NOT NULL
    DROP FUNCTION get_bit_value;
GO

CREATE FUNCTION get_bit_value(@bit_pos INT)
RETURNS BIGINT
AS
BEGIN
    DECLARE @result BIGINT;
    
    -- For positions 0-62, use POWER. Position 63 requires special handling due to signed BIGINT
    IF @bit_pos = 63
        SET @result = CAST(-9223372036854775808 AS BIGINT); -- 2^63 as signed BIGINT (most significant bit)
    ELSE
        SET @result = CAST(POWER(CAST(2 AS FLOAT), @bit_pos) AS BIGINT);
    
    RETURN @result;
END;
GO

-- Create a function to calculate the bloom filter value for a given string
-- This uses a simple hash function approach with multiple hash values
IF OBJECT_ID('calculate_bloom', 'FN') IS NOT NULL
    DROP FUNCTION calculate_bloom;
GO

CREATE FUNCTION calculate_bloom(@input_str VARCHAR(64))
RETURNS BIGINT
AS
BEGIN
    DECLARE @bloom_value BIGINT = 0;
    DECLARE @i INT = 1;
    DECLARE @str_len INT;
    DECLARE @char_code INT;
    DECLARE @hash1 INT;
    DECLARE @hash2 INT;
    DECLARE @hash3 INT;
    DECLARE @bit_pos INT;
    
    SET @str_len = LEN(@input_str);
    
    -- Use multiple hash functions to set bits
    -- Hash function 1: Sum of character codes
    SET @hash1 = 0;
    WHILE @i <= @str_len
    BEGIN
        SET @char_code = ASCII(SUBSTRING(@input_str, @i, 1));
        SET @hash1 = @hash1 + @char_code;
        SET @i = @i + 1;
    END;
    SET @bit_pos = @hash1 % 64;
    SET @bloom_value = @bloom_value | dbo.get_bit_value(@bit_pos);
    
    -- Hash function 2: Product-based hash
    SET @i = 1;
    SET @hash2 = 1;
    WHILE @i <= @str_len
    BEGIN
        SET @char_code = ASCII(SUBSTRING(@input_str, @i, 1));
        SET @hash2 = (@hash2 * @char_code) % 997; -- Prime number
        SET @i = @i + 1;
    END;
    SET @bit_pos = @hash2 % 64;
    SET @bloom_value = @bloom_value | dbo.get_bit_value(@bit_pos);
    
    -- Hash function 3: Position-weighted hash
    SET @i = 1;
    SET @hash3 = 0;
    WHILE @i <= @str_len
    BEGIN
        SET @char_code = ASCII(SUBSTRING(@input_str, @i, 1));
        SET @hash3 = @hash3 + (@char_code * @i);
        SET @i = @i + 1;
    END;
    SET @bit_pos = @hash3 % 64;
    SET @bloom_value = @bloom_value | dbo.get_bit_value(@bit_pos);
    
    -- Hash function 4: XOR-based hash
    SET @i = 1;
    WHILE @i <= @str_len
    BEGIN
        SET @char_code = ASCII(SUBSTRING(@input_str, @i, 1));
        SET @bit_pos = (@char_code ^ @i) % 64;
        SET @bloom_value = @bloom_value | dbo.get_bit_value(@bit_pos);
        SET @i = @i + 1;
    END;
    
    RETURN @bloom_value;
END;
GO

-- Create a trigger to automatically update bloom column on insert
IF OBJECT_ID('bloom_names_insert_trigger', 'TR') IS NOT NULL
    DROP TRIGGER bloom_names_insert_trigger;
GO

CREATE TRIGGER bloom_names_insert_trigger
ON bloom_names
INSTEAD OF INSERT
AS
BEGIN
    INSERT INTO bloom_names (name, bloom)
    SELECT name, dbo.calculate_bloom(name)
    FROM inserted;
END;
GO

-- Create a trigger to automatically update bloom column on update
IF OBJECT_ID('bloom_names_update_trigger', 'TR') IS NOT NULL
    DROP TRIGGER bloom_names_update_trigger;
GO

CREATE TRIGGER bloom_names_update_trigger
ON bloom_names
INSTEAD OF UPDATE
AS
BEGIN
    UPDATE bloom_names
    SET 
        name = i.name,
        bloom = CASE 
            WHEN i.name != d.name THEN dbo.calculate_bloom(i.name)
            ELSE d.bloom
        END
    FROM bloom_names bn
    INNER JOIN inserted i ON bn.id = i.id
    INNER JOIN deleted d ON bn.id = d.id;
END;
GO
