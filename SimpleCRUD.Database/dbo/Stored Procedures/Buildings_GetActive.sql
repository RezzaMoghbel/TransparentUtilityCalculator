CREATE   PROCEDURE [dbo].[Buildings_GetActive]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT [Id], [Name], [IsActive]
    FROM [dbo].[Buildings]
    WHERE [IsActive] = 1
    ORDER BY [Name];
END