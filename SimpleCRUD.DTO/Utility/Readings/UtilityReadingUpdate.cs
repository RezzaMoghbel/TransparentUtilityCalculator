using System.ComponentModel.DataAnnotations;

namespace SimpleCRUD.DTO.Utility.Readings
{
    // UPDATE (Id + same validations)
    public sealed class UtilityReadingUpdate : UtilityReadingCreate
    {
        [Required, Range(1, int.MaxValue)]
        public int Id { get; set; }
    }
}
