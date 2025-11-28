CREATE PROCEDURE [support].[Ticket_Create]
    @Title            NVARCHAR(200),
    @Description      NVARCHAR(MAX),
    @StatusId         INT,
    @PriorityId       INT,
    @CategoryId       INT,
    @CreatedByUserId  NVARCHAR(450),
    @BuildingId       INT,
    @AssignedToUserId NVARCHAR(450) = NULL,
    @RelatedUserId    NVARCHAR(450) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @NewId INT;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO [support].[Ticket] (
            [Title],
            [Description],
            [StatusId],
            [PriorityId],
            [CategoryId],
            [CreatedByUserId],
            [AssignedToUserId],
            [RelatedUserId],
            [BuildingId]
        )
        VALUES (
            @Title,
            @Description,
            @StatusId,
            @PriorityId,
            @CategoryId,
            @CreatedByUserId,
            @AssignedToUserId,
            @RelatedUserId,
            @BuildingId
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

CREATE PROCEDURE [support].[Ticket_Update]
    @Id               INT,
    @Title            NVARCHAR(200),
    @Description      NVARCHAR(MAX),
    @StatusId         INT,
    @PriorityId       INT,
    @CategoryId       INT,
    @AssignedToUserId NVARCHAR(450) = NULL,
    @RelatedUserId    NVARCHAR(450) = NULL,
    @BuildingId       INT,
    @AnnouncementId   INT = NULL,
    @ResolvedAt       DATETIME2 = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE [support].[Ticket]
        SET [Title]            = @Title,
            [Description]      = @Description,
            [StatusId]         = @StatusId,
            [PriorityId]       = @PriorityId,
            [CategoryId]       = @CategoryId,
            [AssignedToUserId] = @AssignedToUserId,
            [RelatedUserId]    = @RelatedUserId,
            [BuildingId]       = @BuildingId,
            [AnnouncementId]   = @AnnouncementId,
            [ResolvedAt]       = @ResolvedAt,
            [UpdatedAt]        = SYSUTCDATETIME()
        WHERE [Id] = @Id;

        IF @@ROWCOUNT = 0
            THROW 52001, 'Ticket not found.', 1;

        COMMIT TRANSACTION;

        SELECT [Id]
        FROM [support].[Ticket]
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

CREATE PROCEDURE [support].[Ticket_Archive]
    @Id INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE [support].[Ticket]
        SET [IsArchived] = 1,
            [UpdatedAt]  = SYSUTCDATETIME()
        WHERE [Id] = @Id;

        IF @@ROWCOUNT = 0
            THROW 52002, 'Ticket not found.', 1;

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

CREATE PROCEDURE [support].[Ticket_GetById]
    @Id INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        SELECT
            [Id],
            [Title],
            [Description],
            [StatusId],
            [PriorityId],
            [CategoryId],
            [CreatedByUserId],
            [AssignedToUserId],
            [RelatedUserId],
            [BuildingId],
            [AnnouncementId],
            [CreatedAt],
            [UpdatedAt],
            [ResolvedAt],
            [IsArchived]
        FROM [support].[Ticket]
        WHERE [Id] = @Id;

        IF @@ROWCOUNT = 0
            THROW 52003, 'Ticket not found.', 1;
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

CREATE PROCEDURE [support].[Ticket_GetForUser]
    @UserId        NVARCHAR(450),
    @StatusCode    NVARCHAR(50) = NULL,
    @PriorityCode  NVARCHAR(50) = NULL,
    @Search        NVARCHAR(200) = NULL,
    @PageNumber    INT = 1,
    @PageSize      INT = 20
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Page INT = CASE WHEN ISNULL(@PageNumber, 1) < 1 THEN 1 ELSE @PageNumber END;
    DECLARE @Size INT = CASE WHEN ISNULL(@PageSize, 20) < 1 THEN 20 WHEN @PageSize > 200 THEN 200 ELSE @PageSize END;
    DECLARE @SearchTerm NVARCHAR(200) = NULLIF(LTRIM(RTRIM(@Search)), '');

    BEGIN TRY
        ;WITH TicketSource AS
        (
            SELECT
                t.[Id],
                t.[Title],
                t.[Description],
                t.[StatusId],
                t.[PriorityId],
                t.[CategoryId],
                t.[CreatedByUserId],
                t.[AssignedToUserId],
                t.[RelatedUserId],
                t.[BuildingId],
                t.[AnnouncementId],
                t.[CreatedAt],
                t.[UpdatedAt],
                t.[ResolvedAt],
                t.[IsArchived],
                ROW_NUMBER() OVER (ORDER BY t.[CreatedAt] DESC) AS RowNum,
                COUNT(1) OVER() AS TotalCount
            FROM [support].[Ticket] t
            INNER JOIN [support].[TicketStatus] ts ON ts.[Id] = t.[StatusId]
            INNER JOIN [support].[TicketPriority] tp ON tp.[Id] = t.[PriorityId]
            WHERE t.[IsArchived] = 0
              AND (t.[CreatedByUserId] = @UserId OR t.[RelatedUserId] = @UserId)
              AND (@StatusCode IS NULL OR ts.[Code] = @StatusCode)
              AND (@PriorityCode IS NULL OR tp.[Code] = @PriorityCode)
              AND (
                    @SearchTerm IS NULL
                 OR t.[Title]       LIKE '%' + @SearchTerm + '%'
                 OR t.[Description] LIKE '%' + @SearchTerm + '%'
              )
        )
        SELECT
            [Id],
            [Title],
            [Description],
            [StatusId],
            [PriorityId],
            [CategoryId],
            [CreatedByUserId],
            [AssignedToUserId],
            [RelatedUserId],
            [BuildingId],
            [AnnouncementId],
            [CreatedAt],
            [UpdatedAt],
            [ResolvedAt],
            [IsArchived],
            TotalCount
        FROM TicketSource
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

CREATE PROCEDURE [support].[Ticket_GetForBuilding]
    @BuildingId        INT = NULL,
    @IncludeArchived   BIT = 0,
    @StatusCode        NVARCHAR(50) = NULL,
    @PriorityCode      NVARCHAR(50) = NULL,
    @AssignedToUserId  NVARCHAR(450) = NULL,
    @Search            NVARCHAR(200) = NULL,
    @PageNumber        INT = 1,
    @PageSize          INT = 20
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Page INT = CASE WHEN ISNULL(@PageNumber, 1) < 1 THEN 1 ELSE @PageNumber END;
    DECLARE @Size INT = CASE WHEN ISNULL(@PageSize, 20) < 1 THEN 20 WHEN @PageSize > 200 THEN 200 ELSE @PageSize END;
    DECLARE @SearchTerm NVARCHAR(200) = NULLIF(LTRIM(RTRIM(@Search)), '');

    BEGIN TRY
        ;WITH TicketSource AS
        (
            SELECT
                t.[Id],
                t.[Title],
                t.[Description],
                t.[StatusId],
                t.[PriorityId],
                t.[CategoryId],
                t.[CreatedByUserId],
                t.[AssignedToUserId],
                t.[RelatedUserId],
                t.[BuildingId],
                t.[AnnouncementId],
                t.[CreatedAt],
                t.[UpdatedAt],
                t.[ResolvedAt],
                t.[IsArchived],
                ROW_NUMBER() OVER (ORDER BY t.[CreatedAt] DESC) AS RowNum,
                COUNT(1) OVER() AS TotalCount
            FROM [support].[Ticket] t
            INNER JOIN [support].[TicketStatus] ts ON ts.[Id] = t.[StatusId]
            INNER JOIN [support].[TicketPriority] tp ON tp.[Id] = t.[PriorityId]
            WHERE (@BuildingId IS NULL OR t.[BuildingId] = @BuildingId)
              AND (@IncludeArchived = 1 OR t.[IsArchived] = 0)
              AND (@StatusCode IS NULL OR ts.[Code] = @StatusCode)
              AND (@PriorityCode IS NULL OR tp.[Code] = @PriorityCode)
              AND (
                    @AssignedToUserId IS NULL
                 OR (@AssignedToUserId = '' AND t.[AssignedToUserId] IS NULL)
                 OR t.[AssignedToUserId] = @AssignedToUserId
              )
              AND (
                    @SearchTerm IS NULL
                 OR t.[Title]       LIKE '%' + @SearchTerm + '%'
                 OR t.[Description] LIKE '%' + @SearchTerm + '%'
              )
        )
        SELECT
            [Id],
            [Title],
            [Description],
            [StatusId],
            [PriorityId],
            [CategoryId],
            [CreatedByUserId],
            [AssignedToUserId],
            [RelatedUserId],
            [BuildingId],
            [AnnouncementId],
            [CreatedAt],
            [UpdatedAt],
            [ResolvedAt],
            [IsArchived],
            TotalCount
        FROM TicketSource
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

