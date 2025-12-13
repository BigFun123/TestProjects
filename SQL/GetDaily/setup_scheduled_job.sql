-- SQL Server Agent Job to run daily model value calculation
-- Server: money
-- This creates a scheduled job that runs daily at 6 PM

USE msdb;
GO

-- Create a job
EXEC dbo.sp_add_job
    @job_name = N'Daily Model Value Calculation',
    @enabled = 1,
    @description = N'Calculates and stores daily model values for historical tracking';

-- Add a job step
EXEC dbo.sp_add_jobstep
    @job_name = N'Daily Model Value Calculation',
    @step_name = N'Calculate and Store Model Values',
    @subsystem = N'TSQL',
    @command = N'
INSERT INTO ModelValueHistory (ModelId, ValueDate, TotalValue)
SELECT 
    m.ModelId,
    CAST(GETDATE() AS DATE) as ValueDate,
    SUM(mg.PortfolioWeight * ISNULL(i.InstrumentValue, 0)) as TotalValue
FROM 
    Model m
    INNER JOIN ModelGroup mg ON m.ModelGroupId = mg.ModelGroupId
    INNER JOIN Portfolio p ON mg.PortfolioId = p.PortfolioId
    INNER JOIN [ios].[dbo].[Portfolio] ip ON p.PortfolioId = ip.PortfolioId
    INNER JOIN [ios].[dbo].[Instrument] i ON ip.InstrumentId = i.InstrumentId
WHERE NOT EXISTS (
    SELECT 1 
    FROM ModelValueHistory mvh 
    WHERE mvh.ModelId = m.ModelId 
      AND mvh.ValueDate = CAST(GETDATE() AS DATE)
)
GROUP BY m.ModelId;
',
    @database_name = N'YourDatabaseName', -- Replace with actual database name
    @retry_attempts = 3,
    @retry_interval = 5;

-- Create a schedule to run daily at 6 PM (18:00)
EXEC dbo.sp_add_schedule
    @schedule_name = N'Daily at 6 PM',
    @freq_type = 4, -- Daily
    @freq_interval = 1, -- Every day
    @active_start_time = 180000; -- 6:00 PM (HHMMSS format)

-- Attach the schedule to the job
EXEC dbo.sp_attach_schedule
    @job_name = N'Daily Model Value Calculation',
    @schedule_name = N'Daily at 6 PM';

-- Add the job to the local server
EXEC dbo.sp_add_jobserver
    @job_name = N'Daily Model Value Calculation',
    @server_name = N'(LOCAL)';

GO

-- To view the job
-- SELECT * FROM msdb.dbo.sysjobs WHERE name = 'Daily Model Value Calculation';

-- To manually execute the job for testing
-- EXEC msdb.dbo.sp_start_job @job_name = N'Daily Model Value Calculation';
