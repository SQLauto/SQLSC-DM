CREATE TABLE [Staging].[Step3_NCP_OrdersUpdt1]
(
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AdCode] [int] NOT NULL,
[NewSeg] [int] NULL,
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[a12mf] [int] NULL,
[Concatenated] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagHoldOut] [smallint] NULL,
[ComboID] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubjRank] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PreferredCategory2] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StartDate] [date] NULL,
[Catalogcode] [int] NOT NULL,
[CatalogName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerSegment] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MultiOrsingle] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OverallSales_ActRecips_03Mo] [money] NULL,
[OverallOrders_ActRecips_03Mo] [int] NULL,
[CourseSales_ActRecips_03Mo] [money] NULL,
[CourseOrders_ActRecips_03Mo] [int] NULL,
[CourseDrvnSales_ActRecips_03Mo] [money] NULL,
[CourseDrvnOrders_ActRecips_03Mo] [int] NULL,
[OverallSales_ActRecips_CatLf] [money] NULL,
[OverallOrders_ActRecips_CatLf] [int] NULL,
[CourseSales_ActRecips_CatLf] [money] NULL,
[CourseOrders_ActRecips_CatLf] [int] NULL,
[CourseDrvnSales_ActRecips_CatLf] [money] NULL,
[CourseDrvnOrders_ActRecips_CatLf] [int] NULL,
[OverallSales_ActRecips_Coded] [money] NULL,
[OverallOrders_ActRecips_Coded] [int] NULL,
[CourseSales_ActRecips_Coded] [money] NULL,
[CourseOrders_ActRecips_Coded] [int] NULL,
[CourseDrvnSales_ActRecips_Coded] [money] NULL,
[CourseDrvnOrders_ActRecips_Coded] [int] NULL,
[MailConsolidateID] [int] NULL,
[OrderID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DateOrdered] [datetime] NULL,
[OrderAdcode] [int] NULL,
[OrderMailConsolidateID] [int] NULL,
[Ordersource] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NetOrderAmount] [money] NULL,
[Shippingcharge] [money] NULL,
[CourseID] [int] NULL,
[StockItemID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TotalQuantity] [int] NULL,
[TotalSales] [money] NULL,
[Salesprice] [money] NULL
) ON [PRIMARY]
GO
