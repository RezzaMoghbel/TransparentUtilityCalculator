CREATE TABLE [utility].[UtilityReadings] (
    [Id]                   INT             IDENTITY (1, 1) NOT NULL,
    [UtilityTypeId]        INT             NOT NULL,
    [UserId]               NVARCHAR (450)  NOT NULL,
    [UnitRate]             DECIMAL (12, 6) NOT NULL,
    [StandingChargePerDay] DECIMAL (12, 6) CONSTRAINT [DF_UtilityReadings_StandingChargePerDay] DEFAULT ((0)) NOT NULL,
    [VatRateFactor]        DECIMAL (5, 4)  CONSTRAINT [DF_UtilityReadings_VatRateFactor] DEFAULT ((1)) NOT NULL,
    [ReadingStartDate]     DATE            NOT NULL,
    [ReadingEndDate]       DATE            NOT NULL,
    [MeterStart]           DECIMAL (18, 3) NOT NULL,
    [MeterEnd]             DECIMAL (18, 3) NOT NULL,
    [UnitsUsed]            AS              (CONVERT([decimal](18,3),[MeterEnd]-[MeterStart])) PERSISTED,
    [BillDays]             AS              (datediff(day,[ReadingStartDate],[ReadingEndDate])) PERSISTED,
    [TotalUsage]           AS              (CONVERT([decimal](18,6),[UnitRate]*CONVERT([decimal](18,3),[MeterEnd]-[MeterStart]))) PERSISTED,
    [TotalStandingCharge]  AS              (CONVERT([decimal](18,6),CONVERT([decimal](18,6),datediff(day,[ReadingStartDate],[ReadingEndDate]))*case when [UtilityTypeId]=(4) then (0) else [StandingChargePerDay] end)) PERSISTED,
    [Total]                AS              (CONVERT([decimal](18,6),(CONVERT([decimal](18,6),[UnitRate]*CONVERT([decimal](18,3),[MeterEnd]-[MeterStart]))+CONVERT([decimal](18,6),CONVERT([decimal](18,6),datediff(day,[ReadingStartDate],[ReadingEndDate]))*case when [UtilityTypeId]=(4) then (0) else [StandingChargePerDay] end))*[VatRateFactor])) PERSISTED,
    [CreatedAt]            DATETIME2 (0)   CONSTRAINT [DF_UtilityReadings_CreatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    [ProviderDebitAmount]  DECIMAL (12, 2) NULL,
    [ProviderDebitDate]    DATE            NULL,
    [Notes]                NVARCHAR (200)  NULL,
    CONSTRAINT [PK_UtilityReadings] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [CK_UtilityReadings_DateRange] CHECK ([ReadingEndDate]>=[ReadingStartDate]),
    CONSTRAINT [CK_UtilityReadings_HotWaterStandingCharge] CHECK ([UtilityTypeId]<>(4) OR [StandingChargePerDay]=(0)),
    CONSTRAINT [CK_UtilityReadings_Meter] CHECK ([MeterEnd]>=[MeterStart]),
    CONSTRAINT [CK_UtilityReadings_Rates] CHECK ([UnitRate]>=(0) AND [StandingChargePerDay]>=(0) AND ([VatRateFactor]>=(0) AND [VatRateFactor]<=(2))),
    CONSTRAINT [FK_UtilityReadings_AspNetUsers_User] FOREIGN KEY ([UserId]) REFERENCES [dbo].[AspNetUsers] ([Id]),
    CONSTRAINT [FK_UtilityReadings_UtilityType] FOREIGN KEY ([UtilityTypeId]) REFERENCES [utility].[UtilityType] ([Id])
);


GO
CREATE NONCLUSTERED INDEX [IX_UtilityReadings_UserId]
    ON [utility].[UtilityReadings]([UserId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_UtilityReadings_Type_Period]
    ON [utility].[UtilityReadings]([UtilityTypeId] ASC, [ReadingStartDate] ASC, [ReadingEndDate] ASC);

