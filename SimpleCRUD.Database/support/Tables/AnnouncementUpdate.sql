CREATE TABLE [support].[AnnouncementUpdate] (
    [Id]              INT            IDENTITY (1, 1) NOT NULL,
    [AnnouncementId]  INT            NOT NULL,
    [Body]            NVARCHAR (MAX) NOT NULL,
    [CreatedByUserId] NVARCHAR (450) NOT NULL,
    [CreatedAt]       DATETIME2 (7)  CONSTRAINT [DF_AnnouncementUpdate_CreatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [PK_AnnouncementUpdate] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_AnnouncementUpdate_Announcement] FOREIGN KEY ([AnnouncementId]) REFERENCES [support].[Announcement] ([Id]) ON DELETE CASCADE,
    CONSTRAINT [FK_AnnouncementUpdate_CreatedBy] FOREIGN KEY ([CreatedByUserId]) REFERENCES [dbo].[AspNetUsers] ([Id])
);


GO
CREATE NONCLUSTERED INDEX [IX_AnnouncementUpdate_AnnouncementId]
    ON [support].[AnnouncementUpdate]([AnnouncementId] ASC, [CreatedAt] ASC);

