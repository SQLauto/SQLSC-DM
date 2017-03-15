CREATE TABLE [Staging].[Audible_ssis_Sales]
(
[Asin] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Category] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Course_ID] [int] NULL,
[Release_Date] [datetime] NULL,
[Report_Month] [datetime] NULL,
[Title] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Units] [int] NULL,
[Revenue] [float] NULL
) ON [PRIMARY]
GO
