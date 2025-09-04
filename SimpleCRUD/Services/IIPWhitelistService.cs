namespace SimpleCRUD.Services
{
    public interface IIPWhitelistService
    {
        Task<bool> IsIPAllowedAsync(string ipAddress, string? userId);
        Task<bool> AnyWhitelistConfiguredAsync();

    }
}
