using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;

namespace SimpleCRUD.Data.Models
{
    public class ApplicationDbContextFactory : IDesignTimeDbContextFactory<ApplicationDbContext>
    {
        public ApplicationDbContext CreateDbContext(string[] args)
        {
            // Get environment from environment variable or default to Development
            var environmentName = Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT") ?? "Development";
            
            // Set connection string based on environment (same as Program.cs)
            string connectionString = environmentName.ToLowerInvariant() switch
            {
                "development" => "Server=DEV-SERVER;Database=DevDatabase;User Id=DevUser;Password=DUMMY_PASSWORD;MultipleActiveResultSets=true;TrustServerCertificate=True",
                "staging" => "Server=STAGING-SERVER\\SQLEXPRESS;Database=StagingDatabase;User Id=StagingUser;Password=DUMMY_PASSWORD;MultipleActiveResultSets=true;TrustServerCertificate=True",
                "production" => "Server=PROD-SERVER\\SQLEXPRESS;Database=ProdDatabase;User Id=ProdUser;Password=DUMMY_PASSWORD;MultipleActiveResultSets=true;TrustServerCertificate=True",
                _ => throw new InvalidOperationException($"Unknown environment: {environmentName}")
            };

            var optionsBuilder = new DbContextOptionsBuilder<ApplicationDbContext>();
            optionsBuilder.UseSqlServer(connectionString);

            return new ApplicationDbContext(optionsBuilder.Options);
        }
    }
}
