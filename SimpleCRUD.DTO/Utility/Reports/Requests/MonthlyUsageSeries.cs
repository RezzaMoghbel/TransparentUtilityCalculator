namespace SimpleCRUD.DTO.Utility.Reports;

public class MonthlyUsageSeries
{
    /// <summary>Series label e.g. 'Electricity'.</summary>
    public string TypeName { get; set; } = string.Empty;

    /// <summary>Unit label for axis/legend (e.g. 'kWh' or 'm3').</summary>
    public string UnitLabel { get; set; } = "units";

    /// <summary>Ordered points, one per month.</summary>
    public List<MonthlyUsagePoint> Points { get; set; } = new();
}
