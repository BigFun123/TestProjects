-- Example stored procedure that the HangFire job will execute daily at midnight
-- This is a sample procedure - replace with your actual business logic

USE [HangFireDemo]
GO

-- Create the stored procedure
CREATE OR ALTER PROCEDURE [dbo].[DailyMaintenanceProc]
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @StartTime DATETIME = GETDATE();
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Example: Clean up old records (older than 90 days)
        -- DELETE FROM [dbo].[SomeTable]
        -- WHERE CreatedDate < DATEADD(DAY, -90, GETDATE());
        
        -- Example: Update statistics or perform maintenance
        -- UPDATE [dbo].[Statistics]
        -- SET LastProcessedDate = GETDATE()
        -- WHERE StatType = 'Daily';
        
        -- Example: Archive old data
        -- INSERT INTO [dbo].[ArchivedData] (...)
        -- SELECT ... FROM [dbo].[ActiveData]
        -- WHERE ProcessedDate < DATEADD(DAY, -30, GETDATE());
        
        COMMIT TRANSACTION;
        
        -- Log success
        PRINT 'Daily maintenance completed successfully at ' + CONVERT(VARCHAR, GETDATE(), 120);
        PRINT 'Duration: ' + CAST(DATEDIFF(SECOND, @StartTime, GETDATE()) AS VARCHAR) + ' seconds';
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        -- Log error
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        PRINT 'Error in daily maintenance: ' + @ErrorMessage;
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO
