using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace SimpleCRUD.DTO.Identity;
public class IPWhiteList
{
    public int ID { get; set; }

    [Required]
    [MaxLength(45)]
    public string IPAddress { get; set; } = string.Empty;
    public string? UserId { get; set; }
    [ForeignKey("UserId")]
    public User? User { get; set; }
    public string UserName { get; set; } = string.Empty;
    [MaxLength(250)]
    public string? Description { get; set; }
    public DateTime? ExpiryDate { get; set; }
    public bool IsActive { get; set; } = true;
}