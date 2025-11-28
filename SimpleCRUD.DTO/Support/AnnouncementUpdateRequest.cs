using System.ComponentModel.DataAnnotations;

namespace SimpleCRUD.DTO.Support;

public class AnnouncementUpdateRequest
{
    [Required]
    public int Id { get; set; }

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
    public bool IsActive { get; set; }
    public bool IsArchived { get; set; }
    public DateTime? PublishedAt { get; set; }
}

