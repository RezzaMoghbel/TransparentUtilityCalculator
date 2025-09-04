using System.Data;

namespace SimpleCRUD.Data.Infrastructure
{
    public interface ISqlConnectionFactory
    {
        /// <summary>
        /// Creates a CLOSED IDbConnection. Caller is responsible for disposing.
        /// </summary>
        IDbConnection Create();
    }
}