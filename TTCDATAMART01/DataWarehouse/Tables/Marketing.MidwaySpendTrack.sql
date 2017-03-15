CREATE TABLE [Marketing].[MidwaySpendTrack]
(
[CustomerID] [dbo].[udtCustomerID] NOT NULL,
[AsOfDate] [datetime] NULL,
[Recency] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Frequency] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MonetaryValue] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Concantonated] [char] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[a12mF] [int] NULL,
[Active] [tinyint] NULL,
[NewSeg] [int] NULL,
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrackStartDate] [datetime] NULL,
[TrackEndDate] [datetime] NULL,
[TotalOrders] [int] NULL,
[TotalSales] [money] NULL,
[TotalCourseParts] [dbo].[udtCourseParts] NULL,
[TotalCourseQuantity] [int] NULL,
[TotalCourseSales] [money] NULL,
[TotalTranscriptParts] [dbo].[udtCourseParts] NULL,
[TotalTranscriptQuantity] [int] NULL,
[TotalTranscriptSales] [money] NULL,
[CountryCode] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
