CREATE TABLE [Legacy].[OrderItems]
(
[OrderID] [int] NOT NULL,
[OrderItemID] [smallint] NOT NULL,
[StockItemID] [nchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StatusCode] [smallint] NOT NULL,
[SalesPrice] [money] NOT NULL,
[Quantity] [int] NULL,
[TaxableFlag] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ShipDate] [datetime] NULL,
[msrepl_tran_version] [uniqueidentifier] NULL,
[Description] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PmtStatus] [int] NULL,
[RegPrice] [money] NULL,
[CustomerID] [int] NULL,
[Available] [int] NULL,
[ShipFlag] [int] NULL,
[ReturnItemKey] [int] NULL,
[TaxRate] [float] NULL,
[ReturnShip] [money] NULL,
[ReturnCoupon] [money] NULL,
[ReturnReason] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReplaceReason] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReturnFlag] [int] NULL,
[ReplaceFlag] [int] NULL,
[pkey] [int] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idxOrderItems_StockItemID] ON [Legacy].[OrderItems] ([StockItemID]) INCLUDE ([Description], [OrderID], [OrderItemID], [PmtStatus], [Quantity], [SalesPrice], [ShipDate], [StatusCode]) ON [PRIMARY]
GO
