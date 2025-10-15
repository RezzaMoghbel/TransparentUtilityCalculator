CREATE PROCEDURE [utility].[DirectDebits_ListByDate]
    @UserId    NVARCHAR(450),     -- required: the caller's AspNetUsers.Id
    @FromDate  DATE = NULL,       -- optional: inclusive lower bound
    @ToDate    DATE = NULL        -- optional: inclusive upper bound
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Validate user
        IF NOT EXISTS (SELECT 1 FROM [dbo].[AspNetUsers] WHERE [Id] = @UserId)
            THROW 50011, 'Invalid UserId.', 1;

        -- Normalize dates (open-ended if NULL)
        DECLARE @From DATE = ISNULL(@FromDate, '19000101');
        DECLARE @To   DATE = ISNULL(@ToDate,   '99991231');

        IF @To < @From
            THROW 50017, 'ToDate must be >= FromDate.', 1;

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
        WHERE d.[UserId] = @UserId
          AND d.[PaymentDate] >= @From
          AND d.[PaymentDate] <= @To
        ORDER BY d.[PaymentDate] DESC, d.[Id] DESC;
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