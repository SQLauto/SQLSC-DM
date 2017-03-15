CREATE TABLE [Archive].[Audible_Sales]
(
[Asin] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Category] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Course_ID] [int] NULL,
[Release_Date] [date] NULL,
[Report_Month] [date] NULL,
[Title] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Units] [int] NULL,
[Revenue] [float] NULL,
[DMLastUpdated] [datetime] NULL CONSTRAINT [DF__Audible_S__DMLas__1361871F] DEFAULT (getdate())
) ON [PRIMARY]
GO
