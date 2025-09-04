
CREATE   PROCEDURE [utility].[UtilityReadings_ListByDate]
    @UserId    NVARCHAR(450),     -- required: the caller's AspNetUsers.Id
    @FromDate  DATE = NULL,       -- optional: inclusive lower bound
    @ToDate    DATE = NULL        -- optional: inclusive upper bound
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Validate user
        IF NOT EXISTS (SELECT 1 FROM [dbo].[AspNetUsers] WHERE [Id] = @UserId)
            THROW 50002, 'Invalid UserId.', 1;

        -- Normalize dates (open-ended if NULL)
        DECLARE @From DATE = ISNULL(@FromDate, '19000101');
        DECLARE @To   DATE = ISNULL(@ToDate,   '99991231');

        IF @To < @From
            THROW 50003, 'ToDate must be >= FromDate.', 1;

        /* Overlap predicate:
           [ReadingEndDate] >= @From AND [ReadingStartDate] <= @To
           (returns any row that intersects the window)
        */
        SELECT
            r.[Id],
            r.[UtilityTypeId],
			t.[Name] AS UtilityType,
            r.[UserId],
            r.[UnitRate],
            r.[StandingChargePerDay],
            r.[VatRateFactor],
            r.[ReadingStartDate],
            r.[ReadingEndDate],
            r.[MeterStart],
            r.[MeterEnd],
            r.[UnitsUsed],
            r.[BillDays],
            r.[TotalUsage],
            r.[TotalStandingCharge],
            r.[Total],
            r.[CreatedAt],
            r.[ProviderDebitAmount],
            r.[ProviderDebitDate],
            r.[Notes]
        FROM [utility].[UtilityReadings] AS r
		LEFT JOIN [utility].UtilityType AS t on t.Id = r.UtilityTypeId
        WHERE r.[UserId] = @UserId
          AND r.[ReadingEndDate]   >= @From
          AND r.[ReadingStartDate] <= @To
        ORDER BY r.[ReadingStartDate] DESC, r.[Id] DESC;
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