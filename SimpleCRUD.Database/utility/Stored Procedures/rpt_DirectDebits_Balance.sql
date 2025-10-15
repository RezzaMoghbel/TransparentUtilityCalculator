CREATE PROCEDURE [utility].[rpt_DirectDebits_Balance]
    @UserId NVARCHAR(450)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        dd.[Id],
        dd.[PaymentDate],
        dd.[Amount] AS DirectDebitAmount,
        up.[Name] AS ProviderName,
        dd.[PaymentStatus],
        ISNULL(SUM(r.[Total]), 0) AS LinkedReadingsTotal,
        dd.[Amount] - ISNULL(SUM(r.[Total]), 0) AS Balance,
        CASE 
            WHEN dd.[Amount] - ISNULL(SUM(r.[Total]), 0) > 0 THEN 'Overpaid'
            WHEN dd.[Amount] - ISNULL(SUM(r.[Total]), 0) = 0 THEN 'Exact'
            ELSE 'Underpaid'
        END AS BalanceStatus,
        COUNT(r.[Id]) AS LinkedReadingsCount
    FROM [utility].[DirectDebits] dd
    LEFT JOIN [dbo].[UtilityProviders] up ON up.[Id] = dd.[UtilityProviderId]
    LEFT JOIN [utility].[DirectDebitReadings] dr ON dr.[DirectDebitId] = dd.[Id]
    LEFT JOIN [utility].[UtilityReadings] r ON r.[Id] = dr.[UtilityReadingId]
    WHERE dd.[UserId] = @UserId
    GROUP BY dd.[Id], dd.[PaymentDate], dd.[Amount], up.[Name], dd.[PaymentStatus]
    ORDER BY dd.[PaymentDate] DESC;
END