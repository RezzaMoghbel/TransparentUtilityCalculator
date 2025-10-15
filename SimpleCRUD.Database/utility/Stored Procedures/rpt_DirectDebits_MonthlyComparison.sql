CREATE PROCEDURE [utility].[rpt_DirectDebits_MonthlyComparison]
    @UserId NVARCHAR(450)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @CurrentYear INT = YEAR(GETDATE());
    DECLARE @YearStart DATE = DATEFROMPARTS(@CurrentYear, 1, 1);
    DECLARE @YearEnd DATE = DATEFROMPARTS(@CurrentYear, 12, 31);
    
    -- Generate 12 months for current year
    ;WITH Months AS (
        SELECT 1 AS MonthNum UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
        UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8
        UNION ALL SELECT 9 UNION ALL SELECT 10 UNION ALL SELECT 11 UNION ALL SELECT 12
    ),
    MonthDates AS (
        SELECT 
            DATEFROMPARTS(@CurrentYear, MonthNum, 1) AS MonthStart,
            MonthNum
        FROM Months
    ),
    DDByMonth AS (
        SELECT 
            DATEFROMPARTS(YEAR(dd.PaymentDate), MONTH(dd.PaymentDate), 1) AS MonthStart,
            SUM(dd.Amount) AS TotalDD
        FROM [utility].[DirectDebits] dd
        WHERE dd.UserId = @UserId
          AND dd.PaymentDate >= @YearStart
          AND dd.PaymentDate <= @YearEnd
        GROUP BY DATEFROMPARTS(YEAR(dd.PaymentDate), MONTH(dd.PaymentDate), 1)
    ),
    LinkedByMonth AS (
        SELECT 
            DATEFROMPARTS(YEAR(dd.PaymentDate), MONTH(dd.PaymentDate), 1) AS MonthStart,
            SUM(r.Total) AS TotalLinked
        FROM [utility].[DirectDebits] dd
        INNER JOIN [utility].[DirectDebitReadings] dr ON dr.DirectDebitId = dd.Id
        INNER JOIN [utility].[UtilityReadings] r ON r.Id = dr.UtilityReadingId
        WHERE dd.UserId = @UserId
          AND dd.PaymentDate >= @YearStart
          AND dd.PaymentDate <= @YearEnd
        GROUP BY DATEFROMPARTS(YEAR(dd.PaymentDate), MONTH(dd.PaymentDate), 1)
    )
    SELECT 
        md.MonthStart,
        ISNULL(dd.TotalDD, 0) AS DirectDebitTotal,
        ISNULL(lm.TotalLinked, 0) AS LinkedReadingsTotal,
        ISNULL(dd.TotalDD, 0) - ISNULL(lm.TotalLinked, 0) AS Balance,
        CASE 
            WHEN ISNULL(dd.TotalDD, 0) = ISNULL(lm.TotalLinked, 0) THEN 'Exact'
            WHEN ISNULL(dd.TotalDD, 0) > ISNULL(lm.TotalLinked, 0) THEN 'Overpaid'
            ELSE 'Underpaid'
        END AS BalanceStatus
    FROM MonthDates md
    LEFT JOIN DDByMonth dd ON dd.MonthStart = md.MonthStart
    LEFT JOIN LinkedByMonth lm ON lm.MonthStart = md.MonthStart
    ORDER BY md.MonthStart;
END