-- Create table to store daily model value snapshots
-- Run this once to set up the historical tracking table
-- Server: money

CREATE TABLE ModelValueHistory (
    HistoryId INT IDENTITY(1,1) PRIMARY KEY,
    ModelId INT NOT NULL,
    ValueDate DATE NOT NULL,
    TotalValue DECIMAL(18,2) NOT NULL,
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT UQ_ModelValueHistory_ModelId_ValueDate UNIQUE (ModelId, ValueDate)
);

CREATE INDEX IX_ModelValueHistory_ModelId_ValueDate 
    ON ModelValueHistory(ModelId, ValueDate DESC);

CREATE INDEX IX_ModelValueHistory_ValueDate 
    ON ModelValueHistory(ValueDate DESC);
