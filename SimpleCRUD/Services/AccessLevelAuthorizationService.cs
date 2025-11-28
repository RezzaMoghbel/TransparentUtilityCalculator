using System.Security.Claims;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using SimpleCRUD.Data.Models;

namespace SimpleCRUD.Services;

public class AccessLevelAuthorizationService : IAccessLevelAuthorizationService
{
    private readonly IDbContextFactory<ApplicationDbContext> _dbContextFactory;
    private readonly UserManager<ApplicationUser> _userManager;
    private readonly ILogger<AccessLevelAuthorizationService> _logger;

    public AccessLevelAuthorizationService(
        IDbContextFactory<ApplicationDbContext> dbContextFactory,
        UserManager<ApplicationUser> userManager,
        ILogger<AccessLevelAuthorizationService> logger)
    {
        _dbContextFactory = dbContextFactory;
        _userManager = userManager;
        _logger = logger;
    }

    public async Task<bool> IsAuthorizedAsync(ClaimsPrincipal principal, string minimumAccessLevelName)
    {
        if (principal?.Identity?.IsAuthenticated != true)
        {
            _logger.LogDebug("Authorization blocked: unauthenticated principal.");
            return false;
        }

        if (string.Equals(minimumAccessLevelName, "all", StringComparison.OrdinalIgnoreCase))
        {
            return true;
        }

        var userId = _userManager.GetUserId(principal);
        if (string.IsNullOrWhiteSpace(userId))
        {
            _logger.LogWarning("Authorization blocked: unable to resolve user ID.");
            return false;
        }

        var normalizedLevelName = minimumAccessLevelName.Trim().ToLower();

        // Create a new DbContext instance for this operation to avoid concurrency issues
        await using var dbContext = await _dbContextFactory.CreateDbContextAsync();

        // Combine both queries into a single database round-trip
        var result = await (
            from user in dbContext.Users
            join accessLevel in dbContext.AccessLevels on user.AccessLevelId equals accessLevel.Id
            where user.Id == userId && accessLevel.Name.ToLower() == normalizedLevelName
            select new { UserLevelId = user.AccessLevelId, RequiredLevelId = accessLevel.Id }
        ).FirstOrDefaultAsync();

        if (result == null)
        {
            // If join fails, check if user exists and access level exists separately
            var userLevelId = await dbContext.Users
                .Where(u => u.Id == userId)
                .Select(u => u.AccessLevelId)
                .FirstOrDefaultAsync();

            if (userLevelId == 0)
            {
                _logger.LogWarning("Authorization blocked: user {UserId} not found.", userId);
                return false;
            }

            var requiredLevelId = await dbContext.AccessLevels
                .Where(a => a.Name.ToLower() == normalizedLevelName)
                .Select(a => a.Id)
                .FirstOrDefaultAsync();

            if (requiredLevelId == 0)
            {
                _logger.LogError("Access level '{AccessLevel}' not found in database.", minimumAccessLevelName);
                return false;
            }

            var isAuthorized = userLevelId >= requiredLevelId;
            _logger.LogDebug(
                "Authorization check for user {UserId}: userLevel={UserLevelId}, requiredLevel={RequiredLevelId}, result={Result}",
                userId, userLevelId, requiredLevelId, isAuthorized);
            return isAuthorized;
        }

        var isAuthorizedResult = result.UserLevelId >= result.RequiredLevelId;
        _logger.LogDebug(
            "Authorization check for user {UserId}: userLevel={UserLevelId}, requiredLevel={RequiredLevelId}, result={Result}",
            userId, result.UserLevelId, result.RequiredLevelId, isAuthorizedResult);
        return isAuthorizedResult;
    }
}


