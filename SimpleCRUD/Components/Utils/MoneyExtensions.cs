namespace SimpleCRUD.Components.Utils;

using System.Globalization;

public static class MoneyExtensions
{
    private static readonly CultureInfo UK = CultureInfo.GetCultureInfo("en-GB");

    /// <summary>
    /// Format as £ with an exact number of decimals (pads or rounds).
    /// Examples: 0.249 -> "£0.249" (decimals:3), 25 -> "£25" (decimals:0)
    /// </summary>
    public static string ToPounds(this decimal amount, int decimals = 2, bool grouping = true)
    {
        var rounded = decimal.Round(amount, decimals, MidpointRounding.AwayFromZero);
        var format = grouping
            ? $"£#,0.{new string('0', decimals)}"
            : $"£0.{new string('0', decimals)}";
        return rounded.ToString(format, UK);
    }

    public static string ToPounds(this decimal? amount, int decimals = 2, bool grouping = true)
            => amount.HasValue ? amount.Value.ToPounds(decimals, grouping) : "";


    /// <summary>
    /// Format as £ with up to maxDecimals, trimming trailing zeros down to minDecimals.
    /// Example: 2.300 -> min=0,max=3 => "£2.3"; 2.000 -> "£2"; 2.50 -> min=2,max=3 => "£2.50"
    /// </summary>
    public static string ToPoundsTrim(this decimal amount, int minDecimals = 0, int maxDecimals = 2, bool grouping = true)
    {
        if (minDecimals < 0 || maxDecimals < minDecimals) throw new ArgumentOutOfRangeException(nameof(maxDecimals));

        var rounded = decimal.Round(amount, maxDecimals, MidpointRounding.AwayFromZero);

        if (maxDecimals == 0)
            return rounded.ToString(grouping ? "£#,0" : "£0", UK);

        // Format with max decimals, then trim trailing zeros down to minDecimals
        var numeric = rounded.ToString(grouping ? $"#,0.{new string('0', maxDecimals)}"
                                                : $"0.{new string('0', maxDecimals)}", UK);
        var sep = UK.NumberFormat.NumberDecimalSeparator;
        var decPos = numeric.LastIndexOf(sep, StringComparison.Ordinal);
        if (decPos >= 0)
        {
            int decimalsShown = numeric.Length - decPos - sep.Length;
            while (decimalsShown > minDecimals && numeric.EndsWith("0", StringComparison.Ordinal))
            {
                numeric = numeric[..^1];
                decimalsShown--;
            }
            if (decimalsShown == 0 && minDecimals == 0)
                numeric = numeric[..^sep.Length]; // remove decimal separator
        }
        return "£" + numeric;
    }

    public static string ToPoundsTrim(this decimal? amount, int minDecimals = 0, int maxDecimals = 2, bool grouping = true)
        => amount.HasValue ? amount.Value.ToPoundsTrim(minDecimals, maxDecimals, grouping) : "";
}
