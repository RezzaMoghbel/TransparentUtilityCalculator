CREATE PROCEDURE [support].[TicketMessage_Create]
    @TicketId        INT,
    @Body            NVARCHAR(MAX),
    @CreatedByUserId NVARCHAR(450),
    @IsInternal      BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @NewId INT;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO [support].[TicketMessage] (
            [TicketId],
            [Body],
            [CreatedByUserId],
            [IsInternal]
        )
        VALUES (
            @TicketId,
            @Body,
            @CreatedByUserId,
            ISNULL(@IsInternal, 0)
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

CREATE PROCEDURE [support].[TicketMessage_GetByTicketId]
    @TicketId        INT,
    @IncludeInternal BIT = 0
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        SELECT [Id],
               [TicketId],
               [Body],
               [CreatedByUserId],
               [CreatedAt],
               [IsInternal]
        FROM [support].[TicketMessage]
        WHERE [TicketId] = @TicketId
          AND (@IncludeInternal = 1 OR [IsInternal] = 0)
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

