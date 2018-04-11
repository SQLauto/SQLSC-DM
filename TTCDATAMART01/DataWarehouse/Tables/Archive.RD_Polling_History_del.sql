CREATE TABLE [Archive].[RD_Polling_History_del]
(
[TableName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PollType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Business] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Emailaddress] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Frequency] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CountryCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustGroup] [int] NULL,
[TransactionType] [int] NULL,
[CustStatusFlag] [int] NULL,
[PaidFlag] [int] NULL,
[PullDate] [date] NULL,
[PreferredCategory2] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MediaFormatPreference] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderSourcePreference] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
