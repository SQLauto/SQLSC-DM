CREATE TABLE [Archive].[DM_VwOrderQC]
(
[AsofDate] [datetime] NOT NULL,
[StatusCode] [int] NULL,
[TotalOrders] [int] NULL,
[TotalMerchandise] [money] NULL,
[TotalShipping] [money] NULL,
[TotalTaxes] [money] NULL,
[TotalCoupons] [money] NULL,
[NetOrderAmount] [money] NULL,
[TotalCustomers] [int] NULL
) ON [PRIMARY]
GO
