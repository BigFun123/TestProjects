DECLARE @StartDate DATE = '2025-01-01',
        @EndDate   DATE = '2025-12-31';

WITH PortfolioDaily AS (
    SELECT
        pv.PortfolioId,
        pv.AsOfDate,
        SUM(pv.PositionValue) AS PortfolioTotalValue
    FROM dbo.PositionValues pv
    WHERE pv.AsOfDate BETWEEN @StartDate AND @EndDate
    GROUP BY pv.PortfolioId, pv.AsOfDate
)
SELECT
    m.ModelId,
    m.ModelName,
    pd.AsOfDate,
    SUM(pd.PortfolioTotalValue)    AS ModelTotalHoldings,
    COUNT(DISTINCT pd.PortfolioId) AS NumPortfolios
FROM PortfolioDaily pd
JOIN dbo.Portfolios p ON p.PortfolioId = pd.PortfolioId
JOIN dbo.Models     m ON m.ModelId = p.ModelId
GROUP BY m.ModelId, m.ModelName, pd.AsOfDate
ORDER BY pd.AsOfDate, m.ModelId;