namespace SimpleCRUD.DTO.Utility.Reports;

public class MonthlyUsagePoint
{
    /// <summary>First day of the month the row represents (from ReadingEndDate).</summary>
    public DateTime MonthStart { get; set; }

    /// <summary>Total units used in that month (kWh for Electricity, m3 for Water/Gas).</summary>
    public decimal UnitsUsed { get; set; }
}
