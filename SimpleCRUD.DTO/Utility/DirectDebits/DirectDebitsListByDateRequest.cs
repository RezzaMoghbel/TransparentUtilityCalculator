namespace SimpleCRUD.DTO.Utility.DirectDebits;

public class DirectDebitsListByDateRequest
{
    public string UserId { get; set; } = string.Empty;
    public DateTime? FromDate { get; set; }
    public DateTime? ToDate { get; set; }
    public string? StoredProcedureName { get; set; }
}

