CREATE TABLE [Archive].[EmailHistory2018]
(
[CustomerID] [dbo].[udtCustomerID] NOT NULL,
[Adcode] [int] NULL,
[StartDate] [datetime] NULL,
[FlagHoldOut] [int] NULL,
[ComboID] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PreferredCategory] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmailAddress] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastPurchOrderSource] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BinDaysSinceLastPurchase] [int] NULL,
[R3FormatMediaPref] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_EmailHistory2018_TSTAMP_FlagHoldOut] ON [Archive].[EmailHistory2018] ([StartDate], [FlagHoldOut]) ON [PRIMARY]
GO
