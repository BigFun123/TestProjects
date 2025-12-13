-- Ad-hoc query to calculate current model value without storing it
-- Useful for testing or real-time queries
-- Server: money (with linked server to "ios")
-- Parameter: @ModelId

DECLARE @ModelId INT = 1; -- Replace with actual ModelId

-- Calculate current total value for a specific model
SELECT 
    m.ModelId,
    SUM(mg.PortfolioWeight * ISNULL(i.InstrumentValue, 0)) as CurrentTotalValue,
    COUNT(DISTINCT mg.PortfolioId) as NumberOfPortfolios,
    COUNT(DISTINCT i.InstrumentId) as NumberOfInstruments,
    GETDATE() as CalculatedAt
FROM 
    Model m
    INNER JOIN ModelGroup mg ON m.ModelGroupId = mg.ModelGroupId
    INNER JOIN Portfolio p ON mg.PortfolioId = p.PortfolioId
    -- Link to the "ios" server for instrument values
    INNER JOIN [ios].[dbo].[Portfolio] ip ON p.PortfolioId = ip.PortfolioId
    INNER JOIN [ios].[dbo].[Instrument] i ON ip.InstrumentId = i.InstrumentId
WHERE 
    m.ModelId = @ModelId
GROUP BY 
    m.ModelId;

-- Optional: Show the breakdown by portfolio
SELECT 
    m.ModelId,
    mg.PortfolioId,
    mg.PortfolioWeight,
    SUM(ISNULL(i.InstrumentValue, 0)) as PortfolioValue,
    mg.PortfolioWeight * SUM(ISNULL(i.InstrumentValue, 0)) as WeightedPortfolioValue
FROM 
    Model m
    INNER JOIN ModelGroup mg ON m.ModelGroupId = mg.ModelGroupId
    INNER JOIN Portfolio p ON mg.PortfolioId = p.PortfolioId
    INNER JOIN [ios].[dbo].[Portfolio] ip ON p.PortfolioId = ip.PortfolioId
    INNER JOIN [ios].[dbo].[Instrument] i ON ip.InstrumentId = i.InstrumentId
WHERE 
    m.ModelId = @ModelId
GROUP BY 
    m.ModelId, mg.PortfolioId, mg.PortfolioWeight
ORDER BY 
    mg.PortfolioId;
