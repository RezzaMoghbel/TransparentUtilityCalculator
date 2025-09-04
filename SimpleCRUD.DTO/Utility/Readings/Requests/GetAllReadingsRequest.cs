namespace SimpleCRUD.DTO.Utility.Readings.Requests;

public class GetAllReadingsRequest
{
    public string? StoredProcedureName { get; set; }
    public string? UserId { get; set; }
    public DateTime? FromDate { get; set; }
    public DateTime? ToDate { get; set; }
}
