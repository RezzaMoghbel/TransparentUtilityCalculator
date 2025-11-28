CREATE PROCEDURE [support].[Announcement_Create]
    @Title           NVARCHAR(200),
    @Body            NVARCHAR(MAX),
    @CategoryId      INT = NULL,
    @ScopeId         INT,
    @BuildingId      INT = NULL,
    @SourceTicketId  INT = NULL,
    @CreatedByUserId NVARCHAR(450),
    @PublishedAt     DATETIME2 = NULL,
    @IsActive        BIT = 1
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @NewId INT;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO [support].[Announcement] (
            [Title],
            [Body],
            [CategoryId],
            [ScopeId],
            [BuildingId],
            [SourceTicketId],
            [CreatedByUserId],
            [CreatedAt],
            [PublishedAt],
            [IsActive],
            [IsArchived]
        )
        VALUES (
            @Title,
            @Body,
            @CategoryId,
            @ScopeId,
            @BuildingId,
            @SourceTicketId,
            @CreatedByUserId,
            SYSUTCDATETIME(),
            @PublishedAt,
            ISNULL(@IsActive, 1),
            0
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

CREATE PROCEDURE [support].[Announcement_Update]
    @Id             INT,
    @Title          NVARCHAR(200),
    @Body           NVARCHAR(MAX),
    @CategoryId     INT = NULL,
    @ScopeId        INT,
    @BuildingId     INT = NULL,
    @SourceTicketId INT = NULL,
    @IsActive       BIT,
    @IsArchived     BIT,
    @PublishedAt    DATETIME2 = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE [support].[Announcement]
        SET [Title]          = @Title,
            [Body]           = @Body,
            [CategoryId]     = @CategoryId,
            [ScopeId]        = @ScopeId,
            [BuildingId]     = @BuildingId,
            [SourceTicketId] = @SourceTicketId,
            [IsActive]       = @IsActive,
            [IsArchived]     = @IsArchived,
            [PublishedAt]    = @PublishedAt
        WHERE [Id] = @Id;

        IF @@ROWCOUNT = 0
            THROW 53001, 'Announcement not found.', 1;

        COMMIT TRANSACTION;

        SELECT [Id]
        FROM [support].[Announcement]
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

CREATE PROCEDURE [support].[Announcement_Archive]
    @Id INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE [support].[Announcement]
        SET [IsActive]   = 0,
            [IsArchived] = 1
        WHERE [Id] = @Id;

        IF @@ROWCOUNT = 0
            THROW 53002, 'Announcement not found.', 1;

        COMMIT TRANSACTION;

        SELECT @Id AS ArchivedId;
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

CREATE PROCEDURE [support].[Announcement_GetById]
    @Id INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        SELECT *
        FROM [support].[Announcement]
        WHERE [Id] = @Id;

        IF @@ROWCOUNT = 0
            THROW 53003, 'Announcement not found.', 1;
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

CREATE PROCEDURE [support].[Announcement_GetForBuilding]
    @BuildingId      INT = NULL,
    @ScopeCode       NVARCHAR(50) = NULL,
    @CategoryCode    NVARCHAR(50) = NULL,
    @IsActive        BIT = 1,
    @IncludeArchived BIT = 0,
    @PageNumber      INT = 1,
    @PageSize        INT = 20
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Page INT = CASE WHEN ISNULL(@PageNumber, 1) < 1 THEN 1 ELSE @PageNumber END;
    DECLARE @Size INT = CASE WHEN ISNULL(@PageSize, 20) < 1 THEN 20 WHEN @PageSize > 200 THEN 200 ELSE @PageSize END;

    BEGIN TRY
        ;WITH AnnouncementSource AS
        (
            SELECT
                a.[Id],
                a.[Title],
                a.[Body],
                a.[CategoryId],
                a.[ScopeId],
                a.[BuildingId],
                a.[SourceTicketId],
                a.[CreatedByUserId],
                a.[CreatedAt],
                a.[PublishedAt],
                a.[IsActive],
                a.[IsArchived],
                ROW_NUMBER() OVER (ORDER BY a.[CreatedAt] DESC) AS RowNum,
                COUNT(1) OVER() AS TotalCount
            FROM [support].[Announcement] a
            INNER JOIN [support].[AnnouncementScope] sc ON sc.[Id] = a.[ScopeId]
            LEFT JOIN [support].[IssueCategory] ic ON ic.[Id] = a.[CategoryId]
            WHERE (@IncludeArchived = 1 OR a.[IsArchived] = 0)
              AND (@IsActive IS NULL OR a.[IsActive] = @IsActive)
              AND (@ScopeCode IS NULL OR sc.[Code] = @ScopeCode)
              AND (
                    sc.[Code] = 'GLOBAL'
                 OR (@BuildingId IS NULL AND sc.[Code] = 'BUILDING')
                 OR (sc.[Code] = 'BUILDING' AND a.[BuildingId] = @BuildingId)
              )
              AND (@CategoryCode IS NULL OR ic.[Code] = @CategoryCode)
        )
        SELECT
            [Id],
            [Title],
            [Body],
            [CategoryId],
            [ScopeId],
            [BuildingId],
            [SourceTicketId],
            [CreatedByUserId],
            [CreatedAt],
            [PublishedAt],
            [IsActive],
            [IsArchived],
            TotalCount
        FROM AnnouncementSource
        WHERE RowNum BETWEEN ((@Page - 1) * @Size) + 1 AND (@Page * @Size)
        ORDER BY RowNum;
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

CREATE PROCEDURE [support].[Announcement_GetGlobal]
    @CategoryCode    NVARCHAR(50) = NULL,
    @IsActive        BIT = 1,
    @IncludeArchived BIT = 0,
    @PageNumber      INT = 1,
    @PageSize        INT = 20
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Page INT = CASE WHEN ISNULL(@PageNumber, 1) < 1 THEN 1 ELSE @PageNumber END;
    DECLARE @Size INT = CASE WHEN ISNULL(@PageSize, 20) < 1 THEN 20 WHEN @PageSize > 200 THEN 200 ELSE @PageSize END;

    BEGIN TRY
        ;WITH AnnouncementSource AS
        (
            SELECT
                a.[Id],
                a.[Title],
                a.[Body],
                a.[CategoryId],
                a.[ScopeId],
                a.[BuildingId],
                a.[SourceTicketId],
                a.[CreatedByUserId],
                a.[CreatedAt],
                a.[PublishedAt],
                a.[IsActive],
                a.[IsArchived],
                ROW_NUMBER() OVER (ORDER BY a.[CreatedAt] DESC) AS RowNum,
                COUNT(1) OVER() AS TotalCount
            FROM [support].[Announcement] a
            INNER JOIN [support].[AnnouncementScope] sc ON sc.[Id] = a.[ScopeId]
            LEFT JOIN [support].[IssueCategory] ic ON ic.[Id] = a.[CategoryId]
            WHERE sc.[Code] = 'GLOBAL'
              AND (@IncludeArchived = 1 OR a.[IsArchived] = 0)
              AND (@IsActive IS NULL OR a.[IsActive] = @IsActive)
              AND (@CategoryCode IS NULL OR ic.[Code] = @CategoryCode)
        )
        SELECT
            [Id],
            [Title],
            [Body],
            [CategoryId],
            [ScopeId],
            [BuildingId],
            [SourceTicketId],
            [CreatedByUserId],
            [CreatedAt],
            [PublishedAt],
            [IsActive],
            [IsArchived],
            TotalCount
        FROM AnnouncementSource
        WHERE RowNum BETWEEN ((@Page - 1) * @Size) + 1 AND (@Page * @Size)
        ORDER BY RowNum;
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

