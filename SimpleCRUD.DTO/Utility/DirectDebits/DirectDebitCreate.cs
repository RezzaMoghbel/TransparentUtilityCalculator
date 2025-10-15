using System.ComponentModel.DataAnnotations;

namespace SimpleCRUD.DTO.Utility.DirectDebits;

// CREATE (required vs nullable input)
public class DirectDebitCreate : IValidatableObject
{
    [Required, StringLength(450)] public string? UserId { get; set; }
    
    [Required, Range(0.01, 999999.99, ErrorMessage = "Amount must be greater than 0")]
    public decimal? Amount { get; set; }
    
    [Required, DataType(DataType.Date)] 
    public DateTime? PaymentDate { get; set; }
    
    public int? UtilityProviderId { get; set; }
    
    [Required, RegularExpression("^(Pending|Paid|Failed|Cancelled)$", ErrorMessage = "PaymentStatus must be: Pending, Paid, Failed, or Cancelled")]
    public string? PaymentStatus { get; set; } = "Paid";
    
    [StringLength(200)] 
    public string? Notes { get; set; }

    // Cross-field validation
    public IEnumerable<ValidationResult> Validate(ValidationContext _)
    {
        // No complex validation needed for the simplified structure
        yield break;
    }
}
