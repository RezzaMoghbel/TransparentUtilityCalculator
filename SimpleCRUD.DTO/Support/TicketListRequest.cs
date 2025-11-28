namespace SimpleCRUD.DTO.Support;

public class TicketListRequest
{
    public string? UserId { get; set; }
    public int? BuildingId { get; set; }
    public string? StatusCode { get; set; }
    public string? PriorityCode { get; set; }
    public string? AssignedToUserId { get; set; }
    public string? Search { get; set; }
    public bool IncludeArchived { get; set; }
    public int PageNumber { get; set; } = 1;
    public int PageSize { get; set; } = 20;
}

