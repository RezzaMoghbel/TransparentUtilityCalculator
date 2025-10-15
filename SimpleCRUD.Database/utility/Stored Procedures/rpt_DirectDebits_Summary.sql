CREATE PROCEDURE [utility].[rpt_DirectDebits_Summary]
    @UserId    NVARCHAR(450),
    @From      DATE = NULL,       -- default: Jan 1 current year
    @To        DATE = NULL        -- default: today
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Validate user
        IF NOT EXISTS (SELECT 1 FROM [dbo].[AspNetUsers] WHERE [Id] = @UserId)
            THROW 50011, 'Invalid UserId.', 1;

        DECLARE @today DATE = CAST(GETDATE() AS DATE);
        DECLARE @yearStart DATE = DATEFROMPARTS(YEAR(@today), 1, 1);

        SET @From = COALESCE(@From, @yearStart);
        SET @To   = COALESCE(@To,   @today);

        -- Summary of Direct Debits vs Actual Usage Costs
        SELECT
            DATEFROMPARTS(YEAR(d.[PaymentDate]), MONTH(d.[PaymentDate]), 1) AS MonthStart,
            COUNT(d.[Id]) AS DirectDebitCount,
            SUM(d.[Amount]) AS TotalDirectDebits,
            SUM(CASE WHEN d.[PaymentStatus] = 'Paid' THEN d.[Amount] ELSE 0 END) AS PaidDirectDebits,
            SUM(CASE WHEN d.[PaymentStatus] = 'Pending' THEN d.[Amount] ELSE 0 END) AS PendingDirectDebits,
            SUM(CASE WHEN d.[PaymentStatus] = 'Failed' THEN d.[Amount] ELSE 0 END) AS FailedDirectDebits,
            -- Calculate actual usage costs for linked readings
            SUM(CASE 
                WHEN dr.[DirectDebitId] IS NOT NULL THEN r.[Total] 
                ELSE 0 
            END) AS LinkedUsageCosts,
            -- Calculate unlinked usage costs
            SUM(CASE 
                WHEN dr.[DirectDebitId] IS NULL THEN r.[Total] 
                ELSE 0 
            END) AS UnlinkedUsageCosts
        FROM [utility].[DirectDebits] d
        LEFT JOIN [utility].[DirectDebitReadings] dr ON dr.[DirectDebitId] = d.[Id]
        LEFT JOIN [utility].[UtilityReadings] r ON r.[Id] = dr.[UtilityReadingId]
        WHERE d.[UserId] = @UserId
          AND d.[PaymentDate] >= @From
          AND d.[PaymentDate] <= @To
        GROUP BY DATEFROMPARTS(YEAR(d.[PaymentDate]), MONTH(d.[PaymentDate]), 1)
        ORDER BY MonthStart DESC;
    END TRY
    BEGIN CATCH
        SELECT
            ERROR_NUMBER()    AS ErrorNumber,
            ERROR_SEVERITY()  AS ErrorSeverity,
            ERROR_STATE()     AS ErrorState,
            ERROR_PROCEDURE() AS ErrorProcedure,
            ERROR_LINE()      AS ErrorLine,
            ERROR_MESSAGE()   AS ErrorMessage;
    END CATCH
END