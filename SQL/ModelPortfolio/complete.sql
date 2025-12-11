/***********************************************
 Create target table for model daily holdings
***********************************************/
IF OBJECT_ID('dbo.ModelDailyHoldings', 'U') IS NOT NULL
    DROP TABLE dbo.ModelDailyHoldings;
GO

CREATE TABLE dbo.ModelDailyHoldings
(
    ModelId       INT         NOT NULL,
    AsOfDate      DATE        NOT NULL,
    TotalValue    DECIMAL(38,4) NOT NULL, -- increase precision/scale if you need
    NumPortfolios INT         NOT NULL,
    CreatedAt     DATETIME2   NOT NULL CONSTRAINT DF_ModelDailyHoldings_CreatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedAt     DATETIME2   NULL,
    CONSTRAINT PK_ModelDailyHoldings PRIMARY KEY (ModelId, AsOfDate)
);
GO

-- Useful index to speed date-range queries by AsOfDate
CREATE NONCLUSTERED INDEX IX_ModelDailyHoldings_AsOfDate
ON dbo.ModelDailyHoldings (AsOfDate)
INCLUDE (TotalValue, NumPortfolios);
GO

/***********************************************
 Stored procedure: upsert model daily totals
 - Aggregates from PortfolioHoldings (or PositionValues)
 - Joins Portfolios -> Models to determine ModelId
 - MERGE into ModelDailyHoldings for the requested date range
***********************************************/
IF OBJECT_ID('dbo.PopulateModelDailyHoldings', 'P') IS NOT NULL
    DROP PROCEDURE dbo.PopulateModelDailyHoldings;
GO

CREATE PROCEDURE dbo.PopulateModelDailyHoldings
    @StartDate DATE,
    @EndDate   DATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Basic validation
    IF @StartDate IS NULL OR @EndDate IS NULL
    BEGIN
        RAISERROR('StartDate and EndDate must be supplied.', 16, 1);
        RETURN;
    END

    IF @EndDate < @StartDate
    BEGIN
        RAISERROR('EndDate must be greater than or equal to StartDate.', 16, 1);
        RETURN;
    END

    BEGIN TRY
        BEGIN TRAN;

        -- Aggregate portfolio-level totals per day.
        -- Adjust source table/column names if you store positions instead of daily portfolio totals.
        WITH PortfolioDaily AS (
            SELECT
                ph.PortfolioId,
                ph.AsOfDate,
                SUM(ph.TotalValue) OVER (PARTITION BY ph.PortfolioId, ph.AsOfDate) AS PortfolioTotalValue
            FROM dbo.PortfolioHoldings ph
            WHERE ph.AsOfDate BETWEEN @StartDate AND @EndDate
            -- If PortfolioHoldings already has one row per portfolio/day, you can simplify:
            -- SELECT PortfolioId, AsOfDate, TotalValue AS PortfolioTotalValue FROM dbo.PortfolioHoldings WHERE AsOfDate BETWEEN ...
        ),
        -- Now roll up portfolios into model totals
        ModelAggregates AS (
            SELECT
                p.ModelId,
                pd.AsOfDate,
                SUM(pd.PortfolioTotalValue)           AS TotalValue,
                COUNT(DISTINCT pd.PortfolioId)        AS NumPortfolios
            FROM PortfolioDaily pd
            JOIN dbo.Portfolios p ON p.PortfolioId = pd.PortfolioId
            GROUP BY p.ModelId, pd.AsOfDate
        )

        -- Upsert results into target table
        MERGE INTO dbo.ModelDailyHoldings AS target
        USING (
            SELECT
                ma.ModelId,
                ma.AsOfDate,
                ma.TotalValue,
                ma.NumPortfolios
            FROM ModelAggregates ma
        ) AS src
        ON (target.ModelId = src.ModelId AND target.AsOfDate = src.AsOfDate)
        WHEN MATCHED AND (
             ISNULL(target.TotalValue,0)    <> ISNULL(src.TotalValue,0)
          OR ISNULL(target.NumPortfolios,0) <> ISNULL(src.NumPortfolios,0)
        ) THEN
            UPDATE SET
                target.TotalValue = src.TotalValue,
                target.NumPortfolios = src.NumPortfolios,
                target.UpdatedAt = SYSUTCDATETIME()
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (ModelId, AsOfDate, TotalValue, NumPortfolios, CreatedAt, UpdatedAt)
            VALUES (src.ModelId, src.AsOfDate, src.TotalValue, src.NumPortfolios, SYSUTCDATETIME(), SYSUTCDATETIME())
        -- optional: when matched but unchanged, do nothing
        ;

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRAN;

        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrNo INT = ERROR_NUMBER();
        RAISERROR('Error populating ModelDailyHoldings: %s (ErrNo: %d)', 16, 1, @ErrMsg, @ErrNo);
        RETURN;
    END CATCH
END
GO

/***********************************************
 Sample call
***********************************************/
-- Populate for a single day
EXEC dbo.PopulateModelDailyHoldings @StartDate = '2025-12-01', @EndDate = '2025-12-01';

-- Or populate a range
EXEC dbo.PopulateModelDailyHoldings @StartDate = '2025-11-01', @EndDate = '2025-12-01';
GO
