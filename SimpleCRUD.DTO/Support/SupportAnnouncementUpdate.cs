namespace SimpleCRUD.DTO.Support;

public class SupportAnnouncementUpdate
{
    public int Id { get; set; }
    public int AnnouncementId { get; set; }
    public string Body { get; set; } = string.Empty;
    public string CreatedByUserId { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }
}

