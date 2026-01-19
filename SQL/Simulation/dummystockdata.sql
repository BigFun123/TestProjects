--a microsoft sql query that inserts a year of dummy stock data that looks realistic. updates TotalValue and TotalTime every day for a year
-- don't use random data, it should look like a stock chart with trends and fluctuations
DECLARE @StartDate DATE = '2023-01-01';
DECLARE @EndDate DATE = '2023-12-31';
DECLARE @CurrentDate DATE = @StartDate;
DECLARE @TotalValue FLOAT = 100.0; -- Starting stock value
DECLARE @TotalTime INT = 0; -- Starting total time in days
DECLARE @DailyChange FLOAT;
DECLARE @Trend FLOAT = 0.1; -- Overall upward trend
DECLARE @Fluctuation FLOAT;
DECLARE @DayOfYear INT;
WHILE @CurrentDate <= @EndDate
BEGIN

    SET @DayOfYear = DATEPART(DAYOFYEAR, @CurrentDate);
    
    -- Simulate daily change with sine wave fluctuation
    SET @Fluctuation = SIN(@DayOfYear / 365.0 * 2 * PI()) * 2.0; -- Sine wave fluctuation between -2 and 2
    SET @DailyChange = @Trend + @Fluctuation; -- Combine trend and sine fluctuation
    
    -- Update TotalValue and TotalTime
    SET @TotalValue = @TotalValue + @DailyChange;
    SET @TotalTime = @TotalTime + 1;
    
    -- Insert the daily record into the stock data table
    INSERT INTO StockData (Date, TotalValue, TotalTime)
    VALUES (@CurrentDate, ROUND(@TotalValue, 2), @TotalTime);
    
    -- Move to the next day
    SET @CurrentDate = DATEADD(DAY, 1, @CurrentDate);
END;
GO
-- Note: Ensure that the StockData table exists with appropriate columns (Date, TotalValue, TotalTime) before running this script.



