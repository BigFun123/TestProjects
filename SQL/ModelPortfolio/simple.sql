DECLARE @StartDate DATE = '2025-01-01',
        @EndDate   DATE = '2025-12-31';

SELECT
    m.ModelId,
    m.ModelName,
    ph.AsOfDate,
    SUM(ph.TotalValue)           AS ModelTotalHoldings,
    COUNT(DISTINCT ph.PortfolioId) AS NumPortfolios
FROM dbo.PortfolioHoldings ph
JOIN dbo.Portfolios      p ON p.PortfolioId = ph.PortfolioId
JOIN dbo.Models          m ON m.ModelId = p.ModelId
WHERE ph.AsOfDate BETWEEN @StartDate AND @EndDate
GROUP BY m.ModelId, m.ModelName, ph.AsOfDate
ORDER BY ph.AsOfDate, m.ModelId;