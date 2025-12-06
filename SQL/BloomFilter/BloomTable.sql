-- =============================================
-- Bloom Filter Demo - Table Creation
-- =============================================
-- This script creates tables to demonstrate a Bloom filter in SQL Server
-- A Bloom filter is a space-efficient probabilistic data structure 
-- that tests whether an element is a member of a set

USE master;
GO

-- Create database if it doesn't exist
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'BloomFilterDemo')
BEGIN
    CREATE DATABASE BloomFilterDemo;
END
GO

USE BloomFilterDemo;
GO

-- =============================================
-- Main Data Table
-- =============================================
-- This is the main table containing customer/account data
IF OBJECT_ID('dbo.Accounts', 'U') IS NOT NULL
    DROP TABLE dbo.Accounts;
GO

CREATE TABLE dbo.Accounts (
    AccountID INT PRIMARY KEY IDENTITY(1,1),
    AccountDate DATE NOT NULL,
    CustomerName NVARCHAR(100) NOT NULL,
    Balance DECIMAL(18, 2) NOT NULL,
    Email NVARCHAR(255) NOT NULL,
    Status NVARCHAR(20) NOT NULL DEFAULT 'Active',
    CreatedAt DATETIME2 DEFAULT GETDATE()
);
GO

-- =============================================
-- Bloom Filter Bit Array Table
-- =============================================
-- This table simulates the bit array used in a Bloom filter
-- In a real implementation, this would be a single bit array,
-- but SQL makes it easier to use a table with bit positions
IF OBJECT_ID('dbo.BloomFilterBits', 'U') IS NOT NULL
    DROP TABLE dbo.BloomFilterBits;
GO

CREATE TABLE dbo.BloomFilterBits (
    BitPosition INT PRIMARY KEY,
    BitValue BIT NOT NULL DEFAULT 0
);
GO

-- Initialize bloom filter with fixed size (10,000 bits for demo)
-- In production, size depends on expected elements and desired false positive rate
DECLARE @i INT = 0;
WHILE @i < 10000
BEGIN
    INSERT INTO dbo.BloomFilterBits (BitPosition, BitValue) VALUES (@i, 0);
    SET @i = @i + 1;
END
GO

-- =============================================
-- Hash Function Helper Table
-- =============================================
-- Store hash seeds for multiple hash functions
-- Bloom filters typically use 3-7 hash functions
IF OBJECT_ID('dbo.BloomFilterConfig', 'U') IS NOT NULL
    DROP TABLE dbo.BloomFilterConfig;
GO

CREATE TABLE dbo.BloomFilterConfig (
    HashFunctionID INT PRIMARY KEY,
    HashSeed INT NOT NULL,
    Description NVARCHAR(100)
);
GO

-- Insert hash function configurations (using different seeds)
INSERT INTO dbo.BloomFilterConfig (HashFunctionID, HashSeed, Description)
VALUES 
    (1, 5381, 'DJB2 Hash'),
    (2, 31, 'Simple Multiplicative Hash'),
    (3, 17, 'Prime-based Hash'),
    (4, 23, 'Alternative Prime Hash'),
    (5, 97, 'Large Prime Hash');
GO

-- =============================================
-- Insert Sample Data
-- =============================================
INSERT INTO dbo.Accounts (AccountDate, CustomerName, Balance, Email, Status)
VALUES
    ('2024-01-15', 'John Smith', 15000.00, 'john.smith@email.com', 'Active'),
    ('2024-02-20', 'Jane Doe', 25000.50, 'jane.doe@email.com', 'Active'),
    ('2024-03-10', 'Bob Johnson', 8500.75, 'bob.johnson@email.com', 'Active'),
    ('2024-04-05', 'Alice Williams', 42000.00, 'alice.williams@email.com', 'Active'),
    ('2024-05-12', 'Charlie Brown', 12300.25, 'charlie.brown@email.com', 'Inactive'),
    ('2024-06-18', 'Diana Prince', 67000.00, 'diana.prince@email.com', 'Active'),
    ('2024-07-22', 'Edward Norton', 19500.00, 'edward.norton@email.com', 'Active'),
    ('2024-08-30', 'Fiona Green', 33000.00, 'fiona.green@email.com', 'Active'),
    ('2024-09-14', 'George Lucas', 45000.00, 'george.lucas@email.com', 'Active'),
    ('2024-10-25', 'Hannah Montana', 28000.00, 'hannah.montana@email.com', 'Active');
GO

-- =============================================
-- Supporting Functions and Procedures
-- =============================================

-- Function to compute hash for a string value
IF OBJECT_ID('dbo.fn_ComputeHash', 'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_ComputeHash;
GO

CREATE FUNCTION dbo.fn_ComputeHash
(
    @InputString NVARCHAR(MAX),
    @Seed INT,
    @MaxBits INT
)
RETURNS INT
AS
BEGIN
    DECLARE @Hash BIGINT = @Seed;
    DECLARE @i INT = 1;
    DECLARE @Len INT = LEN(@InputString);
    DECLARE @Char INT;
    
    WHILE @i <= @Len
    BEGIN
        SET @Char = UNICODE(SUBSTRING(@InputString, @i, 1));
        -- Use BIGINT to prevent overflow, then modulo to keep in range
        SET @Hash = ((@Hash * 33) + @Char) % 2147483647;
        SET @i = @i + 1;
    END
    
    RETURN ABS(@Hash % @MaxBits);
END
GO

-- Stored Procedure to add an email to the Bloom filter
IF OBJECT_ID('dbo.sp_AddToBloomFilter', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_AddToBloomFilter;
GO

CREATE PROCEDURE dbo.sp_AddToBloomFilter
    @Email NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @MaxBits INT = 10000;
    DECLARE @HashFunctionID INT;
    DECLARE @HashSeed INT;
    DECLARE @BitPosition INT;
    
    -- For each hash function, compute position and set bit
    DECLARE hash_cursor CURSOR FOR
        SELECT HashFunctionID, HashSeed FROM dbo.BloomFilterConfig;
    
    OPEN hash_cursor;
    FETCH NEXT FROM hash_cursor INTO @HashFunctionID, @HashSeed;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @BitPosition = dbo.fn_ComputeHash(@Email, @HashSeed, @MaxBits);
        
        -- Set the bit at this position
        UPDATE dbo.BloomFilterBits
        SET BitValue = 1
        WHERE BitPosition = @BitPosition;
        
        FETCH NEXT FROM hash_cursor INTO @HashFunctionID, @HashSeed;
    END
    
    CLOSE hash_cursor;
    DEALLOCATE hash_cursor;
END
GO

-- Stored Procedure to check if an email might exist in Bloom filter
IF OBJECT_ID('dbo.sp_CheckBloomFilter', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_CheckBloomFilter;
GO

CREATE PROCEDURE dbo.sp_CheckBloomFilter
    @Email NVARCHAR(255),
    @PossiblyExists BIT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @MaxBits INT = 10000;
    DECLARE @HashFunctionID INT;
    DECLARE @HashSeed INT;
    DECLARE @BitPosition INT;
    DECLARE @BitValue BIT;
    
    SET @PossiblyExists = 1; -- Assume it exists until proven otherwise
    
    -- For each hash function, check if bit is set
    DECLARE hash_cursor CURSOR FOR
        SELECT HashFunctionID, HashSeed FROM dbo.BloomFilterConfig;
    
    OPEN hash_cursor;
    FETCH NEXT FROM hash_cursor INTO @HashFunctionID, @HashSeed;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @BitPosition = dbo.fn_ComputeHash(@Email, @HashSeed, @MaxBits);
        
        -- Check if bit is set
        SELECT @BitValue = BitValue
        FROM dbo.BloomFilterBits
        WHERE BitPosition = @BitPosition;
        
        IF @BitValue = 0
        BEGIN
            -- If any bit is 0, element definitely doesn't exist
            SET @PossiblyExists = 0;
            BREAK;
        END
        
        FETCH NEXT FROM hash_cursor INTO @HashFunctionID, @HashSeed;
    END
    
    CLOSE hash_cursor;
    DEALLOCATE hash_cursor;
END
GO

PRINT 'Bloom Filter tables and procedures created successfully!';
PRINT 'Database: BloomFilterDemo';
PRINT 'Tables: Accounts, BloomFilterBits, BloomFilterConfig';
PRINT 'Functions: fn_ComputeHash';
PRINT 'Procedures: sp_AddToBloomFilter, sp_CheckBloomFilter';
GO
