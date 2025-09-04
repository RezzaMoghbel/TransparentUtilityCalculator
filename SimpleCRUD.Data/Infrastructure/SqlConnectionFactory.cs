using Microsoft.Data.SqlClient;
using System.Data;

namespace SimpleCRUD.Data.Infrastructure
{
    public sealed class SqlConnectionFactory : ISqlConnectionFactory
    {
        private readonly string _connectionString;

        public SqlConnectionFactory(string connectionString)
        {
            _connectionString = connectionString ?? throw new ArgumentNullException(nameof(connectionString));
        }

        public IDbConnection Create()
        {
            // Return CLOSED connection; open it in the repo method (or let Dapper open it)
            return new SqlConnection(_connectionString);
        }
    }
}
