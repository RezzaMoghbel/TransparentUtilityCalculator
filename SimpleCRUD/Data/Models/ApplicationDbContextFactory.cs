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
                "development" => "Server=HELLODIGI;Database=UtilityCalculator;User Id=UtilityCalculator;Password=0098611Roya;MultipleActiveResultSets=true;TrustServerCertificate=True",
                "staging" => "Server=WIN-AEIFAQC5IFS\\SQLEXPRESS;Database=UtilityCalculatorLive;User Id=UtilityCalculatorUser;Password=0098611Roya;MultipleActiveResultSets=true;TrustServerCertificate=True",
                "production" => "Server=WIN-AEIFAQC5IFS\\SQLEXPRESS;Database=UtilityCalculatorLive;User Id=UtilityCalculatorLive;Password=0098611Roya;MultipleActiveResultSets=true;TrustServerCertificate=True",
                _ => throw new InvalidOperationException($"Unknown environment: {environmentName}")
            };

            var optionsBuilder = new DbContextOptionsBuilder<ApplicationDbContext>();
            optionsBuilder.UseSqlServer(connectionString);

            return new ApplicationDbContext(optionsBuilder.Options);
        }
    }
}
