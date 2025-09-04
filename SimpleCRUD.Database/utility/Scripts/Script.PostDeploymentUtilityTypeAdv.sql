PRINT 'Seeding utility.UtilityTypeAdv...';

MERGE [utility].[UtilityTypeAdv] AS T
USING (VALUES
    (N'Electricity', N'KWH', N'Other'),
    (N'Electricity', N'KWH', N'Hot-Water'),
    (N'Water',       N'M3',  N'Cold-Water'),
    (N'Water',       N'M3',  N'Hot-Water')
) AS S([Name],[Unit],[For])
   ON T.[Name] = S.[Name]
  AND T.[Unit] = S.[Unit]
  AND T.[For]  = S.[For]
WHEN NOT MATCHED BY TARGET
    THEN INSERT ([Name],[Unit],[For]) VALUES (S.[Name], S.[Unit], S.[For])
-- optional: keep Unit/IsActive aligned if you change seed later
WHEN MATCHED AND (T.[Unit] <> S.[Unit] OR T.[IsActive] = 0)
    THEN UPDATE SET T.[Unit] = S.[Unit], T.[IsActive] = 1;
