CREATE TABLE [Marketing].[ActiveMulti_PriorPurchaseAgg]
(
[AsofDate] [date] NULL,
[AsofYear] [int] NULL,
[AsofMonth] [int] NULL,
[NewSeg] [int] NULL,
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PriorNewSeg] [int] NULL,
[PriorName] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PriorCustomerSegment] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Prior2NewSeg] [int] NULL,
[Prior2Name] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Prior2CustomerSegment] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubseqMonthSales] [money] NULL,
[SubseqMonthOrders] [int] NULL,
[CustCnt] [int] NULL
) ON [PRIMARY]
GO
