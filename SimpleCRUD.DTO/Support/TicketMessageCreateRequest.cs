using System.ComponentModel.DataAnnotations;

namespace SimpleCRUD.DTO.Support;

public class TicketMessageCreateRequest
{
    public int TicketId { get; set; }

    [Required]
    [MaxLength(2000)]
    public string Body { get; set; } = string.Empty;

    [Required]
    public string CreatedByUserId { get; set; } = string.Empty;
    public bool IsInternal { get; set; }
}

