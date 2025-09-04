using System.ComponentModel.DataAnnotations.Schema;

namespace SimpleCRUD.DTO.Utility.Readings;

[Table("UtilityReadings", Schema = "utility")]
public sealed class UtilityReading
{
    public int Id { get; set; }
    public int UtilityTypeId { get; set; }              // NOT NULL in DB
    public string UtilityType { get; set; } = string.Empty;
    public string UserId { get; set; } = string.Empty;  // NOT NULL in DB (nvarchar(450))

    // Inputs
    public decimal UnitRate { get; set; }               // NOT NULL
    public decimal StandingChargePerDay { get; set; }   // NOT NULL
    public decimal VatRateFactor { get; set; }          // NOT NULL

    public DateTime ReadingStartDate { get; set; }      // date (no time)
    public DateTime ReadingEndDate { get; set; }        // date (no time)

    public decimal MeterStart { get; set; }             // NOT NULL
    public decimal MeterEnd { get; set; }               // NOT NULL

    // Computed by SQL
    public decimal UnitsUsed { get; set; }
    public int BillDays { get; set; }
    public decimal TotalUsage { get; set; }
    public decimal TotalStandingCharge { get; set; }
    public decimal Total { get; set; }

    public DateTime CreatedAt { get; set; }             // defaulted in DB

    // Optional
    public decimal? ProviderDebitAmount { get; set; }
    public DateTime? ProviderDebitDate { get; set; }
    public string? Notes { get; set; }
}
