CREATE TABLE [Staging].[FBA_DailySOUP_TEMP]
(
[ReportDate] [date] NULL,
[PaymentYear] [int] NULL,
[PaymentMonth] [int] NULL,
[PaymentWeek] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PaymentDate] [date] NULL,
[OrderYear] [int] NULL,
[OrderMonth] [int] NULL,
[OrderWeek] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderDate] [date] NULL,
[currency] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Orders] [int] NULL,
[Customers] [int] NULL,
[Units] [int] NULL,
[ItemPrice] [money] NULL,
[ItemTax] [money] NULL,
[ShippingPrice] [money] NULL,
[ShippingCharge] [money] NULL,
[GiftWrapPrice] [money] NULL,
[GiftWrapTax] [money] NULL,
[ItemDiscount] [money] NULL,
[ShippingDiscount] [money] NULL,
[NetOrderAmount] [money] NULL,
[TotalTax] [money] NULL
) ON [PRIMARY]
GO
