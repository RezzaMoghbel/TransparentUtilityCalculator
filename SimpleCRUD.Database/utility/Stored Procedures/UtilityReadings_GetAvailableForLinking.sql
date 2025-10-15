CREATE PROCEDURE [utility].[UtilityReadings_GetAvailableForLinking]
    @UserId NVARCHAR(450)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Validate user
        IF NOT EXISTS (SELECT 1 FROM [dbo].[AspNetUsers] WHERE [Id] = @UserId)
            THROW 50011, 'Invalid UserId.', 1;
        
        SELECT 
            r.[Id], 
            r.[UtilityTypeId], 
            t.[Name] AS UtilityType,
            r.[ReadingStartDate], 
            r.[ReadingEndDate],
            r.[UnitsUsed], 
            r.[Total]
        FROM [utility].[UtilityReadings] r
        LEFT JOIN [utility].[UtilityType] t ON t.[Id] = r.[UtilityTypeId]
        LEFT JOIN [utility].[DirectDebitReadings] dr ON dr.[UtilityReadingId] = r.[Id]
        WHERE r.[UserId] = @UserId
          AND dr.[DirectDebitId] IS NULL  -- Not linked to any DD
        ORDER BY r.[ReadingStartDate] DESC, t.[Name] ASC;
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