using Microsoft.EntityFrameworkCore;
using SimpleCRUD.Data.Models;
using Serilog;

namespace SimpleCRUD.Services
{
    public class IPWhitelistService(ApplicationDbContext dbContext) : IIPWhitelistService
    {
        public async Task<bool> IsIPAllowedAsync(string ipAddress, string? userId)
        {
            try
            {
                var now = DateTime.UtcNow;
                Log.Debug("Checking IP access for IP: {IP}, UserId: {UserId}", ipAddress, userId);
                
                if (string.IsNullOrWhiteSpace(ipAddress))
                {
                    Log.Warning("Invalid IP address provided: {IP}", ipAddress);
                    return false; // Invalid IP address
                }
                if (string.IsNullOrWhiteSpace(userId))
                {
                    Log.Debug("No user ID provided, checking pre-login access");
                    return await IsIPAllowedBeforeLogginAsync(ipAddress, now);
                }
                
                Log.Debug("User ID provided, checking post-login access");
                return await IsIPAllowedAfterLogginAsync(ipAddress, userId, now);
            }
            catch (Exception ex)
            {
                Log.Error(ex, "Error checking IP access for IP: {IP}, UserId: {UserId}", ipAddress, userId);
                return false; // Fail closed for security
            }
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
                Log.Debug("Checking if any IP whitelist entries exist");
                var result = await dbContext.IPWhitelists.AnyAsync();
                Log.Debug("IP whitelist check result: {Result}", result);
                return result;
            }
            catch (Exception ex)
            {
                Log.Error(ex, "Error checking IP whitelist configuration");
                return false;
            }
        }

    }
}
