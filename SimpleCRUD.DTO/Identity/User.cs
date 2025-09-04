using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace SimpleCRUD.DTO.Identity;

[Table("Users")]
public class User
{
    public string ID { get; set; } = string.Empty;

    public string? UserName { get; set; }

    public bool EmailConfirmed { get; set; }

    public string? PhoneNumber { get; set; }

    public bool PhoneNumberConfirmed { get; set; }

    public bool TwoFactorEnabled { get; set; }

    public bool LockoutEnabled { get; set; }
    public DateTimeOffset? LockoutEnd { get; set; }

    public int AccessFailedCount { get; set; }

    public int? AccessLevelId { get; set; }

    public string? AccessLevel { get; set; }
    public bool AccessAllowed { get; set; }
    public bool Deleted { get; set; }
}
public class UserManageAccountExtras
{

    public string? FlatNumber { get; set; }
    public string? BuildingName { get; set; }
    public string? ProviderName { get; set; }

}
