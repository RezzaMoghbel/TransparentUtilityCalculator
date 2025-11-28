namespace SimpleCRUD.DTO.Support;

public class SupportTicket
{
    public int Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public int StatusId { get; set; }
    public int PriorityId { get; set; }
    public int CategoryId { get; set; }
    public string CreatedByUserId { get; set; } = string.Empty;
    public string? AssignedToUserId { get; set; }
    public string? RelatedUserId { get; set; }
    public int BuildingId { get; set; }
    public int? AnnouncementId { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
    public DateTime? ResolvedAt { get; set; }
    public bool IsArchived { get; set; }
    public int TotalCount { get; set; }
}

