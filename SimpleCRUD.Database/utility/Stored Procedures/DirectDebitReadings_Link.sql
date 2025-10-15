CREATE PROCEDURE [utility].[DirectDebitReadings_Link]
    @DirectDebitId    INT,
    @UtilityReadingId INT,
    @UserId           NVARCHAR(450)   -- required: the caller's AspNetUsers.Id
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

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

        -- Check if link already exists
        IF EXISTS (SELECT 1 FROM [utility].[DirectDebitReadings] WHERE [DirectDebitId] = @DirectDebitId AND [UtilityReadingId] = @UtilityReadingId)
            THROW 50020, 'Link already exists between this DirectDebit and UtilityReading.', 1;

        -- BUSINESS RULE: Check if reading already linked to ANY direct debit
        IF EXISTS (SELECT 1 FROM [utility].[DirectDebitReadings] WHERE [UtilityReadingId] = @UtilityReadingId)
            THROW 50021, 'This reading is already linked to another direct debit.', 1;

        -- BUSINESS RULE: Check if DD already has a reading of the same utility type
        DECLARE @ReadingUtilityTypeId INT = (SELECT [UtilityTypeId] FROM [utility].[UtilityReadings] WHERE [Id] = @UtilityReadingId);
        
        IF EXISTS (
            SELECT 1 FROM [utility].[DirectDebitReadings] dr
            INNER JOIN [utility].[UtilityReadings] r ON r.[Id] = dr.[UtilityReadingId]
            WHERE dr.[DirectDebitId] = @DirectDebitId
              AND r.[UtilityTypeId] = @ReadingUtilityTypeId
        )
            THROW 50022, 'This direct debit already has a reading of this utility type.', 1;

        /* ---------- Insert Link ---------- */

        INSERT INTO [utility].[DirectDebitReadings] (
            [DirectDebitId],
            [UtilityReadingId]
        )
        VALUES (
            @DirectDebitId,
            @UtilityReadingId
        );

        COMMIT TRANSACTION;

        /* ---------- Return success ---------- */
        SELECT @DirectDebitId AS DirectDebitId, @UtilityReadingId AS UtilityReadingId, 'Linked' AS Status;
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