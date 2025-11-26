--a sql query to get the connection string for a given database
CREATE PROCEDURE GetConnectionString
    @DatabaseName NVARCHAR(256),
    @ConnectionString NVARCHAR(1000) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SET @ConnectionString = 
        'Server=' + @@SERVERNAME + 
        ';Database=' + @DatabaseName + 
        ';Trusted_Connection=True;';
END
GO
-- Example usage:
DECLARE @ConnStr NVARCHAR(1000);
EXEC GetConnectionString 'scratch', @ConnStr OUTPUT;
PRINT @ConnStr;
