CREATE TABLE [Marketing].[NatGeoDirectOrdersBKPdel20170807]
(
[YearOrdered] [int] NULL,
[MonthOrdered] [int] NULL,
[MarketingOwner] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BillingCountryCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CurrencyCode] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CourseType] [varchar] (22) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CourseID] [int] NULL,
[CourseName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Format] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AdCode] [int] NULL,
[AdcodeName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CatalogCode] [int] NULL,
[CatalogName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_Channel] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_PromotionType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_CampaignName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TotalUnits] [numeric] (38, 12) NULL,
[TotalSales] [numeric] (38, 6) NULL,
[MinDateOrdered] [datetime] NULL,
[MaxDateOrdered] [datetime] NULL,
[ReportDate] [datetime] NOT NULL
) ON [PRIMARY]
GO
