CREATE TABLE [Staging].[BuffetOrders]
(
[YearOrdered] [int] NULL,
[MonthOrdered] [int] NULL,
[DateOrdered] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerType] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Adcode] [int] NOT NULL,
[AdcodeName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CatalogCode] [int] NOT NULL,
[CatalogName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PromotionTypeID] [smallint] NOT NULL,
[PromotionTypeName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderSource] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OrderID] [dbo].[udtOrderID] NOT NULL,
[NetOrderAmount] [money] NOT NULL,
[ShippingCharge] [money] NOT NULL,
[TotalCourseQuantity] [int] NOT NULL,
[TotalCourseParts] [dbo].[udtCourseParts] NOT NULL,
[ReportDate] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagBoughtUpsell801] [tinyint] NULL
) ON [PRIMARY]
GO
