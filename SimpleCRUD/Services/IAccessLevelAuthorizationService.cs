using System.Security.Claims;

namespace SimpleCRUD.Services;

public interface IAccessLevelAuthorizationService
{
    Task<bool> IsAuthorizedAsync(ClaimsPrincipal principal, string minimumAccessLevelName);
}


