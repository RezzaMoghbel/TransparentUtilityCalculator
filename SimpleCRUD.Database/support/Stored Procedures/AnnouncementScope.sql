CREATE PROCEDURE [support].[AnnouncementScope_Create]
    @Code NVARCHAR(50),
    @Name NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @NewId INT;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO [support].[AnnouncementScope] ([Code], [Name])
        VALUES (@Code, @Name);

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

CREATE PROCEDURE [support].[AnnouncementScope_Update]
    @Id   INT,
    @Code NVARCHAR(50),
    @Name NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE [support].[AnnouncementScope]
        SET [Code] = @Code,
            [Name] = @Name
        WHERE [Id] = @Id;

        IF @@ROWCOUNT = 0
            THROW 51031, 'AnnouncementScope not found.', 1;

        COMMIT TRANSACTION;

        SELECT [Id], [Code], [Name]
        FROM [support].[AnnouncementScope]
        WHERE [Id] = @Id;
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

CREATE PROCEDURE [support].[AnnouncementScope_Delete]
    @Id INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Result INT = -1;

    BEGIN TRY
        BEGIN TRANSACTION;

        DELETE FROM [support].[AnnouncementScope]
        WHERE [Id] = @Id;

        IF @@ROWCOUNT > 0
            SET @Result = @Id;

        COMMIT TRANSACTION;

        SELECT @Result AS DeletedId;
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

CREATE PROCEDURE [support].[AnnouncementScope_GetById]
    @Id INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        SELECT [Id], [Code], [Name]
        FROM [support].[AnnouncementScope]
        WHERE [Id] = @Id;

        IF @@ROWCOUNT = 0
            THROW 51032, 'AnnouncementScope not found.', 1;
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

CREATE PROCEDURE [support].[AnnouncementScope_GetAll]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT [Id], [Code], [Name]
    FROM [support].[AnnouncementScope]
    ORDER BY [Code];
END
GO

