using Microsoft.AspNetCore.Identity;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace SimpleCRUD.Data.Models;

// Add profile data for application users by adding properties to the ApplicationUser class
public class ApplicationUser : IdentityUser
{
    public int AccessLevelId { get; set; } = 1;
    public AccessLevel? AccessLevel { get; set; }

    public bool AccessAllowed { get; set; } = false;
    public bool Deleted { get; set; } = false;
    // FK to Building
    public int? BuildingId { get; set; }
    public Building? Building { get; set; }

    // FK to UtilityProvider
    public int? ProviderId { get; set; }
    public UtilityProvider? Provider { get; set; }

    [MaxLength(100)]
    public string? PropertyName { get; set; }

    [MaxLength(100)]
    public string? AddressLine1 { get; set; }

    [MaxLength(100)]
    public string? AddressLine2 { get; set; }

    [MaxLength(100)]
    public string? AddressLine3 { get; set; }

    [MaxLength(15)]
    public string? Postcode { get; set; }

    [MaxLength(30)]
    public string? Country { get; set; }

}

