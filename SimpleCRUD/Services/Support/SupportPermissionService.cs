using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using SimpleCRUD.Data.Models;
using System.Security.Claims;

namespace SimpleCRUD.Services.Support;

public class SupportPermissionService
{
    private readonly UserManager<ApplicationUser> _userManager;
    private readonly IDbContextFactory<ApplicationDbContext> _dbContextFactory;
    private readonly SupportPermissionOptions _options;

    public SupportPermissionService(
        UserManager<ApplicationUser> userManager,
        IDbContextFactory<ApplicationDbContext> dbContextFactory,
        IOptions<SupportPermissionOptions> optionsAccessor)
    {
        _userManager = userManager ?? throw new ArgumentNullException(nameof(userManager));
        _dbContextFactory = dbContextFactory ?? throw new ArgumentNullException(nameof(dbContextFactory));
        _options = optionsAccessor?.Value ?? new SupportPermissionOptions();
    }

    public async Task<SupportPermissionSet> GetPermissionsAsync(ClaimsPrincipal? principal, CancellationToken cancellationToken = default)
    {
        if (principal is null)
        {
            return GetDefaultPermissions("User");
        }

        // Get userId from claims (no database query needed)
        var userId = _userManager.GetUserId(principal);
        if (string.IsNullOrWhiteSpace(userId))
        {
            return GetDefaultPermissions("User");
        }

        // Create a new DbContext instance for this operation to avoid concurrency issues
        await using var dbContext = await _dbContextFactory.CreateDbContextAsync(cancellationToken);

        // Query only AccessLevelId directly (more efficient than loading full user entity)
        var accessLevelId = await dbContext.Users
            .Where(u => u.Id == userId)
            .Select(u => u.AccessLevelId)
            .FirstOrDefaultAsync(cancellationToken);

        if (accessLevelId == 0)
        {
            return GetDefaultPermissions("User");
        }

        var accessLevelName = MapAccessLevelName(accessLevelId);
        if (_options.AccessLevels.TryGetValue(accessLevelName, out var configured))
        {
            return Clone(configured);
        }

        return GetDefaultPermissions(accessLevelName);
    }

    public Task<bool> CanReadTicketsAsync(ClaimsPrincipal principal, CancellationToken cancellationToken = default)
        => CheckAsync(principal, set => set.Tickets.Read, cancellationToken);

    public Task<bool> CanCreateTicketsAsync(ClaimsPrincipal principal, CancellationToken cancellationToken = default)
        => CheckAsync(principal, set => set.Tickets.Create, cancellationToken);

    public Task<bool> CanUpdateTicketsAsync(ClaimsPrincipal principal, CancellationToken cancellationToken = default)
        => CheckAsync(principal, set => set.Tickets.Update, cancellationToken);

    public Task<bool> CanDeleteTicketsAsync(ClaimsPrincipal principal, CancellationToken cancellationToken = default)
        => CheckAsync(principal, set => set.Tickets.Delete, cancellationToken);

    public Task<bool> CanReadAnnouncementsAsync(ClaimsPrincipal principal, CancellationToken cancellationToken = default)
        => CheckAsync(principal, set => set.Announcements.Read, cancellationToken);

    public Task<bool> CanCreateAnnouncementsAsync(ClaimsPrincipal principal, CancellationToken cancellationToken = default)
        => CheckAsync(principal, set => set.Announcements.Create, cancellationToken);

    public Task<bool> CanUpdateAnnouncementsAsync(ClaimsPrincipal principal, CancellationToken cancellationToken = default)
        => CheckAsync(principal, set => set.Announcements.Update, cancellationToken);

    public Task<bool> CanDeleteAnnouncementsAsync(ClaimsPrincipal principal, CancellationToken cancellationToken = default)
        => CheckAsync(principal, set => set.Announcements.Delete, cancellationToken);

    private async Task<bool> CheckAsync(ClaimsPrincipal principal, Func<SupportPermissionSet, bool> predicate, CancellationToken token)
    {
        var permissions = await GetPermissionsAsync(principal, token);
        return predicate(permissions);
    }

    private static SupportPermissionSet Clone(SupportPermissionSet source)
        => new()
        {
            Tickets = new SupportCrudPermission
            {
                Read = source.Tickets.Read,
                Create = source.Tickets.Create,
                Update = source.Tickets.Update,
                Delete = source.Tickets.Delete
            },
            Announcements = new SupportCrudPermission
            {
                Read = source.Announcements.Read,
                Create = source.Announcements.Create,
                Update = source.Announcements.Update,
                Delete = source.Announcements.Delete
            }
        };

    private static SupportPermissionSet GetDefaultPermissions(string accessLevelName) =>
        MapAccessLevelName(accessLevelName) switch
        {
            "Admin" or "SuperAdmin" or "System" => new SupportPermissionSet
            {
                Tickets = new SupportCrudPermission { Read = true, Create = true, Update = true, Delete = true },
                Announcements = new SupportCrudPermission { Read = true, Create = true, Update = true, Delete = true }
            },
            _ => new SupportPermissionSet
            {
                Tickets = new SupportCrudPermission { Read = true, Create = true, Update = false, Delete = false },
                Announcements = new SupportCrudPermission { Read = true, Create = false, Update = false, Delete = false }
            }
        };

    private static string MapAccessLevelName(int? accessLevelId)
    {
        return accessLevelId switch
        {
            2 => "Admin",
            3 => "SuperAdmin",
            4 => "System",
            _ => "User"
        };
    }

    private static string MapAccessLevelName(string? accessLevelName)
    {
        if (string.IsNullOrWhiteSpace(accessLevelName))
        {
            return "User";
        }

        return accessLevelName switch
        {
            "Admin" or "SuperAdmin" or "System" => accessLevelName,
            _ => "User"
        };
    }
}

