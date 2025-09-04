using System.ComponentModel.DataAnnotations;

namespace SimpleCRUD.DTO.Utility.Readings;

// VIEW-ALL (by user, optional dates)
public sealed class UtilityReadingsListByDateRequest : IValidatableObject
{
    [Required, StringLength(450)]
    public string UserId { get; set; } = string.Empty;

    [DataType(DataType.Date)] public DateTime? FromDate { get; set; }
    [DataType(DataType.Date)] public DateTime? ToDate { get; set; }

    public IEnumerable<ValidationResult> Validate(ValidationContext _)
    {
        if (FromDate.HasValue && ToDate.HasValue && ToDate < FromDate)
            yield return new ValidationResult("ToDate must be >= FromDate.",
                new[] { nameof(ToDate), nameof(FromDate) });
    }
}
