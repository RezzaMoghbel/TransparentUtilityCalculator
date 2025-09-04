using Microsoft.AspNetCore.Identity;

namespace SimpleCRUD.Data.Models;

public class AccessLevel
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;

    public ICollection<ApplicationUser> Users { get; set; } = new List<ApplicationUser>();
}

