CREATE   PROCEDURE [utility].[rpt_SpendByMonth_ByType]
    @UserId NVARCHAR(450),
    @From   DATE = NULL,   -- default: Jan 1 current year
    @To     DATE = NULL    -- default: today
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @today DATE = CAST(GETDATE() AS DATE);
    DECLARE @yearStart DATE = DATEFROMPARTS(YEAR(@today), 1, 1);

    SET @From = COALESCE(@From, @yearStart);
    SET @To   = COALESCE(@To,   @today);

    -- Materialize once so we can query it multiple times
    SELECT
        MonthStart  = DATEFROMPARTS(YEAR(r.ReadingEndDate), MONTH(r.ReadingEndDate), 1),
        TypeName    = t.Name,
        TotalAmount = CAST(r.Total AS DECIMAL(19,4))
    INTO #base
    FROM [utility].[UtilityReadings] r
    JOIN [utility].[UtilityType]     t ON t.Id = r.UtilityTypeId
    WHERE r.UserId = @UserId
      AND r.ReadingEndDate >= @From
      AND r.ReadingEndDate <= @To;

    -- (1) Monthly grid
    SELECT
        b.MonthStart,
        SUM(CASE WHEN b.TypeName = N'Electricity' THEN b.TotalAmount ELSE 0 END) AS [Electricity],
        SUM(CASE WHEN b.TypeName = N'Water-Hot'   THEN b.TotalAmount ELSE 0 END) AS [Water-Hot],
        SUM(CASE WHEN b.TypeName = N'Water-Cold'  THEN b.TotalAmount ELSE 0 END) AS [Water-Cold],
        SUM(CASE WHEN b.TypeName = N'Gas'         THEN b.TotalAmount ELSE 0 END) AS [Gas],
        SUM(b.TotalAmount) AS [PeriodTotal]
    FROM #base AS b
    GROUP BY b.MonthStart
    ORDER BY b.MonthStart;

    -- (2) Totals for whole period
    SELECT
        SUM(CASE WHEN b.TypeName = N'Electricity' THEN b.TotalAmount ELSE 0 END) AS [Electricity],
        SUM(CASE WHEN b.TypeName = N'Water-Hot'   THEN b.TotalAmount ELSE 0 END) AS [Water-Hot],
        SUM(CASE WHEN b.TypeName = N'Water-Cold'  THEN b.TotalAmount ELSE 0 END) AS [Water-Cold],
        SUM(CASE WHEN b.TypeName = N'Gas'         THEN b.TotalAmount ELSE 0 END) AS [Gas],
        SUM(b.TotalAmount) AS [GrandTotal]
    FROM #base AS b;
END