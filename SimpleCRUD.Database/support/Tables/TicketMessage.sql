CREATE TABLE [support].[TicketMessage] (
    [Id]              INT            IDENTITY (1, 1) NOT NULL,
    [TicketId]        INT            NOT NULL,
    [Body]            NVARCHAR (MAX) NOT NULL,
    [CreatedByUserId] NVARCHAR (450) NOT NULL,
    [CreatedAt]       DATETIME2 (7)  CONSTRAINT [DF_TicketMessage_CreatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    [IsInternal]      BIT            CONSTRAINT [DF_TicketMessage_IsInternal] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_TicketMessage] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_TicketMessage_Ticket] FOREIGN KEY ([TicketId]) REFERENCES [support].[Ticket] ([Id]) ON DELETE CASCADE,
    CONSTRAINT [FK_TicketMessage_User] FOREIGN KEY ([CreatedByUserId]) REFERENCES [dbo].[AspNetUsers] ([Id])
);


GO
CREATE NONCLUSTERED INDEX [IX_TicketMessage_TicketId]
    ON [support].[TicketMessage]([TicketId] ASC, [CreatedAt] ASC);

