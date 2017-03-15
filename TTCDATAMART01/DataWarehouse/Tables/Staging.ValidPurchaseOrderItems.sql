CREATE TABLE [Staging].[ValidPurchaseOrderItems]
(
[OrderID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CourseID] [int] NULL,
[OrderItemID] [numeric] (28, 12) NULL,
[DateOrdered] [smalldatetime] NULL,
[TotalSales] [money] NULL,
[TotalParts] [dbo].[udtCourseParts] NULL,
[TotalQuantity] [int] NULL,
[FormatMedia] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FormatAV] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FormatAD] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubjectCategory] [dbo].[udtSubjectPreference] NULL,
[SubjectCategory2] [dbo].[udtSubjectPreference] NULL,
[FlagLegacy] [bit] NULL,
[StockItemID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerID] [dbo].[udtCustomerID] NULL
) ON [PRIMARY]
GO
