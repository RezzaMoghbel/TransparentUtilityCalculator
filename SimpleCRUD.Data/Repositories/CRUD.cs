using Dapper;
using SimpleCRUD.Data.RepositoriesAbstractions;
using System.ComponentModel.DataAnnotations.Schema;
using System.Data;
using System.Reflection;
using SimpleCRUD.Data.Infrastructure;
using SimpleCRUD.DTO.Identity; // you had this in your usings

namespace SimpleCRUD.Data.Repositories
{
    public class CRUD<T> : ICRUD<T> where T : class
    {
        private readonly ISqlConnectionFactory _connFactory;
        private readonly string? _primaryKey;
        private readonly string? _tableName;

        public CRUD(ISqlConnectionFactory connFactory, string? primaryKey = null)
        {
            _connFactory = connFactory;
            _primaryKey = primaryKey;

            // If table name needed, can read it here:
            var tableAttr = typeof(T).GetCustomAttribute<TableAttribute>();
            _tableName = tableAttr?.Name; // unused right now, but handy for generic SQL
        }

        public async Task<IEnumerable<TResult>> ExecuteStoredProcedureAsync<TResult>(
            string procedureName,
            object? parameters = null)
        {
            if (string.IsNullOrWhiteSpace(procedureName))
                throw new ArgumentException("Procedure name is required.", nameof(procedureName));

            try
            {
                using var conn = _connFactory.Create();
                // Dapper will open the connection if closed;
                // Can also do: await ((SqlConnection)conn).OpenAsync();
                var result = (await conn.QueryAsync<TResult>(
                    procedureName,
                    param: parameters,
                    commandType: CommandType.StoredProcedure)).ToList();

                // Preserve your error contract check
                if (typeof(TResult) == typeof(SqlErrorResult) && result.Any())
                {
                    var error = result.First() as SqlErrorResult;
                    throw new Exception($"SQL Error: {error?.ErrorMessage ?? "Unknown error"}");
                }

                return result;
            }
            catch (Exception ex)
            {
                throw new Exception($"Stored procedure execution failed: {procedureName} - {ex.Message}", ex);
            }
        }
    }
}
