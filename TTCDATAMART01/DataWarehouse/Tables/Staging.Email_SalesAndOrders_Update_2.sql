CREATE TABLE [Staging].[Email_SalesAndOrders_Update_2]
(
[CampaignID] [int] NULL,
[CampaignName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CatalogCode] [int] NULL,
[CatalogName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Adcode] [int] NULL,
[AdcodeName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EHistStartDate] [datetime] NULL,
[CCTblStartDate] [datetime] NULL,
[StopDate] [datetime] NULL,
[CustomerID] [dbo].[udtCustomerID] NULL,
[TotalEmailed] [int] NULL,
[ComboID] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SeqNum] [int] NULL,
[CustomerSegment] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MultiOrSingle] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NewSeg] [int] NULL,
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[A12mf] [int] NULL,
[FlagEmailed] [int] NOT NULL,
[OrderSource] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TotalSales] [money] NULL,
[TotalOrders] [int] NULL,
[TotalCourseSales] [money] NULL,
[TotalCourseUnits] [int] NULL,
[TotalCourseParts] [dbo].[udtCourseParts] NULL
) ON [PRIMARY]
GO
