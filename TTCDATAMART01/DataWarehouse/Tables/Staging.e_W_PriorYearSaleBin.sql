CREATE TABLE [Staging].[e_W_PriorYearSaleBin]
(
[AsOfDate] [date] NULL,
[AsOfYear] [int] NULL,
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SalesInPrYr] [money] NOT NULL,
[CoursesInPrYr] [int] NOT NULL
) ON [PRIMARY]
GO
