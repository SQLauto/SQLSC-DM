CREATE TABLE [Marketing].[YTD_ORDERS]
(
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EmailAddress] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LatestPurchase] [varchar] (19) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OrderSource] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NewsegPrior] [int] NULL,
[A12mfPrior] [int] NULL,
[FrequencyPrior] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NamePrior] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerSegmentPrior] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagEmailOrder] [tinyint] NULL,
[MaxOpenDate] [datetime] NULL,
[MaxClickDate] [datetime] NULL,
[DaysBWLastOpenAndLastPurchase] [int] NULL,
[DaysBWLastClickAndLastPurchase] [int] NULL,
[Open_Week_BIN] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Open_Month_BIN] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Click_Week_BIN] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Click_Month_BIN] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
