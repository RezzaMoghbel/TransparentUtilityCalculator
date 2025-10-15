CREATE PROCEDURE [utility].[DirectDebitReadings_Unlink]
    @DirectDebitId    INT,
    @UtilityReadingId INT,
    @UserId           NVARCHAR(450)   -- required: the caller's AspNetUsers.Id
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Result INT = -1;

    BEGIN TRY
        BEGIN TRANSACTION;

        /* ---------- Validation ---------- */

        -- Validate user
        IF NOT EXISTS (SELECT 1 FROM [dbo].[AspNetUsers] WHERE [Id] = @UserId)
            THROW 50011, 'Invalid UserId.', 1;

        -- Direct debit must exist and belong to user
        IF NOT EXISTS (SELECT 1 FROM [utility].[DirectDebits] WHERE [Id] = @DirectDebitId AND [UserId] = @UserId)
            THROW 50018, 'DirectDebit not found or does not belong to user.', 1;

        -- Utility reading must exist and belong to user
        IF NOT EXISTS (SELECT 1 FROM [utility].[UtilityReadings] WHERE [Id] = @UtilityReadingId AND [UserId] = @UserId)
            THROW 50019, 'UtilityReading not found or does not belong to user.', 1;

        /* ---------- Remove Link ---------- */

        DELETE FROM [utility].[DirectDebitReadings]
        WHERE [DirectDebitId] = @DirectDebitId 
          AND [UtilityReadingId] = @UtilityReadingId;

        IF @@ROWCOUNT > 0
            SET @Result = @UtilityReadingId;

        COMMIT TRANSACTION;

        SELECT @Result AS UnlinkedUtilityReadingId;   -- -1 = link not found
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;

        SELECT
            ERROR_NUMBER()    AS ErrorNumber,
            ERROR_SEVERITY()  AS ErrorSeverity,
            ERROR_STATE()     AS ErrorState,
            ERROR_PROCEDURE() AS ErrorProcedure,
            ERROR_LINE()      AS ErrorLine,
            ERROR_MESSAGE()   AS ErrorMessage;
    END CATCH
END