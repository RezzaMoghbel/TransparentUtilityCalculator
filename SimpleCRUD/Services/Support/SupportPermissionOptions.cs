using System.Collections.Generic;

namespace SimpleCRUD.Services.Support;

public class SupportPermissionOptions
{
    public Dictionary<string, SupportPermissionSet> AccessLevels { get; set; } = new(StringComparer.OrdinalIgnoreCase);
}

public class SupportPermissionSet
{
    public SupportCrudPermission Tickets { get; set; } = new();
    public SupportCrudPermission Announcements { get; set; } = new();
}

public class SupportCrudPermission
{
    public bool Read { get; set; }
    public bool Create { get; set; }
    public bool Update { get; set; }
    public bool Delete { get; set; }
}

