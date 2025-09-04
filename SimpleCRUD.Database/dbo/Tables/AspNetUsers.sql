CREATE TABLE [dbo].[AspNetUsers] (
    [Id]                   NVARCHAR (450)     NOT NULL,
    [UserName]             NVARCHAR (256)     NULL,
    [NormalizedUserName]   NVARCHAR (256)     NULL,
    [Email]                NVARCHAR (256)     NULL,
    [NormalizedEmail]      NVARCHAR (256)     NULL,
    [EmailConfirmed]       BIT                NOT NULL,
    [PasswordHash]         NVARCHAR (MAX)     NULL,
    [SecurityStamp]        NVARCHAR (MAX)     NULL,
    [ConcurrencyStamp]     NVARCHAR (MAX)     NULL,
    [PhoneNumber]          NVARCHAR (MAX)     NULL,
    [PhoneNumberConfirmed] BIT                NOT NULL,
    [TwoFactorEnabled]     BIT                NOT NULL,
    [LockoutEnd]           DATETIMEOFFSET (7) NULL,
    [LockoutEnabled]       BIT                NOT NULL,
    [AccessFailedCount]    INT                NOT NULL,
    [AccessAllowed]        BIT                DEFAULT (CONVERT([bit],(0))) NOT NULL,
    [AccessLevelId]        INT                DEFAULT ((1)) NOT NULL,
    [Deleted]              BIT                DEFAULT (CONVERT([bit],(0))) NOT NULL,
    [PropertyName]         NVARCHAR (100)     NULL,
    [AddressLine1]         NVARCHAR (100)     NULL,
    [AddressLine2]         NVARCHAR (100)     NULL,
    [AddressLine3]         NVARCHAR (100)     NULL,
    [Postcode]             NVARCHAR (15)      NULL,
    [Country]              NVARCHAR (30)      NULL,
    [BuildingId]           INT                NULL,
    [ProviderId]           INT                NULL,
    CONSTRAINT [PK_AspNetUsers] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_AspNetUsers_AccessLevels_AccessLevelId] FOREIGN KEY ([AccessLevelId]) REFERENCES [dbo].[AccessLevels] ([Id]) ON DELETE CASCADE,
    CONSTRAINT [FK_AspNetUsers_Buildings_BuildingId] FOREIGN KEY ([BuildingId]) REFERENCES [dbo].[Buildings] ([Id]) ON DELETE SET NULL,
    CONSTRAINT [FK_AspNetUsers_UtilityProviders_ProviderId] FOREIGN KEY ([ProviderId]) REFERENCES [dbo].[UtilityProviders] ([Id]) ON DELETE SET NULL
);


GO
CREATE NONCLUSTERED INDEX [IX_AspNetUsers_ProviderId]
    ON [dbo].[AspNetUsers]([ProviderId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_AspNetUsers_BuildingId]
    ON [dbo].[AspNetUsers]([BuildingId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_AspNetUsers_AccessLevelId]
    ON [dbo].[AspNetUsers]([AccessLevelId] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UserNameIndex]
    ON [dbo].[AspNetUsers]([NormalizedUserName] ASC) WHERE ([NormalizedUserName] IS NOT NULL);


GO
CREATE NONCLUSTERED INDEX [EmailIndex]
    ON [dbo].[AspNetUsers]([NormalizedEmail] ASC);

