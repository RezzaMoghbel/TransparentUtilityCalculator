CREATE PROCEDURE [utility].[DirectDebits_Insert]
    @UserId              NVARCHAR(450),
    @Amount              DECIMAL(12,2),
    @PaymentDate         DATE,
    @UtilityProviderId   INT = NULL,
    @PaymentStatus       NVARCHAR(20) = 'Paid',
    @Notes               NVARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @NewId INT;

    BEGIN TRY
        BEGIN TRANSACTION;

        /* ---------- Validation ---------- */

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

        /* ---------- Insert ---------- */

        INSERT INTO [utility].[DirectDebits] (
            [UserId],
            [Amount],
            [PaymentDate],
            [UtilityProviderId],
            [PaymentStatus],
            [Notes]
        )
        VALUES (
            @UserId,
            @Amount,
            @PaymentDate,
            @UtilityProviderId,
            @PaymentStatus,
            @Notes
        );

        SET @NewId = SCOPE_IDENTITY();

        COMMIT TRANSACTION;

        /* ---------- Return the inserted row ---------- */
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
        WHERE d.[Id] = @NewId;
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