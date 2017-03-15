CREATE TABLE [dbo].[e_W_PriorYearSaleBin2011GB]
(
[AsOfDate] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AsOfYear] [int] NOT NULL,
[CustomerID] [int] NOT NULL,
[SalesInPrYr] [money] NOT NULL,
[CoursesInPrYr] [int] NOT NULL
) ON [PRIMARY]
GO
