using System.ComponentModel.DataAnnotations;
namespace SimpleCRUD.DTO.Utility.Readings;

// CREATE (required vs nullable input)
public class UtilityReadingCreate : IValidatableObject
{
    [Required] public int? UtilityTypeId { get; set; }                 // e.g., 1 Elec, 4 Hot Water
    [Required, StringLength(450)] public string? UserId { get; set; }

    [Required, Range(0, 999999)] public decimal? UnitRate { get; set; }
    [Required, Range(0, 999999)] public decimal? StandingChargePerDay { get; set; }
    [Required, Range(0, 2)] public decimal? VatRateFactor { get; set; }

    [Required, DataType(DataType.Date)] public DateTime? ReadingStartDate { get; set; }
    [Required, DataType(DataType.Date)] public DateTime? ReadingEndDate { get; set; }

    [Required] public decimal? MeterStart { get; set; }
    [Required] public decimal? MeterEnd { get; set; }

    [Range(0, 999999, ErrorMessage = "ProviderDebitAmount must be >= 0")]
    public decimal? ProviderDebitAmount { get; set; }

    [DataType(DataType.Date)] public DateTime? ProviderDebitDate { get; set; }

    [StringLength(200)] public string? Notes { get; set; }

    // Cross-field rules that mirror DB constraints
    public IEnumerable<ValidationResult> Validate(ValidationContext _)
    {
        if (ReadingEndDate < ReadingStartDate)
            yield return new ValidationResult("ReadingEndDate must be >= ReadingStartDate.",
                new[] { nameof(ReadingEndDate), nameof(ReadingStartDate) });

        if (MeterEnd < MeterStart)
            yield return new ValidationResult("MeterEnd must be >= MeterStart.",
                new[] { nameof(MeterEnd), nameof(MeterStart) });

        // Hot Water (Id = 4) rule: StandingChargePerDay must be 0
        if (UtilityTypeId == 4 && StandingChargePerDay != 0)
            yield return new ValidationResult("Hot Water must have StandingChargePerDay = 0.",
                new[] { nameof(UtilityTypeId), nameof(StandingChargePerDay) });
    }
}
