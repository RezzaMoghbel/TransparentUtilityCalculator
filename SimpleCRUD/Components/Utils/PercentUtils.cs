using System.Globalization;

namespace SimpleCRUD.Components.Utils
{
    public static class PercentUtils
    {
        private static readonly CultureInfo UK = CultureInfo.GetCultureInfo("en-GB");

        /// <summary>
        /// 1.0500 -> 5   (returns the percent value)
        /// 0.8000 -> -20
        /// </summary>
        public static decimal FactorToPercentValue(decimal factor, int decimals = 2)
            => Math.Round((factor - 1m) * 100m, decimals, MidpointRounding.AwayFromZero);

        /// <summary>
        /// 1.0500 -> "5%" ; 1.055 -> "5.5%" if decimals=1, etc.
        /// </summary>
        public static string FactorToPercentString(decimal factor, int decimals = 0)
        {
            var pct = FactorToPercentValue(factor, decimals);
            var fmt = decimals == 0 ? "0" : $"0.{new string('0', decimals)}";
            return pct.ToString(fmt, UK) + "%";
        }

        /// <summary>
        /// 5 -> 1.05 ; -20 -> 0.80 ; 100 -> 2.00
        /// </summary>
        public static decimal PercentToFactor(decimal percent, int decimals = 4)
            => Math.Round(1m + (percent / 100m), decimals, MidpointRounding.AwayFromZero);
    }
}
