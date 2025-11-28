CREATE TABLE [support].[Announcement] (
    [Id]              INT            IDENTITY (1, 1) NOT NULL,
    [Title]           NVARCHAR (200) NOT NULL,
    [Body]            NVARCHAR (MAX) NOT NULL,
    [CategoryId]      INT            NULL,
    [ScopeId]         INT            NOT NULL,
    [BuildingId]      INT            NULL,
    [SourceTicketId]  INT            NULL,
    [CreatedByUserId] NVARCHAR (450) NOT NULL,
    [CreatedAt]       DATETIME2 (7)  CONSTRAINT [DF_Announcement_CreatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    [PublishedAt]     DATETIME2 (7)  NULL,
    [IsActive]        BIT            CONSTRAINT [DF_Announcement_IsActive] DEFAULT ((1)) NOT NULL,
    [IsArchived]      BIT            CONSTRAINT [DF_Announcement_IsArchived] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Announcement] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_Announcement_Building] FOREIGN KEY ([BuildingId]) REFERENCES [dbo].[Buildings] ([Id]),
    CONSTRAINT [FK_Announcement_Category] FOREIGN KEY ([CategoryId]) REFERENCES [support].[IssueCategory] ([Id]),
    CONSTRAINT [FK_Announcement_CreatedBy] FOREIGN KEY ([CreatedByUserId]) REFERENCES [dbo].[AspNetUsers] ([Id]),
    CONSTRAINT [FK_Announcement_Scope] FOREIGN KEY ([ScopeId]) REFERENCES [support].[AnnouncementScope] ([Id]),
    CONSTRAINT [FK_Announcement_SourceTicket] FOREIGN KEY ([SourceTicketId]) REFERENCES [support].[Ticket] ([Id])
);


GO
CREATE NONCLUSTERED INDEX [IX_Announcement_BuildingId]
    ON [support].[Announcement]([BuildingId] ASC, [ScopeId] ASC, [CreatedAt] DESC);

