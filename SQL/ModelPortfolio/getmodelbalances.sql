-- MSSQL query to calculate and store combined portfolio balances by model
-- This aggregates portfolio balances for each model and stores them in ModelValues table
-- Uses the ModelPortfolio junction table for many-to-many relationships

-- First, calculate the combined balances per model per date
-- Then insert the results into ModelValues table

-- Insert aggregated model values into ModelValues table
-- Combines all portfolio balances that belong to each model via ModelPortfolio junction table
-- first truncate existing data to avoid duplicates
TRUNCATE TABLE ModelValues;
INSERT INTO ModelValues (id, modelid, value, date)
SELECT 
    ROW_NUMBER() OVER (ORDER BY m.id, p.date) AS id,
    m.id AS modelid,
    SUM(p.balance) AS value,  -- Combined holdings of all portfolios in this model
    p.date
FROM 
    Models m
INNER JOIN 
    ModelPortfolio mp ON m.id = mp.modelid
INNER JOIN 
    portfolio p ON mp.portfolioid = p.id
GROUP BY 
    m.id, p.date
ORDER BY 
    m.id, p.date;

-- Verify the inserted data
SELECT 
    mv.id,
    mv.modelid,
    m.name AS ModelName,
    mv.value AS CombinedModelValue,
    mv.date,
    COUNT(*) OVER (PARTITION BY mv.modelid) AS RecordsPerModel
FROM 
    ModelValues mv
INNER JOIN 
    Models m ON mv.modelid = m.id
ORDER BY 
    mv.modelid, mv.date;

-- Summary: Show total value per model with portfolio counts
SELECT 
    m.id AS ModelId,
    m.name AS ModelName,
    COUNT(DISTINCT mp.portfolioid) AS PortfolioCount,
    COUNT(mv.id) AS ValueRecordCount,
    AVG(mv.value) AS AverageValue,
    MIN(mv.value) AS MinValue,
    MAX(mv.value) AS MaxValue,
    SUM(mv.value) AS TotalValue
FROM 
    Models m
LEFT JOIN 
    ModelPortfolio mp ON m.id = mp.modelid
LEFT JOIN 
    ModelValues mv ON m.id = mv.modelid
GROUP BY 
    m.id, m.name
ORDER BY 
    m.id;


