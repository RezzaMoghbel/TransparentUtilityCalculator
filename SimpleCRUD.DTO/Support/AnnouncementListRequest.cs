namespace SimpleCRUD.DTO.Support;

public class AnnouncementListRequest
{
    public int? BuildingId { get; set; }
    public string? ScopeCode { get; set; }
    public string? CategoryCode { get; set; }
    public bool IncludeArchived { get; set; }
    public bool? IsActive { get; set; } = true;
    public int PageNumber { get; set; } = 1;
    public int PageSize { get; set; } = 20;
}

