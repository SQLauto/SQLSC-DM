CREATE TABLE [Marketing].[CC_SetsUpsell_Report]
(
[CustomerID] [dbo].[udtCustomerID] NOT NULL,
[OrderID] [dbo].[udtOrderID] NOT NULL,
[DateOrdered] [datetime] NULL,
[WeekOf] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[YearOrdered] [int] NULL,
[MonthOrdered] [int] NULL,
[DayOrdered] [int] NULL,
[OrderSource] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StatusCode] [int] NULL,
[StatusDesc] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CSRID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BundleID] [int] NULL,
[BundleName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CourseID] [int] NULL,
[CourseName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Parts] [smallint] NULL,
[TotalQuantity] [int] NULL,
[CurrencyCode] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TotalSales] [money] NULL,
[ReportUpdateDate] [datetime] NULL,
[FlagBuffetSet] [bit] NULL
) ON [PRIMARY]
GO
