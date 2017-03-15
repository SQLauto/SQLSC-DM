CREATE TABLE [Staging].[ValidPurchaseOrderItems_test]
(
[OrderID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CourseID] [int] NULL,
[OrderItemID] [numeric] (28, 12) NULL,
[DateOrdered] [smalldatetime] NULL,
[TotalParts] [dbo].[udtCourseParts] NULL,
[FormatMedia] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FormatAV] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FormatAD] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubjectCategory] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubjectCategory2] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagLegacy] [bit] NULL,
[StockItemID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerID] [dbo].[udtCustomerID] NULL
) ON [PRIMARY]
GO
