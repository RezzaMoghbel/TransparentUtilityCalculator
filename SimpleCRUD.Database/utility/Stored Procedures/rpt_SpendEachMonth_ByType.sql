CREATE   PROCEDURE [utility].[rpt_SpendEachMonth_ByType]
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

    ;WITH base AS (
        SELECT
            MonthStart   = DATEFROMPARTS(YEAR(r.ReadingEndDate), MONTH(r.ReadingEndDate), 1),
            TypeName     = t.Name,
            TotalAmount  = CAST(r.Total AS DECIMAL(19,4))
        FROM [utility].[UtilityReadings] r
        JOIN [utility].[UtilityType]     t ON t.Id = r.UtilityTypeId
        WHERE r.UserId = @UserId
          AND r.ReadingEndDate >= @From
          AND r.ReadingEndDate <= @To
    )
    -- (1) Monthly grid: one row per month, split by utility type
    SELECT
        MonthStart,
        SUM(CASE WHEN TypeName = N'Electricity' THEN TotalAmount ELSE 0 END) AS [Electricity],
        SUM(CASE WHEN TypeName = N'Water-Hot'   THEN TotalAmount ELSE 0 END) AS [Water-Hot],
        SUM(CASE WHEN TypeName = N'Water-Cold'  THEN TotalAmount ELSE 0 END) AS [Water-Cold],
        SUM(CASE WHEN TypeName = N'Gas'         THEN TotalAmount ELSE 0 END) AS [Gas],
        SUM(TotalAmount)                                                            AS [PeriodTotal]
    FROM base
    GROUP BY MonthStart
    ORDER BY MonthStart;

    ---- (2) Overall totals for the whole period
    --SELECT
    --    SUM(CASE WHEN TypeName = N'Electricity' THEN TotalAmount ELSE 0 END) AS [Electricity],
    --    SUM(CASE WHEN TypeName = N'Water-Hot'   THEN TotalAmount ELSE 0 END) AS [Water-Hot],
    --    SUM(CASE WHEN TypeName = N'Water-Cold'  THEN TotalAmount ELSE 0 END) AS [Water-Cold],
    --    SUM(CASE WHEN TypeName = N'Gas'         THEN TotalAmount ELSE 0 END) AS [Gas],
    --    SUM(TotalAmount)                                                    AS [GrandTotal]
    --FROM base;
END