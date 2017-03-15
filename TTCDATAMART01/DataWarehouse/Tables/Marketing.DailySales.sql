CREATE TABLE [Marketing].[DailySales]
(
[Yr] [int] NULL,
[Mo] [int] NULL,
[Order_Day] [int] NULL,
[customers] [int] NULL,
[orders] [int] NULL,
[sales] [money] NULL,
[billingcountrycode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CurrencyCode] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ReportDate] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
