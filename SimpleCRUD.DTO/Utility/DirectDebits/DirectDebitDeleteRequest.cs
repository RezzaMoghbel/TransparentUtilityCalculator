namespace SimpleCRUD.DTO.Utility.DirectDebits;

public class DirectDebitDeleteRequest
{
    public int Id { get; set; }
    public string? UserId { get; set; }  // Optional for ownership validation
}

