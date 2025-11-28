namespace SimpleCRUD.DTO.Support;

public class SupportAnnouncement
{
    public int Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public string Body { get; set; } = string.Empty;
    public int? CategoryId { get; set; }
    public int ScopeId { get; set; }
    public int? BuildingId { get; set; }
    public int? SourceTicketId { get; set; }
    public string CreatedByUserId { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }
    public DateTime? PublishedAt { get; set; }
    public bool IsActive { get; set; }
    public bool IsArchived { get; set; }
    public int TotalCount { get; set; }
}

