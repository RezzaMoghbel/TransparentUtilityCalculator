using System.ComponentModel.DataAnnotations.Schema;

namespace SimpleCRUD.DTO.Utility.DirectDebits;

public sealed class DirectDebitMonthlyComparison
{
    public DateTime MonthStart { get; set; }
    public decimal DirectDebitTotal { get; set; }
    public decimal LinkedReadingsTotal { get; set; }
    public decimal Balance { get; set; }
    public string BalanceStatus { get; set; } = string.Empty;
}

