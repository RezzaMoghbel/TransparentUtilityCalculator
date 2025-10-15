CREATE TABLE [utility].[DirectDebitReadings] (
    [DirectDebitId]    INT NOT NULL,
    [UtilityReadingId] INT NOT NULL,
    CONSTRAINT [PK_DirectDebitReadings] PRIMARY KEY CLUSTERED ([DirectDebitId] ASC, [UtilityReadingId] ASC),
    CONSTRAINT [FK_DirectDebitReadings_DirectDebits] FOREIGN KEY ([DirectDebitId]) REFERENCES [utility].[DirectDebits] ([Id]) ON DELETE CASCADE,
    CONSTRAINT [FK_DirectDebitReadings_UtilityReadings] FOREIGN KEY ([UtilityReadingId]) REFERENCES [utility].[UtilityReadings] ([Id]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_DirectDebitReadings_UtilityReadingId]
    ON [utility].[DirectDebitReadings]([UtilityReadingId] ASC);

