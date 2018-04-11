CREATE TABLE [Staging].[MC_TGC_WebVisits]
(
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MonthStartDate] [date] NULL,
[AllVisits] [int] NULL,
[ProdViews] [int] NULL,
[PageViews] [int] NULL
) ON [PRIMARY]
GO
