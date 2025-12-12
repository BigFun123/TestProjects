using Microsoft.Data.SqlClient;

namespace HangFire.Data;

public class DatabaseService
{
    private readonly string _connectionString;
    private readonly ILogger<DatabaseService> _logger;

    public DatabaseService(IConfiguration configuration, ILogger<DatabaseService> logger)
    {
        _connectionString = configuration.GetConnectionString("DefaultConnection") 
            ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");
        _logger = logger;
    }

    public async Task ExecuteStoredProcedureAsync(string procedureName)
    {
        try
        {
            _logger.LogInformation("Executing stored procedure: {ProcedureName}", procedureName);

            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();

            using var command = new SqlCommand(procedureName, connection)
            {
                CommandType = System.Data.CommandType.StoredProcedure,
                CommandTimeout = 300 // 5 minutes timeout
            };

            var rowsAffected = await command.ExecuteNonQueryAsync();
            
            _logger.LogInformation(
                "Successfully executed stored procedure: {ProcedureName}. Rows affected: {RowsAffected}", 
                procedureName, 
                rowsAffected);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error executing stored procedure: {ProcedureName}", procedureName);
            throw;
        }
    }
}
