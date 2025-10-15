CREATE PROCEDURE [dbo].[UtilityProviders_GetAllActive]
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        SELECT 
            [Id], 
            [Name], 
            [URL], 
            [IsActive]
        FROM [dbo].[UtilityProviders]
        WHERE [IsActive] = 1
        ORDER BY [Name] ASC;
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

