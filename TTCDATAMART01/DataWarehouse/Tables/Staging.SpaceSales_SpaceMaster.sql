CREATE TABLE [Staging].[SpaceSales_SpaceMaster]
(
[CampaignName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AdID] [int] NULL,
[Adcode] [int] NOT NULL,
[AdCodeName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AdcodeDescription] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MinOfDateOrdered] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MaxOfDateOrdered] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SumOfNetOrderAmount] [money] NULL,
[CountOfOrderID] [int] NULL,
[StartDate] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SaleDate] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReportPullDate] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
