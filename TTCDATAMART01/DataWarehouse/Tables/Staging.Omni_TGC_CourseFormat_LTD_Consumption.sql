CREATE TABLE [Staging].[Omni_TGC_CourseFormat_LTD_Consumption]
(
[Customerid] [dbo].[udtCustomerID] NULL,
[courseid] [int] NULL,
[StockItemID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FormatMedia] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FormatAD] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateOrdered] [date] NULL,
[FormatType] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StreamedFlag] [bit] NULL,
[DownloadedFlag] [bit] NULL,
[FirstStreamActivity] [date] NULL,
[FirstDownloadActivity] [date] NULL
) ON [PRIMARY]
GO
