CREATE TABLE [dbo].[BL_SujbectSplitAnalysisNewCust_AllSubj]
(
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[YearOrdered] [int] NULL,
[MonthOrdered] [int] NULL,
[DateOrdered] [date] NULL,
[SequenceNum] [int] NULL,
[CurrencyCode] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BillingCountryCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CourseID] [int] NULL,
[AbbrvCourseName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubjectCategory2] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReleaseDate] [datetime] NULL,
[SubjectCategory] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Totalsales] [money] NULL,
[TotalParts] [dbo].[udtCourseParts] NULL,
[TotalQuantity] [int] NULL,
[DS3moOrders] [int] NOT NULL,
[DS3moSales] [money] NOT NULL,
[DS3moFlagRepeatByr] [tinyint] NOT NULL
) ON [PRIMARY]
GO
