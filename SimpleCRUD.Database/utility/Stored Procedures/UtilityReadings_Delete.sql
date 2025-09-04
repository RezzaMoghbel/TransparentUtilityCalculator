
CREATE PROCEDURE [utility].[UtilityReadings_Delete]
    @Id     INT,
    @UserId NVARCHAR(450) = NULL   -- optional: pass to enforce ownership
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Result INT = -1;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF @UserId IS NULL
        BEGIN
            DELETE FROM [utility].[UtilityReadings]
            WHERE [Id] = @Id;
        END
        ELSE
        BEGIN
            DELETE FROM [utility].[UtilityReadings]
            WHERE [Id] = @Id AND [UserId] = @UserId;
        END

        IF @@ROWCOUNT > 0
            SET @Result = @Id;

        COMMIT TRANSACTION;

        SELECT @Result AS DeletedId;   -- -1 = not found / not owned
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