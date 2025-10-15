CREATE TABLE [utility].[DirectDebits] (
    [Id]                INT             IDENTITY (1, 1) NOT NULL,
    [UserId]            NVARCHAR (450)  NOT NULL,
    [Amount]            DECIMAL (12, 2) NOT NULL,
    [PaymentDate]       DATE            NOT NULL,
    [UtilityProviderId] INT             NULL,
    [PaymentStatus]     NVARCHAR (20)   CONSTRAINT [DF_DirectDebits_PaymentStatus] DEFAULT ('Paid') NOT NULL,
    [Notes]             NVARCHAR (200)  NULL,
    [CreatedAt]         DATETIME2 (0)   CONSTRAINT [DF_DirectDebits_CreatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [PK_DirectDebits] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [CK_DirectDebits_Amount] CHECK ([Amount]>(0)),
    CONSTRAINT [CK_DirectDebits_PaymentStatus] CHECK ([PaymentStatus]='Cancelled' OR [PaymentStatus]='Failed' OR [PaymentStatus]='Paid' OR [PaymentStatus]='Pending'),
    CONSTRAINT [FK_DirectDebits_AspNetUsers_User] FOREIGN KEY ([UserId]) REFERENCES [dbo].[AspNetUsers] ([Id]),
    CONSTRAINT [FK_DirectDebits_UtilityProviders] FOREIGN KEY ([UtilityProviderId]) REFERENCES [dbo].[UtilityProviders] ([Id])
);


GO
CREATE NONCLUSTERED INDEX [IX_DirectDebits_UtilityProviderId]
    ON [utility].[DirectDebits]([UtilityProviderId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_DirectDebits_PaymentDate]
    ON [utility].[DirectDebits]([PaymentDate] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_DirectDebits_UserId]
    ON [utility].[DirectDebits]([UserId] ASC);

