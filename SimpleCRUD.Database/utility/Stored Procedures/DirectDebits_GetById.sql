CREATE PROCEDURE [utility].[DirectDebits_GetById]
    @Id     INT,
    @UserId NVARCHAR(450)   -- the logged-in user's Id from AspNetUsers
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Validate user exists
        IF NOT EXISTS (SELECT 1 FROM [dbo].[AspNetUsers] WHERE [Id] = @UserId)
            THROW 50011, 'Invalid UserId.', 1;

        -- Try to fetch the row for this user
        SELECT
            d.[Id],
            d.[UserId],
            d.[Amount],
            d.[PaymentDate],
            d.[UtilityProviderId],
            up.[Name] AS ProviderName,
            d.[PaymentStatus],
            d.[Notes],
            d.[CreatedAt]
        FROM [utility].[DirectDebits] d
        LEFT JOIN [dbo].[UtilityProviders] up ON up.[Id] = d.[UtilityProviderId]
        WHERE d.[Id] = @Id
          AND d.[UserId] = @UserId;

        IF @@ROWCOUNT = 0
        BEGIN
            -- Determine if it's "not found" or "forbidden"
            IF EXISTS (SELECT 1 FROM [utility].[DirectDebits] WHERE [Id] = @Id)
                THROW 50016, 'Forbidden: direct debit does not belong to this user.', 1;
            ELSE
                THROW 50014, 'DirectDebit not found.', 1;
        END
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