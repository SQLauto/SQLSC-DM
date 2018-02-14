CREATE TABLE [Marketing].[DMPurchaseOrderItems]
(
[OrderID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderItemID] [numeric] (28, 12) NULL,
[CourseID] [int] NULL,
[BundleID] [int] NULL,
[StockItemID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateOrdered] [smalldatetime] NULL,
[CourseReleaseDate] [smalldatetime] NULL,
[DaysSinceRelease] [int] NULL,
[FormatMedia] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FormatAD] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FormatAV] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CourseName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubjectCategory] [dbo].[udtSubjectPreference] NULL,
[Parts] [dbo].[udtCourseParts] NULL,
[TotalParts] [dbo].[udtCourseParts] NULL,
[TotalQuantity] [int] NULL,
[SalesPrice] [money] NULL,
[TotalSales] [money] NULL,
[PaymentStatus] [int] NULL,
[FlagNewCourse] [bit] NULL,
[FlagReturn] [bit] NULL,
[FlagPaymentRejected] [bit] NULL,
[FlagLegacy] [bit] NULL,
[SubjectCategory2] [dbo].[udtSubjectPreference] NULL,
[OriginalOrderID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerID] [dbo].[udtCustomerID] NULL,
[AdCode] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagCLRCourse] [bit] NULL,
[StandardSalePrice] [money] NULL,
[TotalStandardSalePrice] [money] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_DMPurchaseOrderItems_Cover_1] ON [Marketing].[DMPurchaseOrderItems] ([CourseID], [CustomerID], [DateOrdered]) INCLUDE ([OrderID], [StockItemID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_DMPurchaseOrderItems_Temp1] ON [Marketing].[DMPurchaseOrderItems] ([FlagReturn], [FlagPaymentRejected], [FlagLegacy]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_DMPurchaseOrderItems_OrderID_CustomerID] ON [Marketing].[DMPurchaseOrderItems] ([OrderID], [CustomerID]) INCLUDE ([CourseID], [Parts], [TotalSales]) ON [PRIMARY]
GO
