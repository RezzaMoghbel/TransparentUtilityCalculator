
CREATE   PROCEDURE [utility].[UtilityReadings_GetById]
    @Id     INT,
    @UserId NVARCHAR(450)   -- the logged-in user's Id from AspNetUsers
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- (optional) validate user exists
        IF NOT EXISTS (SELECT 1 FROM [dbo].[AspNetUsers] WHERE [Id] = @UserId)
            THROW 50002, 'Invalid UserId.', 1;

        -- Try to fetch the row for this user
        SELECT
            r.[Id],
            r.[UtilityTypeId],
			t.[Name] AS UtilityType,
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
		LEFT JOIN [utility].UtilityType AS t on t.Id = r.UtilityTypeId
        WHERE r.[Id] = @Id
          AND r.[UserId] = @UserId;

        IF @@ROWCOUNT = 0
        BEGIN
            -- Determine if it's "not found" or "forbidden"
            IF EXISTS (SELECT 1 FROM [utility].[UtilityReadings] WHERE [Id] = @Id)
                THROW 50008, 'Forbidden: reading does not belong to this user.', 1;
            ELSE
                THROW 50006, 'Reading not found.', 1;
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