CREATE TABLE [Marketing].[CompleteCoursePurchase]
(
[OrderID] [dbo].[udtOrderID] NULL,
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CourseID] [int] NULL,
[BundleID] [int] NULL,
[Portion] [float] NULL,
[Amount] [money] NULL,
[SubjectCategory] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateOrdered] [datetime] NULL,
[SubjectCategory2] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StockItemID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderSource] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CompleteCoursePurchase] ON [Marketing].[CompleteCoursePurchase] ([CourseID], [DateOrdered], [StockItemID]) INCLUDE ([CustomerID], [OrderID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_CompleteCoursePurchase_DateOrdered] ON [Marketing].[CompleteCoursePurchase] ([DateOrdered]) INCLUDE ([CourseID], [CustomerID], [StockItemID], [SubjectCategory], [SubjectCategory2]) ON [PRIMARY]
GO
