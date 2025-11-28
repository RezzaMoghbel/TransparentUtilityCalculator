CREATE TABLE [support].[TicketPriority] (
    [Id]   INT            IDENTITY (1, 1) NOT NULL,
    [Code] NVARCHAR (50)  NOT NULL,
    [Name] NVARCHAR (100) NOT NULL,
    CONSTRAINT [PK_TicketPriority] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [UQ_TicketPriority_Code] UNIQUE NONCLUSTERED ([Code] ASC)
);

