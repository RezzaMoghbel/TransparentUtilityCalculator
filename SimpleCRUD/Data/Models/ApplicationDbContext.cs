using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;

namespace SimpleCRUD.Data.Models;

public class ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
    : IdentityDbContext<ApplicationUser>(options)
{
    public DbSet<AccessLevel> AccessLevels => Set<AccessLevel>();
    public DbSet<IPWhiteList> IPWhitelists => Set<IPWhiteList>();
    public DbSet<Building> Buildings => Set<Building>();
    public DbSet<UtilityProvider> UtilityProviders => Set<UtilityProvider>();

    protected override void OnModelCreating(ModelBuilder builder)
    {
        base.OnModelCreating(builder);

        // Seed Access Levels
        builder.Entity<AccessLevel>().HasData(
            new AccessLevel { Id = 1, Name = "User", Description = "Standard authenticated user with access to their own data (e.g., policies, claims, profile)." },
            new AccessLevel { Id = 2, Name = "Admin", Description = "In-house staff with permissions to manage users, content, claims, and business operations (excluding system configuration)." },
            new AccessLevel { Id = 3, Name = "SuperAdmin", Description = "Full system access including role management, configurations, audit logs, and administrative overrides." },
            new AccessLevel { Id = 4, Name = "System", Description = "Reserved for automated internal processes such as scheduled tasks, integrations, or system-generated actions." }
        );

        // Seed default IP whitelist
        builder.Entity<IPWhiteList>().HasData(
            new IPWhiteList { Id = 1, IPAddress = "127.0.0.1", Description = "Local IP 1" },
            new IPWhiteList { Id = 2, IPAddress = "::1", Description = "Local IP 2" }
        );

        // Seed Buildings
        builder.Entity<Building>().HasData(
            new Building { Id = 1, Name = "Anchor House", IsActive = true },
            new Building { Id = 2, Name = "Bale House", IsActive = true }
        );

        // Seed Utility Providers
        builder.Entity<UtilityProvider>().HasData(
            new UtilityProvider { Id = 1, Name = "HomeBox", URL = "www.HomeBox.co.uk", IsActive = true }
        );

        // Building relationship
        builder.Entity<ApplicationUser>()
            .HasOne(u => u.Building)
            .WithMany()
            .HasForeignKey(u => u.BuildingId)
            .OnDelete(DeleteBehavior.SetNull);

        // Provider relationship
        builder.Entity<ApplicationUser>()
            .HasOne(u => u.Provider)
            .WithMany()
            .HasForeignKey(u => u.ProviderId)
            .OnDelete(DeleteBehavior.SetNull);
    }
}
