CREATE TABLE [dbo].[AccessLevels] (
    [Id]          INT            IDENTITY (1, 1) NOT NULL,
    [Name]        NVARCHAR (MAX) NOT NULL,
    [Description] NVARCHAR (500) NULL,
    CONSTRAINT [PK_AccessLevels] PRIMARY KEY CLUSTERED ([Id] ASC)
);

