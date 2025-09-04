CREATE TABLE [utility].[UtilityType] (
    [Id]        INT            IDENTITY (1, 1) NOT NULL,
    [Name]      NVARCHAR (20)  NOT NULL,
    [Unit]      NVARCHAR (16)  NOT NULL,
    [CreatedAt] DATETIME2 (0)  CONSTRAINT [DF_UtilityType_CreatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    [Notes]     NVARCHAR (200) NULL,
    [IsActive]  BIT            CONSTRAINT [DF_UtilityType_IsActive] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_UtilityType] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [UQ_UtilityType_Name] UNIQUE NONCLUSTERED ([Name] ASC),
    CONSTRAINT [UQ_UtilityType_Name_Unit] UNIQUE NONCLUSTERED ([Name] ASC, [Unit] ASC)
);