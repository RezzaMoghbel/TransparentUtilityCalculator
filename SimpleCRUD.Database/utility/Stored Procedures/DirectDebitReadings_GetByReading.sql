CREATE PROCEDURE [utility].[DirectDebitReadings_GetByReading]
    @UtilityReadingId INT,
    @UserId           NVARCHAR(450)   -- required: the caller's AspNetUsers.Id
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Validate user
        IF NOT EXISTS (SELECT 1 FROM [dbo].[AspNetUsers] WHERE [Id] = @UserId)
            THROW 50011, 'Invalid UserId.', 1;

        -- Utility reading must exist and belong to user
        IF NOT EXISTS (SELECT 1 FROM [utility].[UtilityReadings] WHERE [Id] = @UtilityReadingId AND [UserId] = @UserId)
            THROW 50019, 'UtilityReading not found or does not belong to user.', 1;

        SELECT
            d.[Id],
            d.[UserId],
            d.[Amount],
            d.[PaymentDate],
            d.[UtilityProviderId],
            up.[Name] AS [ProviderName],
            d.[PaymentStatus],
            d.[Notes],
            d.[CreatedAt]
        FROM [utility].[DirectDebitReadings] dr
        INNER JOIN [utility].[DirectDebits] d ON d.[Id] = dr.[DirectDebitId]
        LEFT JOIN [dbo].[UtilityProviders] up ON up.[Id] = d.[UtilityProviderId]
        WHERE dr.[UtilityReadingId] = @UtilityReadingId
        ORDER BY d.[PaymentDate] DESC, d.[Id] DESC;
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