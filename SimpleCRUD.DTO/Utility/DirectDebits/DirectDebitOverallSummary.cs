namespace SimpleCRUD.DTO.Utility.DirectDebits;

public sealed class DirectDebitOverallSummary
{
    public string Period { get; set; } = string.Empty; // "AllTime" or "CurrentYear"
    public decimal TotalDirectDebits { get; set; }
    public decimal TotalLinkedReadings { get; set; }
    public decimal Balance { get; set; }
    public string BalanceStatus { get; set; } = string.Empty;
    public bool HasOverYearData { get; set; }
}

