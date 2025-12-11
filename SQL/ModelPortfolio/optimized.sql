IF OBJECT_ID('dbo.PopulateModelDailyHoldings_Simple', 'P') IS NOT NULL
    DROP PROCEDURE dbo.PopulateModelDailyHoldings_Simple;
GO

CREATE PROCEDURE dbo.PopulateModelDailyHoldings_Simple
    @StartDate DATE,
    @EndDate   DATE
AS
BEGIN
    SET NOCOUNT ON;

    IF @StartDate IS NULL OR @EndDate IS NULL
        RETURN;

    IF @EndDate < @StartDate
        RETURN;

    -- Aggregate to model/day
    ;WITH ModelAggregates AS (
        SELECT
            p.ModelId,
            ph.AsOfDate,
            SUM(ph.TotalValue)    AS TotalValue,
            COUNT(DISTINCT ph.PortfolioId) AS NumPortfolios
        FROM dbo.PortfolioHoldings ph
        JOIN dbo.Portfolios p ON p.PortfolioId = ph.PortfolioId
        WHERE ph.AsOfDate BETWEEN @StartDate AND @EndDate
        GROUP BY p.ModelId, ph.AsOfDate
    )

    -- 1) Update existing rows
    UPDATE target
    SET
        target.TotalValue    = src.TotalValue,
        target.NumPortfolios = src.NumPortfolios,
        target.UpdatedAt     = SYSUTCDATETIME()
    FROM dbo.ModelDailyHoldings target
    JOIN ModelAggregates src
        ON target.ModelId = src.ModelId
       AND target.AsOfDate = src.AsOfDate;

    -- 2) Insert missing rows
    INSERT INTO dbo.ModelDailyHoldings (ModelId, AsOfDate, TotalValue, NumPortfolios, CreatedAt, UpdatedAt)
    SELECT
        src.ModelId,
        src.AsOfDate,
        src.TotalValue,
        src.NumPortfolios,
        SYSUTCDATETIME(),
        SYSUTCDATETIME()
    FROM ModelAggregates src
    LEFT JOIN dbo.ModelDailyHoldings target
        ON target.ModelId = src.ModelId
       AND target.AsOfDate = src.AsOfDate
    WHERE target.ModelId IS NULL;
END
GO

-- sample call
EXEC dbo.PopulateModelDailyHoldings_Simple @StartDate = '2025-12-01', @EndDate = '2025-12-01';
GO
