using System.ComponentModel.DataAnnotations.Schema;

namespace SimpleCRUD.DTO.Utility.DirectDebits;

[Table("DirectDebits", Schema = "utility")]
public sealed class DirectDebit
{
    public int Id { get; set; }
    public string UserId { get; set; } = string.Empty;  // NOT NULL in DB (nvarchar(450))
    public decimal Amount { get; set; }                  // NOT NULL
    public DateTime PaymentDate { get; set; }           // NOT NULL (date)
    public int? UtilityProviderId { get; set; }         // NULLABLE FK to dbo.UtilityProviders
    public string? ProviderName { get; set; }           // Read-only from join with UtilityProviders
    public string PaymentStatus { get; set; } = "Paid"; // NOT NULL, default 'Paid'
    public string? Notes { get; set; }                  // NULLABLE
    public DateTime CreatedAt { get; set; }             // defaulted in DB
}
