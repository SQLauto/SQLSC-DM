CREATE TABLE [Marketing].[DailySpendTrackerBKPDEL2]
(
[AsOfDate] [date] NULL,
[ToDate] [date] NULL,
[IsActive] [bit] NULL,
[Frequency] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CountOfCustomers] [int] NULL,
[CountOfBuyers] [int] NULL,
[TotalSales] [money] NULL,
[TotalOrders] [int] NULL,
[AsOfMonth] [int] NULL,
[AsOfYear] [int] NULL,
[DayOfMonth] [int] NULL,
[TotalCourseParts] [money] NULL,
[TotalCourseQuantity] [int] NULL,
[TotalCourseSales] [money] NULL,
[TotalTranscriptParts] [money] NULL,
[TotalTranscriptQuantity] [int] NULL,
[TotalTranscriptSales] [money] NULL,
[CountryCode] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
