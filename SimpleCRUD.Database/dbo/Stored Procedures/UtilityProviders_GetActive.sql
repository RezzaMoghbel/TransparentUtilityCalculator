CREATE   PROCEDURE [dbo].[UtilityProviders_GetActive]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT [Id], [Name], [URL], [IsActive]
    FROM [dbo].[UtilityProviders]
    WHERE [IsActive] = 1
    ORDER BY [Name];
END