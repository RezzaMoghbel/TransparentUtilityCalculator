CREATE PROCEDURE [utility].[rpt_DirectDebits_BalanceById]
    @DirectDebitId INT,
    @UserId NVARCHAR(450)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Summary
    SELECT 
        dd.[Id],
        dd.[PaymentDate],
        dd.[Amount] AS DirectDebitAmount,
        up.[Name] AS ProviderName,
        dd.[PaymentStatus],
        dd.[Notes],
        dd.[CreatedAt],
        ISNULL(SUM(r.[Total]), 0) AS LinkedReadingsTotal,
        dd.[Amount] - ISNULL(SUM(r.[Total]), 0) AS Balance,
        CASE 
            WHEN dd.[Amount] - ISNULL(SUM(r.[Total]), 0) > 0 THEN 'Overpaid'
            WHEN dd.[Amount] - ISNULL(SUM(r.[Total]), 0) = 0 THEN 'Exact'
            ELSE 'Underpaid'
        END AS BalanceStatus
    FROM [utility].[DirectDebits] dd
    LEFT JOIN [dbo].[UtilityProviders] up ON up.[Id] = dd.[UtilityProviderId]
    LEFT JOIN [utility].[DirectDebitReadings] dr ON dr.[DirectDebitId] = dd.[Id]
    LEFT JOIN [utility].[UtilityReadings] r ON r.[Id] = dr.[UtilityReadingId]
    WHERE dd.[Id] = @DirectDebitId AND dd.[UserId] = @UserId
    GROUP BY dd.[Id], dd.[PaymentDate], dd.[Amount], up.[Name], dd.[PaymentStatus], dd.[Notes], dd.[CreatedAt];
    
    -- Breakdown of linked readings
    SELECT 
        r.[Id],
        t.[Name] AS UtilityType,
        r.[ReadingStartDate],
        r.[ReadingEndDate],
        r.[UnitsUsed],
        r.[Total]
    FROM [utility].[DirectDebitReadings] dr
    INNER JOIN [utility].[UtilityReadings] r ON r.[Id] = dr.[UtilityReadingId]
    LEFT JOIN [utility].[UtilityType] t ON t.[Id] = r.[UtilityTypeId]
    WHERE dr.[DirectDebitId] = @DirectDebitId AND r.[UserId] = @UserId
    ORDER BY r.[ReadingStartDate] DESC;
END