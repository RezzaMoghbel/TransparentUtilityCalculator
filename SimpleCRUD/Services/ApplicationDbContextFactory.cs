using Microsoft.EntityFrameworkCore;
using SimpleCRUD.Data.Models;

namespace SimpleCRUD.Services;

/// <summary>
/// Custom DbContextFactory implementation that creates contexts independently
/// without depending on scoped services, suitable for Blazor Server concurrent scenarios.
/// </summary>
public class ApplicationDbContextFactory : IDbContextFactory<ApplicationDbContext>
{
    private readonly string _connectionString;

    public ApplicationDbContextFactory(string connectionString)
    {
        _connectionString = connectionString ?? throw new ArgumentNullException(nameof(connectionString));
    }

    public ApplicationDbContext CreateDbContext()
    {
        var optionsBuilder = new DbContextOptionsBuilder<ApplicationDbContext>();
        optionsBuilder.UseSqlServer(_connectionString);
        return new ApplicationDbContext(optionsBuilder.Options);
    }
}

