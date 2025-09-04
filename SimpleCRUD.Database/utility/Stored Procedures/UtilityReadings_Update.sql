
CREATE   PROCEDURE [utility].[UtilityReadings_Update]
    @Id                   INT,               -- row to update
    @UtilityTypeId        INT,
    @UserId               NVARCHAR(450),
    @UnitRate             DECIMAL(12,6),
    @StandingChargePerDay DECIMAL(12,6) = 0,
    @VatRateFactor        DECIMAL(5,4)  = 1,
    @ReadingStartDate     DATE,
    @ReadingEndDate       DATE,
    @MeterStart           DECIMAL(18,3),
    @MeterEnd             DECIMAL(18,3),
    @ProviderDebitAmount  DECIMAL(12,2) = NULL,
    @ProviderDebitDate    DATE          = NULL,
    @Notes                NVARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        /* ---------- Validation ---------- */

        -- Row must exist
        IF NOT EXISTS (SELECT 1 FROM [utility].[UtilityReadings] WHERE [Id] = @Id)
            THROW 50006, 'UtilityReadings Id not found.', 1;

        -- Utility type must exist (change table name if you FK to UtilityTypeAdv)
        IF NOT EXISTS (SELECT 1 FROM [utility].[UtilityType] WHERE [Id] = @UtilityTypeId)
            THROW 50001, 'Invalid UtilityTypeId.', 1;

        -- User must exist
        IF NOT EXISTS (SELECT 1 FROM [dbo].[AspNetUsers] WHERE [Id] = @UserId)
            THROW 50002, 'Invalid UserId.', 1;

        -- Date range valid (BillDays is exclusive of end date)
        IF (@ReadingEndDate < @ReadingStartDate)
            THROW 50003, 'ReadingEndDate must be >= ReadingStartDate.', 1;

        -- Meter readings valid
        IF (@MeterEnd < @MeterStart)
            THROW 50004, 'MeterEnd must be >= MeterStart.', 1;

        -- Rate ranges valid
        IF (@UnitRate < 0 OR @StandingChargePerDay < 0 OR @VatRateFactor < 0 OR @VatRateFactor > 2)
            THROW 50005, 'Rate values out of valid range.', 1;

        -- Enforce Hot Water rule (Id = 4 => standing charge = 0)
        DECLARE @StandingChargePerDayEff DECIMAL(12,6) =
            CASE WHEN @UtilityTypeId = 4 THEN 0 ELSE @StandingChargePerDay END;

        /* ---------- Update ---------- */

        UPDATE r
        SET
            r.[UtilityTypeId]        = @UtilityTypeId,
            r.[UserId]               = @UserId,
            r.[UnitRate]             = @UnitRate,
            r.[StandingChargePerDay] = @StandingChargePerDayEff,
            r.[VatRateFactor]        = @VatRateFactor,
            r.[ReadingStartDate]     = @ReadingStartDate,
            r.[ReadingEndDate]       = @ReadingEndDate,
            r.[MeterStart]           = @MeterStart,
            r.[MeterEnd]             = @MeterEnd,
            r.[ProviderDebitAmount]  = @ProviderDebitAmount,
            r.[ProviderDebitDate]    = @ProviderDebitDate,
            r.[Notes]                = @Notes
        FROM [utility].[UtilityReadings] r
        WHERE r.[Id] = @Id;

        -- (optional) double-check a row was updated
        IF @@ROWCOUNT = 0
            THROW 50007, 'Update failed unexpectedly.', 1;

        COMMIT TRANSACTION;

        /* ---------- Return updated row (incl. computed cols) ---------- */
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
        WHERE r.[Id] = @Id;
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