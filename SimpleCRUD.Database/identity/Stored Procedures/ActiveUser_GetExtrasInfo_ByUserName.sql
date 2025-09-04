
CREATE PROCEDURE [identity].[ActiveUser_GetExtrasInfo_ByUserName]
    @UserName    NVARCHAR(256)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @UserID NVARCHAR(450)

    BEGIN TRY
        -- Validate user
        IF NOT EXISTS (SELECT 1 FROM [dbo].[AspNetUsers] WHERE [UserName] = @UserName AND Deleted = 0 AND AccessAllowed = 1)
            THROW 50001, 'Invalid UserName.', 1;


        SELECT 
			A.Id, 
			A.PropertyName AS FlatNumber,
			B.[Name] AS BuildingName,
			C.[Name] AS ProviderName
        FROM [dbo].[AspNetUsers] AS A
		LEFT JOIN Buildings AS B ON B.Id = A.BuildingId
		LEFT JOIN UtilityProviders AS C ON  C.Id = A.ProviderId
        WHERE UserName = @UserName

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