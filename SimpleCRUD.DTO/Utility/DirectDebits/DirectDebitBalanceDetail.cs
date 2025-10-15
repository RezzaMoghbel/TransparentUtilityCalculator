namespace SimpleCRUD.DTO.Utility.DirectDebits;

public sealed class DirectDebitBalanceDetail
{
    public int Id { get; set; }
    public DateTime PaymentDate { get; set; }
    public decimal DirectDebitAmount { get; set; }
    public string? ProviderName { get; set; }
    public string PaymentStatus { get; set; } = "Paid";
    public string? Notes { get; set; }
    public DateTime CreatedAt { get; set; }
    public decimal LinkedReadingsTotal { get; set; }
    public decimal Balance { get; set; }
    public string BalanceStatus { get; set; } = string.Empty;
}
