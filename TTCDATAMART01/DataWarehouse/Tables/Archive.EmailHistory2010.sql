CREATE TABLE [Archive].[EmailHistory2010]
(
[CustomerID] [int] NOT NULL,
[Adcode] [int] NULL,
[StartDate] [datetime] NULL,
[FlagHoldOut] [int] NULL,
[ComboID] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PreferredCategory] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmailAddress] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_EmailHistory2010_TSTAMP_FlagHoldOut] ON [Archive].[EmailHistory2010] ([StartDate], [FlagHoldOut]) ON [PRIMARY]
GO
