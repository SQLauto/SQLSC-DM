CREATE TABLE [Marketing].[Email_SalesAndOrders_Summary]
(
[CampaignID] [int] NULL,
[CampaignName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CatalogCode] [int] NULL,
[CatalogName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Adcode] [int] NULL,
[AdcodeName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EHistStartDate] [datetime] NULL,
[CCTblStartDate] [datetime] NULL,
[CCTblStartMonth] [int] NULL,
[CCTblStartYear] [int] NULL,
[StopDate] [datetime] NULL,
[TotalEmailed] [int] NULL,
[ComboID] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SeqNum] [int] NULL,
[CustomerSegment] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MultiOrSingle] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NewSeg] [int] NULL,
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[A12mf] [int] NULL,
[OrderSource] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagEmailed] [int] NOT NULL,
[CustCount] [int] NULL,
[TotalSales] [money] NULL,
[TotalOrders] [int] NULL,
[EmailUpdateDate] [datetime] NULL,
[TableUpdateDate] [datetime] NULL,
[TotalCourseSales] [money] NULL,
[TotalCourseUnits] [int] NULL,
[TotalCourseParts] [dbo].[udtCourseParts] NULL
) ON [PRIMARY]
GO
