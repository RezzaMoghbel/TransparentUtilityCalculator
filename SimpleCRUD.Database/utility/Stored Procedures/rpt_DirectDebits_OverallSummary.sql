CREATE   PROCEDURE [utility].[rpt_DirectDebits_OverallSummary]
    @UserId NVARCHAR(450)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @CurrentYear INT = YEAR(GETDATE());
    DECLARE @YearStart DATE = DATEFROMPARTS(@CurrentYear, 1, 1);
    DECLARE @Today DATE = CAST(GETDATE() AS DATE);
    
    -- Get earliest DD payment date to determine if we have > 12 months of data
    DECLARE @EarliestPaymentDate DATE = (
        SELECT MIN(PaymentDate) 
        FROM [utility].[DirectDebits] 
        WHERE UserId = @UserId
    );
    
    DECLARE @HasOverYearData BIT = CASE 
        WHEN DATEDIFF(MONTH, @EarliestPaymentDate, @Today) > 12 THEN 1 
        ELSE 0 
    END;
    
    -- All-time totals (FIXED: Use subqueries to avoid duplication)
    SELECT 
        CASE 
            WHEN @HasOverYearData = 1 THEN 'AllTime'
            ELSE 'CurrentYear'
        END AS Period,
        (SELECT ISNULL(SUM(Amount), 0) FROM [utility].[DirectDebits] WHERE UserId = @UserId) AS TotalDirectDebits,
        (SELECT ISNULL(SUM(r.Total), 0) 
         FROM [utility].[DirectDebitReadings] ddr
         JOIN [utility].[UtilityReadings] r ON ddr.UtilityReadingId = r.Id
         JOIN [utility].[DirectDebits] dd ON ddr.DirectDebitId = dd.Id
         WHERE dd.UserId = @UserId) AS TotalLinkedReadings,
        (SELECT ISNULL(SUM(Amount), 0) FROM [utility].[DirectDebits] WHERE UserId = @UserId) - 
        (SELECT ISNULL(SUM(r.Total), 0) 
         FROM [utility].[DirectDebitReadings] ddr
         JOIN [utility].[UtilityReadings] r ON ddr.UtilityReadingId = r.Id
         JOIN [utility].[DirectDebits] dd ON ddr.DirectDebitId = dd.Id
         WHERE dd.UserId = @UserId) AS Balance,
        CASE 
            WHEN (SELECT ISNULL(SUM(Amount), 0) FROM [utility].[DirectDebits] WHERE UserId = @UserId) - 
                 (SELECT ISNULL(SUM(r.Total), 0) 
                  FROM [utility].[DirectDebitReadings] ddr
                  JOIN [utility].[UtilityReadings] r ON ddr.UtilityReadingId = r.Id
                  JOIN [utility].[DirectDebits] dd ON ddr.DirectDebitId = dd.Id
                  WHERE dd.UserId = @UserId) > 0 THEN 'Overpaid'
            WHEN (SELECT ISNULL(SUM(Amount), 0) FROM [utility].[DirectDebits] WHERE UserId = @UserId) - 
                 (SELECT ISNULL(SUM(r.Total), 0) 
                  FROM [utility].[DirectDebitReadings] ddr
                  JOIN [utility].[UtilityReadings] r ON ddr.UtilityReadingId = r.Id
                  JOIN [utility].[DirectDebits] dd ON ddr.DirectDebitId = dd.Id
                  WHERE dd.UserId = @UserId) = 0 THEN 'Exact'
            ELSE 'Underpaid'
        END AS BalanceStatus,
        @HasOverYearData AS HasOverYearData
    
    UNION ALL
    
    -- Current year totals (only if HasOverYearData = 1)
    SELECT 
        'CurrentYear' AS Period,
        (SELECT ISNULL(SUM(Amount), 0) 
         FROM [utility].[DirectDebits] 
         WHERE UserId = @UserId 
           AND PaymentDate >= @YearStart 
           AND PaymentDate <= @Today) AS TotalDirectDebits,
        (SELECT ISNULL(SUM(r.Total), 0) 
         FROM [utility].[DirectDebitReadings] ddr
         JOIN [utility].[UtilityReadings] r ON ddr.UtilityReadingId = r.Id
         JOIN [utility].[DirectDebits] dd ON ddr.DirectDebitId = dd.Id
         WHERE dd.UserId = @UserId
           AND dd.PaymentDate >= @YearStart 
           AND dd.PaymentDate <= @Today) AS TotalLinkedReadings,
        (SELECT ISNULL(SUM(Amount), 0) 
         FROM [utility].[DirectDebits] 
         WHERE UserId = @UserId 
           AND PaymentDate >= @YearStart 
           AND PaymentDate <= @Today) - 
        (SELECT ISNULL(SUM(r.Total), 0) 
         FROM [utility].[DirectDebitReadings] ddr
         JOIN [utility].[UtilityReadings] r ON ddr.UtilityReadingId = r.Id
         JOIN [utility].[DirectDebits] dd ON ddr.DirectDebitId = dd.Id
         WHERE dd.UserId = @UserId
           AND dd.PaymentDate >= @YearStart 
           AND dd.PaymentDate <= @Today) AS Balance,
        CASE 
            WHEN (SELECT ISNULL(SUM(Amount), 0) 
                  FROM [utility].[DirectDebits] 
                  WHERE UserId = @UserId 
                    AND PaymentDate >= @YearStart 
                    AND PaymentDate <= @Today) - 
                 (SELECT ISNULL(SUM(r.Total), 0) 
                  FROM [utility].[DirectDebitReadings] ddr
                  JOIN [utility].[UtilityReadings] r ON ddr.UtilityReadingId = r.Id
                  JOIN [utility].[DirectDebits] dd ON ddr.DirectDebitId = dd.Id
                  WHERE dd.UserId = @UserId
                    AND dd.PaymentDate >= @YearStart 
                    AND dd.PaymentDate <= @Today) > 0 THEN 'Overpaid'
            WHEN (SELECT ISNULL(SUM(Amount), 0) 
                  FROM [utility].[DirectDebits] 
                  WHERE UserId = @UserId 
                    AND PaymentDate >= @YearStart 
                    AND PaymentDate <= @Today) - 
                 (SELECT ISNULL(SUM(r.Total), 0) 
                  FROM [utility].[DirectDebitReadings] ddr
                  JOIN [utility].[UtilityReadings] r ON ddr.UtilityReadingId = r.Id
                  JOIN [utility].[DirectDebits] dd ON ddr.DirectDebitId = dd.Id
                  WHERE dd.UserId = @UserId
                    AND dd.PaymentDate >= @YearStart 
                    AND dd.PaymentDate <= @Today) = 0 THEN 'Exact'
            ELSE 'Underpaid'
        END AS BalanceStatus,
        @HasOverYearData AS HasOverYearData
    WHERE @HasOverYearData = 1;
END