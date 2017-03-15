CREATE TABLE [Staging].[TempCustomerOverLay_RawData]
(
[CustomerID] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BirthDateCCYYMM] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CombinedAge] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EstHouseholdIncomeV4] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Education_Individual1] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[POC0_3YearsOldConfirm] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[POC0_3YearsOldCode] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[POC4_6YearsOldConfirm] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[POC4_6YearsOldCode] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[POC7_9YearsOldConfirm] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[POC7_9YearsOldCode] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[POC10_12YRSOldConfirm] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[POC10_12YRSOldCode] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[POC13_18YRSOldConfirm] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[POC13_18YRSOldCode] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[POCAge0_3V3] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[POCAge4_6V3] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[POCAge7_9V3] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[POCAge10_12V3] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[POCAge13_15V3] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[POCAge16_18V3] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Gender] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TotalEnhancementMatchType] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateFromExperian] [datetime] NULL,
[IntlPurchaseDate] [datetime] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_TempCustomerOverLay_RawData1] ON [Staging].[TempCustomerOverLay_RawData] ([CustomerID]) ON [PRIMARY]
GO
