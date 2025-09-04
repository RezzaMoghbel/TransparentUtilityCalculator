namespace SimpleCRUD.DTO.Identity
{
    public class SqlErrorResult
    {
        public string? ErrorMessage { get; set; }
        public int? ErrorNumber { get; set; }
        public int? ErrorLine { get; set; }
        public string? ErrorProcedure { get; set; }
    }
}
