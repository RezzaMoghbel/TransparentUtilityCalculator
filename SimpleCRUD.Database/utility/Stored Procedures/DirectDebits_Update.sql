CREATE PROCEDURE [utility].[DirectDebits_Update]
    @Id                 INT,
    @UserId             NVARCHAR(450),
    @Amount             DECIMAL(12,2),
    @PaymentDate        DATE,
    @UtilityProviderId  INT = NULL,
    @PaymentStatus      NVARCHAR(20),
    @Notes              NVARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        /* ---------- Validation ---------- */

        -- Row must exist
        IF NOT EXISTS (SELECT 1 FROM [utility].[DirectDebits] WHERE [Id] = @Id)
            THROW 50014, 'DirectDebit Id not found.', 1;

        -- User must exist
        IF NOT EXISTS (SELECT 1 FROM [dbo].[AspNetUsers] WHERE [Id] = @UserId)
            THROW 50011, 'Invalid UserId.', 1;

        -- Amount must be positive
        IF (@Amount <= 0)
            THROW 50012, 'Amount must be greater than 0.', 1;

        -- Payment status must be valid
        IF (@PaymentStatus NOT IN ('Pending', 'Paid', 'Failed', 'Cancelled'))
            THROW 50013, 'Invalid PaymentStatus. Must be: Pending, Paid, Failed, or Cancelled.', 1;

        -- UtilityProviderId must exist if provided
        IF (@UtilityProviderId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM [dbo].[UtilityProviders] WHERE [Id] = @UtilityProviderId AND [IsActive] = 1))
            THROW 50023, 'Invalid UtilityProviderId or provider is not active.', 1;

        /* ---------- Update ---------- */

        UPDATE d
        SET
            d.[UserId]             = @UserId,
            d.[Amount]             = @Amount,
            d.[PaymentDate]        = @PaymentDate,
            d.[UtilityProviderId]  = @UtilityProviderId,
            d.[PaymentStatus]      = @PaymentStatus,
            d.[Notes]              = @Notes
        FROM [utility].[DirectDebits] d
        WHERE d.[Id] = @Id;

        -- Double-check a row was updated
        IF @@ROWCOUNT = 0
            THROW 50015, 'Update failed unexpectedly.', 1;

        COMMIT TRANSACTION;

        /* ---------- Return updated row ---------- */
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
        WHERE d.[Id] = @Id;
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