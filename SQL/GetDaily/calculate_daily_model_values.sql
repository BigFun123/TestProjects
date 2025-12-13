-- Daily query to calculate and store current model values
-- This should be run daily (via scheduled job) to capture today's values
-- Server: money (with linked server to "ios")

-- Calculate today's model values and insert into history
INSERT INTO ModelValueHistory (ModelId, ValueDate, TotalValue)
SELECT 
    m.ModelId,
    CAST(GETDATE() AS DATE) as ValueDate,
    SUM(mg.PortfolioWeight * ISNULL(i.InstrumentValue, 0)) as TotalValue
FROM 
    Model m
    INNER JOIN ModelGroup mg ON m.ModelGroupId = mg.ModelGroupId
    INNER JOIN Portfolio p ON mg.PortfolioId = p.PortfolioId
    -- Link to the "ios" server for instrument values
    INNER JOIN [ios].[dbo].[Portfolio] ip ON p.PortfolioId = ip.PortfolioId
    INNER JOIN [ios].[dbo].[Instrument] i ON ip.InstrumentId = i.InstrumentId
GROUP BY 
    m.ModelId
-- Only insert if we don't already have today's value
HAVING NOT EXISTS (
    SELECT 1 
    FROM ModelValueHistory mvh 
    WHERE mvh.ModelId = m.ModelId 
      AND mvh.ValueDate = CAST(GETDATE() AS DATE)
);

-- Return the values that were just inserted
SELECT 
    ModelId,
    ValueDate,
    TotalValue,
    CreatedAt
FROM 
    ModelValueHistory
WHERE 
    ValueDate = CAST(GETDATE() AS DATE)
ORDER BY 
    ModelId;
