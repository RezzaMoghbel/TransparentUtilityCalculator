namespace SimpleCRUD.Components.Utils
{
    public static class UtilityUnits
    {
        private static readonly Dictionary<string, string> Map = new(StringComparer.OrdinalIgnoreCase)
        {
            ["Electricity"] = "kWh",
            ["Gas"] = "m3",
            ["Water-Hot"] = "m3",
            ["Water-Cold"] = "m3"
        };

        public static string For(string typeName) =>
            Map.TryGetValue(typeName, out var u) ? u : "units";
    }
    public static class UtilityTypes
    {
        private static readonly Dictionary<string, string> Map = new(StringComparer.OrdinalIgnoreCase)
        {
            ["1"] = "Electricity",
            ["2"] = "Gas",
            ["3"] = "Water-Cold",
            ["4"] = "Water-Hot"
        };

        public static string For(string typeId) =>
            Map.TryGetValue(typeId, out var u) ? u : "utilityTypes";
    }
}
