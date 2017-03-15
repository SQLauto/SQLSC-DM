CREATE TABLE [Marketing].[CC_MonthlyAddonUpsell_Report]
(
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateOrdered] [datetime] NULL,
[WeekOf] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[YearOrdered] [int] NULL,
[MonthOrdered] [int] NULL,
[DayOrdered] [int] NULL,
[OrderSource] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StatusCode] [int] NULL,
[SalesStatusCode] [int] NOT NULL,
[CSRID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BundleID] [int] NULL,
[BundleName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CourseID] [int] NULL,
[CourseName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Parts] [dbo].[udtCourseParts] NULL,
[TotalQuantity] [int] NULL,
[CurrencyCode] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TotalSales] [money] NULL,
[ItemsLevelAdcode] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ItemsLevelAdcodeName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ItemsLevelCatalogCode] [int] NOT NULL,
[ItemsLevelCatalogName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReportUpdateDate] [datetime] NULL
) ON [PRIMARY]
GO
