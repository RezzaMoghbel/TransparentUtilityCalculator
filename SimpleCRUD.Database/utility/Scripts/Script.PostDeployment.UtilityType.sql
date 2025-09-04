SET IDENTITY_INSERT [utility].[UtilityType] ON;

MERGE [utility].[UtilityType] AS T
USING (VALUES
    (1, N'Electricity', N'KWH', 1),
    (2, N'Gas',         N'M3',  1),
    (3, N'Water-Cold',       N'M3',  1),
    (4, N'Water-Hot',       N'M3',  1)
) AS S([Id],[Name],[Unit],[IsActive])
    ON T.[Id] = S.[Id]
WHEN MATCHED AND (T.[Name] <> S.[Name] OR T.[Unit] <> S.[Unit] OR T.[IsActive] <> S.[IsActive])
    THEN UPDATE SET [Name]=S.[Name], [Unit]=S.[Unit], [IsActive]=S.[IsActive]
WHEN NOT MATCHED BY TARGET
    THEN INSERT ([Id],[Name],[Unit],[IsActive]) VALUES (S.[Id],S.[Name],S.[Unit],S.[IsActive]);

SET IDENTITY_INSERT [utility].[UtilityType] OFF;
