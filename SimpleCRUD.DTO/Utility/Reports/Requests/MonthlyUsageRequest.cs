namespace SimpleCRUD.DTO.Utility.Reports.Requests;

public class MonthlyUsageRequest
{
    /// <summary>Required: current user's Id.</summary>
    public string UserId { get; set; } = string.Empty;

    /// <summary>'Electricity' | 'Gas' | 'Water-Hot' | 'Water-Cold'</summary>
    public string TypeName { get; set; } = "Electricity";

    /// <summary>Optional range (defaults in SP: Jan 1 this year → today).</summary>
    public DateTime? From { get; set; }
    public DateTime? To { get; set; }
}
