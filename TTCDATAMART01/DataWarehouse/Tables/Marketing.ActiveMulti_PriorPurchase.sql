CREATE TABLE [Marketing].[ActiveMulti_PriorPurchase]
(
[AsofDate] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[NewSeg] [int] NULL,
[name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PriorNewSeg] [int] NULL,
[PriorName] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PriorCustomerSegment] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubseqMonthSales] [money] NULL,
[SubseqMonthOrders] [int] NULL,
[Prior2NewSeg] [int] NULL,
[Prior2Name] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Prior2CustomerSegment] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
