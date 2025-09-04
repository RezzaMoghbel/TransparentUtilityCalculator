using System.ComponentModel.DataAnnotations;

namespace SimpleCRUD.DTO.Utility.Readings;

// DELETE (by user)
public sealed class UtilityReadingDeleteRequest
{
    [Required, Range(1, int.MaxValue)]
    public int Id { get; set; }

    [Required, StringLength(450)]
    public string UserId { get; set; } = string.Empty;
}
