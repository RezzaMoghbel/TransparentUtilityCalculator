using System.ComponentModel.DataAnnotations;

namespace SimpleCRUD.DTO.Support;

public class AnnouncementCreateRequest
{
    [Required]
    [MaxLength(200)]
    public string Title { get; set; } = string.Empty;

    [Required]
    public string Body { get; set; } = string.Empty;
    public int? CategoryId { get; set; }

    [Required]
    public int ScopeId { get; set; }
    public int? BuildingId { get; set; }
    public int? SourceTicketId { get; set; }

    [Required]
    public string CreatedByUserId { get; set; } = string.Empty;
    public DateTime? PublishedAt { get; set; }
    public bool IsActive { get; set; } = true;
}

