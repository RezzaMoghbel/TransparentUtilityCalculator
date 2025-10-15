using System.ComponentModel.DataAnnotations.Schema;

namespace SimpleCRUD.DTO.Identity;

[Table("UtilityProviders", Schema = "dbo")]
public sealed class UtilityProvider
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? URL { get; set; }
    public bool IsActive { get; set; }
}

