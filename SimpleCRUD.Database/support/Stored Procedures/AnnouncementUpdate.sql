CREATE PROCEDURE [support].[AnnouncementUpdate_Create]
    @AnnouncementId  INT,
    @Body            NVARCHAR(MAX),
    @CreatedByUserId NVARCHAR(450)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @NewId INT;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO [support].[AnnouncementUpdate] (
            [AnnouncementId],
            [Body],
            [CreatedByUserId],
            [CreatedAt]
        )
        VALUES (
            @AnnouncementId,
            @Body,
            @CreatedByUserId,
            SYSUTCDATETIME()
        );

        SET @NewId = SCOPE_IDENTITY();

        COMMIT TRANSACTION;

        SELECT CAST(@NewId AS INT) AS Id;
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
GO

CREATE PROCEDURE [support].[AnnouncementUpdate_GetByAnnouncementId]
    @AnnouncementId INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        SELECT [Id],
               [AnnouncementId],
               [Body],
               [CreatedByUserId],
               [CreatedAt]
        FROM [support].[AnnouncementUpdate]
        WHERE [AnnouncementId] = @AnnouncementId
        ORDER BY [CreatedAt] ASC;
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
GO

