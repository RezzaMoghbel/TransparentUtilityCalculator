namespace SimpleCRUD.DTO.Utility.DirectDebits;

public sealed class DirectDebitBalance
{
    public int Id { get; set; }
    public DateTime PaymentDate { get; set; }
    public decimal DirectDebitAmount { get; set; }
    public string? ProviderName { get; set; }
    public string PaymentStatus { get; set; } = "Paid";
    public decimal LinkedReadingsTotal { get; set; }
    public decimal Balance { get; set; }
    public string BalanceStatus { get; set; } = string.Empty;
    public int LinkedReadingsCount { get; set; }
}
