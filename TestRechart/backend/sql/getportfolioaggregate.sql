-- Create ModelDailyTotal table
CREATE TABLE ModelDailyTotal (
    ModelDailyTotalId INT PRIMARY KEY IDENTITY(1,1),
    ModelId INT NOT NULL,
    Date DATE NOT NULL,
    TotalBalance DECIMAL(18,2) NOT NULL,
    PortfolioIds NVARCHAR(MAX) NULL, -- JSON array of portfolio IDs, e.g. [1,2,3]
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT UQ_ModelDailyTotal_ModelId_Date UNIQUE (ModelId, Date)
);

-- Create PortfolioDailyTotal table
CREATE TABLE PortfolioDailyTotal (
    PortfolioDailyTotalId INT PRIMARY KEY IDENTITY(1,1),
    PortfolioId INT NOT NULL,
    Date DATE NOT NULL,
    Balance DECIMAL(18,2) NOT NULL,
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT UQ_PortfolioDailyTotal_PortfolioId_Date UNIQUE (PortfolioId, Date)
);

-- Add dummy data to PortfolioDailyTotal for multiple portfolios
-- Model 1 with 3 portfolios over 30 days
DECLARE @StartDate DATE = '2024-01-01';
DECLARE @EndDate DATE = '2024-01-30';
DECLARE @CurrentDate DATE = @StartDate;

WHILE @CurrentDate <= @EndDate
BEGIN
    -- Portfolio 1 for Model 1 (starting at 10000, growing by ~1% daily)
    INSERT INTO PortfolioDailyTotal (PortfolioId, Date, Balance)
    VALUES (1, @CurrentDate, 10000 + (DATEDIFF(DAY, @StartDate, @CurrentDate) * 100) + (RAND() * 500));

    -- Portfolio 2 for Model 1 (starting at 25000, growing by ~1.5% daily)
    INSERT INTO PortfolioDailyTotal (PortfolioId, Date, Balance)
    VALUES (2, @CurrentDate, 25000 + (DATEDIFF(DAY, @StartDate, @CurrentDate) * 250) + (RAND() * 800));

    -- Portfolio 3 for Model 1 (starting at 15000, growing by ~0.8% daily)
    INSERT INTO PortfolioDailyTotal (PortfolioId, Date, Balance)
    VALUES (3, @CurrentDate, 15000 + (DATEDIFF(DAY, @StartDate, @CurrentDate) * 120) + (RAND() * 600));

    SET @CurrentDate = DATEADD(DAY, 1, @CurrentDate);
END;

-- Add data for Model 2 with 2 portfolios
SET @CurrentDate = @StartDate;

WHILE @CurrentDate <= @EndDate
BEGIN
    -- Portfolio 4 for Model 2 (starting at 50000, growing steadily)
    INSERT INTO PortfolioDailyTotal (PortfolioId, Date, Balance)
    VALUES (4, @CurrentDate, 50000 + (DATEDIFF(DAY, @StartDate, @CurrentDate) * 400) + (RAND() * 1000));

    -- Portfolio 5 for Model 2 (starting at 30000, with some volatility)
    INSERT INTO PortfolioDailyTotal (PortfolioId, Date, Balance)
    VALUES (5, @CurrentDate, 30000 + (DATEDIFF(DAY, @StartDate, @CurrentDate) * 200) + (RAND() * 1500));

    SET @CurrentDate = DATEADD(DAY, 1, @CurrentDate);
END;

GO

-- Create stored procedure GetDailyTotals
CREATE OR ALTER PROCEDURE GetDailyTotals
    @ModelId INT,
    @PortfolioIds VARCHAR(MAX), -- Comma-separated list of portfolio IDs
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Calculate and update/insert daily totals into ModelDailyTotal
    MERGE INTO ModelDailyTotal AS target
    USING (
        SELECT 
            @ModelId AS ModelId,
            Date,
            SUM(Balance) AS TotalBalance,
            '[' + STRING_AGG(CAST(PortfolioId AS VARCHAR), ',') + ']' AS PortfolioIds
        FROM 
            PortfolioDailyTotal
        WHERE 
            PortfolioId IN (SELECT value FROM STRING_SPLIT(@PortfolioIds, ','))
            AND Date >= @StartDate
            AND Date <= @EndDate
        GROUP BY 
            Date
    ) AS source
    ON (target.ModelId = source.ModelId AND target.Date = source.Date)
    WHEN MATCHED THEN
        UPDATE SET 
            target.TotalBalance = source.TotalBalance,
            target.PortfolioIds = source.PortfolioIds
    WHEN NOT MATCHED THEN
        INSERT (ModelId, Date, TotalBalance, PortfolioIds)
        VALUES (source.ModelId, source.Date, source.TotalBalance, source.PortfolioIds);

    -- Return the daily total balances for the specified portfolios within the date range
    SELECT 
        Date,
        SUM(Balance) AS TotalBalance,
        COUNT(PortfolioId) AS PortfolioCount
    FROM 
        PortfolioDailyTotal
    WHERE 
        PortfolioId IN (SELECT value FROM STRING_SPLIT(@PortfolioIds, ','))
        AND Date >= @StartDate
        AND Date <= @EndDate
    GROUP BY 
        Date
    ORDER BY 
        Date;
END;

GO

-- Example usage of the stored procedure
-- For Model 1 portfolios (1, 2, 3):
-- EXEC GetDailyTotals @ModelId = 1, @PortfolioIds = '1,2,3', @StartDate = '2024-01-01', @EndDate = '2024-01-30';
-- For Model 2 portfolios (4, 5):
-- EXEC GetDailyTotals @ModelId = 2, @PortfolioIds = '4,5', @StartDate = '2024-01-01', @EndDate = '2024-01-30';