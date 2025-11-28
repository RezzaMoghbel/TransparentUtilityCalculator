namespace SimpleCRUD.DTO.Support;

public class SupportTicketMessage
{
    public int Id { get; set; }
    public int TicketId { get; set; }
    public string Body { get; set; } = string.Empty;
    public string CreatedByUserId { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }
    public bool IsInternal { get; set; }
}

