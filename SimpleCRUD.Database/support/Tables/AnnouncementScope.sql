CREATE TABLE [support].[AnnouncementScope] (
    [Id]   INT            IDENTITY (1, 1) NOT NULL,
    [Code] NVARCHAR (50)  NOT NULL,
    [Name] NVARCHAR (100) NOT NULL,
    CONSTRAINT [PK_AnnouncementScope] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [UQ_AnnouncementScope_Code] UNIQUE NONCLUSTERED ([Code] ASC)
);

