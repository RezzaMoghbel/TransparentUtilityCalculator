namespace SimpleCRUD.DTO.Utility.Types;

public class UtilityType
{
    public int Id { get; set; }                 // PK (IDENTITY)
    public string Name { get; set; } = string.Empty;  // NVARCHAR(20) NOT NULL (UQ)
    public string Unit { get; set; } = string.Empty;  // NVARCHAR(16) NOT NULL
    public DateTime CreatedAt { get; set; }     // DATETIME2(0), default SYSUTCDATETIME()
    public string? Notes { get; set; }          // NVARCHAR(200) NULL
    public bool IsActive { get; set; }          // BIT, default 1
    public string Display => $"{Name} ({Unit})";
}
