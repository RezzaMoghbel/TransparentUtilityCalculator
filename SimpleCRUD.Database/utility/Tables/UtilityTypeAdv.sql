CREATE TABLE [utility].[UtilityTypeAdv] (
    [Id]        INT            IDENTITY (1, 1) NOT NULL,
    [Name]      NVARCHAR (20)  NOT NULL,
    [Unit]      NVARCHAR (16)  NOT NULL,
    [For]       NVARCHAR (16)  NOT NULL,
    [CreatedAt] DATETIME2 (0)  CONSTRAINT [DF_UtilityTypeAdv_CreatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    [Notes]     NVARCHAR (200) NULL,
    [IsActive]  BIT            CONSTRAINT [DF_UtilityTypeAdv_IsActive] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_UtilityTypeAdv] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [UQ_UtilityTypeAdv_Name_Unit_For] UNIQUE NONCLUSTERED ([Name] ASC, [Unit] ASC, [For] ASC)
);

