CREATE TABLE [support].[Ticket] (
    [Id]               INT            IDENTITY (1, 1) NOT NULL,
    [Title]            NVARCHAR (200) NOT NULL,
    [Description]      NVARCHAR (MAX) NOT NULL,
    [StatusId]         INT            NOT NULL,
    [PriorityId]       INT            NOT NULL,
    [CategoryId]       INT            NOT NULL,
    [CreatedByUserId]  NVARCHAR (450) NOT NULL,
    [AssignedToUserId] NVARCHAR (450) NULL,
    [RelatedUserId]    NVARCHAR (450) NULL,
    [BuildingId]       INT            NOT NULL,
    [AnnouncementId]   INT            NULL,
    [CreatedAt]        DATETIME2 (7)  CONSTRAINT [DF_Ticket_CreatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    [UpdatedAt]        DATETIME2 (7)  NULL,
    [ResolvedAt]       DATETIME2 (7)  NULL,
    [IsArchived]       BIT            CONSTRAINT [DF_Ticket_IsArchived] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Ticket] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_Ticket_Announcement] FOREIGN KEY ([AnnouncementId]) REFERENCES [support].[Announcement] ([Id]),
    CONSTRAINT [FK_Ticket_AssignedTo] FOREIGN KEY ([AssignedToUserId]) REFERENCES [dbo].[AspNetUsers] ([Id]),
    CONSTRAINT [FK_Ticket_Building] FOREIGN KEY ([BuildingId]) REFERENCES [dbo].[Buildings] ([Id]),
    CONSTRAINT [FK_Ticket_Category] FOREIGN KEY ([CategoryId]) REFERENCES [support].[IssueCategory] ([Id]),
    CONSTRAINT [FK_Ticket_CreatedBy] FOREIGN KEY ([CreatedByUserId]) REFERENCES [dbo].[AspNetUsers] ([Id]),
    CONSTRAINT [FK_Ticket_Priority] FOREIGN KEY ([PriorityId]) REFERENCES [support].[TicketPriority] ([Id]),
    CONSTRAINT [FK_Ticket_RelatedUser] FOREIGN KEY ([RelatedUserId]) REFERENCES [dbo].[AspNetUsers] ([Id]),
    CONSTRAINT [FK_Ticket_Status] FOREIGN KEY ([StatusId]) REFERENCES [support].[TicketStatus] ([Id])
);


GO
CREATE NONCLUSTERED INDEX [IX_Ticket_CreatedAt]
    ON [support].[Ticket]([CreatedAt] DESC);


GO
CREATE NONCLUSTERED INDEX [IX_Ticket_StatusId]
    ON [support].[Ticket]([StatusId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Ticket_BuildingId]
    ON [support].[Ticket]([BuildingId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Ticket_AssignedToUserId]
    ON [support].[Ticket]([AssignedToUserId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Ticket_CreatedByUserId]
    ON [support].[Ticket]([CreatedByUserId] ASC);

