namespace SimpleCRUD.DTO.Utility.Reports;

public class MonthlyAmountPoint
{
    /// <summary>First day of the month bucket (based on ReadingEndDate).</summary>
    public DateTime MonthStart { get; set; }

    /// <summary>Total £ amount for that month.</summary>
    public decimal TotalAmount { get; set; }
}
