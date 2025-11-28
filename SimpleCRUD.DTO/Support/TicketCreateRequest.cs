using System.ComponentModel.DataAnnotations;

namespace SimpleCRUD.DTO.Support;

public class TicketCreateRequest
{
    [Required]
    [MaxLength(200)]
    public string Title { get; set; } = string.Empty;

    [Required]
    public string Description { get; set; } = string.Empty;

    [Required]
    public int StatusId { get; set; }

    [Required]
    public int PriorityId { get; set; }

    [Required]
    public int CategoryId { get; set; }

    [Required]
    public string CreatedByUserId { get; set; } = string.Empty;

    [Range(1, int.MaxValue, ErrorMessage = "Building is required.")]
    public int BuildingId { get; set; }
    public string? AssignedToUserId { get; set; }
    public string? RelatedUserId { get; set; }
}

