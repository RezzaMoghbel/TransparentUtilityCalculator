CREATE PROCEDURE [utility].[DirectDebitReadings_GetByDirectDebit]
    @DirectDebitId INT,
    @UserId        NVARCHAR(450)   -- required: the caller's AspNetUsers.Id
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Validate user
        IF NOT EXISTS (SELECT 1 FROM [dbo].[AspNetUsers] WHERE [Id] = @UserId)
            THROW 50011, 'Invalid UserId.', 1;

        -- Direct debit must exist and belong to user
        IF NOT EXISTS (SELECT 1 FROM [utility].[DirectDebits] WHERE [Id] = @DirectDebitId AND [UserId] = @UserId)
            THROW 50018, 'DirectDebit not found or does not belong to user.', 1;

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
        FROM [utility].[DirectDebitReadings] dr
        INNER JOIN [utility].[UtilityReadings] r ON r.[Id] = dr.[UtilityReadingId]
        LEFT JOIN [utility].[UtilityType] t ON t.[Id] = r.[UtilityTypeId]
        WHERE dr.[DirectDebitId] = @DirectDebitId
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