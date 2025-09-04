using Microsoft.EntityFrameworkCore;
using SimpleCRUD.Data.Models;

namespace SimpleCRUD.Services
{
    public class IPWhitelistService(ApplicationDbContext dbContext) : IIPWhitelistService
    {
        public async Task<bool> IsIPAllowedAsync(string ipAddress, string? userId)
        {
            var now = DateTime.UtcNow;
            if (string.IsNullOrWhiteSpace(ipAddress))
            {
                return false; // Invalid IP address
            }
            if (string.IsNullOrWhiteSpace(userId))
            {
                return await IsIPAllowedBeforeLogginAsync(ipAddress, now);

            }
            return await IsIPAllowedAfterLogginAsync(ipAddress, userId, now);


        }
        private async Task<bool> IsIPAllowedBeforeLogginAsync(string ipAddress, DateTime now)
        {
            // Check if any entry matches the current IP and (optionally) user ID
            var hasActiveMatch = await dbContext.IPWhitelists.AnyAsync(entry =>
                entry.IsActive && // Only consider active entries
                (entry.ExpiryDate == null || entry.ExpiryDate > now) && // Not expired
                entry.IPAddress == ipAddress // IP must match
            );

            // Check if *any* active whitelist entries exist at all
            var hasAnyActive = await dbContext.IPWhitelists.AnyAsync(entry => entry.IsActive);
            // Grant access if:
            // - there are no active entries at all (fallback open access), OR
            // - a valid match exists
            return !hasAnyActive || hasActiveMatch;
        }
        private async Task<bool> IsIPAllowedAfterLogginAsync(string ipAddress, string userId, DateTime now)
        {
            // Check if any entry matches the current IP and (optionally) user ID
            var hasActiveMatch = await dbContext.IPWhitelists.AnyAsync(entry =>
                entry.IsActive && // Only consider active entries
                (entry.ExpiryDate == null || entry.ExpiryDate > now) && // Not expired
                entry.IPAddress == ipAddress && // IP must match
                (entry.UserId == null || entry.UserId == userId) // Either global or specific to this user
            );

            // Check if *any* active whitelist entries exist at all
            var hasAnyActive = await dbContext.IPWhitelists.AnyAsync(entry => entry.IsActive);
            // Grant access if:
            // - there are no active entries at all (fallback open access), OR
            // - a valid match exists
            return !hasAnyActive || hasActiveMatch;
        }
        public async Task<bool> AnyWhitelistConfiguredAsync()
        {
            try
            {
                return await dbContext.IPWhitelists.AnyAsync();
            }
            catch
            {
                return false;
            }
        }

    }
}
