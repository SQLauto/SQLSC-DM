CREATE TABLE [dbo].[EmailReportPrep1_ByYear]
(
[CampaignId] [int] NULL,
[campaignName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PromotionTypeID] [int] NULL,
[PromotionType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Country] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CatalogCode] [int] NOT NULL,
[catalogname] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StartDate] [datetime] NULL,
[EmailYear] [int] NULL,
[EmailMonth] [int] NULL,
[CustomerSegmentFnl] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerSegmentFrcst] [varchar] (57) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StopDate] [datetime] NULL,
[TotalEmailed] [int] NULL,
[TotalSales] [money] NULL,
[TotalOrders] [int] NULL,
[TotalCourseParts] [money] NULL,
[TotalCourseSales] [money] NULL,
[TotalCourseUnits] [int] NULL,
[Flag_DoublePunch] [int] NOT NULL,
[EmailOfferID] [int] NULL,
[EmailOffer] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Recency] [int] NULL,
[Interval] [int] NULL,
[Frequency] [int] NULL,
[FrequencyByYear] [int] NULL,
[FrequencyByCampiagn] [int] NULL,
[PriorRunDate] [datetime] NULL,
[ReportDate] [datetime] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_EmailReportPrep1_ByYear1] ON [dbo].[EmailReportPrep1_ByYear] ([CampaignId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_EmailReportPrep1_ByYear2] ON [dbo].[EmailReportPrep1_ByYear] ([CatalogCode]) ON [PRIMARY]
GO
