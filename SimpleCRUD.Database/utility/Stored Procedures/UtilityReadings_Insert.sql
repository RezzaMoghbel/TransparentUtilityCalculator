
CREATE PROCEDURE [utility].[UtilityReadings_Insert]
    @UtilityTypeId         INT,
    @UserId                NVARCHAR(450),
    @UnitRate              DECIMAL(12,6),
    @StandingChargePerDay  DECIMAL(12,6) = 0,
    @VatRateFactor         DECIMAL(5,4)  = 1,
    @ReadingStartDate      DATE,
    @ReadingEndDate        DATE,
    @MeterStart            DECIMAL(18,3),
    @MeterEnd              DECIMAL(18,3),
    @ProviderDebitAmount   DECIMAL(12,2) = NULL,
    @ProviderDebitDate     DATE          = NULL,
    @Notes                 NVARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @NewId INT;

    BEGIN TRY
        BEGIN TRANSACTION;

        /* ---------- Validation ---------- */

        -- Utility type must exist (change to UtilityTypeAdv if that's your FK)
        IF NOT EXISTS (SELECT 1 FROM [utility].[UtilityType] WHERE [Id] = @UtilityTypeId)
            THROW 50001, 'Invalid UtilityTypeId.', 1;

        -- User must exist
        IF NOT EXISTS (SELECT 1 FROM [dbo].[AspNetUsers] WHERE [Id] = @UserId)
            THROW 50002, 'Invalid UserId.', 1;

        -- Dates valid (exclusive end)
        IF (@ReadingEndDate < @ReadingStartDate)
            THROW 50003, 'ReadingEndDate must be >= ReadingStartDate.', 1;

        -- Meter values valid
        IF (@MeterEnd < @MeterStart)
            THROW 50004, 'MeterEnd must be >= MeterStart.', 1;

        -- Rates within guardrails
        IF (@UnitRate < 0 OR @StandingChargePerDay < 0 OR @VatRateFactor < 0 OR @VatRateFactor > 2)
            THROW 50005, 'Rate values out of valid range.', 1;

        -- Enforce Hot Water rule (Id = 4 => standing charge = 0)
        DECLARE @StandingChargePerDayEff DECIMAL(12,6) =
            CASE WHEN @UtilityTypeId = 4 THEN 0 ELSE @StandingChargePerDay END;

        /* ---------- Insert ---------- */

        INSERT INTO [utility].[UtilityReadings] (
            [UtilityTypeId],
            [UserId],
            [UnitRate],
            [StandingChargePerDay],
            [VatRateFactor],
            [ReadingStartDate],
            [ReadingEndDate],
            [MeterStart],
            [MeterEnd],
            [ProviderDebitAmount],
            [ProviderDebitDate],
            [Notes]
        )
        VALUES (
            @UtilityTypeId,
            @UserId,
            @UnitRate,
            @StandingChargePerDayEff,
            @VatRateFactor,
            @ReadingStartDate,
            @ReadingEndDate,
            @MeterStart,
            @MeterEnd,
            @ProviderDebitAmount,
            @ProviderDebitDate,
            @Notes
        );

        SET @NewId = SCOPE_IDENTITY();

        COMMIT TRANSACTION;

        /* ---------- Return the inserted row (incl. computed cols) ---------- */
        SELECT
            r.[Id],
            r.[UtilityTypeId],
            r.[UserId],
            r.[UnitRate],
            r.[StandingChargePerDay],
            r.[VatRateFactor],
            r.[ReadingStartDate],
            r.[ReadingEndDate],
            r.[MeterStart],
            r.[MeterEnd],
            r.[UnitsUsed],
            r.[BillDays],
            r.[TotalUsage],
            r.[TotalStandingCharge],
            r.[Total],
            r.[CreatedAt],
            r.[ProviderDebitAmount],
            r.[ProviderDebitDate],
            r.[Notes]
        FROM [utility].[UtilityReadings] r
        WHERE r.[Id] = @NewId;
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