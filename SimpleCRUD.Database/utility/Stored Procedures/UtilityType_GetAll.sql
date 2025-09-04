
CREATE   PROCEDURE [utility].[UtilityType_GetAll]
    @OnlyActive BIT = NULL   -- NULL = all, 1 = only active, 0 = only inactive
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        SELECT
            [Id],
            [Name],
            [Unit],
            [CreatedAt],
            [Notes],
            [IsActive]
        FROM [utility].[UtilityType]
        WHERE (@OnlyActive IS NULL)
           OR (@OnlyActive = 1 AND [IsActive] = 1)
           OR (@OnlyActive = 0 AND [IsActive] = 0)
        ORDER BY [Name] ASC, [Unit] ASC, [Id] ASC;
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