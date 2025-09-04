CREATE   PROCEDURE [utility].[rpt_MonthlyAmount_ByType]
    @UserId    NVARCHAR(450),
    @TypeName  NVARCHAR(50),      -- 'Electricity' | 'Gas' | 'Water-Hot' | 'Water-Cold'
    @From      DATE = NULL,       -- default: Jan 1 current year
    @To        DATE = NULL        -- default: today
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @today DATE = CAST(GETDATE() AS DATE);
    DECLARE @yearStart DATE = DATEFROMPARTS(YEAR(@today), 1, 1);

    SET @From = COALESCE(@From, @yearStart);
    SET @To   = COALESCE(@To,   @today);

    -- Aggregate £ totals by month for the chosen type
    IF OBJECT_ID('tempdb..#agg') IS NOT NULL DROP TABLE #agg;

    SELECT
        DATEFROMPARTS(YEAR(r.ReadingEndDate), MONTH(r.ReadingEndDate), 1) AS MonthStart,
        CONVERT(DECIMAL(19,4), SUM(r.Total))                               AS TotalAmount
    INTO #agg
    FROM [utility].[UtilityReadings] r
    JOIN [utility].[UtilityType] t ON t.Id = r.UtilityTypeId
    WHERE r.UserId = @UserId
      AND t.Name   = @TypeName
      AND r.ReadingEndDate >= @From
      AND r.ReadingEndDate <= @To
    GROUP BY DATEFROMPARTS(YEAR(r.ReadingEndDate), MONTH(r.ReadingEndDate), 1);

    -- Month calendar so empty months appear as 0.00
    ;WITH months AS (
        SELECT DATEFROMPARTS(YEAR(@From), MONTH(@From), 1) AS MonthStart
        UNION ALL
        SELECT DATEADD(MONTH, 1, MonthStart)
        FROM months
        WHERE MonthStart < DATEFROMPARTS(YEAR(@To), MONTH(@To), 1)
    )
    SELECT
        m.MonthStart,
        ISNULL(a.TotalAmount, 0) AS TotalAmount
    FROM months AS m
    LEFT JOIN #agg AS a
           ON a.MonthStart = m.MonthStart
    ORDER BY m.MonthStart
    OPTION (MAXRECURSION 366);
END