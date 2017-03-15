CREATE TABLE [dbo].[e_W_PriorYearSaleBinGB]
(
[AsOfDate] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AsOfYear] [int] NOT NULL,
[CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SalesInPrYr] [money] NOT NULL,
[CoursesInPrYr] [int] NOT NULL
) ON [PRIMARY]
GO
