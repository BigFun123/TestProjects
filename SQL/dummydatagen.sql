USE [scratch]
GO

/****** Object:  Table [dbo].[ModelDailyTotal]    Script Date: 2025/12/06 10:08:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ModelDailyTotal](
	[Id] [uniqueidentifier] NULL,
	[ModelId] [uniqueidentifier] NULL,
	[Date] [datetime] NULL,
	[Balance] [decimal](18, 0) NULL
) ON [PRIMARY]
GO


-- make 1000 dummy records for ModelDailyTotal

DECLARE @Counter INT = 0;
DECLARE @ModelId1 UNIQUEIDENTIFIER = NEWID();
DECLARE @ModelId2 UNIQUEIDENTIFIER = NEWID();
DECLARE @ModelId3 UNIQUEIDENTIFIER = NEWID();
DECLARE @StartDate DATE = '2023-01-01';

WHILE @Counter < 1000
BEGIN
    INSERT INTO [dbo].[ModelDailyTotal] ([Id], [ModelId], [Date], [Balance])
    VALUES (
        NEWID(),
        CASE 
            WHEN @Counter % 3 = 0 THEN @ModelId1
            WHEN @Counter % 3 = 1 THEN @ModelId2
            ELSE @ModelId3
        END,
        DATEADD(DAY, @Counter, @StartDate),
        CAST((ABS(CHECKSUM(NEWID())) % 100000) + 1000 AS DECIMAL(18, 0))
    );
    
    SET @Counter = @Counter + 1;
END

SELECT COUNT(*) AS TotalRecords FROM [dbo].[ModelDailyTotal];
SELECT TOP 10 * FROM [dbo].[ModelDailyTotal] ORDER BY [Date];