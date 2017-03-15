CREATE TABLE [Staging].[OrdAllctn_BudCodeAssignJFM14DLR]
(
[AsnBudsCatalogCode] [int] NULL,
[AsnDescription] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AsnName_Campaign] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AsnInsertDate] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AsnForecastWeek] [date] NULL,
[OrderID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[YearOrdered] [int] NULL,
[NetOrderAmount] [money] NULL,
[MonthOrdered] [int] NULL,
[WeekOfOrder] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagCountry] [int] NOT NULL,
[MD_Country] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateOrdered] [date] NULL,
[OrderSource] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StartDate] [datetime] NULL,
[StopDate] [datetime] NULL,
[WeekDiff] [int] NULL,
[FlagUnsourcedOrder] [int] NOT NULL,
[AdCode] [int] NULL,
[AdcodeName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CatalogCode] [int] NULL,
[CatalogName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PriceTypeID] [int] NULL,
[PromotionType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_Audience] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_Channel] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_PromotionType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_CampaignName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MD_PriceType] [varchar] (81) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BudsCatalogCode] [int] NOT NULL,
[BudsCategoryName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Coupon] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CouponDesc] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AssignedBudCode] [int] NULL,
[AssignedBudName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagRecvdCampaign] [tinyint] NULL,
[CouponPriorityCode] [int] NULL,
[CouponCatalogCode] [int] NULL,
[CouponCatalogCodeName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CouponAdCodeName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AssignReason] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CrsMatchCatalogCode] [int] NULL,
[CrsMatchCatalogName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SequenceNum] [int] NULL,
[FlagNewCustomer] [int] NOT NULL,
[NamePrior] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagDigitalPhysical] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CurrencyCode] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BillingCountryCode] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
