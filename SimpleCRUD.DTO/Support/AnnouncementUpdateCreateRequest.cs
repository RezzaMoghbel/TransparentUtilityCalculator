using System.ComponentModel.DataAnnotations;

namespace SimpleCRUD.DTO.Support;

public class AnnouncementUpdateCreateRequest
{
    [Required]
    public int AnnouncementId { get; set; }

    [Required]
    [MaxLength(4000)]
    public string Body { get; set; } = string.Empty;

    [Required]
    public string CreatedByUserId { get; set; } = string.Empty;
}

