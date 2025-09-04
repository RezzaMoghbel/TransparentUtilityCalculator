CREATE TABLE [dbo].[UtilityProviders] (
    [Id]       INT            IDENTITY (1, 1) NOT NULL,
    [Name]     NVARCHAR (100) NOT NULL,
    [URL]      NVARCHAR (50)  NULL,
    [IsActive] BIT            NOT NULL,
    CONSTRAINT [PK_UtilityProviders] PRIMARY KEY CLUSTERED ([Id] ASC)
);

