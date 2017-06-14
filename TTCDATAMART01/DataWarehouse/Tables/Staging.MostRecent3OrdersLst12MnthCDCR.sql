CREATE TABLE [Staging].[MostRecent3OrdersLst12MnthCDCR]
(
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DateOrdered] [datetime] NULL,
[OrderID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderItemID] [int] NULL,
[CourseID] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Parts] [money] NULL,
[SubjectCategory] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubjectCategory2] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubjectPreferenceID] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderSource] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FormatMedia] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FormatAV] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FormatAD] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StockItemID] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderRecencyRank] [int] NULL,
[Adcode] [int] NULL
) ON [PRIMARY]
GO
