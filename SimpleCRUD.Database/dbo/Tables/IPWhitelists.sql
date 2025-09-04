CREATE TABLE [dbo].[IPWhitelists] (
    [Id]          INT            IDENTITY (1, 1) NOT NULL,
    [IPAddress]   NVARCHAR (45)  NOT NULL,
    [UserId]      NVARCHAR (450) NULL,
    [Description] NVARCHAR (250) NULL,
    [ExpiryDate]  DATETIME2 (7)  NULL,
    [IsActive]    BIT            DEFAULT (CONVERT([bit],(0))) NOT NULL,
    CONSTRAINT [PK_IPWhitelists] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_IPWhitelists_AspNetUsers_UserId] FOREIGN KEY ([UserId]) REFERENCES [dbo].[AspNetUsers] ([Id])
);


GO
CREATE NONCLUSTERED INDEX [IX_IPWhitelists_UserId]
    ON [dbo].[IPWhitelists]([UserId] ASC);

