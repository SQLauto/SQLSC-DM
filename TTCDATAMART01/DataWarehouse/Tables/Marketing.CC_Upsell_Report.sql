CREATE TABLE [Marketing].[CC_Upsell_Report]
(
[ReportDate] [datetime] NULL,
[YearOrdered] [int] NULL,
[MonthOrdered] [int] NULL,
[WeekOrdered] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateOrdered] [date] NULL,
[OrderSource] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CurrencyCode] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CSRID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BillingCountryCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TotalCourseSales] [money] NULL,
[TotalTranscriptSales] [money] NULL,
[NetOrderAmount] [money] NULL,
[ShippingCharge] [money] NULL,
[DiscountAmount] [money] NULL,
[Tax] [money] NULL,
[TotalUpsell_Sold] [numeric] (38, 6) NULL,
[TotalUpsell_Delivered] [numeric] (38, 6) NULL,
[TotalUpsell] [numeric] (38, 6) NULL
) ON [PRIMARY]
GO
