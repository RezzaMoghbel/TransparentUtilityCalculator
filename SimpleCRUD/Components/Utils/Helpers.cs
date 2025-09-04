namespace SimpleCRUD.Components.Utils
{
    public class Helpers
    {
        public static string GetNameFromUsername(string? input)
        {
            if (string.IsNullOrWhiteSpace(input))
                return "No Username";

            // Take everything before @ (or full input if no @)
            var atIndex = input.IndexOf('@');
            string basePart = atIndex >= 0 ? input[..atIndex] : input;

            // Truncate to 10 characters
            if (basePart.Length > 10)
                basePart = basePart[..10];

            // Capitalize first letter, lowercase the rest
            return char.ToUpper(basePart[0]) + basePart[1..].ToLower();
        }

    }
}
