-- mssql
-- Drop tables in reverse order (respecting foreign key dependencies)
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'ModelValues')
    DROP TABLE ModelValues;

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'ModelPortfolio')
    DROP TABLE ModelPortfolio;

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Models')
    DROP TABLE Models;

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'portfolio')
    DROP TABLE portfolio;

-- create tables for portfolio, models, and modelvalues
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'portfolio')
BEGIN
    CREATE TABLE portfolio (
        id INT PRIMARY KEY,
        balance DECIMAL(18,2),
        name VARCHAR(100),
        date DATE
    );
END

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Models')
BEGIN
    CREATE TABLE Models (
        id INT PRIMARY KEY,
        name VARCHAR(100)
    );
END

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ModelPortfolio')
BEGIN
    CREATE TABLE ModelPortfolio (
        id INT PRIMARY KEY IDENTITY(1,1),
        modelid INT,
        portfolioid INT,
        FOREIGN KEY (modelid) REFERENCES Models(id),
        FOREIGN KEY (portfolioid) REFERENCES portfolio(id),
        UNIQUE(modelid, portfolioid)  -- Prevent duplicate model-portfolio pairs
    );
END

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ModelValues')
BEGIN
    CREATE TABLE ModelValues (
        id INT PRIMARY KEY,
        modelid INT,
        value DECIMAL(18,2),
        date DATE,
        FOREIGN KEY (modelid) REFERENCES Models(id)
    );
END


-- Insert dummy data into portfolio, models, and modelportfolio tables

-- Create test data for portfolio table
-- Generates 100 sample records with realistic data
DECLARE @Counter INT = 1;
DECLARE @MaxRecords INT = 100;
DECLARE @StartDate DATE = '2020-01-01';

WHILE @Counter <= @MaxRecords
BEGIN
    INSERT INTO portfolio (id, balance, name, date)
    VALUES (
        @Counter,
        ROUND((RAND() * 1000000), 2), -- Random balance between 0 and 1,000,000
        CONCAT('User_', @Counter, '_', 
               CHAR(65 + ABS(CHECKSUM(NEWID())) % 26), -- Random letter
               CHAR(65 + ABS(CHECKSUM(NEWID())) % 26)),  -- Random letter
        DATEADD(DAY, @Counter - 1, @StartDate) -- Increment date by 1 day for each record
    );
    
    SET @Counter = @Counter + 1;
END;

-- Verify inserted portfolio data
SELECT COUNT(*) as TotalRecords FROM portfolio;
SELECT TOP 10 * FROM portfolio ORDER BY id;

-- Create test data for models table
DECLARE @ModelCounter INT = 1;
DECLARE @MaxModels INT = 10;

WHILE @ModelCounter <= @MaxModels
BEGIN
    INSERT INTO Models (id, name)
    VALUES (
        @ModelCounter,
        CONCAT('Model_', @ModelCounter)
    );
    
    SET @ModelCounter = @ModelCounter + 1;
END;

-- Verify inserted models data
SELECT * FROM Models ORDER BY id;

-- Create test data for ModelPortfolio junction table (many-to-many relationship)
-- Each model can have multiple portfolios
DECLARE @MPCounter INT = 1;
DECLARE @MaxModelPortfolios INT = 50;

WHILE @MPCounter <= @MaxModelPortfolios
BEGIN
    DECLARE @RandomModelId INT = (ABS(CHECKSUM(NEWID())) % 10) + 1;  -- Random model 1-10
    DECLARE @RandomPortfolioId INT = (ABS(CHECKSUM(NEWID())) % 100) + 1;  -- Random portfolio 1-100
    
    -- Only insert if this combination doesn't already exist
    IF NOT EXISTS (SELECT 1 FROM ModelPortfolio WHERE modelid = @RandomModelId AND portfolioid = @RandomPortfolioId)
    BEGIN
        INSERT INTO ModelPortfolio (modelid, portfolioid)
        VALUES (@RandomModelId, @RandomPortfolioId);
    END
    
    SET @MPCounter = @MPCounter + 1;
END;

-- Verify the many-to-many relationships
SELECT 
    m.id AS ModelId, 
    m.name AS ModelName, 
    COUNT(mp.portfolioid) AS PortfolioCount
FROM Models m
LEFT JOIN ModelPortfolio mp ON m.id = mp.modelid
GROUP BY m.id, m.name
ORDER BY m.id;

-- Show sample model-portfolio relationships
SELECT TOP 20
    mp.id,
    m.id AS ModelId,
    m.name AS ModelName,
    p.id AS PortfolioId,
    p.name AS PortfolioName,
    p.balance AS PortfolioBalance
FROM ModelPortfolio mp
INNER JOIN Models m ON mp.modelid = m.id
INNER JOIN portfolio p ON mp.portfolioid = p.id
ORDER BY m.id, p.id;
