using Microsoft.Data.SqlClient;

namespace SqlWindowsAuthDemo
{
    class Program
    {
        static async Task Main(string[] args)
        {
            // Connection string using Windows Authentication for LocalDB
            // Option 1: Use (localdb)\MSSQLLocalDB for the default LocalDB instance
            string connectionString = "Server=(localdb)\\MSSQLLocalDB;Database=scratch;Integrated Security=true;TrustServerCertificate=true;";
            
            // Option 2: If you have a named instance, uncomment and use:
            // string connectionString = "Server=(localdb)\\YourInstanceName;Database=scratch;Integrated Security=true;TrustServerCertificate=true;";
            
            // Option 3: For SQL Server Express, use:
            // string connectionString = "Server=.\\SQLEXPRESS;Database=scratch;Integrated Security=true;TrustServerCertificate=true;";

            try
            {
                Console.WriteLine("Attempting to connect to SQL Server using Windows Authentication...");
                
                using (SqlConnection connection = new SqlConnection(connectionString))
                {
                    await connection.OpenAsync();
                    Console.WriteLine("Connection successful!");
                    Console.WriteLine($"Connected to: {connection.Database} on {connection.DataSource}");
                    Console.WriteLine($"Server Version: {connection.ServerVersion}");

                    // Example query
                    string query = "SELECT GETDATE() AS CurrentDateTime, SYSTEM_USER AS WindowsUser";
                    
                    using (SqlCommand command = new SqlCommand(query, connection))
                    {
                        using (SqlDataReader reader = await command.ExecuteReaderAsync())
                        {
                            if (await reader.ReadAsync())
                            {
                                Console.WriteLine($"\nCurrent Server Time: {reader["CurrentDateTime"]}");
                                Console.WriteLine($"Connected as Windows User: {reader["WindowsUser"]}");
                            }
                        }
                    }

                    // Example: Get row count from a table
                    // Update "YourTableName" with an actual table name in your database
                    string tableName = "YourTableName";
                    long rowCount = await GetTableRowCountAsync(connection, tableName);
                    Console.WriteLine($"\nTotal rows in '{tableName}': {rowCount}");
                }
            }
            catch (SqlException ex)
            {
                Console.WriteLine($"SQL Error: {ex.Message}");
                Console.WriteLine($"Error Number: {ex.Number}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error: {ex.Message}");
            }

            Console.WriteLine("\nPress any key to exit...");
            Console.ReadKey();
        }

        /// <summary>
        /// Gets the total number of rows in a specified table
        /// </summary>
        /// <param name="connection">Active SQL connection</param>
        /// <param name="tableName">Name of the table (can include schema: "dbo.TableName")</param>
        /// <returns>Total row count</returns>
        static async Task<long> GetTableRowCountAsync(SqlConnection connection, string tableName)
        {
            // Use QUOTENAME to safely handle table names with special characters
            string query = $"SELECT COUNT(*) FROM {tableName}";
            
            using (SqlCommand command = new SqlCommand(query, connection))
            {
                object? result = await command.ExecuteScalarAsync();
                return result != null ? Convert.ToInt64(result) : 0;
            }
        }
    }
}
